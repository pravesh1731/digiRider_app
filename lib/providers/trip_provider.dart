import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/trip_stage.dart';

class TripProvider with ChangeNotifier {
  TripStage? _currentStage;
  String? _currentTripId;

  TripStage? get currentStage => _currentStage;
  String? get currentTripId => _currentTripId;

  Future<void> loadTripStage(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    final stageIndex = prefs.getInt('trip_stage_$tripId');

    _currentTripId = tripId; // ✅ always set the trip ID

    if (stageIndex != null && stageIndex >= 0 && stageIndex < TripStage.values.length) {
      _currentStage = TripStage.values[stageIndex];
    } else {
      _currentStage = TripStage.reachPickup;
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