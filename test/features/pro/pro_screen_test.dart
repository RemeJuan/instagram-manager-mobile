import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/app/kinship_theme.dart';
import 'package:kinship_mobile/features/pro/pro_screen.dart';
import 'package:kinship_mobile/l10n/app_localizations.dart';
import 'package:kinship_mobile/purchases/purchase_gateway.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class FakeGateway extends PurchaseGateway {
  FakeGateway() : super(testApiKey: '', appleApiKey: '');

  PurchaseSnapshot snapshot = const PurchaseSnapshot(EntitlementState.inactive);
  LifetimeOffer? offer;
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
    return snapshot;
  }

  @override
  Future<LifetimeOffer?> lifetimeOffer() async => offer;
  @override
  Future<PurchaseOutcome> restore() async {
    restoreCalls++;
    return restoreResult;
  }

  @override
  Future<void> dispose() => changes.close();
}

class FakePresenter implements ProPaywallPresenter {
  int calls = 0;
  PaywallResult result = PaywallResult.cancelled;

  @override
  Future<PaywallResult> present() async {
    calls++;
    return result;
  }
}

void main() {
  late FakeGateway gateway;
  late FakePresenter presenter;

  setUp(() {
    gateway = FakeGateway();
    presenter = FakePresenter();
  });
  tearDown(() => gateway.dispose());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: KinshipTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: ProScreen(gateway: gateway, presenter: presenter),
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

  testWidgets('offer absent disables paywall but restore remains available', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
    expect(find.byKey(const Key('pro-offer-unavailable')), findsOneWidget);
    await tapAction(tester, 'pro-restore');
    expect(gateway.restoreCalls, 1);
    expect(presenter.calls, 0);
  });

  testWidgets(
    'user action presents paywall; cancellation refreshes without activating',
    (tester) async {
      gateway.offer = sampleOffer();
      await pump(tester);
      expect(find.textContaining('€12,49'), findsOneWidget);
      expect(presenter.calls, 0);
      final before = gateway.infoCalls;
      await tapAction(tester, 'pro-purchase');
      expect(presenter.calls, 1);
      expect(gateway.infoCalls, before + 1);
      expect(
        find.text('Kinship Pro is not active on this account.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('paywall result only activates after refreshed entitlement', (
    tester,
  ) async {
    gateway.offer = sampleOffer();
    presenter.result = PaywallResult.purchased;
    await pump(tester);
    await tapAction(tester, 'pro-purchase');
    expect(find.textContaining('not confirmed yet'), findsOneWidget);
    gateway.snapshot = const PurchaseSnapshot(EntitlementState.active);
    gateway.changes.add(gateway.snapshot);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('pro-purchase')), findsNothing);
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
        home: ProScreen(gateway: gateway, presenter: presenter),
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
