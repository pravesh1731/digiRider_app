import 'package:flutter/material.dart';

import '../global/l10n.dart';
import '../services/rider_feed.dart';
import 'widgets.dart';

/// Backend city values (case-sensitive).
const List<String> kCities = ['Gotan', 'Jodhpur'];

/// Backend vehicle values (case-sensitive).
const List<String> kVehicles = ['Bike', 'Auto', 'Car'];

/// The website's "Choose your city" sheet. Saves the city on the server.
Future<void> showCityPicker(BuildContext context) async {
  final l10n = context.l10n;
  final feed = RiderFeed.instance;
  final picked = await showOptionPicker<String>(
    context,
    label: l10n.cServiceArea,
    title: l10n.cChooseCity,
    note: l10n.cServiceAreaNote,
    selected: feed.city,
    options: [for (final c in kCities) PickerOption(c, l10n.cityName(c), subtitle: l10n.cRajasthan)],
  );
  if (picked == null || picked == feed.city || !context.mounted) return;
  final ok = await feed.setCity(picked);
  if (!context.mounted) return;
  showCapToast(context, ok ? l10n.cCityToast(l10n.cityName(picked)) : l10n.cityUpdateFailed, color: ok ? null : context.cap.rd);
}

/// Vehicle sheet; the vehicle filters which ride requests this rider sees.
Future<void> showVehiclePicker(BuildContext context) async {
  final l10n = context.l10n;
  final feed = RiderFeed.instance;
  final picked = await showOptionPicker<String>(
    context,
    label: l10n.cYourVehicle,
    title: l10n.cChooseVehicle,
    note: l10n.cVehicleNote,
    selected: feed.vehicle,
    options: [for (final v in kVehicles) PickerOption(v, l10n.vehicleName(v), icon: CapIcons.car)],
  );
  if (picked == null || picked == feed.vehicle || !context.mounted) return;
  await feed.setVehicle(picked);
  if (context.mounted) showCapToast(context, l10n.vehicleUpdated(l10n.vehicleName(picked)));
}
