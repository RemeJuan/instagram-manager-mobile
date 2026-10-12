import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/data/app_database.dart';
import 'package:kinship_mobile/data/import_repository.dart';
import 'package:kinship_mobile/data/import_review_repository.dart';
import 'package:kinship_mobile/data/relationship_read_repository.dart';
import 'package:kinship_mobile/app/kinship_theme.dart';
import 'package:kinship_mobile/domain/relationship.dart';
import 'package:kinship_mobile/features/import/import_home_screen.dart';
import 'package:kinship_mobile/features/import/import_workspace.dart';
import 'package:kinship_mobile/import/import_preview.dart';
import 'package:kinship_mobile/l10n/app_localizations.dart';
import 'package:kinship_mobile/purchases/purchase_gateway.dart';

class _FakeGateway extends PurchaseGateway {
  _FakeGateway() : super(testApiKey: '', appleApiKey: '');
  PurchaseSnapshot snapshot = const PurchaseSnapshot(EntitlementState.active);
  Completer<PurchaseSnapshot>? pendingInfo;
  final changes = StreamController<PurchaseSnapshot>.broadcast();

  void update(EntitlementState state) {
    snapshot = PurchaseSnapshot(state);
    changes.add(snapshot);
  }

  @override
  Stream<PurchaseSnapshot> get updates => changes.stream;
  @override
  Future<PurchaseSnapshot> customerInfo() async =>
      pendingInfo?.future ?? snapshot;
  @override
  Future<bool> initialize() async => true;
  @override
  Future<void> dispose() => changes.close();
}

