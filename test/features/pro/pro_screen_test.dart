import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/app/kinship_theme.dart';
import 'package:kinship_mobile/features/pro/pro_screen.dart';
import 'package:kinship_mobile/l10n/app_localizations.dart';
import 'package:kinship_mobile/purchases/purchase_gateway.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class FakeGateway extends PurchaseGateway {
  FakeGateway() : super(testApiKey: '', appleApiKey: '');

  PurchaseSnapshot snapshot = const PurchaseSnapshot(EntitlementState.inactive);
  LifetimeOffer? offer;
  PurchaseOutcome purchaseResult = const PurchaseOutcome(
    snapshot: PurchaseSnapshot(EntitlementState.inactive),
  );
  int purchaseCalls = 0;
  Completer<PurchaseOutcome>? pendingPurchase;
  Object? purchaseError;
  PurchaseOutcome restoreResult = const PurchaseOutcome(
    snapshot: PurchaseSnapshot(EntitlementState.inactive),
  );
  int restoreCalls = 0;
  int infoCalls = 0;
  Completer<PurchaseSnapshot>? pendingInfo;
  final changes = StreamController<PurchaseSnapshot>.broadcast();

  @override
  Stream<PurchaseSnapshot> get updates => changes.stream;
  @override
  Future<bool> initialize() async => true;
  @override
  Future<PurchaseSnapshot> customerInfo() async {
    infoCalls++;
    if (pendingInfo case final pending?) return pending.future;
    if (purchaseError case final error?) throw error;
    return snapshot;
  }

  @override
  Future<LifetimeOffer?> lifetimeOffer() async => offer;
  @override
  Future<PurchaseOutcome> purchase(LifetimeOffer offer) async {
    purchaseCalls++;
    snapshot = purchaseResult.snapshot;
    if (pendingPurchase case final pending?) return pending.future;
    return purchaseResult;
  }

  @override
  Future<PurchaseOutcome> restore() async {
    restoreCalls++;
    return restoreResult;
  }

  @override
  Future<void> dispose() => changes.close();
}

