import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/features/spike/spike_screen.dart';
import 'package:kinship_mobile/probe/sqlite_probe.dart';

void main() {
  late Directory root;

  setUp(
    () async =>
        root = await Directory.systemTemp.createTemp('spike-screen-test-'),
  );
  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  Widget screen({
    required SpikeParser parse,
    required SpikePicker picker,
    SpikeProbeRunner? runProbe,
  }) => MaterialApp(
    home: SpikeScreen(
      parse: parse,
      pickFile: picker,
      temporaryDirectory: () async => root,
      runProbe: runProbe,
    ),
  );

  Future<void> settleIo(WidgetTester tester) async {
    // Filesystem operations need real asynchronous time in widget tests.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsNothing);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows validated counts, unknown sides, and clears working copy',
    (tester) async {
      String? workingPath;
      await tester.pumpWidget(
        screen(
          picker: () async => XFile.fromData(
            Uint8List.fromList([1, 2, 3]),
            name: 'private.json',
          ),
          parse: (path) async {
            workingPath = path;
            expect(await File(path).readAsBytes(), [1, 2, 3]);
            return const SpikeSummary(
              following: 810,
              followers: 783,
              mutual: 747,
              followingOnly: 63,
              followerOnly: 36,
              warnings: ['One side is partial.'],
            );
          },
        ),
      );
      await tester.runAsync(() async {
        await tester.tap(find.text('Choose ZIP or JSON'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await settleIo(tester);
      expect(find.text('810'), findsOneWidget);
      expect(find.text('783'), findsOneWidget);
      expect(find.text('747'), findsOneWidget);
      expect(find.text('63'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('36'), 150);
      expect(find.text('36'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Warning: One side is partial.'),
        150,
      );
      expect(find.text('Warning: One side is partial.'), findsOneWidget);
      await tester.runAsync(() async {
        expect(await File(workingPath!).exists(), isFalse);
        expect(await root.list().toList(), isEmpty);
      });
    },
  );

  testWidgets('cancel does not create working copy; unknown is not zero', (
    tester,
  ) async {
    var called = false;
    await tester.pumpWidget(
      screen(
        picker: () async => null,
        parse: (_) async {
          called = true;
          return const SpikeSummary();
        },
      ),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Choose ZIP or JSON'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settleIo(tester);
    expect(find.text('Selection cancelled. No data imported.'), findsOneWidget);
    expect(called, isFalse);
    await tester.runAsync(
      () async => expect(await root.list().toList(), isEmpty),
    );
  });

  testWidgets('rejects oversize input before parsing', (tester) async {
    var called = false;
    await tester.pumpWidget(
      screen(
        picker: () async => XFile.fromData(Uint8List(spikeMaxInputBytes + 1)),
        parse: (_) async {
          called = true;
          return const SpikeSummary();
        },
      ),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Choose ZIP or JSON'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settleIo(tester);
    expect(find.text('File exceeds the 50 MiB input limit.'), findsOneWidget);
    expect(called, isFalse);
    await tester.runAsync(
      () async => expect(await root.list().toList(), isEmpty),
    );
  });

  testWidgets('hides raw parser errors and removes working copy on failure', (
    tester,
  ) async {
    await tester.pumpWidget(
      screen(
        picker: () async =>
            XFile.fromData(Uint8List.fromList([4]), name: 'secret.json'),
        parse: (_) async => throw Exception('secret.json username-private'),
      ),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Choose ZIP or JSON'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await settleIo(tester);
    expect(
      find.text('Unable to import this file. No results were saved.'),
      findsOneWidget,
    );
    expect(find.textContaining('username-private'), findsNothing);
    await tester.runAsync(
      () async => expect(await root.list().toList(), isEmpty),
    );
  });

  testWidgets('shows in-progress state and disables concurrent operations', (
    tester,
  ) async {
    final pending = Completer<SpikeSummary>();
    await tester.pumpWidget(
      screen(
        picker: () async => XFile.fromData(Uint8List.fromList([1])),
        parse: (_) => pending.future,
      ),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Choose ZIP or JSON'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    pending.complete(const SpikeSummary(following: 1));
    await settleIo(tester);
    expect(find.text('Unknown'), findsNWidgets(3));
    await tester.scrollUntilVisible(find.text('Follower only'), 150);
    expect(find.text('Unknown'), findsNWidgets(4));
  });

  testWidgets('displays four SQLite checks without displaying database path', (
    tester,
  ) async {
    await tester.pumpWidget(
      screen(
        picker: () async => null,
        parse: (_) async => const SpikeSummary(),
        runProbe: () async => const SqliteProbeResult(
          initialRows: [
            ProbeObservation(
              id: 'synthetic',
              side: 'following',
              value: 'sample',
            ),
          ],
          reopenedRows: [
            ProbeObservation(
              id: 'synthetic',
              side: 'following',
              value: 'sample',
            ),
          ],
          rollbackPreservedRows: true,
          futureSchemaRejected: true,
          databasePath: '/private/db-path',
        ),
      ),
    );
    await tester.tap(find.text('Run SQLite probe'));
    await tester.pumpAndSettle();
    expect(find.text('Fail'), findsOneWidget); // two synthetic rows required
    expect(find.text('Pass'), findsNWidgets(3));
    expect(find.textContaining('/private/db-path'), findsNothing);
  });
}
