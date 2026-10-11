import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/purchases/capability_policy.dart';
import 'package:kinship_mobile/purchases/purchase_gateway.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PurchaseGateway', () {
    test(
      'configures fake backend once with supplied test key on iOS',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);
        final fake = _FakePurchaseBackend();
        final gateway = PurchaseGateway(
          backend: fake,
          testApiKey: 'test_public_key',
        );
        addTearDown(gateway.dispose);

        expect(await gateway.initialize(), isTrue);
        expect(await gateway.initialize(), isTrue);
        expect(fake.configureCalls, 1);
        expect(fake.configuredKey, 'test_public_key');
        expect(fake.listener, isNotNull);
      },
    );

    test('missing key and unsupported platform fail closed', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final noKeyBackend = _FakePurchaseBackend();
      final noKeyGateway = PurchaseGateway(
        backend: noKeyBackend,
        testApiKey: '',
        appleApiKey: '',
      );
      expect(await noKeyGateway.initialize(), isFalse);
      expect(
        (await noKeyGateway.customerInfo()).state,
        EntitlementState.unknown,
      );
      expect(noKeyBackend.configureCalls, 0);
      await noKeyGateway.dispose();

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      final unsupportedBackend = _FakePurchaseBackend();
      final unsupported = PurchaseGateway(
        backend: unsupportedBackend,
        testApiKey: 'test_key',
      );
      expect(await unsupported.initialize(), isFalse);
      expect(unsupportedBackend.configureCalls, 0);
      await unsupported.dispose();
    });

    test('transient configure error can be retried', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final fake = _FakePurchaseBackend()..configureFailures = 1;
      final gateway = PurchaseGateway(
        backend: fake,
        testApiKey: 'test_public_key',
      );
      addTearDown(gateway.dispose);

      expect(await gateway.initialize(), isFalse);
      expect(await gateway.initialize(), isTrue);
      expect(fake.configureCalls, 2);
      expect(fake.listener, isNotNull);
    });

    test('coalesces parallel initialization', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final fake = _FakePurchaseBackend()..configureGate = Completer<void>();
      final gateway = PurchaseGateway(
        backend: fake,
        testApiKey: 'test_public_key',
      );
      addTearDown(gateway.dispose);

      final first = gateway.initialize();
      final second = gateway.initialize();
      expect(fake.configureCalls, 1);
      fake.configureGate!.complete();
      expect(await Future.wait([first, second]), [true, true]);
    });

    test(
      'customer info recognizes only active kinship_pro entitlement',
      () async {
        final fake = _FakePurchaseBackend();
        final gateway = await _initializedGateway(fake);
        addTearDown(gateway.dispose);

        fake.info = _customerInfo(active: {'kinship_pro'});
        expect((await gateway.customerInfo()).state, EntitlementState.active);
        fake.info = _customerInfo(active: {'other_entitlement'});
        expect((await gateway.customerInfo()).state, EntitlementState.inactive);
        fake.customerInfoError = StateError('contains private data');
        expect((await gateway.customerInfo()).state, EntitlementState.unknown);
      },
    );

    test('lifetime offer returns store-localized price; absent or failed offer is null', () async {
      final fake = _FakePurchaseBackend();
      final gateway = await _initializedGateway(fake);
      addTearDown(gateway.dispose);

      fake.offeringsValue = _offerings(
        lifetime: _package(price: '€9.99', productId: 'kinship_lifetime'),
      );
      final offer = await gateway.lifetimeOffer();
      expect(offer?.price, '€9.99');
      expect(offer?.package.identifier, 'lifetime');
      fake.offeringsValue = _offerings(
        lifetime: _package(price: '€9.99', productId: 'incorrect_product'),
      );
      expect(await gateway.lifetimeOffer(), isNull);
      fake.offeringsValue = _offerings(
        lifetime: _package(
          price: '€9.99',
          category: ProductCategory.subscription,
        ),
      );
      expect(await gateway.lifetimeOffer(), isNull);
      fake.offeringsValue = _offerings(
        lifetime: _package(price: '€9.99', packageType: PackageType.annual),
      );
      expect(await gateway.lifetimeOffer(), isNull);
      fake.offeringsValue = _offerings();
      expect(await gateway.lifetimeOffer(), isNull);
      fake.offeringsError = StateError('offline');
      expect(await gateway.lifetimeOffer(), isNull);
    });

    test(
      'purchase succeeds only with entitlement active in purchase result',
      () async {
        final fake = _FakePurchaseBackend();
        final gateway = await _initializedGateway(fake);
        addTearDown(gateway.dispose);
        final offer = LifetimeOffer(price: '€9.99', package: _package());

        fake.purchaseInfo = _customerInfo(active: {'kinship_pro'});
        expect((await gateway.purchase(offer)).succeeded, isTrue);
        fake.purchaseInfo = _customerInfo();
        expect((await gateway.purchase(offer)).succeeded, isFalse);
        expect(
          (await gateway.purchase(offer)).snapshot.state,
          EntitlementState.inactive,
        );
        fake.purchaseFailure = StateError('private details');
        final failed = await gateway.purchase(offer);
        expect(failed.snapshot.state, EntitlementState.unknown);
        expect(failed.error, 'Purchase failed.');
      },
    );

    test('purchase refuses forged offers before calling backend', () async {
      final fake = _FakePurchaseBackend();
      final gateway = await _initializedGateway(fake);
      addTearDown(gateway.dispose);
      final forgedOffers = [
        LifetimeOffer(
          price: '\$9.99',
          package: _package(productId: 'other'),
        ),
        LifetimeOffer(
          price: '\$9.99',
          package: _package(category: ProductCategory.subscription),
        ),
        LifetimeOffer(
          price: '\$9.99',
          package: _package(packageType: PackageType.annual),
        ),
      ];

      for (final offer in forgedOffers) {
        final result = await gateway.purchase(offer);
        expect(result.error, 'Purchases unavailable.');
        expect(result.snapshot.state, EntitlementState.unknown);
      }
      expect(fake.purchaseCalls, 0);
    });

    test(
      'SDK cancellation helper classifies cancellation without error',
      () async {
        final fake = _FakePurchaseBackend();
        final gateway = await _initializedGateway(fake);
        addTearDown(gateway.dispose);
        fake.info = _customerInfo(active: {'kinship_pro'});
        fake.purchaseFailure = PlatformException(
          code: PurchasesErrorCode.purchaseCancelledError.index.toString(),
          message: 'cancelled',
        );

        final outcome = await gateway.purchase(
          LifetimeOffer(price: '€9.99', package: _package()),
        );
        expect(outcome.cancelled, isTrue);
        expect(outcome.error, isNull);
        expect(outcome.snapshot.state, EntitlementState.active);
        expect(outcome.succeeded, isFalse);
      },
    );

    test('restore succeeds only when returned customer info has active entitlement', () async {
      final fake = _FakePurchaseBackend();
      final gateway = await _initializedGateway(fake);
      addTearDown(gateway.dispose);

      fake.restoreInfo = _customerInfo(active: {'kinship_pro'});
      expect((await gateway.restore()).succeeded, isTrue);
      fake.restoreInfo = _customerInfo();
      expect((await gateway.restore()).succeeded, isFalse);
      fake.restoreFailure = StateError('offline');
      final failure = await gateway.restore();
      expect(failure.snapshot.state, EntitlementState.unknown);
      expect(failure.error, 'Restore failed.');
    });

    test('streams customer updates, removes exact listener, and dispose is idempotent', () async {
      final fake = _FakePurchaseBackend();
      final gateway = await _initializedGateway(fake);
      final observed = <PurchaseSnapshot>[];
      final subscription = gateway.updates.listen(observed.add);
      final listener = fake.listener!;
      listener(_customerInfo(active: {'kinship_pro'}));
      await Future<void>.delayed(Duration.zero);
      expect(observed.map((snapshot) => snapshot.state), [
        EntitlementState.active,
      ]);

      await gateway.dispose();
      await gateway.dispose();
      expect(fake.removedListener, same(listener));
      listener(_customerInfo());
      await subscription.cancel();
      expect(observed, hasLength(1));
      expect(await gateway.initialize(), isFalse);
    });

    test('capability policy treats unknown as not Pro but preserves core capabilities', () {
      const policy = CapabilityPolicy(
        PurchaseSnapshot(EntitlementState.unknown),
      );
      expect(policy.allows(ProCapability.advancedInsights), isFalse);
      expect(policy.canImport, isTrue);
      expect(policy.canValidate, isTrue);
      expect(policy.canViewCoverageWarnings, isTrue);
      expect(policy.canUsePrivacyControls, isTrue);
      expect(policy.canRestore, isTrue);
    });

    test('release builds reject test_ key before configure', () async {
      // dart.vm.product is a compile-time value and is false in this test process.
      // Verify release selection through a small predicate exposed for the test seam.
      expect(
        PurchaseGateway.isReleaseKeyAllowed('test_key', release: true),
        isFalse,
      );
      expect(
        PurchaseGateway.isReleaseKeyAllowed('appl_public_key', release: true),
        isTrue,
      );
      expect(
        PurchaseGateway.isReleaseKeyAllowed('anything', release: true),
        isFalse,
      );
      expect(
        PurchaseGateway.isReleaseKeyAllowed('test_key', release: false),
        isTrue,
      );
      expect(
        PurchaseGateway.isReleaseKeyAllowed('appl_public_key', release: false),
        isTrue,
      );
      expect(
        PurchaseGateway.isReleaseKeyAllowed('anything', release: false),
        isFalse,
      );
    });
  });
}