void main() {
  late FakeGateway gateway;

  setUp(() {
    gateway = FakeGateway();
  });
  tearDown(() => gateway.dispose());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: KinshipTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProScreen(gateway: gateway),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapAction(WidgetTester tester, String key) async {
    final target = find.byKey(Key(key));
    await tester.scrollUntilVisible(
      target,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  LifetimeOffer sampleOffer() => LifetimeOffer(
    price: '€12,49',
    package: Package(
      'lifetime',
      PackageType.lifetime,
      StoreProduct(
        'product',
        'Lifetime',
        'Lifetime access',
        12.49,
        '€12,49',
        'EUR',
      ),
      const PresentedOfferingContext('default', null, null),
    ),
  );

  testWidgets('offer absent disables purchase but restore remains available', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
    expect(find.byKey(const Key('pro-offer-unavailable')), findsOneWidget);
    await tapAction(tester, 'pro-restore');
    expect(gateway.restoreCalls, 1);
    expect(gateway.purchaseCalls, 0);
  });

  testWidgets(
    'purchase requires deliberate action; cancellation refreshes silently',
    (tester) async {
      gateway.offer = sampleOffer();
      gateway.purchaseResult = const PurchaseOutcome(
        cancelled: true,
        snapshot: PurchaseSnapshot(EntitlementState.inactive),
      );
      await pump(tester);
      expect(find.textContaining('€12,49'), findsOneWidget);
      expect(find.textContaining('lifetime'), findsOneWidget);
      expect(gateway.purchaseCalls, 0);
      final before = gateway.infoCalls;
      await tapAction(tester, 'pro-purchase');
      expect(gateway.purchaseCalls, 1);
      expect(gateway.infoCalls, before);
      expect(find.byKey(const Key('pro-notice')), findsNothing);
    },
  );

  testWidgets('successful purchase activates refreshed entitlement', (
    tester,
  ) async {
    gateway.offer = sampleOffer();
    gateway.purchaseResult = const PurchaseOutcome(
      snapshot: PurchaseSnapshot(EntitlementState.active),
    );
    await pump(tester);
    await tapAction(tester, 'pro-purchase');
    expect(find.byKey(const Key('pro-status')), findsOneWidget);
    expect(
      find.text('Kinship Pro is active on this account.'),
      findsNWidgets(2),
    );
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
  });

  testWidgets('purchase error shows failure without claiming active', (
    tester,
  ) async {
    gateway.offer = sampleOffer();
    gateway.purchaseResult = const PurchaseOutcome(
      snapshot: PurchaseSnapshot(EntitlementState.unknown),
      error: 'Purchase failed.',
    );
    gateway.snapshot = const PurchaseSnapshot(EntitlementState.unknown);
    await pump(tester);
    await tapAction(tester, 'pro-purchase');
    expect(
      find.textContaining('could not be checked right now'),
      findsOneWidget,
    );
    expect(find.textContaining('could not be completed'), findsOneWidget);
    expect(find.byKey(const Key('pro-purchase')), findsOneWidget);
  });

  testWidgets('confirmed purchase retained when refresh is unknown', (
    tester,
  ) async {
    gateway.offer = sampleOffer();
    gateway.purchaseResult = const PurchaseOutcome(
      snapshot: PurchaseSnapshot(EntitlementState.active),
    );
    gateway.snapshot = const PurchaseSnapshot(EntitlementState.unknown);
    await pump(tester);
    await tapAction(tester, 'pro-purchase');
    expect(find.text('Kinship Pro is active on this account.'), findsWidgets);
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
  });

  testWidgets('confirmed purchase retained when refresh throws', (
    tester,
  ) async {
    gateway.offer = sampleOffer();
    gateway.purchaseResult = const PurchaseOutcome(
      snapshot: PurchaseSnapshot(EntitlementState.active),
    );
    await pump(tester);
    gateway.purchaseError = StateError('Refresh unavailable');
    await tapAction(tester, 'pro-purchase');
    expect(find.text('Kinship Pro is active on this account.'), findsWidgets);
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
  });

  testWidgets('pending purchase blocks repeat taps', (tester) async {
    gateway.offer = sampleOffer();
    gateway.pendingPurchase = Completer<PurchaseOutcome>();
    await pump(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('pro-purchase')),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('pro-purchase')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('pro-purchase')));
    expect(gateway.purchaseCalls, 1);
    gateway.pendingPurchase!.complete(
      const PurchaseOutcome(
        snapshot: PurchaseSnapshot(EntitlementState.inactive),
      ),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('restore works without offer and confirms active entitlement', (
    tester,
  ) async {
    gateway.restoreResult = const PurchaseOutcome(
      snapshot: PurchaseSnapshot(EntitlementState.active),
    );
    await pump(tester);
    await tapAction(tester, 'pro-restore');
    expect(find.text('Kinship Pro restored.'), findsOneWidget);
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
  });

  testWidgets('active on load does not offer purchase', (tester) async {
    gateway.snapshot = const PurchaseSnapshot(EntitlementState.active);
    gateway.offer = sampleOffer();
    await pump(tester);
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
    await tester.scrollUntilVisible(find.byKey(const Key('pro-restore')), 150);
    expect(find.byKey(const Key('pro-restore')), findsOneWidget);
  });

  testWidgets('unknown stays unverified; later entitlement update activates', (
    tester,
  ) async {
    gateway.snapshot = const PurchaseSnapshot(EntitlementState.unknown);
    gateway.offer = sampleOffer();
    await pump(tester);
    expect(
      find.textContaining('could not be checked right now'),
      findsOneWidget,
    );
    gateway.changes.add(const PurchaseSnapshot(EntitlementState.active));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
  });

  testWidgets('stale customer info cannot undo newer entitlement update', (
    tester,
  ) async {
    gateway.pendingInfo = Completer<PurchaseSnapshot>();
    await tester.pumpWidget(
      MaterialApp(
        theme: KinshipTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProScreen(gateway: gateway),
      ),
    );
    await tester.pump();
    gateway.changes.add(const PurchaseSnapshot(EntitlementState.active));
    await tester.pump();
    gateway.pendingInfo!.complete(
      const PurchaseSnapshot(EntitlementState.inactive),
    );
    await tester.pumpAndSettle();
    expect(find.text('Kinship Pro is active on this account.'), findsOneWidget);
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
  });
}
