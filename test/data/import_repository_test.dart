import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/data/app_database.dart';
import 'package:kinship_mobile/data/import_repository.dart';
import 'package:kinship_mobile/domain/relationship.dart';
import 'package:kinship_mobile/domain/result.dart';
import 'package:kinship_mobile/import/import_preview.dart';

void main() {
  late Directory directory;
  late AppDatabase db;
  late ImportRepository repository;

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('kinship-repository-');
    db = AppDatabase.openFile(File('${directory.path}/history.sqlite'));
    await db.customSelect('SELECT * FROM imports').get();
    repository = ImportRepository(db);
  });
  tearDown(() async {
    await db.close();
    directory.deleteSync(recursive: true);
  });

  ParsedImport data(
    Map<RelationshipSide, List<String>> names, {
    int? timestamp,
  }) => ParsedImport(
    sides: {
      for (final entry in names.entries)
        entry.key: ParsedImportSide(
          observations: entry.value.map(
            (name) => RelationshipObservation(
              identity: UsernameIdentity.tryParse(name)!,
              sourceTimestamp: timestamp ?? 1,
            ),
          ),
          rowCount: entry.value.length,
          invalidCount: 0,
          duplicateCount: 0,
        ),
    },
    warningCodes: const [],
    recognizedFileCount: names.length,
  );

  Future<CommitOutcome> commit(
    Map<RelationshipSide, List<String>> names,
    Map<RelationshipSide, Coverage> coverage, {
    int? timestamp,
  }) =>
      repository.commitImport(data(names, timestamp: timestamp ?? 0), coverage);

  test(
    'baseline, partial omission, complete absence, return and replay',
    () async {
      final side = RelationshipSide.followers;
      final baseline = await commit(
        {
          side: ['Alice', 'Bob'],
        },
        {side: Coverage.complete},
      );
      final partial = await commit(
        {
          side: ['Alice'],
        },
        {side: Coverage.partial},
      );
      expect(partial.status, CommitStatus.committed);
      expect(await db.select(db.relationshipChanges).get(), hasLength(2));

      final complete = await commit(
        {
          side: ['Alice'],
        },
        {side: Coverage.complete},
      );
      expect(complete.status, CommitStatus.committed);
      expect((await db.select(db.imports).get()).length, 3);
      var events = await db.select(db.relationshipChanges).get();
      expect(
        events.where((e) => e.importId == complete.importId).map((e) => e.kind),
        ['absence_first_detected'],
      );

      final returned = await commit(
        {
          side: ['Alice', 'Bob'],
        },
        {side: Coverage.complete},
      );
      expect(returned.status, CommitStatus.committed);
      expect(
        (await db.select(db.relationshipChanges).get())
            .where((e) => e.importId == returned.importId)
            .map((e) => e.kind),
        ['returned_after_absence'],
      );
      final replay = await commit(
        {
          side: ['Alice', 'Bob'],
        },
        {side: Coverage.complete},
      );
      expect(replay.status, CommitStatus.replay);
      expect(replay.importId, returned.importId);
      expect((await db.select(db.imports).get()).length, 4);
      expect(baseline.status, CommitStatus.committed);
    },
  );

  test('coverage change, A-B-A, single side refresh, late discovery', () async {
    final side = RelationshipSide.following;
    final a = await commit(
      {
        side: ['one'],
      },
      {side: Coverage.partial},
    );
    final b = await commit(
      {
        side: ['two'],
      },
      {side: Coverage.partial},
    );
    final again = await commit(
      {
        side: ['one'],
      },
      {side: Coverage.partial},
    );
    expect([
      a.status,
      b.status,
      again.status,
    ], everyElement(CommitStatus.committed));
    final changedCoverage = await commit(
      {
        side: ['one'],
      },
      {side: Coverage.complete},
    );
    expect(changedCoverage.status, CommitStatus.committed);

    final opposite = RelationshipSide.followers;
    final prior = await commit(
      {
        opposite: ['other'],
      },
      {opposite: Coverage.complete},
    );
    final refreshed = await commit(
      {
        side: ['one', 'newcomer'],
      },
      {side: Coverage.partial},
    );
    expect(refreshed.status, CommitStatus.committed);
    final newcomerId = (await db.select(db.observedAccounts).get())
        .firstWhere((account) => account.canonicalUsername == 'newcomer')
        .id;
    final state = await (db.select(
      db.relationshipStates,
    )..where((row) => row.accountId.equals(newcomerId))).get();
    expect(state.single.status, 'present');
    expect(prior.status, CommitStatus.committed);
  });

  test(
    'requires explicit coverage and preserves source timestamp semantics',
    () async {
      final missingChoice = await repository.commitImport(
        data({
          RelationshipSide.followers: ['zero'],
        }),
        const {},
      );
      expect(missingChoice.status, CommitStatus.rejected);
      expect(
        missingChoice.failure?.category,
        DomainFailureCategory.unsupportedCoverage,
      );
      final saved = await commit(
        {
          RelationshipSide.followers: ['zero'],
          RelationshipSide.following: ['null'],
        },
        {
          RelationshipSide.followers: Coverage.partial,
          RelationshipSide.following: Coverage.partial,
        },
        timestamp: 0,
      );
      expect(saved.status, CommitStatus.committed);
      final entries = await db.select(db.importEntries).get();
      expect(entries.first.sourceTimestampSeconds, 0);
      expect(entries.first.timestampKind, 'export_row');
      expect(entries.last.timestampKind, 'export_row');
      expect(
        (await db.select(db.imports).get()).single.parserVersion,
        importParserVersion,
      );
    },
  );

  test('replay requires exact same requested side set', () async {
    final a = await commit(
      {
        RelationshipSide.following: ['alice'],
      },
      {RelationshipSide.following: Coverage.partial},
    );
    final b = await commit(
      {
        RelationshipSide.followers: ['bob'],
      },
      {RelationshipSide.followers: Coverage.partial},
    );
    final combined = await commit(
      {
        RelationshipSide.following: ['alice'],
        RelationshipSide.followers: ['bob'],
      },
      {
        RelationshipSide.following: Coverage.partial,
        RelationshipSide.followers: Coverage.partial,
      },
    );
    expect([
      a.status,
      b.status,
      combined.status,
    ], everyElement(CommitStatus.committed));
    expect(
      (await commit(
        {
          RelationshipSide.following: ['alice'],
          RelationshipSide.followers: ['bob'],
        },
        {
          RelationshipSide.following: Coverage.partial,
          RelationshipSide.followers: Coverage.partial,
        },
      )).status,
      CommitStatus.replay,
    );
    final oneSide = await commit(
      {
        RelationshipSide.following: ['alice'],
      },
      {RelationshipSide.following: Coverage.partial},
    );
    expect(oneSide.status, CommitStatus.committed);
    expect(oneSide.importId, isNot(combined.importId));
  });

  test(
    'rejected complete invalid count and database writes roll back',
    () async {
      final unsupported = await repository.commitImport(
        data({
          RelationshipSide.followers: ['valid'],
        }),
        {RelationshipSide.followers: Coverage.missing},
      );
      expect(
        unsupported.failure?.category,
        DomainFailureCategory.unsupportedCoverage,
      );
      final badCounts = ParsedImport(
        sides: {
          RelationshipSide.followers: ParsedImportSide(
            observations: const [],
            rowCount: 2,
            invalidCount: 1,
            duplicateCount: 0,
          ),
        },
        warningCodes: const [],
        recognizedFileCount: 1,
      );
      expect(
        (await repository.commitImport(badCounts, const {
          RelationshipSide.followers: Coverage.complete,
        })).failure?.category,
        DomainFailureCategory.invalidInput,
      );

      await db.customStatement(
        '''CREATE TRIGGER fail_changes BEFORE INSERT ON relationship_changes
      BEGIN SELECT RAISE(ABORT, 'forced failure'); END''',
      );
      final failedPreview = data({
        RelationshipSide.followers: ['new.user'],
      }, timestamp: 2);
      final failed = await repository.commitImport(failedPreview, {
        RelationshipSide.followers: Coverage.partial,
      });
      expect(failed.status, CommitStatus.rejected);
      expect(await db.select(db.imports).get(), isEmpty);
      expect(await db.select(db.observedAccounts).get(), isEmpty);
      expect(await db.select(db.importEntries).get(), isEmpty);
      expect(await db.select(db.relationshipStates).get(), isEmpty);
      expect(await db.select(db.relationshipChanges).get(), isEmpty);
      expect(await db.select(db.importWarnings).get(), isEmpty);
      await db.close();
      db = AppDatabase.openFile(File('${directory.path}/history.sqlite'));
      await db.customSelect('SELECT * FROM imports').get();
      expect(await db.select(db.imports).get(), isEmpty);
    },
  );

  test('partial refresh does not update unrelated seeded state', () async {
    for (var i = 0; i < 80; i++) {
      await commit(
        {
          RelationshipSide.followers: ['seed$i'],
        },
        {RelationshipSide.followers: Coverage.partial},
      );
    }
    await db.customStatement(
      '''CREATE TRIGGER abort_unrelated BEFORE UPDATE ON relationship_states
      WHEN (SELECT canonical_username FROM observed_accounts WHERE id = NEW.account_id) != 'target'
      BEGIN SELECT RAISE(ABORT, 'unrelated state updated'); END''',
    );
    final result = await commit(
      {
        RelationshipSide.followers: ['target'],
      },
      {RelationshipSide.followers: Coverage.partial},
    );
    expect(result.status, CommitStatus.committed);
  });

  test('large partial refresh batches account and state lookups', () async {
    final names = List.generate(1205, (i) => 'batchuser$i');
    final first = await commit(
      {RelationshipSide.followers: names},
      {RelationshipSide.followers: Coverage.partial},
    );
    expect(first.status, CommitStatus.committed);
    expect(
      (await db.select(db.relationshipChanges).get()).where(
        (event) => event.importId == first.importId,
      ),
      hasLength(1205),
    );

    final otherSide = await commit(
      {
        RelationshipSide.following: ['independent'],
      },
      {RelationshipSide.following: Coverage.partial},
    );
    expect(otherSide.status, CommitStatus.committed);
    final priorFollowing = (await db.select(db.relationshipStates).get())
        .where((state) => state.side == RelationshipSide.following.name)
        .toList();
    final second = await commit(
      {
        RelationshipSide.followers: [...names, 'newbatchuser'],
      },
      {RelationshipSide.followers: Coverage.partial},
    );
    expect(second.status, CommitStatus.committed);
    expect(
      (await db.select(db.relationshipChanges).get())
          .where((event) => event.importId == second.importId)
          .map((event) => event.kind),
      ['first_observed'],
    );
    final afterStates = await db.select(db.relationshipStates).get();
    expect(
      afterStates.where(
        (state) => state.side == RelationshipSide.following.name,
      ),
      priorFollowing,
    );
    expect(
      afterStates.where(
        (state) => state.side == RelationshipSide.followers.name,
      ),
      hasLength(1206),
    );
  });

  test('warning insert failure rolls back all writes after reopen', () async {
    await db.customStatement(
      '''CREATE TRIGGER fail_warning BEFORE INSERT ON import_warnings
      BEGIN SELECT RAISE(ABORT, 'forced warning failure'); END''',
    );
    final preview = ParsedImport(
      sides: {
        RelationshipSide.followers: ParsedImportSide(
          observations: [
            RelationshipObservation(
              identity: UsernameIdentity.tryParse('rollback')!,
              sourceTimestamp: 0,
            ),
          ],
          rowCount: 1,
          invalidCount: 0,
          duplicateCount: 1,
        ),
      },
      warningCodes: const [ImportWarningCode.duplicateRows],
      recognizedFileCount: 1,
    );
    expect(
      (await repository.commitImport(preview, const {
        RelationshipSide.followers: Coverage.partial,
      })).status,
      CommitStatus.rejected,
    );
    expect(await db.select(db.imports).get(), isEmpty);
    expect(await db.select(db.importSides).get(), isEmpty);
    expect(await db.select(db.observedAccounts).get(), isEmpty);
    expect(await db.select(db.importEntries).get(), isEmpty);
    expect(await db.select(db.relationshipStates).get(), isEmpty);
    expect(await db.select(db.relationshipChanges).get(), isEmpty);
    expect(await db.select(db.importWarnings).get(), isEmpty);
    await db.close();
    db = AppDatabase.openFile(File('${directory.path}/history.sqlite'));
    await db.customSelect('SELECT * FROM imports').get();
    expect(await db.select(db.imports).get(), isEmpty);
    expect(await db.select(db.importSides).get(), isEmpty);
    expect(await db.select(db.observedAccounts).get(), isEmpty);
    expect(await db.select(db.importEntries).get(), isEmpty);
    expect(await db.select(db.relationshipStates).get(), isEmpty);
    expect(await db.select(db.relationshipChanges).get(), isEmpty);
    expect(await db.select(db.importWarnings).get(), isEmpty);
  });

  test(
    'committed import survives reopen and identical preview replays',
    () async {
      final preview = ParsedImport(
        sides: {
          RelationshipSide.followers: ParsedImportSide(
            observations: [
              RelationshipObservation(
                identity: UsernameIdentity.tryParse('persistedfollower')!,
                sourceTimestamp: 0,
              ),
            ],
            rowCount: 1,
            invalidCount: 0,
            duplicateCount: 0,
          ),
          RelationshipSide.following: ParsedImportSide(
            observations: [
              RelationshipObservation(
                identity: UsernameIdentity.tryParse('persistedfollowing')!,
                sourceTimestamp: 1700000000,
              ),
            ],
            rowCount: 1,
            invalidCount: 0,
            duplicateCount: 0,
          ),
        },
        warningCodes: const [ImportWarningCode.duplicateRows],
        recognizedFileCount: 2,
      );
      const coverage = {
        RelationshipSide.followers: Coverage.complete,
        RelationshipSide.following: Coverage.partial,
      };

      final committed = await repository.commitImport(preview, coverage);
      expect(committed.status, CommitStatus.committed);
      final importsBefore = await db.select(db.imports).get();
      final sidesBefore = await db.select(db.importSides).get();
      final entriesBefore = await db.select(db.importEntries).get();
      final statesBefore = await db.select(db.relationshipStates).get();
      final changesBefore = await db.select(db.relationshipChanges).get();
      final warningsBefore = await db.select(db.importWarnings).get();

      await db.close();
      db = AppDatabase.openFile(File('${directory.path}/history.sqlite'));
      await db.customSelect('SELECT * FROM imports').get();
      repository = ImportRepository(db);

      expect(await db.select(db.imports).get(), importsBefore);
      expect(await db.select(db.importSides).get(), sidesBefore);
      expect(await db.select(db.importEntries).get(), entriesBefore);
      expect(await db.select(db.relationshipStates).get(), statesBefore);
      expect(await db.select(db.relationshipChanges).get(), changesBefore);
      expect(await db.select(db.importWarnings).get(), warningsBefore);
      expect(
        (await db.select(db.importEntries).get()).map(
          (entry) => entry.sourceTimestampSeconds,
        ),
        [0, 1700000000],
      );
      expect(
        (await db.select(db.importWarnings).get()).map(
          (warning) => warning.count,
        ),
        [0],
      );

      final replay = await repository.commitImport(preview, coverage);
      expect(replay.status, CommitStatus.replay);
      expect(replay.importId, committed.importId);
      expect(await db.select(db.imports).get(), importsBefore);
    },
  );
}
