import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/app/app_providers.dart';
import 'package:kinship_mobile/data/app_database.dart';
import 'package:kinship_mobile/features/import/import_home_screen.dart';
import 'package:kinship_mobile/features/pro/pro_screen.dart';
import 'package:kinship_mobile/purchases/purchase_gateway.dart';
import 'package:kinship_mobile/main.dart';
import 'package:kinship_mobile/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'Home Pro entry opens restore without presenting a native paywall',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      final gateway = PurchaseGateway(testApiKey: '', appleApiKey: '');
      addTearDown(database.close);
      addTearDown(gateway.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWith((ref) async => database),
            purchaseGatewayProvider.overrideWith((ref) => gateway),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-pro')));
      await tester.pumpAndSettle();
      expect(find.byType(ProScreen), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('pro-restore')),
        150,
      );
      expect(find.byKey(const Key('pro-offer-unavailable')), findsOneWidget);
      expect(find.byKey(const Key('pro-restore')), findsOneWidget);
    },
  );

  testWidgets('app opens production import screen using overridden database', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => database),
          purchaseGatewayProvider.overrideWith(
            (ref) => PurchaseGateway(testApiKey: '', appleApiKey: ''),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ImportHomeScreen), findsOneWidget);
    expect(find.text('Your connections,\nin context.'), findsOneWidget);
    expect(find.text('Kinship'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/icons/kinship_logo.png',
      ),
      findsWidgets,
    );
  });

  testWidgets('database startup failure does not expose exception details', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async {
            throw StateError('/private/path/kinship.db');
          }),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Kinship could not start. Please restart the app.'),
      findsOneWidget,
    );
    expect(find.textContaining('/private/path'), findsNothing);
    expect(find.byType(ImportHomeScreen), findsNothing);
  });

  testWidgets('unsupported locale safely falls back to English', (
    tester,
  ) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale(
      'de',
      'DE',
    );
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => database),
          purchaseGatewayProvider.overrideWith(
            (ref) => PurchaseGateway(testApiKey: '', appleApiKey: ''),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Start with your export'), findsOneWidget);
    expect(
      AppLocalizations.of(tester.element(find.byType(ImportHomeScreen))),
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('en-US device uses the English GB catalogue', (tester) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale(
      'en',
      'US',
    );
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) async => database),
          purchaseGatewayProvider.overrideWith(
            (ref) => PurchaseGateway(testApiKey: '', appleApiKey: ''),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start with your export'), findsOneWidget);
    expect(
      AppLocalizations.of(tester.element(find.byType(ImportHomeScreen))),
      isNotNull,
    );
  });
}