Future<PurchaseGateway> _initializedGateway(_FakePurchaseBackend fake) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  final gateway = PurchaseGateway(backend: fake, testApiKey: 'test_public_key');
  expect(await gateway.initialize(), isTrue);
  return gateway;
}

CustomerInfo _customerInfo({Set<String> active = const {}}) => CustomerInfo(
  EntitlementInfos(const {}, {for (final id in active) id: _entitlement(id)}),
  const {},
  const [],
  const [],
  const [],
  'first-seen',
  'synthetic-user',
  const {},
  'request-date',
);

EntitlementInfo _entitlement(String id) => EntitlementInfo(
  id,
  true,
  true,
  'purchase-date',
  'original-purchase-date',
  'synthetic-product',
  true,
  ownershipType: OwnershipType.purchased,
  store: Store.appStore,
  periodType: PeriodType.normal,
);

Package _package({
  String price = '\$9.99',
   String productId = 'kinship_lifetime',
  ProductCategory category = ProductCategory.nonSubscription,
  PackageType packageType = PackageType.lifetime,
}) => Package(
  'lifetime',
  packageType,
  StoreProduct(
    productId,
    'Synthetic description',
    'Synthetic title',
    9.99,
    price,
    'USD',
    productCategory: category,
    presentedOfferingContext: const PresentedOfferingContext(
      'default',
      null,
      null,
    ),
  ),
  const PresentedOfferingContext('default', null, null),
);

