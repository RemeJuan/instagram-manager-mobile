import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/domain/reconciliation.dart';
import 'package:kinship_mobile/domain/relationship.dart';

RelationshipObservation observation(String username, [int? timestamp]) =>
    RelationshipObservation(
      identity: UsernameIdentity.tryParse(username)!,
      sourceTimestamp: timestamp,
    );

void main() {
  test('positive, partial omission, complete omission, and return', () {
    var result = reconcileSide(
      side: RelationshipSide.following,
      coverage: Coverage.complete,
      observations: [observation('A', 0)],
      previousStates: const {},
      knownCanonicalUsernames: const {},
      importId: 1,
    );
    expect(result.events.single.type, ReconciliationEventType.firstObserved);
    expect(result.states['a']!.lastPositiveImportId, 1);

    result = reconcileSide(
      side: RelationshipSide.following,
      coverage: Coverage.partial,
      observations: const [],
      previousStates: result.states,
      knownCanonicalUsernames: {'a'},
      importId: 2,
    );
    expect(result.events, isEmpty);
    expect(result.states['a']!.presence, RelationshipPresence.present);

    result = reconcileSide(
      side: RelationshipSide.following,
      coverage: Coverage.complete,
      observations: const [],
      previousStates: result.states,
      knownCanonicalUsernames: {'a'},
      importId: 3,
    );
    expect(
      result.events.single.type,
      ReconciliationEventType.absenceFirstDetected,
    );
    expect(result.events.single.priorEvidenceImportId, 1);

    result = reconcileSide(
      side: RelationshipSide.following,
      coverage: Coverage.complete,
      observations: [observation('a')],
      previousStates: result.states,
      knownCanonicalUsernames: {'a'},
      importId: 4,
    );
    expect(
      result.events.single.type,
      ReconciliationEventType.returnedAfterAbsence,
    );
    expect(result.events.single.priorEvidenceImportId, 3);
  });

  test('already present refreshes; already absent refreshes without event', () {
    final first = reconcileSide(
      side: RelationshipSide.followers,
      coverage: Coverage.partial,
      observations: [observation('a')],
      previousStates: const {},
      knownCanonicalUsernames: const {},
      importId: 1,
    );
    final present = reconcileSide(
      side: RelationshipSide.followers,
      coverage: Coverage.partial,
      observations: [observation('a', 0)],
      previousStates: first.states,
      knownCanonicalUsernames: const {},
      importId: 2,
    );
    expect(present.events, isEmpty);
    expect(present.states['a']!.firstPositiveImportId, 1);
    expect(present.states['a']!.lastPositiveImportId, 2);

    final absent = reconcileSide(
      side: RelationshipSide.followers,
      coverage: Coverage.complete,
      observations: const [],
      previousStates: present.states,
      knownCanonicalUsernames: {'a'},
      importId: 3,
    );
    final repeated = reconcileSide(
      side: RelationshipSide.followers,
      coverage: Coverage.complete,
      observations: const [],
      previousStates: absent.states,
      knownCanonicalUsernames: {'a'},
      importId: 4,
    );
    expect(
      absent.events.single.type,
      ReconciliationEventType.absenceFirstDetected,
    );
    expect(repeated.events, isEmpty);
    expect(repeated.states['a']!.firstCompleteAbsenceImportId, 3);
    expect(repeated.states['a']!.latestCompleteAbsenceImportId, 4);
  });

  test('first absence evidence survives later absence episodes', () {
    var result = reconcileSide(
      side: RelationshipSide.following,
      coverage: Coverage.complete,
      observations: [observation('a')],
      previousStates: const {},
      knownCanonicalUsernames: const {},
      importId: 10,
    );
    result = reconcileSide(
      side: RelationshipSide.following,
      coverage: Coverage.complete,
      observations: const [],
      previousStates: result.states,
      knownCanonicalUsernames: {'a'},
      importId: 20,
    );
    expect(result.states['a']!.firstCompleteAbsenceImportId, 20);
    result = reconcileSide(
      side: RelationshipSide.following,
      coverage: Coverage.partial,
      observations: [observation('a')],
      previousStates: result.states,
      knownCanonicalUsernames: {'a'},
      importId: 30,
    );
    expect(result.states['a']!.firstPositiveImportId, 10);
    expect(result.states['a']!.lastPositiveImportId, 30);
    result = reconcileSide(
      side: RelationshipSide.following,
      coverage: Coverage.complete,
      observations: const [],
      previousStates: result.states,
      knownCanonicalUsernames: {'a'},
      importId: 40,
    );
    expect(result.states['a']!.firstCompleteAbsenceImportId, 20);
    expect(result.states['a']!.latestCompleteAbsenceImportId, 40);
    expect(result.events.single.priorEvidenceImportId, 30);
  });

  test('absence before first positive is first observed, not a return', () {
    var result = reconcileSide(
      side: RelationshipSide.followers,
      coverage: Coverage.complete,
      observations: const [],
      previousStates: const {},
      knownCanonicalUsernames: {'a'},
      importId: 1,
    );
    result = reconcileSide(
      side: RelationshipSide.followers,
      coverage: Coverage.partial,
      observations: [observation('a', 0)],
      previousStates: result.states,
      knownCanonicalUsernames: {'a'},
      importId: 2,
    );
    expect(result.events.single.type, ReconciliationEventType.firstObserved);
    expect(result.events.single.priorEvidenceImportId, isNull);
    expect(result.states['a']!.firstPositiveImportId, 2);
    expect(result.states['a']!.lastPositiveImportId, 2);
  });

  test(
    'unknown omission, late discovery, coverage change and missing side',
    () {
      final baseline = reconcileSide(
        side: RelationshipSide.following,
        coverage: Coverage.complete,
        observations: [observation('a')],
        previousStates: const {},
        knownCanonicalUsernames: const {},
        importId: 1,
      );
      final unchanged = reconcileSide(
        side: RelationshipSide.following,
        coverage: Coverage.complete,
        observations: const [],
        previousStates: baseline.states,
        knownCanonicalUsernames: {'a', 'late'},
        importId: 2,
      );
      expect(unchanged.events, hasLength(1));
      expect(unchanged.states['late']!.presence, RelationshipPresence.absent);
      expect(unchanged.states['late']!.firstPositiveImportId, isNull);
      expect(unchanged.states['late']!.lastPositiveImportId, isNull);
      expect(unchanged.states['late']!.firstCompleteAbsenceImportId, 2);
      expect(unchanged.states['late']!.latestCompleteAbsenceImportId, 2);
      expect(
        unchanged.events.where((event) => event.username == 'late'),
        isEmpty,
      );
      final repeatedLateAbsence = reconcileSide(
        side: RelationshipSide.following,
        coverage: Coverage.complete,
        observations: const [],
        previousStates: unchanged.states,
        knownCanonicalUsernames: {'late'},
        importId: 3,
      );
      expect(repeatedLateAbsence.events, isEmpty);
      expect(
        repeatedLateAbsence.states['late']!.firstCompleteAbsenceImportId,
        2,
      );
      expect(
        repeatedLateAbsence.states['late']!.latestCompleteAbsenceImportId,
        3,
      );
      final discovered = reconcileSide(
        side: RelationshipSide.following,
        coverage: Coverage.partial,
        observations: [observation('late')],
        previousStates: repeatedLateAbsence.states,
        knownCanonicalUsernames: {'a', 'late'},
        importId: 4,
      );
      expect(
        discovered.events.single.type,
        ReconciliationEventType.firstObserved,
      );
      expect(discovered.events.single.priorEvidenceImportId, isNull);
      expect(discovered.states['late']!.firstPositiveImportId, 4);

      final missing = reconcileSide(
        side: RelationshipSide.followers,
        coverage: Coverage.missing,
        observations: const [],
        previousStates: discovered.states,
        knownCanonicalUsernames: {'a'},
        importId: 4,
      );
      expect(missing.states, discovered.states);
      expect(missing.events, isEmpty);
      expect(
        () => reconcileSide(
          side: RelationshipSide.following,
          coverage: Coverage.missing,
          observations: [observation('a')],
          previousStates: const {},
          knownCanonicalUsernames: const {},
          importId: 5,
        ),
        throwsArgumentError,
      );
    },
  );
}
