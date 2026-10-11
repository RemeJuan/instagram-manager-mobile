import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kinship_mobile/app/kinship_theme.dart';
import 'package:kinship_mobile/l10n/app_localizations.dart';
import 'package:kinship_mobile/purchases/purchase_gateway.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Keep native UI outside widget tests. Only a deliberate tap presents it.
abstract interface class ProPaywallPresenter {
  Future<PaywallResult> present();
}

class RevenueCatPaywallPresenter implements ProPaywallPresenter {
  const RevenueCatPaywallPresenter();

  @override
  Future<PaywallResult> present() =>
      RevenueCatUI.presentPaywallIfNeeded('kinship_pro');
}

class ProScreen extends StatefulWidget {
  const ProScreen({super.key, required this.gateway, required this.presenter});

  final PurchaseGateway gateway;
  final ProPaywallPresenter presenter;

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  PurchaseSnapshot _snapshot = const PurchaseSnapshot(EntitlementState.unknown);
  LifetimeOffer? _offer;
  bool _loading = true;
  bool _busy = false;
  String? _notice;
  StreamSubscription<PurchaseSnapshot>? _subscription;
  int _entitlementVersion = 0;

  AppLocalizations get l => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _subscription = widget.gateway.updates.listen((snapshot) {
      if (mounted) {
        _entitlementVersion++;
        setState(() => _snapshot = snapshot);
      }
    });
    _load();
  }

  Future<void> _load() async {
    final version = _entitlementVersion;
    try {
      await widget.gateway.initialize();
      final snapshot = await widget.gateway.customerInfo();
      final offer = await widget.gateway.lifetimeOffer();
      if (mounted) {
        setState(() {
          if (version == _entitlementVersion) _snapshot = snapshot;
          _offer = offer;
        });
      }
    } on Object {
      // No entitlement or price may be inferred from a failed request.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showPaywall() async {
    if (_busy || _offer == null || _snapshot.isPro) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      final result = await widget.presenter.present();
      final version = _entitlementVersion;
      final snapshot = await widget.gateway.customerInfo();
      if (!mounted) return;
      setState(() {
        if (version == _entitlementVersion) _snapshot = snapshot;
        _notice = _snapshot.isPro
            ? l.proActive
            : result == PaywallResult.error
            ? l.proPurchaseFailed
            : result == PaywallResult.cancelled ||
                  result == PaywallResult.notPresented
            ? null
            : l.proNotConfirmed;
      });
    } on Object {
      if (mounted) setState(() => _notice = l.proPurchaseFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    final version = _entitlementVersion;
    try {
      final outcome = await widget.gateway.restore();
      if (!mounted) return;
      setState(() {
        if (version == _entitlementVersion) _snapshot = outcome.snapshot;
        _notice = outcome.error != null
            ? l.proRestoreFailed
            : _snapshot.isPro
            ? l.proRestored
            : _snapshot.state == EntitlementState.unknown
            ? l.proStatusUnknown
            : l.proNothingToRestore;
      });
    } on Object {
      if (mounted) setState(() => _notice = l.proRestoreFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.proTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: KinshipColors.mint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: KinshipColors.success,
                        size: 30,
                      ),
                      const SizedBox(height: 20),
                      Text(l.proHeadline, style: text.headlineLarge),
                      const SizedBox(height: 8),
                      Text(l.proIntro, style: text.bodyLarge),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(l.proFreeNote, style: text.bodyMedium),
                const SizedBox(height: 24),
                if (_loading) const Center(child: CircularProgressIndicator()),
                if (!_loading) ...[
                  Text(
                    _snapshot.state == EntitlementState.active
                        ? l.proActive
                        : _snapshot.state == EntitlementState.unknown
                        ? l.proStatusUnknown
                        : l.proInactive,
                    key: const Key('pro-status'),
                    style: text.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (!_snapshot.isPro) ...[
                    if (_offer != null) ...[
                      Text(
                        l.proLifetimePrice(_offer!.price),
                        style: text.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        key: const Key('pro-purchase'),
                        onPressed: _busy ? null : _showPaywall,
                        child: Text(l.proViewOffer),
                      ),
                    ] else
                      Text(
                        l.proOfferUnavailable,
                        key: const Key('pro-offer-unavailable'),
                      ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const Key('pro-restore'),
                    onPressed: _busy ? null : _restore,
                    child: Text(l.proRestore),
                  ),
                  if (_busy)
                    const Padding(
                      padding: EdgeInsets.only(top: 14),
                      child: LinearProgressIndicator(),
                    ),
                  if (_notice != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(_notice!, key: const Key('pro-notice')),
                      ),
                    ),
                ],
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 14),
                Text(l.proPrivacy, style: text.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