Offerings _offerings({Package? lifetime}) => Offerings(
  const {},
  current: Offering(
    'default',
    'synthetic',
    const {},
    const [],
    lifetime: lifetime,
  ),
);

class _FakePurchaseBackend implements PurchaseBackend {
  int configureCalls = 0;
  int configureFailures = 0;
  String? configuredKey;
  Completer<void>? configureGate;
  CustomerInfo info = _customerInfo();
  Object? customerInfoError;
  Offerings offeringsValue = _offerings();
  Object? offeringsError;
  CustomerInfo purchaseInfo = _customerInfo();
  Object? purchaseFailure;
  CustomerInfo restoreInfo = _customerInfo();
  Object? restoreFailure;
  CustomerInfoUpdateListener? listener;
  CustomerInfoUpdateListener? removedListener;
  int purchaseCalls = 0;

  @override
  Future<void> configure(String apiKey) async {
    configureCalls++;
    configuredKey = apiKey;
    await configureGate?.future;
    if (configureFailures > 0) {
      configureFailures--;
      throw StateError('sanitized configure failure');
    }
  }

  @override
  Future<CustomerInfo> customerInfo() async {
    if (customerInfoError case final error?) throw error;
    return info;
  }

  @override
  Future<Offerings> offerings() async {
    if (offeringsError case final error?) throw error;
    return offeringsValue;
  }

  @override
  Future<PurchaseResult> purchase(Package package) async {
    purchaseCalls++;
    if (purchaseFailure case final error?) throw error;
    return PurchaseResult(
      purchaseInfo,
      const StoreTransaction('', 'synthetic-product', 'synthetic-date'),
    );
  }

  @override
  Future<CustomerInfo> restore() async {
    if (restoreFailure case final error?) throw error;
    return restoreInfo;
  }

  @override
  void addListener(CustomerInfoUpdateListener listener) =>
      this.listener = listener;

  @override
  void removeListener(CustomerInfoUpdateListener listener) {
    removedListener = listener;
    if (identical(this.listener, listener)) this.listener = null;
  }
}
