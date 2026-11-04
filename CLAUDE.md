# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

DigiRider ("Digital Rider") is the Flutter rider/driver app for Digistall (cities: Gotan, Jodhpur). Riders sign in with Google, then accept and fulfil orders from the backend at `Common.baseUrl` (`https://gotanbackend.digistall.in/`, set in `lib/global/Common.dart`). The main target is Android (applicationId, Gradle namespace and Kotlin package are all `com.digistall.rider1`). Firebase is configured for Android only. iOS options in `lib/firebase_options.dart` still use the placeholder bundle id `com.example.digirider`.

## Commands

```bash
flutter pub get                 # install deps (also regenerates l10n because `generate: true`)
flutter run                     # run on connected device/emulator
flutter analyze                 # lint (flutter_lints via analysis_options.yaml)
flutter test                    # all tests
flutter test test/widget_test.dart --plain-name "<test name>"   # single test
flutter gen-l10n                # regenerate lib/gen_l10n from lib/l10n/*.arb
flutter build appbundle --release  # release signing reads gitignored android/key.properties (see android/app/build.gradle.kts)
```

`test/widget_test.dart` is still Flutter's default counter template. It does not compile against this app because `MyApp` lives in `lib/global/my_app_state.dart`, not `main.dart`. There are no real tests.

## Architecture

### Startup and session
- `main.dart` initializes Firebase, registers the FCM background handler, initializes `NotificationService`, and wraps the app in `MultiProvider` (`TripProvider`, `NotificationProvider`).
- `MyApp` and `MyAppState` live in `lib/global/my_app_state.dart`. The file imports `main.dart` for `SplashScreen`, so the two files import each other. The same file also defines the global `navigatorKey`, which notifications use for navigation.
- `SplashScreen` shows the website's animated loader (`lib/ui/splash.dart`, always dark) for 2 s, then reads SharedPreferences: if `isLoggedIn` and `email` are set, it goes to `NavMain`; otherwise it goes to `LandingPage`. A launch from a notification also opens `NavMain` on Home (tab 0), where the new request appears.
- **There is no auth token.** The session is just SharedPreferences keys (`email`, `name`, `cityName`, `vehicleType`, `phoneNumber`, `riderDomain`, `userStatus`, `riderId`, `licence`, `qrcode`, `isLoggedIn`, …). Pages read prefs directly, and API calls identify the rider by `email` in the request body. Logout (SettingsPage) stops location tracking, deletes the FCM token, signs out of Google/Firebase, and clears prefs except `languageCode`, `captainTheme` and `notificationsEnabled`.

### Onboarding (`lib/pages/`)
`LandingPage` → `GoogleLoginPage` (`GoogleSignInUp.dart`, with an `isSignUp` flag) → Firebase Google sign-in → `POST api/rider/login`.
- If the rider exists and `userStatus == 'Adv'`, the app goes to `NavMain`. Otherwise it goes to `DocumentUploadPage`.
- A new rider goes through `SubdomainPage` (`api/rider/verifydomain`) → `PersonalInfoPage` (`api/rider/basic`) → `DocumentUploadPage` (multipart `api/rider/adv`; this step sets `isLoggedIn`).

### Main shell
`NavMain` has the website's floating glass pill nav with 5 tabs (constants on `NavMain`): `0` = `HomePage` (default; live map, online switch, today's earnings and a bottom sheet that shows, in order: offline notice, the rider's active trip, the next incoming request with a 25 s countdown and slide-to-accept, or "all caught up"), `1` = `IncomingBookingPage` (the site's "All orders": Open / Missed / Expired, 24-hour retention), `2` = `HistoryPage` ("Your trips"), `3` = `EarningsPage` (Earnings / Wallet / Bonus), `4` = `SettingsPage` (Profile: Captain pass, settings, links to `lib/settings/sub_pages.dart` Documents / Alerts / Refer / Help). Sub-tabs go back to Home on Android back; Home asks before exiting. `DashboardPage` is not used anywhere. `NavMain.selectTab(i)` switches tabs from outside (used by notification taps). While `NavMain` is mounted, `LocationService` runs and `RiderFeed` polls.
- `RiderFeed.instance` (`lib/services/rider_feed.dart`) is the one place that fetches for the tabs: incoming orders (5 s), active orders (5 s), history (30 s), plus a refresh on every foreground push. Pages listen to it with `ListenableBuilder`. It also owns accept, the online switch, city/vehicle changes, and the "missed" list (requests skipped or timed out on Home, stored as ids in the `missedOrders` pref).
- The Home Online switch is the `isOnline` pref (default on) in `LocationService`: offline posts `activeupdate {active:false}` and hides requests, but location keeps streaming so customers of active orders still see the rider (same as the website).
- `CapOrder` (`lib/model/cap_order.dart`) is a read-only view over a raw order map for display: kind, short id (last 5 chars), addresses, fare (`expectedPrice`, or `coupontotal` for Digistall), COD detection, posted time and 24 h time left.

