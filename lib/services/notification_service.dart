import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../NavMain.dart';
import '../global/Common.dart';
import '../global/my_app_state.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String channelId = 'order_channel_id';
  static const String channelName = 'Order Notifications';
  static const String channelDescription = 'Notifications for new ride orders';
  static const String _enabledKey = 'notificationsEnabled';
  static const String _payload = 'incoming_booking';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Emits every FCM message received while the app is open so order lists can refresh at once.
  final StreamController<RemoteMessage> _messages = StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessage => _messages.stream;

  bool _localReady = false;
  bool _listenersAttached = false;

  // Rider-facing titles/bodies sent by gotanbackend, translated for foreground notifications.
  static const Map<String, String> _hindi = {
    'New Rider Order': 'नया राइड ऑर्डर',
    'Check the app to accept a new ride.': 'नई राइड स्वीकार करने के लिए ऐप खोलें।',
    'New Parcel Order': 'नया पार्सल ऑर्डर',
    'Check the app to accept a new parcel.': 'नया पार्सल स्वीकार करने के लिए ऐप खोलें।',
    'New Digi Order Available!': 'नया डिजीस्टॉल ऑर्डर उपलब्ध है!',
    'Check the app to accept a new order in Gotan.': 'गोटन में नया ऑर्डर स्वीकार करने के लिए ऐप खोलें।',
  };

  /// Sets up the local notifications plugin and the Android channel. Safe to call from
  /// the background isolate, so it never asks for permissions or touches FCM listeners.
  Future<void> initLocalNotifications() async {
    if (_localReady) return;

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/logo'),
    );
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _localReady = true;
  }

  /// Main-isolate setup: FCM listeners, token sync and tap handling.
  Future<void> initialize() async {
    await initLocalNotifications();
    if (_listenersAttached) return;
    _listenersAttached = true;

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _saveAndRegisterToken(token);
    });

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // App was in the background and the rider tapped the system notification.
    FirebaseMessaging.onMessageOpenedApp.listen((_) => openIncomingBookings());

    unawaited(syncToken());
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? true;
  }

  /// Asks for the Android 13+ notification permission. Returns true when notifications can be shown.
  Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return false;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
    }
    return areNotificationsEnabled();
  }

  /// Gets the current FCM token and stores it on the rider record, which is what
  /// gotanbackend uses to send "new order" pushes to every rider in the city.
  Future<void> syncToken() async {
    if (!await isEnabled()) return;
    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _saveAndRegisterToken(token);
    } catch (e) {
      debugPrint('Could not get FCM token: $e');
    }
  }

  /// Turns order notifications on or off, like the "Allow Notifications" switch on the website.
  /// Turning them off deletes the FCM token so the backend can no longer reach this device.
  Future<bool> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);

    if (enabled) {
      final granted = await requestPermission();
      await syncToken();
      return granted;
    }

    try {
      await FirebaseMessaging.instance.setAutoInitEnabled(false);
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('Could not delete FCM token: $e');
    }
    await prefs.remove('deviceToken');
    return false;
  }

  /// Called on logout so the previous rider stops receiving this city's orders on this phone.
  Future<void> onLogout() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (e) {
      debugPrint('Could not delete FCM token: $e');
    }
  }

  Future<void> _saveAndRegisterToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_enabledKey) ?? true)) return;
    await prefs.setString('deviceToken', token);

    final email = prefs.getString('email') ?? '';
    if (email.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('${Common.baseUrl}api/auth/gettoken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'deviceToken': token}),
      );
      debugPrint('Device token registered: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error sending device token to server: $e');
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    _messages.add(message);
    if (!await isEnabled()) return;

    final title = message.notification?.title ?? message.data['title']?.toString();
    final body = message.notification?.body ?? message.data['body']?.toString();
    await _show(message.hashCode, title, body);
  }

  /// Shows data-only messages received while the app is in the background or killed.
  /// Messages with a `notification` block are already shown by Android itself.
  Future<void> showBackgroundNotification(RemoteMessage message) async {
    if (message.notification != null) return;
    final title = message.data['title']?.toString();
    final body = message.data['body']?.toString();
    if (title == null && body == null) return;

    await initLocalNotifications();
    await _show(message.hashCode, title, body);
  }

  Future<void> _show(int id, String? title, String? body) async {
    final prefs = await SharedPreferences.getInstance();
    final isHindi = (prefs.getString('languageCode') ?? 'hi') == 'hi';
    String tr(String text) => isHindi ? (_hindi[text] ?? text) : text;

    await flutterLocalNotificationsPlugin.show(
      id,
      tr(title ?? 'New Order'),
      tr(body ?? 'Check the app to accept a new ride.'),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/logo',
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
      ),
      payload: _payload,
    );
  }

  // Test notification method for the Settings screen
  Future<void> showTestNotification() async {
    await initLocalNotifications();
    await _show(999, 'New Rider Order', 'Check the app to accept a new ride.');
  }

  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return false;
  }

  /// True when the app was started by tapping one of our notifications (FCM or local).
  Future<bool> launchedFromNotification() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) return true;
    final details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    return details?.didNotificationLaunchApp ?? false;
  }

  void _handleNotificationTap(NotificationResponse response) {
    openIncomingBookings();
  }

  /// Opens the Incoming Bookings tab, waiting for the navigator if the app is still starting.
  Future<void> openIncomingBookings() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final navigator = navigatorKey.currentState;
      if (navigator != null) {
        final prefs = await SharedPreferences.getInstance();
        if (!(prefs.getBool('isLoggedIn') ?? false)) return;

        if (NavMain.isMounted) {
          navigator.popUntil((route) => route.isFirst);
          NavMain.selectTab(0);
        } else {
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const NavMain(initialIndex: 0)),
            (route) => false,
          );
        }
        return;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
