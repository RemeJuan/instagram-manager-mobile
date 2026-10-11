import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/data/app_database.dart';
import 'package:kinship_mobile/data/import_repository.dart';
import 'package:kinship_mobile/data/import_review_repository.dart';
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
  test('counts prior positive and unknown; partial omissions cannot propose absence; stale guard rejects', () async {
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
    final imports = ImportRepository(db);
    await imports.commitImport(p(['known']), {side: Coverage.complete});
    final review = ImportReviewRepository(db);
    final proposal = await review.propose(
      preview: p([]),
      choices: const {RelationshipSide.followers: Coverage.complete},
      side: side,
    );
    expect(proposal.presentCount, 1);
    expect(proposal.unknownCount, 0);
    await imports.commitImport(p([]), {side: Coverage.complete});
    final alreadyAbsent = await review.propose(
      preview: p([]),
      choices: const {RelationshipSide.followers: Coverage.complete},
      side: side,
    );
    expect(alreadyAbsent.presentCount, 0);
    expect(alreadyAbsent.unknownCount, 0);
    final nullBaseline = await review.propose(
      preview: p([]),
      choices: const {RelationshipSide.followers: Coverage.complete},
      side: side,
    );
    expect(nullBaseline.expectedLatestImportId, 2);
    await imports.commitImport(p([]), {side: Coverage.partial});
    final partial = await review.propose(
      preview: p([]),
      choices: const {RelationshipSide.followers: Coverage.partial},
      side: side,
    );
    expect(partial.presentCount, 0);
    final stale = await imports.commitImport(p(['new']), {
      side: Coverage.partial,
    }, expectedLatestImportId: proposal.expectedLatestImportId);
    expect(stale.status, CommitStatus.stale);
    expect((await db.select(db.imports).get()), hasLength(3));
  });

  test('empty baseline revision rejects an intervening first commit', () async {
    final side = RelationshipSide.following;
    ParsedImport p(String name) => ParsedImport(
      sides: {
        side: ParsedImportSide(
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
      },
      warningCodes: const [],
      recognizedFileCount: 1,
    );
    final review = ImportReviewRepository(db);
    final proposal = await review.propose(
      preview: p('reviewed'),
      choices: const {RelationshipSide.following: Coverage.complete},
      side: side,
    );
    expect(proposal.expectedLatestImportId, isNull);
    await ImportRepository(db).commitImport(p('intervening'), const {
      RelationshipSide.following: Coverage.partial,
    });
    final stale = await review.commit(
      preview: p('reviewed'),
      choices: const {RelationshipSide.following: Coverage.complete},
      expectedLatestImportId: proposal.expectedLatestImportId,
    );
    expect(stale.status, CommitStatus.stale);
    expect(await db.select(db.imports).get(), hasLength(1));
    expect(await db.select(db.relationshipChanges).get(), hasLength(1));
  });

  test(
    'opposite-side incoming names count as unknown omissions without events',
    () async {
      const followers = RelationshipSide.followers;
      const following = RelationshipSide.following;
      ParsedImport preview() => ParsedImport(
        sides: {
          followers: ParsedImportSide(
            observations: const [],
            rowCount: 0,
            invalidCount: 0,
            duplicateCount: 0,
          ),
          following: ParsedImportSide(
            observations: [
              RelationshipObservation(
                identity: UsernameIdentity.tryParse('alice')!,
                sourceTimestamp: null,
              ),
            ],
            rowCount: 1,
            invalidCount: 0,
            duplicateCount: 0,
          ),
        },
        warningCodes: const [],
        recognizedFileCount: 2,
      );
      const choices = {
        followers: Coverage.complete,
        following: Coverage.partial,
      };
      final review = ImportReviewRepository(db);
      final proposal = await review.review(
        preview: preview(),
        choices: choices,
      );
      expect(proposal.proposals[followers]!.unknownCount, 1);
      expect(proposal.expectedLatestImportId, isNull);
      final outcome = await review.commit(
        preview: preview(),
        choices: choices,
        expectedLatestImportId: proposal.expectedLatestImportId,
      );
      expect(outcome.status, CommitStatus.committed);
      final account = (await db.select(db.observedAccounts).get()).single;
      final states = await (db.select(
        db.relationshipStates,
      )..where((s) => s.accountId.equals(account.id))).get();
      expect(
        states.singleWhere((s) => s.side == followers.name).status,
        'absent',
      );
      expect(
        states.singleWhere((s) => s.side == following.name).status,
        'present',
      );
      expect(await db.select(db.relationshipChanges).get(), hasLength(1));
    },
  );

  test('both selected sides share review snapshot revision', () async {
    final revision = await ImportReviewRepository(db).review(
      preview: ParsedImport(
        sides: {
          for (final side in RelationshipSide.values)
            side: ParsedImportSide(
              observations: const [],
              rowCount: 0,
              invalidCount: 0,
              duplicateCount: 0,
            ),
        },
        warningCodes: const [],
        recognizedFileCount: 2,
      ),
      choices: const {
        RelationshipSide.followers: Coverage.complete,
        RelationshipSide.following: Coverage.complete,
      },
    );
    expect(revision.proposals.keys, hasLength(2));
    expect(
      revision.proposals.values.map((p) => p.expectedLatestImportId).toSet(),
      {revision.expectedLatestImportId},
    );
  });

  test(
    'large two-side incoming review pages rows and bounds sorted samples',
    () async {
      ParsedImport preview() => ParsedImport(
        sides: {
          for (final side in RelationshipSide.values)
            side: ParsedImportSide(
              observations: List.generate(
                1250,
                (i) => RelationshipObservation(
                  identity: UsernameIdentity.tryParse(
                    '${side.name}${i.toString().padLeft(4, '0')}',
                  )!,
                  sourceTimestamp: null,
                ),
              ),
              rowCount: 1250,
              invalidCount: 0,
              duplicateCount: 0,
            ),
        },
        warningCodes: const [],
        recognizedFileCount: 2,
      );
      final result = await ImportReviewRepository(db).review(
        preview: preview(),
        choices: const {
          RelationshipSide.followers: Coverage.complete,
          RelationshipSide.following: Coverage.complete,
        },
        sampleLimit: 3,
      );
      expect(result.proposals[RelationshipSide.followers]!.unknownCount, 1250);
      expect(result.proposals[RelationshipSide.following]!.unknownCount, 1250);
      expect(result.proposals[RelationshipSide.followers]!.sample, isEmpty);
      expect(
        result.proposals.values.map((p) => p.expectedLatestImportId).toSet(),
        {null},
      );
    },
  );
}
