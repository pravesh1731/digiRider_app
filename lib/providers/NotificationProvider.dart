// notification_provider.dart
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  bool _showHomeBadge = false;

  bool get showHomeBadge => _showHomeBadge;

  void showBadge() {
    _showHomeBadge = true;
    notifyListeners();
  }

  void hideBadge() {
    _showHomeBadge = false;
    notifyListeners();
  }
}