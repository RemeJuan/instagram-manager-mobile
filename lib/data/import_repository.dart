import 'package:drift/drift.dart';

import '../domain/reconciliation.dart';
import '../domain/relationship.dart';
import '../domain/result.dart';
import '../import/import_preview.dart';
import 'app_database.dart';
import 'import_digest.dart';

const String importParserVersion = 'kinship-parser-v1';

enum CommitStatus { committed, replay, rejected, stale }

final class CommitOutcome {
  const CommitOutcome._(this.status, {this.importId, this.failureCategory});

  const CommitOutcome.committed(int id)
    : this._(CommitStatus.committed, importId: id);
  const CommitOutcome.replay(int id)
    : this._(CommitStatus.replay, importId: id);
  const CommitOutcome.rejected(DomainFailureCategory category)
    : this._(CommitStatus.rejected, failureCategory: category);
  const CommitOutcome.stale() : this._(CommitStatus.stale);

  final CommitStatus status;
  final int? importId;
  final DomainFailureCategory? failureCategory;
  DomainFailure? get failure => status == CommitStatus.rejected
      ? DomainFailure(
          failureCategory ?? DomainFailureCategory.persistenceUnavailable,
        )
      : null;
}

final class ImportRepository {
  const ImportRepository(this.db);
  final AppDatabase db;

