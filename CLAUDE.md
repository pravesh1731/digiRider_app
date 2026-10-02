# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

DigiRider ("Digital Rider") is the Flutter rider/driver app for Digistall (cities: Gotan, Jodhpur). Riders sign in with Google, then accept and fulfil orders from the backend at `Common.baseUrl` (`https://gotanbackend.digistall.in/`, set in `lib/global/Common.dart`). The main target is Android (`com.digistall.rider`). Firebase is configured for Android only. iOS options in `lib/firebase_options.dart` still use the placeholder bundle id `com.example.digirider`.

## Commands

```bash
flutter pub get                 # install deps (also regenerates l10n because `generate: true`)
flutter run                     # run on connected device/emulator
flutter analyze                 # lint (flutter_lints via analysis_options.yaml)
flutter test                    # all tests
flutter test test/widget_test.dart --plain-name "<test name>"   # single test
flutter gen-l10n                # regenerate lib/gen_l10n from lib/l10n/*.arb
flutter build apk --release     # release signing config is in android/app/build.gradle.kts (android/app/keystore/release_key.jks)
```

`test/widget_test.dart` is still Flutter's default counter template. It does not compile against this app because `MyApp` lives in `lib/global/my_app_state.dart`, not `main.dart`. There are no real tests.

## Architecture

### Startup and session
- `main.dart` initializes Firebase, registers the FCM background handler, initializes `NotificationService`, and wraps the app in `MultiProvider` (`TripProvider`, `NotificationProvider`).
- `MyApp` and `MyAppState` live in `lib/global/my_app_state.dart`. The file imports `main.dart` for `SplashScreen`, so the two files import each other. The same file also defines the global `navigatorKey`, which notifications use for navigation.
- `SplashScreen` reads SharedPreferences: if `isLoggedIn` and `email` are set, it goes to `NavMain`; otherwise it goes to `LandingPage`. If the app was launched from a notification, it opens `NavMain(initialIndex: 0)`.
- **There is no auth token.** The session is just SharedPreferences keys (`email`, `name`, `cityName`, `vehicleType`, `phoneNumber`, `riderDomain`, `userStatus`, `riderId`, `licence`, `qrcode`, `isLoggedIn`, …). Pages read prefs directly, and API calls identify the rider by `email` in the request body. Logout (SettingsPage) calls `prefs.clear()`.

### Onboarding (`lib/pages/`)
`LandingPage` → `GoogleLoginPage` (`GoogleSignInUp.dart`, with an `isSignUp` flag) → Firebase Google sign-in → `POST api/rider/login`.
- If the rider exists and `userStatus == 'Adv'`, the app goes to `NavMain`. Otherwise it goes to `DocumentUploadPage`.
- A new rider goes through `SubdomainPage` (`api/rider/verifydomain`) → `PersonalInfoPage` (`api/rider/basic`) → `DocumentUploadPage` (multipart `api/rider/adv`; this step sets `isLoggedIn`).

### Main shell
`NavMain` has a custom bottom bar with 3 tabs: `0` = `IncomingBookingPage` (new orders to accept), `1` = `HomePage` (the rider's accepted orders; this is the default tab), `2` = `SettingsPage`. `HistoryPage` is opened from Settings. `DashboardPage` is not used anywhere.

### Three order sources, merged into one list
`IncomingBookingPage`, `HomePage` and `HistoryPage` each loop over a hard-coded list of three backends. They merge the results into one `List<dynamic>` of raw JSON maps (there are no model classes) and tag every order with `orderType` and `endpointPost`:

| orderType | Incoming (GET, response key) | Accept (POST) | Rider's orders (POST) | Status update (POST) = `endpointPost` on Home |
|---|---|---|---|---|
| Rider Orders | `api/rider/dashboard?vehicleType&cityName` (`filteredOrders`) | `api/rider/acceptriderorder` | `api/rider/riderorderhistory` | `api/rider/setriderstatus` |
| Parcel Orders | `api/parcel/dashboard?cityName` (`parcelOrders`) | `api/parcel/acceptriderorder` | `api/parcel/riderorderhistory` | `api/parcel/setriderstatus` |
| Digistall Orders | `api/digiorder/getDigiOrder` (`DigiOrders`) | `api/digiorder/acceptedByRider` | `api/digiorder/orderStatus` | `api/digiorder/setorderStatus` |

Later code chooses behavior by **comparing the `endpointPost` string**. For example, `endpointPost == 'api/digiorder/setorderStatus'` means a Digistall order: it has no OTP and no `sellerPhone`, and it uses different field names. Renaming an endpoint therefore silently breaks these branches. These pages poll every 5 s with `Timer.periodic` and sort by `pickupTime`/`createdAt`, newest first.

### Trip flow
`HomePage` → `TripFlowPage(order, endpointPost)` → `TripCompletePage`. The trip stage is held in `TripProvider` and persisted in prefs as `trip_stage_<orderId>`, stored as the **enum index** of `TripStage` (`lib/model/trip_stage.dart`). Reordering the enum values therefore corrupts saved progress.
- In practice the flow is `reachPickup` → `inProgress`. `readyToStart` is legacy.
- At `reachPickup` the app POSTs `riderStatus: "In Transit"`, plus `userOtp` and `sellerPhone` for non-Digistall orders.
- At `inProgress` it POSTs `riderStatus: "Delivered"`.

### Notifications
`NotificationService` (`lib/services/notification_service.dart`) is a singleton. It handles FCM and `flutter_local_notifications` with the Android channel `order_channel_id`. In the foreground it shows a local notification. When a notification is tapped, it navigates through `navigatorKey` to `NavMain(initialIndex: 0)`, retrying after a delay if no context is available yet. The FCM token is saved to prefs as `deviceToken`, but `_sendTokenToServer` is not called yet (TODO). `NotificationProvider` only controls the red badge on the Home tab, which is shown after a rider accepts an order.

### Localization
`l10n.yaml` reads ARB files from `lib/l10n/` (`app_en.arb` is the template, plus `intl_hi.arb`) and writes generated code to `lib/gen_l10n/`. Always import `gen_l10n/app_localizations.dart`. The `lib/l10n/app_localizations*.dart` files are stale generated copies. The default locale is Hindi (`hi`). `SettingsPage` switches it through `findAncestorStateOfType<MyAppState>().setLocale`, and the choice is not persisted. Only `SettingsPage` uses `AppLocalizations`; other screens hard-code English strings.

### Conventions
- Each page calls `package:http` directly; there is no service or repository layer. `http` is not declared in `pubspec.yaml` and only resolves transitively, so add it explicitly if you change dependencies.
- Shared theme values are in `Common`: `primary` = white and `secondary` = black (the UI is dark), plus font sizes `title`/`h1`–`h4`. The font family `bevan` maps to `assets/fonts/sans.ttf`, not `Bevan-Regular.ttf`.
- Snackbar helpers are in `lib/utils/` (`bottomSnackBar.dart`, `_TimedSnackBar.dart`), and the back-press exit dialog is in `show_exit_dialog.dart`.

## Repo quirks
Working-tree files use CRLF line endings, while the committed versions use LF. As a result, `git status` shows almost every file as modified. Use `git diff --ignore-cr-at-eol` to see real changes.
