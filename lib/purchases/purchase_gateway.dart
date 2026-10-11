import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const _entitlementId = 'kinship_pro';

enum EntitlementState { active, inactive, unknown }

@immutable
class PurchaseSnapshot {
  const PurchaseSnapshot(this.state);

  final EntitlementState state;
  bool get isPro => state == EntitlementState.active;
}

@immutable
class PurchaseOutcome {
  const PurchaseOutcome({
    required this.snapshot,
    this.cancelled = false,
    this.error,
  });

  final PurchaseSnapshot snapshot;
  final bool cancelled;
  final String? error;
  bool get succeeded => !cancelled && error == null && snapshot.isPro;
}

@immutable
class LifetimeOffer {
  const LifetimeOffer({required this.price, required this.package});

  final String price;
  final Package package;
}

abstract interface class PurchaseBackend {
  Future<void> configure(String apiKey);
  Future<CustomerInfo> customerInfo();
  Future<Offerings> offerings();
  Future<PurchaseResult> purchase(Package package);
  Future<CustomerInfo> restore();
  void addListener(CustomerInfoUpdateListener listener);
  void removeListener(CustomerInfoUpdateListener listener);
}

class RevenueCatBackend implements PurchaseBackend {
  @override
  Future<void> configure(String apiKey) async {
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  @override
  Future<CustomerInfo> customerInfo() => Purchases.getCustomerInfo();
  @override
  Future<Offerings> offerings() => Purchases.getOfferings();
  @override
  Future<PurchaseResult> purchase(Package package) =>
      Purchases.purchase(PurchaseParams.package(package));
  @override
  Future<CustomerInfo> restore() => Purchases.restorePurchases();
  @override
  void addListener(CustomerInfoUpdateListener listener) =>
      Purchases.addCustomerInfoUpdateListener(listener);
  @override
  void removeListener(CustomerInfoUpdateListener listener) =>
      Purchases.removeCustomerInfoUpdateListener(listener);
}

class PurchaseGateway {
  PurchaseGateway({
    PurchaseBackend? backend,
    String? testApiKey,
    String? appleApiKey,
  }) : _backend = backend ?? RevenueCatBackend(),
       _testApiKey =
           testApiKey ??
           const String.fromEnvironment('REVENUECAT_TEST_API_KEY'),
       _appleApiKey =
           appleApiKey ??
           const String.fromEnvironment('REVENUECAT_APPLE_API_KEY');

  final PurchaseBackend _backend;
  final String _testApiKey;
  final String _appleApiKey;
  bool _configured = false;
  bool _disposed = false;
  Future<bool>? _initializing;
  CustomerInfoUpdateListener? _listener;
  final _updates = StreamController<PurchaseSnapshot>.broadcast();

  Stream<PurchaseSnapshot> get updates => _updates.stream;

  String? get _apiKey {
    final key = _selectedApiKey;
    if (!isReleaseKeyAllowed(key, release: _isRelease)) return null;
    return key;
  }

  static const bool _isRelease = bool.fromEnvironment('dart.vm.product');
  @visibleForTesting
  static bool isReleaseKeyAllowed(String key, {required bool release}) =>
      release
      ? key.startsWith('appl_')
      : key.startsWith('test_') || key.startsWith('appl_');
  String get _selectedApiKey => _isRelease
      ? _appleApiKey
      : (_testApiKey.isNotEmpty ? _testApiKey : _appleApiKey);

  Future<bool> initialize() async {
    if (_disposed) return false;
    if (_configured) return true;
    final pending = _initializing;
    if (pending != null) return pending;
    final future = _initializeOnce();
    _initializing = future;
    try {
      return await future;
    } finally {
      if (identical(_initializing, future)) _initializing = null;
    }
  }

  Future<bool> _initializeOnce() async {
    final key = _apiKey;
    if (key == null || kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) {
      return false;
    }
    try {
      await _backend.configure(key);
      if (_disposed) return false;
      _configured = true;
      _listener = (info) {
        if (!_disposed && !_updates.isClosed) _updates.add(_snapshot(info));
      };
      _backend.addListener(_listener!);
      return true;
    } catch (_) {
      return false;
    }
  }

  PurchaseSnapshot _snapshot(CustomerInfo info) => PurchaseSnapshot(
    info.entitlements.active.containsKey(_entitlementId)
        ? EntitlementState.active
        : EntitlementState.inactive,
  );

  Future<PurchaseSnapshot> customerInfo() async {
    if (!await initialize()) {
      return const PurchaseSnapshot(EntitlementState.unknown);
    }
    try {
      return _snapshot(await _backend.customerInfo());
    } catch (_) {
      return const PurchaseSnapshot(EntitlementState.unknown);
    }
  }

  Future<LifetimeOffer?> lifetimeOffer() async {
    if (!await initialize()) return null;
    try {
      final pkg = (await _backend.offerings()).current?.lifetime;
      return pkg == null || !_isValidLifetimePackage(pkg)
          ? null
          : LifetimeOffer(price: pkg.storeProduct.priceString, package: pkg);
    } catch (_) {
      return null;
    }
  }

  Future<PurchaseOutcome> purchase(LifetimeOffer offer) async {
    if (!await initialize()) {
      return const PurchaseOutcome(
        snapshot: PurchaseSnapshot(EntitlementState.unknown),
        error: 'Purchases unavailable.',
      );
    }
    if (!_isValidLifetimePackage(offer.package)) {
      return const PurchaseOutcome(
        snapshot: PurchaseSnapshot(EntitlementState.unknown),
        error: 'Purchases unavailable.',
      );
    }
    try {
      final result = await _backend.purchase(offer.package);
      return PurchaseOutcome(snapshot: _snapshot(result.customerInfo));
    } on PlatformException catch (error) {
      if (PurchasesErrorHelper.getErrorCode(error) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseOutcome(snapshot: await customerInfo(), cancelled: true);
      }
      return PurchaseOutcome(
        snapshot: const PurchaseSnapshot(EntitlementState.unknown),
        error: 'Purchase failed.',
      );
    } catch (_) {
      return PurchaseOutcome(
        snapshot: const PurchaseSnapshot(EntitlementState.unknown),
        error: 'Purchase failed.',
      );
    }
  }

  bool _isValidLifetimePackage(Package package) =>
      package.storeProduct.identifier == 'kinship_lifetime' &&
      package.packageType == PackageType.lifetime &&
      package.storeProduct.productCategory == ProductCategory.nonSubscription;

  Future<PurchaseOutcome> restore() async {
    if (!await initialize()) {
      return const PurchaseOutcome(
        snapshot: PurchaseSnapshot(EntitlementState.unknown),
        error: 'Purchases unavailable.',
      );
    }
    try {
      return PurchaseOutcome(snapshot: _snapshot(await _backend.restore()));
    } catch (_) {
      return const PurchaseOutcome(
        snapshot: PurchaseSnapshot(EntitlementState.unknown),
        error: 'Restore failed.',
      );
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    final listener = _listener;
    _listener = null;
    if (listener != null) {
      _backend.removeListener(listener);
    }
    await _updates.close();
  }
}