  Future<CommitOutcome> commitImport(
    ParsedImport preview,
    Map<RelationshipSide, Coverage> choices, {
    int? expectedLatestImportId,
    bool enforceExpectedLatestImportId = false,
  }) async {
    final validation = _validate(preview, choices);
    if (validation != null) return CommitOutcome.rejected(validation);
    final sideCoverage = <RelationshipSide, Coverage>{
      for (final side in preview.sides.keys) side: choices[side]!,
    };
    final snapshotResult = prepareSnapshot(preview, choices);
    if (snapshotResult case Failure(:final error)) {
      return CommitOutcome.rejected(error.category);
    }
    final snapshot = (snapshotResult as Success<RelationshipSnapshot>).value;
    final sideDigests = digestPresentSides(
      snapshot,
      parserVersion: importParserVersion,
    );
    final wholeDigest = digestImport(
      snapshot,
      parserVersion: importParserVersion,
    );

    try {
      return await db.transaction(() async {
        if (enforceExpectedLatestImportId || expectedLatestImportId != null) {
          final latest =
              await (db.select(db.imports)
                    ..orderBy([(i) => OrderingTerm.desc(i.id)])
                    ..limit(1))
                  .getSingleOrNull();
          if (latest?.id != expectedLatestImportId) {
            return const CommitOutcome.stale();
          }
        }
        var allSidesUnchanged = true;
        final latestSideImportIds = <RelationshipSide, int>{};
        for (final entry in sideDigests.entries) {
          final row =
              await (db.select(db.importSides)
                    ..where((s) => s.side.equals(entry.key.name))
                    ..orderBy([(s) => OrderingTerm.desc(s.importId)])
                    ..limit(1))
                  .getSingleOrNull();
          if (row == null || row.sideDigest != entry.value) {
            allSidesUnchanged = false;
          } else {
            latestSideImportIds[entry.key] = row.importId;
          }
        }
        if (allSidesUnchanged &&
            latestSideImportIds.length == sideDigests.length) {
          final candidateId = latestSideImportIds.values.first;
          if (latestSideImportIds.values.every((id) => id == candidateId)) {
            final candidateSides = await (db.select(
              db.importSides,
            )..where((s) => s.importId.equals(candidateId))).get();
            final exactSet =
                candidateSides.length == sideDigests.length &&
                sideDigests.entries.every(
                  (entry) => candidateSides.any(
                    (row) =>
                        row.side == entry.key.name &&
                        row.sideDigest == entry.value,
                  ),
                );
            if (exactSet) return CommitOutcome.replay(candidateId);
          }
        }

        final importId = await db
            .into(db.imports)
            .insert(
              ImportsCompanion.insert(
                parserVersion: importParserVersion,
                digest: wholeDigest,
                importedAt: Value(DateTime.now().toUtc()),
              ),
            );
        for (final side in RelationshipSide.values) {
          final coverage = sideCoverage[side];
          if (coverage == null) continue;
          final parsed = preview.sides[side]!;
          await db
              .into(db.importSides)
              .insert(
                ImportSidesCompanion.insert(
                  importId: importId,
                  side: side.name,
                  coverage: coverage.name,
                  sideDigest: sideDigests[side]!,
                  rowCount: parsed.rowCount,
                  invalidCount: parsed.invalidCount,
                  duplicateCount: parsed.duplicateCount,
                ),
              );
        }

        final accountIds = <String, int>{};
        final observedNames = <String>{
          for (final side in sideCoverage.keys)
            for (final observation in preview.sides[side]!.observations)
              observation.identity.canonical,
        };
        for (final batch in _chunks(observedNames, 500)) {
          final accounts = await (db.select(
            db.observedAccounts,
          )..where((a) => a.canonicalUsername.isIn(batch))).get();
          for (final account in accounts) {
            accountIds[account.canonicalUsername] = account.id;
          }
        }
        final knownNames = accountIds.keys.toSet();
        if (sideCoverage.values.any(
          (coverage) => coverage == Coverage.complete,
        )) {
          final knownAccounts = await db.select(db.observedAccounts).get();
          for (final account in knownAccounts) {
            accountIds.putIfAbsent(account.canonicalUsername, () => account.id);
            knownNames.add(account.canonicalUsername);
          }
        }
        for (final side in sideCoverage.keys) {
          final data = preview.sides[side]!;
          for (final observation in data.observations) {
            var accountId = accountIds[observation.identity.canonical];
            if (accountId == null) {
              accountId = await db
                  .into(db.observedAccounts)
                  .insert(
                    ObservedAccountsCompanion.insert(
                      canonicalUsername: observation.identity.canonical,
                      firstDisplayUsername: observation.identity.display,
                      firstSeenImportId: importId,
                    ),
                  );
              accountIds[observation.identity.canonical] = accountId;
              knownNames.add(observation.identity.canonical);
            }
            await db
                .into(db.importEntries)
                .insert(
                  ImportEntriesCompanion.insert(
                    importId: importId,
                    side: side.name,
                    accountId: accountId,
                    displayUsername: observation.identity.display,
                    sourceTimestampSeconds: Value(observation.sourceTimestamp),
                    timestampKind: Value(
                      observation.sourceTimestamp == null ? null : 'export_row',
                    ),
                  ),
                );
          }
        }

        for (final side in sideCoverage.keys) {
          final observedIds = sideCoverage[side] == Coverage.complete
              ? null
              : accountIds.values.toSet();
          if (observedIds != null && observedIds.isEmpty) continue;
          final rows = <RelationshipState>[];
          if (observedIds == null) {
            rows.addAll(
              await (db.select(
                db.relationshipStates,
              )..where((s) => s.side.equals(side.name))).get(),
            );
          } else {
            for (final batch in _chunks(observedIds, 500)) {
              rows.addAll(
                await (db.select(db.relationshipStates)
                      ..where((s) => s.side.equals(side.name))
                      ..where((s) => s.accountId.isIn(batch)))
                    .get(),
              );
            }
          }
          final previous = <String, RelationshipEvidenceState>{};
          final canonicalById = <int, String>{
            for (final entry in accountIds.entries) entry.value: entry.key,
          };
          for (final row in rows) {
            final canonical = canonicalById[row.accountId];
            if (canonical != null) previous[canonical] = _decodeState(row);
          }
          final result = reconcileSide(
            side: side,
            coverage: sideCoverage[side]!,
            observations: preview.sides[side]!.observations,
            previousStates: previous,
            knownCanonicalUsernames: knownNames,
            importId: importId,
          );
          for (final entry in result.states.entries) {
            final accountId = accountIds[entry.key];
            if (accountId == null) continue;
            final state = entry.value;
            final prior = previous[entry.key];
            if (prior == state) continue;
            await db
                .into(db.relationshipStates)
                .insertOnConflictUpdate(
                  RelationshipStatesCompanion.insert(
                    accountId: accountId,
                    side: side.name,
                    status: state.presence.name,
                    firstPositiveImportId: Value(state.firstPositiveImportId),
                    lastPositiveImportId: Value(state.lastPositiveImportId),
                    firstCompleteAbsenceImportId: Value(
                      state.firstCompleteAbsenceImportId,
                    ),
                    latestCompleteAbsenceImportId: Value(
                      state.latestCompleteAbsenceImportId,
                    ),
                  ),
                );
          }
          for (final event in result.events) {
            await db
                .into(db.relationshipChanges)
                .insert(
                  RelationshipChangesCompanion.insert(
                    importId: importId,
                    side: side.name,
                    accountId: accountIds[event.username]!,
                    kind: switch (event.type) {
                      ReconciliationEventType.firstObserved => 'first_observed',
                      ReconciliationEventType.returnedAfterAbsence =>
                        'returned_after_absence',
                      ReconciliationEventType.absenceFirstDetected =>
                        'absence_first_detected',
                    },
                    priorEvidenceImportId: Value(event.priorEvidenceImportId),
                  ),
                );
          }
        }
        for (final warning in preview.warningCodes) {
          var count = 0;
          for (final entry in preview.sides.entries) {
            if (warning == ImportWarningCode.invalidRows) {
              count += entry.value.invalidCount;
            }
            if (warning == ImportWarningCode.duplicateRows) {
              count += entry.value.duplicateCount;
            }
            if (warning == ImportWarningCode.conflictingDuplicate) {
              count = 1;
            }
          }
          await db
              .into(db.importWarnings)
              .insert(
                ImportWarningsCompanion.insert(
                  importId: importId,
                  code: warning.name,
                  count: count,
                ),
              );
        }
        return CommitOutcome.committed(importId);
      });
    } catch (_) {
      return const CommitOutcome.rejected(
        DomainFailureCategory.persistenceUnavailable,
      );
    }
  }