The website these features mirror is the `rider` repo (rider.digistall.in); all rider APIs live in `gotanbackend`. `hri-backend` has no rider endpoints.

### Three order sources, merged into one list
`RiderFeed` loops over hard-coded lists of three backends for incoming orders and history; the rider's active orders (Home, accept limit, live location) come from `ActiveOrders.fetch` in `lib/services/active_orders.dart`. They merge the results into one `List<dynamic>` of raw JSON maps (there are no model classes) and tag every order with `orderType` and `endpointPost`:

| orderType | Incoming (GET, response key) | Accept (POST) | Rider's orders (POST) | Status update (POST) = `endpointPost` on Home |
|---|---|---|---|---|
| Rider Orders | `api/rider/dashboard?vehicleType&cityName` (`filteredOrders`) | `api/rider/acceptriderorder` | `api/rider/riderorderhistory` | `api/rider/setriderstatus` |
| Parcel Orders | `api/parcel/dashboard?cityName` (`parcelOrders`) | `api/parcel/acceptriderorder` | `api/parcel/riderorderhistory` | `api/parcel/setriderstatus` |
| Digistall Orders | `api/digiorder/getDigiOrder` (`DigiOrders`) | `api/digiorder/acceptedByRider` | `api/digiorder/orderStatus` | `api/digiorder/setorderStatus` |

Later code chooses behavior by **comparing the `endpointPost` string**. For example, `endpointPost == 'api/digiorder/setorderStatus'` means a Digistall order: it has no pickup OTP and no `sellerPhone`, and it uses different field names (`sellerAddress`/`address`, `sellerLat`/`customerLat`, `coupontotal`). Renaming an endpoint therefore silently breaks these branches. These pages poll every 5 s with `Timer.periodic` and sort by `pickupTime`/`createdAt`, newest first.

### Trip flow
`HomePage` → `TripFlowPage(order, endpointPost)` → `TripCompletePage`. The trip stage is held in `TripProvider` and persisted in prefs as `trip_stage_<orderId>`, stored as the **enum index** of `TripStage` (`lib/model/trip_stage.dart`). Reordering the enum values therefore corrupts saved progress.
- In practice the flow is `reachPickup` → `inProgress`. `readyToStart` is legacy.
- At `reachPickup` the app POSTs `riderStatus: "In Transit"`, plus `userOtp` and `sellerPhone` for non-Digistall orders.
- At `inProgress` it POSTs `riderStatus: "Delivered"`; Digistall orders also send the customer's delivery `otp` (required when the order has an `otp`).
- `loadTripStage(tripId, riderStatus:)` resumes at `inProgress` when the server says the order is already `In Transit`.
- A rider may hold at most `ActiveOrders.maxActiveOrders` (2) active orders; the accept check asks the server.
- History and earnings are queried by `phoneNumber` only (not `cityName`) so changing city keeps past orders. Earnings count orders whose `riderStatus` is `Delivered` and whose last `riderDetails` entry is this rider.

