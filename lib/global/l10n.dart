import 'package:flutter/widgets.dart';

import '../gen_l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension AppLocalizationsLabels on AppLocalizations {
  /// Display name for a backend city value ("Gotan", "Jodhpur").
  String cityName(String city) {
    switch (city.toLowerCase()) {
      case 'gotan':
        return gotan;
      case 'jodhpur':
        return jodhpur;
      default:
        return city;
    }
  }

  /// Display name for a backend vehicle value ("Bike", "Auto", "Car").
  String vehicleName(String vehicle) {
    switch (vehicle.toLowerCase()) {
      case 'bike':
        return bike;
      case 'auto':
        return auto;
      case 'car':
        return car;
      default:
        return vehicle;
    }
  }

  /// Display name for an `orderType` tag ("Rider Orders", "Parcel Orders", "Digistall Orders").
  String orderTypeName(String orderType) {
    switch (orderType) {
      case 'Rider Orders':
        return riderOrders;
      case 'Parcel Orders':
        return parcelOrders;
      case 'Digistall Orders':
        return digistallOrders;
      default:
        return orderType;
    }
  }

  /// Display name for a backend `riderStatus` value.
  String riderStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'en route':
        return statusEnRoute;
      case 'in transit':
      case 'intransit':
        return statusInTransit;
      case 'delivered':
        return statusDelivered;
      case 'cancelled':
        return statusCancelled;
      default:
        return status;
    }
  }
}
