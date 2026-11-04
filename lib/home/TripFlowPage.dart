import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../global/Common.dart';
import '../global/l10n.dart';
import '../model/cap_order.dart';
import '../model/trip_stage.dart';
import '../providers/trip_provider.dart';
import '../services/rider_feed.dart';
import '../ui/cap_visuals.dart';
import '../ui/order_actions.dart';
import '../ui/widgets.dart';
import 'HomePage.dart' show tripStageLabel;
import 'TripCompletePage.dart';

/// Active trip, laid out like the website's trip sheet over the live map.
/// Stage 1 (`reachPickup`): rides/parcels verify the customer OTP and go "In Transit";
/// Digistall orders just confirm pickup. Stage 2 (`inProgress`): mark "Delivered"
/// (Digistall orders send the customer's delivery OTP when the order has one).
class TripFlowPage extends StatefulWidget {
  final String tripId;
  final String endpointPost;
  final Map<String, dynamic> order;

  const TripFlowPage({
    super.key,
    required this.tripId,
    required this.order,
    required this.endpointPost,
  });

  @override
  State<TripFlowPage> createState() => _TripFlowPageState();
}

class _TripFlowPageState extends State<TripFlowPage> {
  bool _isLoading = false;
  String _otp = '';
  int _shakeTick = 0;
  bool _cashCollected = false;

  bool get _isDigistall => widget.endpointPost == 'api/digiorder/setorderStatus';
  CapOrder get _o => CapOrder({...widget.order, 'endpointPost': widget.endpointPost});

  // Older Digistall orders have no OTP; the backend only checks it when one is set.
  bool get _needsDeliveryOtp => _isDigistall && (widget.order['otp']?.toString().isNotEmpty ?? false);