### Notifications
`NotificationService` (`lib/services/notification_service.dart`) is a singleton. It handles FCM and `flutter_local_notifications` with the Android channel `order_channel_id` (also the manifest's default FCM channel).
- gotanbackend sends new-order pushes to every rider whose `cityName` matches, using the `deviceToken` stored on the rider. `syncToken()` stores it through `POST api/auth/gettoken {email, deviceToken}`. It runs on start, on token refresh, after login and signup, and when NavMain opens. If this breaks, riders silently get no pushes.
- Backend messages carry a `notification` block, so Android shows them itself when the app is in the background or killed. The background handler only displays data-only messages. In the foreground, `onMessage` shows a local notification (known titles are translated to Hindi) and emits on `NotificationService().onMessage`, which `RiderFeed` listens to so it refreshes at once.
- Do **not** declare a `FirebaseMessagingService` in `AndroidManifest.xml`; the plugin registers its own, and a second one swallows messages before Flutter sees them.
- The small icon is `@drawable/logo` (white silhouette in `drawable-*dpi`, because the backend asks for icon `logo`), tinted with `@color/notification_accent`.
- The Settings switch (`notificationsEnabled` pref) deletes the FCM token when turned off.
- `NotificationProvider` is still registered but no longer used; the nav shows the open-order count as an amber badge on Orders.

### Live location
`LocationService` (`lib/services/location_service.dart`) ports the website's tracking. It POSTs `api/rider/activeupdate` (online/offline), streams `api/rider/updateLocation {riderDomain, latitude, longitude}` (throttled to 15 s), and every 60 s sends `api/{rider|parcel}/currentlocation {orderId, city: <address>, sellerPhone}` for the rider's active ride/parcel orders, so customers can see where their rider is.

### Localization
`l10n.yaml` reads ARB files from `lib/l10n/` (`app_en.arb` is the template, plus `intl_hi.arb`) and writes generated code to `lib/gen_l10n/`. Always import `gen_l10n/app_localizations.dart`. The `lib/l10n/app_localizations*.dart` files are stale generated copies. The default locale is Hindi (`hi`). `SettingsPage`, the `LandingPage` En/हि switch and the auth screens' language pill switch it through `findAncestorStateOfType<MyAppState>().setLocale`, which saves it as the `languageCode` pref (loaded in `main`). Every screen uses `context.l10n` (`lib/global/l10n.dart`), which also has `cityName`/`vehicleName`/`orderTypeName`/`riderStatusName` helpers that map backend values to labels. Keep backend values (`Gotan`, `Bike`, `Rider Orders`, `In Transit`) in English and translate only at display time. PDFs (invoice, rider ID card) stay English because the PDF font has no Devanagari glyphs.

### Conventions
- Pages call `package:http` directly; shared logic lives in small singletons under `lib/services/` (notifications, location, active orders).
- Backend city and vehicle values are case-sensitive (`Gotan`, `Jodhpur`, `Bike`, `Auto`, `Car`) and are stored in the `cityName`/`vehicleType` prefs.
- The UI copies the rider website "Digi Captain" (rider.digistall.in), which has a dark theme (default) and a light theme. Both palettes are `CapPalette.dark/light` in `lib/ui/app_theme.dart`, copied from the site's CSS variables (`bg`, `s1`, `s2`, `ln`, `tx`, `mu`, `am` amber, `lv` mint, `rd`, map colours…) and read with `context.cap`. The theme is the `captainTheme` pref (`dark`/`light`), switched by `MyAppState.setDark` from Profile. Never hard-code colours; use the palette.
- Fonts as on the site: Geist (body), Geist Mono (`.k` labels, ids), Instrument Serif (headings and amounts), via `CapText.sans/mono/serif/k`. They have no Devanagari, so every style falls back to Poppins for Hindi.
- Shared widgets (`lib/ui/widgets.dart`, named after the site's CSS classes): `Glass`, `CapList`/`CapListItem`/`CapListMessage`, `IconBox`, `KLabel`, `PageTitle`, `CapChip` (+ `CapChip.back`), `LanguagePill`, `CapSeg`, `CapButton` (amber / ghost / danger / white), `CapSwitch`, `LiveDot`, `CapTag`, `CapAvatar`, `CapLogo`, `RouteRail`/`RouteTimeline`, `CodBanner`/`PrepaidStrip`, `SlideToAct`, `OtpBoxes` (4 digits), `showCapSheet`/`SheetHeader`/`showOptionPicker`/`showConfirmDialog` (bottom sheets), `showCapToast`, `CapPage` (page padding with room for the floating nav). Icons are the site's SVG line icons (`CapIcon(CapIcons.x)`, `lib/ui/cap_icons.dart`). Map, earnings ring/chart and Captain pass are in `lib/ui/cap_visuals.dart`; city/vehicle sheets in `lib/ui/pickers.dart`; accept/call/navigate helpers in `lib/ui/order_actions.dart`; auth layout in `lib/pages/auth_widgets.dart`.
- Website-only placeholders are copied as screens but move no money: Wallet "Withdraw" and Bonus "Claim" show a coming-soon toast, Bonus targets/peak-hour amounts are the site's placeholder values, Refer is "coming soon". Rating and acceptance show "—" (no data).
- `getSnackBar` (`lib/utils/bottomSnackBar.dart`) and `showTimedSnackBar` now both show the site's glass toast; the back-press exit dialog is in `show_exit_dialog.dart`.

## Repo quirks
Files are committed with CRLF line endings. Keep CRLF when editing, or the whole file shows as changed; `git diff --ignore-cr-at-eol` shows the real changes.
