import 'package:drift/drift.dart';

import '../domain/relationship.dart';
import '../import/import_preview.dart';
import 'app_database.dart';
import 'import_repository.dart';

final class AbsenceReviewProposal {
  const AbsenceReviewProposal({
    required this.side,
    required this.expectedLatestImportId,
    required this.presentCount,
    required this.unknownCount,
    required this.sample,
  });
  final RelationshipSide side;
  final int? expectedLatestImportId;
  final int presentCount;
  final int unknownCount;
  final List<String> sample;
}

final class ImportReview {
  const ImportReview({
    required this.expectedLatestImportId,
    required this.proposals,
  });
  final int? expectedLatestImportId;
  final Map<RelationshipSide, AbsenceReviewProposal> proposals;
}

/// Proposes omissions only for sides explicitly selected complete. Samples bounded and sorted.
final class ImportReviewRepository {
  const ImportReviewRepository(this.db);
  final AppDatabase db;

  Future<int?> _latestRevision() async =>
      (await (db.select(db.imports)
                ..orderBy([(i) => OrderingTerm.desc(i.id)])
                ..limit(1))
              .getSingleOrNull())
          ?.id;

  Future<AbsenceReviewProposal> propose({
    required ParsedImport preview,
    required Map<RelationshipSide, Coverage> choices,
    required RelationshipSide side,
    int sampleLimit = 50,
  }) async => (await review(
    preview: preview,
    choices: choices,
    sides: {side},
    sampleLimit: sampleLimit,
  )).proposals[side]!;

  Future<ImportReview> review({
    required ParsedImport preview,
    required Map<RelationshipSide, Coverage> choices,
    Set<RelationshipSide>? sides,
    int sampleLimit = 50,
  }) async {
    if (sampleLimit < 0 || sampleLimit > 500) {
      throw ArgumentError('Invalid sample limit');
    }
    final selected = sides ?? RelationshipSide.values.toSet();
    return db.transaction(() async {
      final revision = await _latestRevision();
      final incomingKnown = <String>{
        for (final side in preview.sides.keys)
          for (final observation in preview.sides[side]!.observations)
            observation.identity.canonical,
      };
      final proposals = <RelationshipSide, AbsenceReviewProposal>{};
      for (final side in RelationshipSide.values.where(selected.contains)) {
        var present = 0, unknown = 0;
        final sample = <String>[];
        if (choices[side] == Coverage.complete &&
            preview.sides.containsKey(side)) {
          final incoming = preview.sides[side]!.observations
              .map((observation) => observation.identity.canonical)
              .toSet();
          // Query known current states; incoming names on any side are not unknown identities.
          final seenPersisted = <String>{};
          var lastId = 0;
          while (true) {
            final rows = await db
                .customSelect(
                  '''SELECT a.id AS id,
              a.canonical_username AS username, rs.status AS status
              FROM observed_accounts a LEFT JOIN relationship_states rs
                ON rs.account_id=a.id AND rs.side=?
              WHERE a.id > ? ORDER BY a.id LIMIT 500''',
                  variables: [
                    Variable.withString(side.name),
                    Variable.withInt(lastId),
                  ],
                )
                .get();
            if (rows.isEmpty) break;
            for (final row in rows) {
              lastId = row.read<int>('id');
              final username = row.read<String>('username');
              if (incomingKnown.contains(username)) seenPersisted.add(username);
              if (incoming.contains(username)) continue;
              final status = row.data['status'] as String?;
              if (status == 'present') {
                present++;
                if (sampleLimit > 0) {
                  sample.add(username);
                  sample.sort();
                  if (sample.length > sampleLimit) sample.removeLast();
                }
              } else if (status == null) {
                unknown++;
              }
            }
          }
          unknown += incomingKnown
              .difference(incoming)
              .difference(seenPersisted)
              .length;
        }
        proposals[side] = AbsenceReviewProposal(
          side: side,
          expectedLatestImportId: revision,
          presentCount: present,
          unknownCount: unknown,
          sample: List.unmodifiable(sample),
        );
      }
      return ImportReview(
        expectedLatestImportId: revision,
        proposals: Map.unmodifiable(proposals),
      );
    });
  }

  Future<CommitOutcome> commit({
    required ParsedImport preview,
    required Map<RelationshipSide, Coverage> choices,
    required int? expectedLatestImportId,
  }) => ImportRepository(db).commitImport(
    preview,
    choices,
    expectedLatestImportId: expectedLatestImportId,
    enforceExpectedLatestImportId: true,
  );
}
