import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../global/Common.dart';
import '../global/my_app_state.dart';
import '../booking/IncomingBookingPage.dart';
import '../NavMain.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> saveFcmTokenLocally(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? existingToken = prefs.getString('deviceToken');
    if (existingToken != token) {
      await prefs.setString('deviceToken', token);
      print("✅ FCM Token saved in SharedPreferences");
      print("Token: $token");
      
      // TODO: Send token to backend server
      // await _sendTokenToServer(token);
    } else {
      print("🔄 FCM Token unchanged: $token");
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    // Implement API call to save token to backend
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      
      if (email != null && email.isNotEmpty) {
        final response = await http.post(
          Uri.parse('${Common.baseUrl}api/rider/updateDeviceToken'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': email,
            'deviceToken': token,
          }),
        );
        
        if (response.statusCode == 200) {
          print("✅ Device token sent to server successfully");
        } else {
          print("❌ Failed to send device token to server: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("❌ Error sending device token to server: $e");
    }
  }

  Future<void> initialize() async {
    // Create notification channel for Android
    const AndroidInitializationSettings androidInitSettings =
    AndroidInitializationSettings('@drawable/logo');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('🔔 Notification tapped: ${response.payload}');
        _handleNotificationTap(response);
      },
    );

    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'order_channel_id',
      'Order Notifications',
      description: 'Notifications for new ride orders',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request notification permissions for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Get token on app start
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        print("🔑 FCM Token: $token");
        saveFcmTokenLocally(token);
      }
    });

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("🔄 Refreshed FCM Token: $newToken");
      saveFcmTokenLocally(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📢 Foreground message received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title ?? 'New Order',
          notification.body ?? 'You have a new ride request',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'order_channel_id',
              'Order Notifications',
              channelDescription: 'Notifications for new ride orders',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@drawable/logo',
              showWhen: true,
              enableVibration: true,
              playSound: true,
              actions: [
                AndroidNotificationAction(
                  'view_order',
                  'View Order',
                  showsUserInterface: true,
                ),
              ],
            ),
          ),
          payload: 'incoming_booking', // Add payload to identify notification type
        );
      }
    });

    // Handle when app is opened from notification (when app was in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App opened from notification');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      
      // Navigate to IncomingBookingPage when app is opened from notification
      _navigateToIncomingBooking();
    });

    // Check if app was opened from a terminated state by a notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('🚀 App launched from notification');
        print('Title: ${message.notification?.title}');
        print('Body: ${message.notification?.body}');
        print('Data: ${message.data}');
        
        // No need to navigate here - SplashScreen will handle initial navigation
        print('📍 Navigation will be handled by SplashScreen');
      }
    });

    print("📡 Firebase onMessage listener attached globally.");
  }

  // Call this when switching user accounts (logout/login)
  // Future<void> resetFcmToken() async {
  //   await FirebaseMessaging.instance.deleteToken();
  //   String? token = await FirebaseMessaging.instance.getToken();
  //   if (token != null) {
  //     print("🔑 FCM Token: $token");
  //     saveFcmTokenLocally(token);
  //     //call here
  //   }
  // }

  Future<void> resetFcmToken() async {
    await FirebaseMessaging.instance.deleteToken();
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      print("🔑 FCM Token: $token");
      await saveFcmTokenLocally(token);
    }
  }

  // Test notification method for debugging
  Future<void> showTestNotification() async {
    await flutterLocalNotificationsPlugin.show(
      999,
      'Test Notification',
      'This is a test notification to verify the system is working',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'order_channel_id',
          'Order Notifications',
          channelDescription: 'Notifications for new ride orders',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/logo',
          showWhen: true,
          enableVibration: true,
          playSound: true,
        ),
      ),
    );
    print("🧪 Test notification sent");
  }

  // Check notification permissions status
  Future<bool> areNotificationsEnabled() async {
    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final bool? result = await androidImplementation.areNotificationsEnabled();
      print("📱 Notifications enabled: ${result ?? false}");
      return result ?? false;
    }
    return false;
  }

  // Test method to manually trigger navigation (for debugging)
  void testNavigationToIncomingBooking() {
    print('🧪 Testing navigation to IncomingBookingPage...');
    _navigateToIncomingBooking();
  }

  // Handle notification tap and navigate to incoming booking page
  void _handleNotificationTap(NotificationResponse response) {
    print('🚀 Notification tapped!');
    print('🔍 Payload: ${response.payload}');
    print('🔍 Action ID: ${response.actionId}');
    
    // Add a small delay to ensure the app is fully loaded
    Future.delayed(Duration(milliseconds: 300), () {
      _navigateToIncomingBooking();
    });
  }
  
  void _navigateToIncomingBooking() {
    print('🚀 Attempting to navigate to IncomingBookingPage tab...');
    
    // Use the global navigator key to navigate
    final context = navigatorKey.currentContext;
    if (context != null) {
      print('✅ Navigator context found, navigating...');
      
      // Navigate to NavMain with IncomingBookingPage tab (index 0)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => NavMain(initialIndex: 0), // Set to IncomingBookingPage tab
        ),
        (route) => false, // Remove all previous routes to ensure clean navigation
      );
      
      print('✅ Navigation to IncomingBookingPage tab completed');
    } else {
      print('❌ Navigator context is null, retrying in 500ms...');
      // Retry after a short delay if context is not available
      Future.delayed(Duration(milliseconds: 500), () {
        final retryContext = navigatorKey.currentContext;
        if (retryContext != null) {
          print('✅ Retry successful, navigating...');
          Navigator.of(retryContext).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => NavMain(initialIndex: 0),
            ),
            (route) => false,
          );
          print('✅ Navigation to IncomingBookingPage tab completed (retry)');
        } else {
          print('❌ Still no navigator context available after retry');
          // Try one more time after app is fully loaded
          Future.delayed(Duration(seconds: 2), () {
            final finalContext = navigatorKey.currentContext;
            if (finalContext != null) {
              print('✅ Final attempt successful, navigating...');
              Navigator.of(finalContext).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => NavMain(initialIndex: 0),
                ),
                (route) => false,
              );
              print('✅ Navigation to IncomingBookingPage tab completed (final attempt)');
            } else {
              print('❌ Navigation failed - no context available');
            }
          });
        }
      });
    }
  }

  // Handle background notifications
  Future<void> showBackgroundNotification(RemoteMessage message) async {
    print('📨 Background notification triggered');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Show background notification
    if (message.notification != null) {
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification!.title ?? 'New Order',
        message.notification!.body ?? 'You have a new ride request',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'order_channel_id',
            'Order Notifications',
            channelDescription: 'Notifications for new ride orders',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@drawable/logo',
            showWhen: true,
            enableVibration: true,
            playSound: true,
          ),
        ),
        payload: 'incoming_booking', // Add payload to identify notification type
      );
    }
  }

}
