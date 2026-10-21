import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/trip_stage.dart';

class TripProvider with ChangeNotifier {
  TripStage? _currentStage;
  String? _currentTripId;

  TripStage? get currentStage => _currentStage;
  String? get currentTripId => _currentTripId;

  int _activeOrdersCount = 0;
  int get activeOrdersCount => _activeOrdersCount;

  Future<void> incrementActiveOrders() async {
    _activeOrdersCount++;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_orders_count', _activeOrdersCount);
  }

  Future<void> decrementActiveOrders() async {
    if (_activeOrdersCount > 0) {
      _activeOrdersCount--;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('active_orders_count', _activeOrdersCount);
    }
  }

  /// Syncs the count with the server's list of the rider's active orders.
  Future<void> setActiveOrdersCount(int count) async {
    if (_activeOrdersCount == count) return;
    _activeOrdersCount = count;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('active_orders_count', _activeOrdersCount);
  }

  Future<void> loadActiveOrdersCount() async {
    final prefs = await SharedPreferences.getInstance();
    _activeOrdersCount = prefs.getInt('active_orders_count') ?? 0;
    notifyListeners();
  }

  /// [riderStatus] is the order's status from the server. An order that is already
  /// "In Transit" resumes at [TripStage.inProgress] even if the saved stage was lost
  /// (reinstall, cleared data, another device), so the rider is not asked for the OTP again.
  Future<void> loadTripStage(String tripId, {String? riderStatus}) async {
    final prefs = await SharedPreferences.getInstance();
    final stageIndex = prefs.getInt('trip_stage_$tripId');

    _currentTripId = tripId; // ✅ always set the trip ID

    if (stageIndex != null && stageIndex >= 0 && stageIndex < TripStage.values.length) {
      _currentStage = TripStage.values[stageIndex];
    } else {
      _currentStage = TripStage.reachPickup;
    }

    if (riderStatus?.toLowerCase() == 'in transit' && _currentStage != TripStage.inProgress) {
      _currentStage = TripStage.inProgress;
      await prefs.setInt('trip_stage_$tripId', TripStage.inProgress.index);
    }

    notifyListeners();
  }

  Future<void> updateTripStage(TripStage newStage) async {
    if (_currentTripId == null) return;

    _currentStage = newStage;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trip_stage_$_currentTripId', newStage.index);
  }

  Future<void> completeTrip() async {
    if (_currentTripId == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('trip_stage_$_currentTripId');

    _currentStage = null;
    _currentTripId = null;
    notifyListeners();
  }

  // Helper to check if a specific trip has progress
  Future<bool> hasTripProgress(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('trip_stage_$tripId');
    return index != null && index != TripStage.reachPickup.index;
  }
}