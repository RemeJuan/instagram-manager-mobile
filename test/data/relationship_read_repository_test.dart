import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/data/app_database.dart';
import 'package:kinship_mobile/data/import_repository.dart';
import 'package:kinship_mobile/data/relationship_read_repository.dart';
import 'package:kinship_mobile/domain/relationship.dart';
import 'package:kinship_mobile/import/import_preview.dart';

void main() {
  late Directory dir;
  late AppDatabase db;
  setUp(() async {
    dir = Directory.systemTemp.createTempSync();
    db = AppDatabase.openFile(File('${dir.path}/db'));
    await db.customSelect('SELECT * FROM imports').get();
  });
  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  ParsedImport parsed(Map<RelationshipSide, List<String>> sides) =>
      ParsedImport(
        sides: {
          for (final entry in sides.entries)
            entry.key: ParsedImportSide(
              observations: entry.value
                  .map(
                    (name) => RelationshipObservation(
                      identity: UsernameIdentity.tryParse(name)!,
                      sourceTimestamp: null,
                    ),
                  )
                  .toList(),
              rowCount: entry.value.length,
              invalidCount: 0,
              duplicateCount: 0,
            ),
        },
        warningCodes: const [],
        recognizedFileCount: 1,
      );

  test(
    'both-side complete omission excludes absent account from read model',
    () async {
      final imports = ImportRepository(db);
      await imports.commitImport(
        parsed({
          RelationshipSide.followers: ['gone', 'staysunknown'],
          RelationshipSide.following: ['gone'],
        }),
        const {
          RelationshipSide.followers: Coverage.complete,
          RelationshipSide.following: Coverage.complete,
        },
      );
      await imports.commitImport(
        parsed({
          RelationshipSide.followers: ['staysunknown'],
          RelationshipSide.following: [],
        }),
        const {
          RelationshipSide.followers: Coverage.complete,
          RelationshipSide.following: Coverage.complete,
        },
      );

      final repo = RelationshipReadRepository(db);
      final page = await repo.page(limit: 10);
      final counts = await repo.counts();
      expect(page.rows.map((row) => row.username), ['staysunknown']);
      expect(page.totalCount, 1);
      expect(page.rows.single.category, RelationshipCategory.followerOnly);
      expect(counts.followerOnly, 1);
      expect(
        counts.mutual +
            counts.followingOnly +
            counts.followerOnly +
            counts.unknown,
        page.totalCount,
      );
      expect(
        (await repo.page(category: RelationshipCategory.unknown)).totalCount,
        counts.unknown,
      );

      final history = await db.customSelect('''
      SELECT status FROM relationship_states
      WHERE account_id = (SELECT id FROM observed_accounts WHERE canonical_username='gone')
      ORDER BY side
    ''').get();
      expect(history, hasLength(2));
      expect(history.map((row) => row.read<String>('status')).toSet(), {
        'absent',
      });
    },
  );

  test(
    'partial omission retains complete absence evidence and latest coverage',
    () async {
      final imports = ImportRepository(db);
      await imports.commitImport(
        parsed({
          RelationshipSide.following: ['target'],
          RelationshipSide.followers: ['target'],
        }),
        const {
          RelationshipSide.following: Coverage.complete,
          RelationshipSide.followers: Coverage.complete,
        },
      );
      final absence = await imports.commitImport(
        parsed({
          RelationshipSide.following: ['target'],
          RelationshipSide.followers: [],
        }),
        const {
          RelationshipSide.following: Coverage.complete,
          RelationshipSide.followers: Coverage.complete,
        },
      );
      expect(absence.importId, isNotNull);

      final repo = RelationshipReadRepository(db);
      var page = await repo.page(category: RelationshipCategory.followingOnly);
      expect(page.totalCount, 1);
      expect(page.rows.single.followersAbsenceImportId, absence.importId);
      expect(page.rows.single.category, RelationshipCategory.followingOnly);

      final partial = await imports.commitImport(
        parsed({RelationshipSide.followers: []}),
        const {RelationshipSide.followers: Coverage.partial},
      );
      expect(partial.importId, greaterThan(absence.importId!));

      page = await repo.page(category: RelationshipCategory.followingOnly);
      final row = page.rows.single;
      expect(row.category, RelationshipCategory.followingOnly);
      expect(row.followersAbsenceImportId, absence.importId);
      expect(row.followersCoverage, Coverage.partial);
      expect(row.followersCoverageImportId, partial.importId);
      final counts = await repo.counts();
      expect(counts.followingOnly, 1);
      expect(page.totalCount, counts.followingOnly);
      expect(
        (await repo.page(limit: 10)).totalCount,
        counts.mutual +
            counts.followingOnly +
            counts.followerOnly +
            counts.unknown,
      );
    },
  );

  test(
    'stable pages, literal wildcard search, coverage and unknown distinction',
    () async {
      final side = RelationshipSide.followers;
      ParsedImport p(List<String> names) => ParsedImport(
        sides: {
          side: ParsedImportSide(
            observations: names
                .map(
                  (n) => RelationshipObservation(
                    identity: UsernameIdentity.tryParse(n)!,
                    sourceTimestamp: null,
                  ),
                )
                .toList(),
            rowCount: names.length,
            invalidCount: 0,
            duplicateCount: 0,
          ),
        },
        warningCodes: const [],
        recognizedFileCount: 1,
      );
      await ImportRepository(db).commitImport(
        p(['under_score', 'percentname']),
        {side: Coverage.complete},
      );
      final repo = RelationshipReadRepository(db);
      final underscore = await repo.page(search: '_', limit: 1);
      expect(underscore.totalCount, 1);
      expect(underscore.rows.single.username, 'under_score');
      final page = await repo.page(limit: 1);
      expect(page.totalCount, 2);
      expect(page.rows.single.category, RelationshipCategory.unknown);
      expect(
        (await repo.page(limit: 1, offset: 1)).rows.single.username,
        'under_score',
      );
    },
  );

  test('bounded SQL paging across large account set', () async {
    final names = List.generate(
      1205,
      (i) => 'pageuser${i.toString().padLeft(4, '0')}',
    );
    final parsed = ParsedImport(
      sides: {
        RelationshipSide.following: ParsedImportSide(
          observations: names
              .map(
                (n) => RelationshipObservation(
                  identity: UsernameIdentity.tryParse(n)!,
                  sourceTimestamp: null,
                ),
              )
              .toList(),
          rowCount: names.length,
          invalidCount: 0,
          duplicateCount: 0,
        ),
      },
      warningCodes: const [],
      recognizedFileCount: 1,
    );
    await ImportRepository(db).commitImport(parsed, const {
      RelationshipSide.following: Coverage.partial,
    });
    final repo = RelationshipReadRepository(db);
    final page = await repo.page(limit: 5, offset: 0, search: 'pageuser1');
    expect(page.rows, hasLength(5));
    expect(page.totalCount, 205);
    expect(page.rows.first.username, 'pageuser1000');
  });
}