void main() {
  late AppDatabase db;
  late Directory temp;
  late ParsedImport preview;
  late _FakeGateway gateway;
  final opened = <Uri>[];

  ParsedImport fixture({
    bool followers = true,
    int invalid = 0,
    String name = 'sample_one',
  }) => ParsedImport(
    sides: {
      RelationshipSide.following: ParsedImportSide(
        observations: [
          RelationshipObservation(
            identity: UsernameIdentity.tryParse(name)!,
            sourceTimestamp: null,
          ),
        ],
        rowCount: 1,
        invalidCount: 0,
        duplicateCount: 0,
      ),
      if (followers)
        RelationshipSide.followers: ParsedImportSide(
          observations: [
            RelationshipObservation(
              identity: UsernameIdentity.tryParse(name)!,
              sourceTimestamp: null,
            ),
          ],
          rowCount: 1 + invalid,
          invalidCount: invalid,
          duplicateCount: 0,
        ),
    },
    warningCodes: invalid > 0 ? [ImportWarningCode.invalidRows] : [],
    recognizedFileCount: 2,
  );

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    temp = await Directory.systemTemp.createTemp('import-home-test-');
    preview = fixture();
    gateway = _FakeGateway();
    opened.clear();
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
    await gateway.dispose();
  });

  Widget buildScreen({
    bool cancel = false,
    String? errorCode,
    Locale? locale,
    bool failLinks = false,
    bool throwOnLinks = false,
  }) => MaterialApp(
    theme: KinshipTheme.light,
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [Locale('en', 'US'), Locale('en', 'GB')],
    home: ImportHomeScreen(
      workspace: ImportWorkspace(
        pickFiles: () async => cancel
            ? null
            : [
                XFile.fromData(Uint8List.fromList([1])),
              ],
        temporaryDirectory: () async => temp,
        parse: (_) async {
          if (errorCode != null) throw ImportWorkspaceException(errorCode);
          return preview;
        },
      ),
      review: ImportReviewRepository(db),
      read: RelationshipReadRepository(db),
      openProfile: (uri) async {
        opened.add(uri);
        if (throwOnLinks) throw StateError('Could not launch');
        if (failLinks) return false;
        return true;
      },
      purchaseGateway: gateway,
    ),
  );

  Future<void> show(WidgetTester tester, Key key) async {
    final name = (key is ValueKey<String>) ? key.value : '';
    final inAccounts =
        name.startsWith('category-') ||
        name.startsWith('profile-') ||
        name.startsWith('details-') ||
        name == 'results-count' ||
        name == 'next-page' ||
        name == 'previous-page' ||
        name == 'search-field';
    final destination = inAccounts
        ? const Key('nav-accounts')
        : const Key('nav-home');
    if (find.byKey(key).evaluate().isEmpty) {
      await tester.tap(find.byKey(destination));
      await tester.pumpAndSettle();
    }
    for (var i = 0; i < 15 && find.byKey(key).evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, 320));
      await tester.pumpAndSettle();
    }
    for (var i = 0; i < 15 && find.byKey(key).evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -320));
      await tester.pumpAndSettle();
    }
    for (var i = 0; i < 15 && find.byKey(key).evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, 320));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.byKey(key));
    await tester.pumpAndSettle();
  }

  Future<void> toggleAbout(WidgetTester tester) async {
    await show(tester, const Key('about-results'));
    await tester.ensureVisible(find.text('About your results'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('About your results'));
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester) async {
    await show(tester, const Key('pick-import'));
    await tester.pumpAndSettle();
    await show(tester, const Key('pick-import'));
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('pick-import')));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pumpAndSettle();
  }

  Future<void> tapWithIo(WidgetTester tester, Key key) async {
    await show(tester, key);
    await tester.runAsync(() async {
      await tester.tap(find.byKey(key));
      await Future<void>.delayed(const Duration(milliseconds: 120));
    });
    await tester.pumpAndSettle();
  }

  testWidgets(
    'privacy and support links open on both tabs without expanding About',
    (tester) async {
      await tester.pumpWidget(buildScreen());
      expect(find.byKey(const Key('privacy-copy')), findsNothing);
      await tester.tap(find.byKey(const Key('privacy-policy-link')));
      await tester.pump();
      expect(
        opened.single.toString(),
        'https://remejuan.github.io/instagram-manager-mobile/privacy/',
      );
      await tester.tap(find.byKey(const Key('nav-accounts')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('support-link')));
      await tester.pump();
      expect(
        opened.last.toString(),
        'https://remejuan.github.io/instagram-manager-mobile/support/',
      );
    },
  );

  testWidgets('external link failures show localized notice', (tester) async {
    await tester.pumpWidget(buildScreen(failLinks: true));
    await tester.tap(find.byKey(const Key('privacy-policy-link')));
    await tester.pump();
    expect(
      find.text('Could not open the link. Please try again.'),
      findsOneWidget,
    );
    await tester.pumpWidget(
      buildScreen(throwOnLinks: true, locale: const Locale('en', 'GB')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('support-link')));
    await tester.pump();
    expect(
      find.text('Could not open the link. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'partial default can review without extra confirmation; cancel quiet',
    (tester) async {
      await tester.pumpWidget(buildScreen());
      await pick(tester);
      await show(tester, const Key('review-import'));
      expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('review-import')))
            .onPressed,
        isNotNull,
      );
      for (final side in RelationshipSide.values) {
        expect(
          tester
              .widget<ChoiceChip>(find.byKey(Key('partial-${side.name}')))
              .selected,
          isTrue,
        );
        expect(
          tester
              .widget<ChoiceChip>(find.byKey(Key('complete-${side.name}')))
              .selected,
          isFalse,
        );
      }
      expect(find.byType(CheckboxListTile), findsNothing);
      await tapWithIo(tester, const Key('review-import'));
      await show(tester, const Key('confirm-import'));
      expect(find.textContaining('No absence is proposed'), findsOneWidget);
      expect(find.byKey(const Key('confirm-import')), findsOneWidget);
      expect(find.textContaining('Recognized files: 2'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(buildScreen(cancel: true));
      await pick(tester);
      expect(find.byKey(const Key('import-notice')), findsNothing);
      await toggleAbout(tester);
      await show(tester, const Key('privacy-copy'));
      expect(find.textContaining('device backup'), findsOneWidget);
    },
  );

  testWidgets('invalid rows block complete; missing side remains unknown', (
    tester,
  ) async {
    preview = fixture(invalid: 1);
    await tester.pumpWidget(buildScreen());
    await pick(tester);
    await show(tester, const Key('complete-followers'));
    expect(
      tester
          .widget<ChoiceChip>(find.byKey(const Key('complete-followers')))
          .onSelected,
      isNull,
    );
    expect(find.textContaining('Invalid rows: 1'), findsOneWidget);
    preview = fixture(followers: false);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(buildScreen());
    await pick(tester);
    await show(tester, const Key('missing-followers'));
    expect(find.text('Followers: missing · unknown, not zero'), findsOneWidget);
    expect(find.byKey(const Key('complete-followers')), findsNothing);
    await tapWithIo(tester, const Key('review-import'));
    await show(tester, const Key('confirm-import'));
    expect(find.byKey(const Key('confirm-import')), findsOneWidget);
  });

  testWidgets('complete review separates prior present and unknown omissions', (
    tester,
  ) async {
    final prior = fixture(name: 'prior_one');
    final initial = await ImportRepository(db).commitImport(prior, {
      RelationshipSide.following: Coverage.partial,
      RelationshipSide.followers: Coverage.partial,
    });
    expect(initial.status, CommitStatus.committed);
    preview = fixture(name: 'new_one');
    await tester.pumpWidget(buildScreen());
    await pick(tester);
    await show(tester, const Key('complete-following'));
    await tester.tap(find.byKey(const Key('complete-following')));
    await tester.pump();
    await show(tester, const Key('review-import'));
    await tester.tap(find.byKey(const Key('review-import')));
    await tester.pumpAndSettle();
    await show(tester, const Key('confirm-import'));
    expect(
      find.textContaining(
        '1 previously present → not present in this complete following snapshot.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        '0 previously unknown → not present in this complete following snapshot.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('prior_one'), findsWidgets);
    expect(opened, isEmpty);
    await show(tester, const Key('partial-following'));
    await tester.tap(find.byKey(const Key('partial-following')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('confirm-import')), findsNothing);
    await tapWithIo(tester, const Key('review-import'));
    await show(tester, const Key('confirm-import'));
    expect(find.textContaining('No absence is proposed'), findsOneWidget);
  });

  testWidgets(
    'stale review requires new confirmation; replay says already saved',
    (tester) async {
      preview = fixture(followers: false);
      await tester.pumpWidget(buildScreen());
      await pick(tester);
      await show(tester, const Key('review-import'));
      await tester.tap(find.byKey(const Key('review-import')));
      await tester.pumpAndSettle();
      final competing = fixture(name: 'other_person', followers: false);
      expect(
        (await ImportRepository(db).commitImport(competing, {
          RelationshipSide.following: Coverage.partial,
        })).status,
        CommitStatus.committed,
      );
      await tapWithIo(tester, const Key('confirm-import'));
      await show(tester, const Key('pick-import'));
      await show(tester, const Key('import-notice'));
      expect(find.textContaining('Review this import again'), findsOneWidget);
      expect(find.byKey(const Key('confirm-import')), findsNothing);
      await tapWithIo(tester, const Key('review-import'));
      await tapWithIo(tester, const Key('confirm-import'));
      await show(tester, const Key('import-notice'));
      expect(find.text('Import saved on this device.'), findsOneWidget);
      await pick(tester);
      await tapWithIo(tester, const Key('review-import'));
      await tapWithIo(tester, const Key('confirm-import'));
      await show(tester, const Key('import-notice'));
      expect(find.text('This import is already saved.'), findsOneWidget);
    },
  );

  testWidgets(
    'saved categories and search; copy on row, profile only on explicit button',
    (tester) async {
      final saved = fixture(name: 'sample_one');
      expect(
        (await ImportRepository(db).commitImport(saved, {
          RelationshipSide.following: Coverage.partial,
          RelationshipSide.followers: Coverage.partial,
        })).status,
        CommitStatus.committed,
      );
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      String? copied;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copied =
                  (call.arguments as Map<Object?, Object?>)['text'] as String?;
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await show(tester, const Key('profile-sample_one'));
      expect(opened, isEmpty);
      await tester.tap(find.byKey(const Key('details-sample_one')));
      await tester.pumpAndSettle();
      expect(
        find.text('Snapshot evidence is not a follow or unfollow time.'),
        findsOneWidget,
      );
      expect(opened, isEmpty);
      Navigator.of(tester.element(find.text('Open profile'))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('@sample_one'));
      await tester.pump();
      expect(copied, 'sample_one');
      expect(opened, isEmpty);
      await tester.tap(find.byKey(const Key('profile-sample_one')));
      await tester.pump();
      expect(opened.single, Uri.https('www.instagram.com', '/sample_one/'));
      await tapWithIo(tester, const Key('category-mutual'));
      await show(tester, const Key('results-count'));
      expect(find.textContaining('Showing 1–1 of 1'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'nobody');
      await tester.runAsync(() async {
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await Future<void>.delayed(const Duration(milliseconds: 120));
      });
      await tester.pumpAndSettle();
      expect(find.text('No saved results in this view yet.'), findsOneWidget);
    },
  );

  testWidgets('replaces pages, bounds rows, and resets offset on search', (
    tester,
  ) async {
    final bulk = ParsedImport(
      sides: {
        RelationshipSide.following: ParsedImportSide(
          observations: [
            for (var i = 0; i < 67; i++)
              RelationshipObservation(
                identity: UsernameIdentity.tryParse('sample_$i')!,
                sourceTimestamp: null,
              ),
          ],
          rowCount: 67,
          invalidCount: 0,
          duplicateCount: 0,
        ),
      },
      warningCodes: const [],
      recognizedFileCount: 1,
    );
    expect(
      (await ImportRepository(db).commitImport(bulk, {
        RelationshipSide.following: Coverage.partial,
      })).status,
      CommitStatus.committed,
    );
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    await show(tester, const Key('results-count'));
    expect(find.text('Showing 1–30 of 67'), findsOneWidget);
    await show(tester, const Key('previous-page'));
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('previous-page')))
          .onPressed,
      isNull,
    );
    await tapWithIo(tester, const Key('next-page'));
    await show(tester, const Key('results-count'));
    expect(find.text('Showing 31–60 of 67'), findsOneWidget);
    expect(
      tester.widgetList<ListTile>(find.byType(ListTile)).length,
      lessThanOrEqualTo(30),
    );
    await tapWithIo(tester, const Key('next-page'));
    await show(tester, const Key('results-count'));
    expect(find.text('Showing 61–67 of 67'), findsOneWidget);
    await show(tester, const Key('next-page'));
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('next-page')))
          .onPressed,
      isNull,
    );
    await tapWithIo(tester, const Key('previous-page'));
    await show(tester, const Key('results-count'));
    expect(find.text('Showing 31–60 of 67'), findsOneWidget);
    await tapWithIo(tester, const Key('category-unknown'));
    await show(tester, const Key('results-count'));
    expect(find.text('Showing 1–30 of 67'), findsOneWidget);
    await tapWithIo(tester, const Key('next-page'));
    await show(tester, const Key('search-field'));
    await tester.enterText(find.byKey(const Key('search-field')), 'sample_3');
    await tester.runAsync(() async {
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await Future<void>.delayed(const Duration(milliseconds: 120));
    });
    await tester.pumpAndSettle();
    await show(tester, const Key('results-count'));
    expect(find.text('Showing 1–11 of 11'), findsOneWidget);
  });

  testWidgets(
    'unknown and inactive see at most ten per category; Pro transitions restore full lists',
    (tester) async {
      final bulk = ParsedImport(
        sides: {
          RelationshipSide.following: ParsedImportSide(
            observations: [
              for (var i = 0; i < 35; i++)
                RelationshipObservation(
                  identity: UsernameIdentity.tryParse(
                    'sample_${i.toString().padLeft(2, '0')}',
                  )!,
                  sourceTimestamp: null,
                ),
            ],
            rowCount: 35,
            invalidCount: 0,
            duplicateCount: 0,
          ),
        },
        warningCodes: const [],
        recognizedFileCount: 1,
      );
      expect(
        (await ImportRepository(db).commitImport(bulk, {
          RelationshipSide.following: Coverage.partial,
        })).status,
        CommitStatus.committed,
      );
      gateway.snapshot = const PurchaseSnapshot(EntitlementState.unknown);
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();
      await show(tester, const Key('category-unknown'));
      await tapWithIo(tester, const Key('category-unknown'));
      await show(tester, const Key('results-count'));
      expect(
        find.text('Showing first 10 of 35 in this category'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('search-field')), findsNothing);
      expect(find.byKey(const Key('category-all')), findsNothing);
      expect(find.byKey(const Key('next-page')), findsNothing);
      expect(find.byKey(const Key('details-sample_00')), findsNothing);
      await tester.drag(find.byType(ListView).first, const Offset(0, 1200));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sample-upgrade')), findsOneWidget);
      expect(find.textContaining('could not be verified'), findsOneWidget);
      gateway.update(EntitlementState.inactive);
      await tester.pumpAndSettle();
      await show(tester, const Key('results-count'));
      expect(
        find.text('Showing first 10 of 35 in this category'),
        findsOneWidget,
      );
      gateway.update(EntitlementState.active);
      await tester.pumpAndSettle();
      await show(tester, const Key('search-field'));
      expect(find.byKey(const Key('category-all')), findsOneWidget);
      await show(tester, const Key('results-count'));
      expect(find.text('Showing 1–30 of 35'), findsOneWidget);
      gateway.update(EntitlementState.unknown);
      await tester.pumpAndSettle();
      await show(tester, const Key('category-unknown'));
      await tapWithIo(tester, const Key('category-unknown'));
      await show(tester, const Key('results-count'));
      expect(
        find.text('Showing first 10 of 35 in this category'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('search-field')), findsNothing);
    },
  );

  testWidgets('late initial status cannot replace newer Pro update', (
    tester,
  ) async {
    gateway.pendingInfo = Completer<PurchaseSnapshot>();
    await tester.pumpWidget(buildScreen());
    await tester.pump();
    gateway.update(EntitlementState.active);
    await tester.pump();
    gateway.pendingInfo!.complete(
      const PurchaseSnapshot(EntitlementState.inactive),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav-accounts')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-field')), findsOneWidget);
    expect(find.byKey(const Key('sample-upgrade')), findsNothing);
  });

  testWidgets('complete evidence remains distinct from later partial coverage', (
    tester,
  ) async {
    final first = fixture(followers: false);
    expect(
      (await ImportRepository(db).commitImport(first, {
        RelationshipSide.following: Coverage.partial,
      })).status,
      CommitStatus.committed,
    );
    final second = ParsedImport(
      sides: {
        RelationshipSide.followers: ParsedImportSide(
          observations: const [],
          rowCount: 0,
          invalidCount: 0,
          duplicateCount: 0,
        ),
      },
      warningCodes: const [],
      recognizedFileCount: 1,
    );
    final complete = await ImportRepository(db)
        .commitImport(second, {RelationshipSide.followers: Coverage.complete});
    expect(complete.status, CommitStatus.committed);
    final later = fixture(name: 'other_person', followers: true);
    expect(
      (await ImportRepository(db).commitImport(later, {
        RelationshipSide.followers: Coverage.partial,
        RelationshipSide.following: Coverage.partial,
      })).status,
      CommitStatus.committed,
    );
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    await show(tester, const Key('profile-sample_one'));
    expect(
      find.textContaining(
        'Not present in complete followers snapshot (import #${complete.importId})',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('followers partial (import #'), findsWidgets);
  });

  testWidgets('cleanup failure is actionable without exposing a path', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(errorCode: 'cleanup_failed'));
    await pick(tester);
    expect(
      find.textContaining('temporary import copy may remain'),
      findsOneWidget,
    );
    expect(find.textContaining(temp.path), findsNothing);
  });

  testWidgets('about results expands to full caveat and privacy disclosure', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    await show(tester, const Key('about-results'));
    expect(find.byKey(const Key('privacy-copy')), findsNothing);
    await toggleAbout(tester);
    expect(
      find.textContaining('Export and import timestamps are not event times'),
      findsOneWidget,
    );
    expect(
      find.textContaining('cannot prove a block, rename or deletion'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Missing or partial sides cannot establish absence'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Kinship does not upload your selected export'),
      findsOneWidget,
    );
    expect(find.textContaining('device backup'), findsOneWidget);
    await toggleAbout(tester);
    expect(find.byKey(const Key('privacy-copy')), findsNothing);
  });

  testWidgets('saved accounts reduce hero and show current connections', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    final emptyHero = tester.getSize(find.byKey(const Key('import-hero')));
    expect(find.text('Start with your export'), findsOneWidget);
    expect(find.text('Your connections'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(
      (await ImportRepository(db).commitImport(fixture(), {
        RelationshipSide.following: Coverage.partial,
        RelationshipSide.followers: Coverage.partial,
      })).status,
      CommitStatus.committed,
    );
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    expect(find.text('Add another export'), findsOneWidget);
    expect(find.text('Your connections'), findsOneWidget);
    expect(find.text('Saved snapshot'), findsNothing);
    expect(
      find.text('A quieter way to understand your Instagram exports.'),
      findsNothing,
    );
    expect(
      tester.getSize(find.byKey(const Key('import-hero'))).height,
      lessThan(emptyHero.height),
    );
    final heading = tester.widget<Text>(
      find.text('Your connections,\nin context.'),
    );
    expect(
      heading.style?.fontSize,
      KinshipTheme.light.textTheme.headlineSmall?.fontSize,
    );
  });

  testWidgets('compact accessible filters and native nav selection', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();
    final theme = KinshipTheme.light.navigationBarTheme;
    expect(theme.height, 64);
    expect(theme.indicatorColor, KinshipColors.peach);
    expect(
      theme.iconTheme?.resolve({WidgetState.selected})?.color,
      KinshipColors.terracotta,
    );
    await tester.tap(find.byKey(const Key('nav-accounts')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    final all = tester.widget<FilterChip>(
      find.byKey(const Key('category-all')),
    );
    expect(all.selected, isTrue);
    expect(all.showCheckmark, isFalse);
    expect(all.selectedColor, KinshipColors.peach);
    expect(all.materialTapTargetSize, MaterialTapTargetSize.padded);
    expect(find.byKey(const Key('search-field')), findsOneWidget);
    await show(tester, const Key('category-mutual'));
    await tester.tap(find.byKey(const Key('category-mutual')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilterChip>(find.byKey(const Key('category-mutual')))
          .selected,
      isTrue,
    );
    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
  });

  testWidgets('two real views remain usable on a small scaled display', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 680);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.35)),
        child: buildScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Kinship'), findsOneWidget);
    expect(find.text('✳'), findsNothing);
    final appMark = tester.widget<Image>(
      find.descendant(of: find.byType(AppBar), matching: find.byType(Image)),
    );
    expect(appMark.image, const AssetImage('assets/icons/kinship_logo.png'));
    expect(appMark.width, 28);
    expect(appMark.height, 28);
    expect(appMark.filterQuality, FilterQuality.high);
    expect(
      find.descendant(
        of: find.byKey(const Key('import-hero')),
        matching: find.byType(Image),
      ),
      findsNothing,
    );
    expect(
      tester.widget<Text>(find.text('Kinship')).style?.color,
      KinshipColors.heading,
    );
    expect(KinshipTheme.light.textTheme.headlineLarge?.fontFamily, 'Manrope');
    expect(KinshipTheme.light.textTheme.bodyMedium?.fontFamily, 'DM Sans');
    expect(find.byKey(const Key('nav-home')), findsOneWidget);
    expect(find.byKey(const Key('nav-accounts')), findsOneWidget);
    await show(tester, const Key('explore-accounts'));
    await tester.tap(find.byKey(const Key('explore-accounts')));
    await tester.pumpAndSettle();
    expect(find.text('Saved accounts'), findsOneWidget);
    await show(tester, const Key('search-field'));
    expect(find.byKey(const Key('search-field')), findsOneWidget);
    await show(tester, const Key('category-followingOnly'));
    await tester.tap(find.byKey(const Key('category-followingOnly')));
    await tester.pumpAndSettle();
    await toggleAbout(tester);
    expect(find.textContaining('device backup'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'regional English falls back to English catalog without losing safety copy',
    (tester) async {
      await tester.pumpWidget(buildScreen(locale: const Locale('en', 'GB')));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(ImportHomeScreen));
      expect(AppLocalizations.of(context), isNotNull);
      expect(find.text('Start with your export'), findsOneWidget);
      await toggleAbout(tester);
      expect(
        find.textContaining(
          'Missing or partial sides cannot establish absence',
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('may be included in device backup'),
        findsOneWidget,
      );
    },
  );
}