  DomainFailureCategory? _validate(
    ParsedImport preview,
    Map<RelationshipSide, Coverage> choices,
  ) {
    if (preview.recognizedFileCount <= 0 || preview.sides.isEmpty) {
      return DomainFailureCategory.invalidInput;
    }
    for (final entry in preview.sides.entries) {
      final side = entry.value;
      // Stage 4 requires explicit user coverage choice per side. Preview's
      // partial default must never silently become persisted coverage.
      if (!choices.containsKey(entry.key) ||
          choices[entry.key] == Coverage.missing) {
        return DomainFailureCategory.unsupportedCoverage;
      }
      if (side.rowCount < 0 ||
          side.invalidCount < 0 ||
          side.duplicateCount < 0 ||
          side.observations.length + side.invalidCount + side.duplicateCount !=
              side.rowCount) {
        return DomainFailureCategory.invalidInput;
      }
      final seen = <String>{};
      for (final observation in side.observations) {
        final identity = observation.identity;
        final parsed = UsernameIdentity.tryParse(identity.display);
        if (parsed == null ||
            parsed.canonical != identity.canonical ||
            !seen.add(identity.canonical) ||
            observation.sourceTimestamp != null &&
                observation.sourceTimestamp! < 0) {
          return DomainFailureCategory.invalidInput;
        }
      }
    }
    if (choices.keys.any((side) => !preview.sides.containsKey(side)) ||
        preview.warningCodes.toSet().length != preview.warningCodes.length) {
      return DomainFailureCategory.invalidInput;
    }
    return null;
  }

  RelationshipEvidenceState _decodeState(RelationshipState row) =>
      RelationshipEvidenceState(
        presence: row.status == 'present'
            ? RelationshipPresence.present
            : RelationshipPresence.absent,
        firstPositiveImportId: row.firstPositiveImportId,
        lastPositiveImportId: row.lastPositiveImportId,
        firstCompleteAbsenceImportId: row.firstCompleteAbsenceImportId,
        latestCompleteAbsenceImportId: row.latestCompleteAbsenceImportId,
      );

  Iterable<List<T>> _chunks<T>(Iterable<T> values, int size) sync* {
    var batch = <T>[];
    for (final value in values) {
      batch.add(value);
      if (batch.length == size) {
        yield batch;
        batch = <T>[];
      }
    }
    if (batch.isNotEmpty) yield batch;
  }
}