  bool _needsOtp(TripStage stage) => stage == TripStage.inProgress ? _needsDeliveryOtp : !_isDigistall;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TripProvider>(context, listen: false).loadTripStage(widget.tripId, riderStatus: widget.order['riderStatus']?.toString());
    });
  }

  Future<bool> _callStageApi(TripStage? currentStage) async {
    final l10n = context.l10n;
    try {
      final url = Uri.parse('${Common.baseUrl}${widget.endpointPost}');
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email') ?? widget.order['riderDetails']?[0]?['email'];
      Map<String, dynamic> payload;

      switch (currentStage) {
        case TripStage.reachPickup:
        case TripStage.readyToStart:
          payload = {
            "orderId": widget.order['_id'],
            "riderStatus": "In Transit",
            "email": email,
            if (!_isDigistall) "sellerPhone": widget.order['sellerPhone'],
            if (!_isDigistall) "userOtp": _otp.trim(),
          };
          break;

        case TripStage.inProgress:
          payload = {
            "orderId": widget.order['_id'],
            "riderStatus": "Delivered",
            "email": email,
            if (!_isDigistall) "sellerPhone": widget.order['sellerPhone'],
            if (_isDigistall) "otp": _otp.trim(),
          };
          break;

        default:
          return false;
      }

      final response = await http.post(url, body: jsonEncode(payload), headers: {'Content-Type': 'application/json'});
      if (!mounted) return false;

      if (response.statusCode != 200) {
        String? message;
        try {
          message = jsonDecode(response.body)['message'];
        } catch (_) {}
        showCapToast(context, message ?? l10n.actionFailed, color: context.cap.rd);
        return false;
      }

      showCapToast(context, currentStage == TripStage.inProgress ? l10n.tripCompletedSuccess : l10n.tripStarted);
      return true;
    } catch (e) {
      debugPrint('API Error: $e');
      if (mounted) showCapToast(context, l10n.somethingWentWrong, color: context.cap.rd);
      return false;
    }
  }

  Future<void> _submit(TripStage stage) async {
    final l10n = context.l10n;
    if (_needsOtp(stage) && _otp.trim().length < 4) {
      setState(() => _shakeTick++);
      showCapToast(context, l10n.cEnter4DigitOtp, color: context.cap.rd);
      return;
    }
    if (stage == TripStage.inProgress && _isDigistall && _o.isCod && _o.codAmount > 0 && !_cashCollected) {
      showCapToast(context, l10n.cConfirmCashFirst('${_o.codAmount}'), color: CapPalette.cod);
      return;
    }
    setState(() => _isLoading = true);
    await _nextStage();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _nextStage() async {
    final tripProvider = Provider.of<TripProvider>(context, listen: false);
    final currentStage = tripProvider.currentStage;

    final success = await _callStageApi(currentStage);
    if (!success) {
      if (_needsOtp(currentStage ?? TripStage.reachPickup) && mounted) setState(() => _shakeTick++);
      return;
    }
    if (!mounted) return;

    await Navigator.of(context).push(
      PageRouteBuilder(opaque: false, barrierDismissible: false, pageBuilder: (_, __, ___) => const _SuccessOverlay()),
    );
    if (!mounted) return;
    RiderFeed.instance.refreshActive();

    if (currentStage == TripStage.inProgress) {
      await tripProvider.decrementActiveOrders();
      await tripProvider.completeTrip();
      RiderFeed.instance.refreshHistory();

      final notAvailable = context.l10n.notAvailable;
      final o = _o;
      final pickup = o.pickupAddress.isEmpty ? notAvailable : o.pickupAddress;
      final destination = o.dropAddress.isEmpty ? notAvailable : o.dropAddress;
      final amount = _isDigistall ? (widget.order['totalCartValue']?.toString() ?? '0') : (widget.order['expectedPrice']?.toString() ?? '0');
      final couponTotal = _isDigistall ? (widget.order['coupontotal']?.toString()) : null;

      String riderId = widget.order['riderId']?.toString() ?? widget.order['rider_id']?.toString() ?? '';
      if (riderId.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        riderId = prefs.getString('riderId') ?? '';
      }
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TripCompletePage(
            pickupLocation: pickup,
            destinationLocation: destination,
            totalAmount: amount,
            riderId: riderId,
            couponTotal: couponTotal,
            orderShortId: o.shortId,
            customerName: o.isStore ? null : o.customerName,
            cashAmount: o.isCod ? o.codAmount : 0,
            earning: o.fare,
          ),
        ),
      );
      return;
    }

    // reachPickup (and the legacy readyToStart) both continue to inProgress.
    setState(() {
      _otp = '';
      _cashCollected = false;
    });
    await tripProvider.updateTripStage(TripStage.inProgress);
  }

  Future<void> _openSos() {
    final l10n = context.l10n;
    return showCapSheet<void>(
      context,
      borderColor: context.cap.rd,
      builder: (ctx) {
        final p = ctx.cap;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(label: l10n.cEmergencyAssistance, title: l10n.cSafetySos, color: p.rd),
            Text(l10n.cSosDesc, style: CapText.sans(size: 14, color: p.mu, height: 1.45)),
            const SizedBox(height: 18),
            CapButton(label: l10n.cCall112, icon: CapIcons.phone, style: CapButtonStyle.danger, onPressed: () => launchUrl(Uri.parse('tel:112'))),
            const SizedBox(height: 10),
            CapButton(
              label: l10n.cShareLocation,
              icon: CapIcons.nav,
              style: CapButtonStyle.ghost,
              onPressed: () async {
                String link = 'https://rider.digistall.in';
                try {
                  final pos = await Geolocator.getCurrentPosition();
                  link = 'https://maps.google.com/?q=${pos.latitude},${pos.longitude}';
                } catch (_) {}
                await launchUrl(Uri.parse('sms:?body=${Uri.encodeComponent(l10n.cEmergencyShareText(link))}'));
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Consumer<TripProvider>(
      builder: (context, tripProvider, child) {
        final stage = tripProvider.currentStage ?? TripStage.reachPickup;
        final p = context.cap;
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            backgroundColor: p.bg,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                const Positioned.fill(child: CityMap(showHighDemand: false)),
                Positioned(
                  left: 18,
                  right: 18,
                  top: media.padding.top + 16,
                  child: Row(
                    children: [
                      CapChip.back(context, label: context.l10n.cNavHome),
                      const Spacer(),
                      CapChip(icon: CapIcons.pin, label: context.l10n.cViewRoute, onTap: () => openRoute(context, widget.order)),
                    ],
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 16 + media.padding.bottom + media.viewInsets.bottom,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: media.size.height - media.padding.top - media.viewInsets.bottom - 90),
                    child: Glass(
                      radius: CapRadius.sheet,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                        child: _buildSheet(stage),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheet(TripStage stage) {
    final p = context.cap;
    final l10n = context.l10n;
    final o = _o;
    final started = stage == TripStage.inProgress;
    final target = started ? o.dropAddress : o.pickupAddress;
    final sub = [
      if (o.customerName != null && !o.isStore) o.customerName!,
      if (o.isStore && (widget.order['productName']?.toString().isNotEmpty ?? false))
        l10n.productLabel(widget.order['productName'].toString()),
      o.isCod ? l10n.cCodShort('${o.codAmount}') : o.payLabel(l10n),
    ].join(' · ');
    final needsOtp = _needsOtp(stage);
    final collectCash = started && _isDigistall && o.isCod && o.codAmount > 0;

    String buttonLabel() {
      if (!started) return o.isRide ? l10n.cVerifyStartRide : l10n.cVerifyStartDelivery;
      if (collectCash) return l10n.cConfirmCompleteDelivery('${o.codAmount}');
      return l10n.cVerifyCompleteDelivery;
    }

    String slideLabel() {
      if (!started) return l10n.cSlidePickedUp;
      return o.isRide ? l10n.cSlideEndRide : l10n.cSlideToDeliver;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const GrabHandle(),
        Row(
          children: [
            Flexible(child: CapTag(tripStageLabel(l10n, o, started), leading: const LiveDot())),
            const Spacer(),
            Text('#${o.shortId}', style: CapText.mono(size: 12, weight: FontWeight.w400, color: p.mu)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(target.isEmpty ? l10n.notAvailable : target, maxLines: 3, overflow: TextOverflow.ellipsis, style: CapText.serif(size: 24, color: p.tx, height: 1.1)),
                  const SizedBox(height: 4),
                  Text(sub, style: CapText.sans(size: 13, color: p.mu)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (o.phone != null) ...[
              IconBox(icon: CapIcons.phone, iconSize: 18, tooltip: l10n.callCustomer, onTap: () => callCustomer(context, widget.order)),
              const SizedBox(width: 8),
            ],
            IconBox(
              icon: CapIcons.nav,
              iconSize: 18,
              tooltip: started ? l10n.navigateToDestination : l10n.navigateToPickup,
              onTap: () => openNavigation(context, widget.order, toPickup: !started),
            ),
            if (started) ...[
              const SizedBox(width: 8),
              IconBox(icon: CapIcons.sos, iconSize: 18, color: p.rd, background: p.rd.withValues(alpha: 0.15), tooltip: 'SOS', onTap: _openSos),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (o.isCod)
          CodBanner(
            title: l10n.cCollectCash('${o.codAmount}'),
            subtitle: l10n.cCodOrder,
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                KLabel(l10n.cYouEarn, size: 10, padding: EdgeInsets.zero),
                Text(rupees(o.fare), style: CapText.sans(size: 15, weight: FontWeight.w700, color: p.amx)),
              ],
            ),
          )
        else
          PrepaidStrip(l10n.cPrepaidNoCash),
        const SizedBox(height: 14),
        RouteTimeline(pickup: o.pickupAddress, drop: o.dropAddress, ellipsis: false, pickupLabel: o.isStore ? l10n.storeLocation : null),
        const SizedBox(height: 14),
        if (needsOtp) ...[
          KLabel(started ? l10n.cAskDeliveryOtp : (o.isRide ? l10n.cAskRideOtp : l10n.cAskParcelOtp), padding: const EdgeInsets.only(bottom: 8)),
          OtpBoxes(key: ValueKey('otp-$stage'), onChanged: (v) => _otp = v, shakeTick: _shakeTick),
          if (collectCash) ...[const SizedBox(height: 12), _cashCheck(o)],
          const SizedBox(height: 10),
          Text(l10n.cVerifyCodeHint, style: CapText.sans(size: 12, color: p.mu)),
          const SizedBox(height: 14),
          CapButton(label: buttonLabel(), loading: _isLoading, onPressed: () => _submit(stage)),
        ] else ...[
          if (collectCash) ...[_cashCheck(o), const SizedBox(height: 14)],
          SlideToAct(label: slideLabel(), loading: _isLoading, onAction: () => _submit(stage)),
        ],
      ],
    );
  }

  Widget _cashCheck(CapOrder o) {
    final p = context.cap;
    final l10n = context.l10n;
    final on = _cashCollected;
    final color = on ? CapPalette.prepaid : CapPalette.cod;
    return GestureDetector(
      onTap: () => setState(() => _cashCollected = !on),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: on ? 0.12 : 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: on ? color.withValues(alpha: 0.4) : color, width: 1.5),
        ),
        child: Row(
          children: [
            SizedBox(width: 22, height: 22, child: Checkbox(value: on, onChanged: (v) => setState(() => _cashCollected = v ?? false))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(on ? l10n.cCashCollectedCheck('${o.codAmount}') : l10n.cCollectCashFrom('${o.codAmount}'),
                      style: CapText.sans(size: 13, weight: FontWeight.w700, color: color)),
                  Text(on ? l10n.cCashConfirmed : l10n.cTapWhenCash, style: CapText.sans(size: 11.5, color: p.mu)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessOverlay extends StatefulWidget {
  const _SuccessOverlay();

  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cap.bg,
      body: Center(child: SizedBox(height: 200, width: 200, child: Lottie.asset('assets/animation/success.json'))),
    );
  }
}
