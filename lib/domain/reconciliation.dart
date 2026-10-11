import 'relationship.dart';

enum RelationshipPresence { present, absent }

enum ReconciliationEventType {
  firstObserved,
  returnedAfterAbsence,
  absenceFirstDetected,
}

/// Durable per-username, per-side evidence. Import ids are not timestamps.
final class RelationshipEvidenceState {
  const RelationshipEvidenceState({
    required this.presence,
    required this.firstPositiveImportId,
    required this.lastPositiveImportId,
    required this.firstCompleteAbsenceImportId,
    required this.latestCompleteAbsenceImportId,
  });

  final RelationshipPresence presence;
  final int? firstPositiveImportId;
  final int? lastPositiveImportId;
  final int? firstCompleteAbsenceImportId;
  final int? latestCompleteAbsenceImportId;

  @override
  bool operator ==(Object other) =>
      other is RelationshipEvidenceState &&
      presence == other.presence &&
      firstPositiveImportId == other.firstPositiveImportId &&
      lastPositiveImportId == other.lastPositiveImportId &&
      firstCompleteAbsenceImportId == other.firstCompleteAbsenceImportId &&
      latestCompleteAbsenceImportId == other.latestCompleteAbsenceImportId;

  @override
  int get hashCode => Object.hash(
    presence,
    firstPositiveImportId,
    lastPositiveImportId,
    firstCompleteAbsenceImportId,
    latestCompleteAbsenceImportId,
  );
}

final class ReconciliationEvent {
  const ReconciliationEvent({
    required this.username,
    required this.side,
    required this.type,
    required this.importId,
    this.priorEvidenceImportId,
  });

  final String username;
  final RelationshipSide side;
  final ReconciliationEventType type;
  final int importId;

  /// Import establishing prior positive evidence for a return, or prior
  /// positive evidence for first detected absence.
  final int? priorEvidenceImportId;
}

final class ReconciliationResult {
  ReconciliationResult({
    required Map<String, RelationshipEvidenceState> states,
    required Iterable<ReconciliationEvent> events,
  }) : states = Map.unmodifiable(states),
       events = List.unmodifiable(events);

  final Map<String, RelationshipEvidenceState> states;
  final List<ReconciliationEvent> events;
}

ReconciliationResult reconcileSide({
  required RelationshipSide side,
  required Coverage coverage,
  required Iterable<RelationshipObservation> observations,
  required Map<String, RelationshipEvidenceState> previousStates,
  required Set<String> knownCanonicalUsernames,
  required int importId,
}) {
  final observed = <String>{};
  for (final observation in observations) {
    if (!observed.add(observation.identity.canonical)) {
      throw ArgumentError('Duplicate canonical relationship identity.');
    }
  }
  if (coverage == Coverage.missing) {
    if (observed.isNotEmpty) {
      throw ArgumentError('Missing side cannot contain observations.');
    }
    return ReconciliationResult(states: previousStates, events: const []);
  }

  final states = Map<String, RelationshipEvidenceState>.of(previousStates);
  final events = <ReconciliationEvent>[];

  // Positive observations always apply, including during partial imports.
  for (final username in observed) {
    final old = previousStates[username];
    if (old == null) {
      states[username] = RelationshipEvidenceState(
        presence: RelationshipPresence.present,
        firstPositiveImportId: importId,
        lastPositiveImportId: importId,
        firstCompleteAbsenceImportId: null,
        latestCompleteAbsenceImportId: null,
      );
      events.add(
        ReconciliationEvent(
          username: username,
          side: side,
          type: ReconciliationEventType.firstObserved,
          importId: importId,
        ),
      );
    } else if (old.presence == RelationshipPresence.absent) {
      states[username] = RelationshipEvidenceState(
        presence: RelationshipPresence.present,
        firstPositiveImportId: old.firstPositiveImportId ?? importId,
        lastPositiveImportId: importId,
        firstCompleteAbsenceImportId: old.firstCompleteAbsenceImportId,
        latestCompleteAbsenceImportId: old.latestCompleteAbsenceImportId,
      );
      events.add(
        ReconciliationEvent(
          username: username,
          side: side,
          type: old.firstPositiveImportId == null
              ? ReconciliationEventType.firstObserved
              : ReconciliationEventType.returnedAfterAbsence,
          importId: importId,
          priorEvidenceImportId: old.firstPositiveImportId == null
              ? null
              : old.latestCompleteAbsenceImportId,
        ),
      );
    } else {
      states[username] = RelationshipEvidenceState(
        presence: RelationshipPresence.present,
        firstPositiveImportId: old.firstPositiveImportId ?? importId,
        lastPositiveImportId: importId,
        firstCompleteAbsenceImportId: old.firstCompleteAbsenceImportId,
        latestCompleteAbsenceImportId: old.latestCompleteAbsenceImportId,
      );
    }
  }

  if (coverage == Coverage.complete) {
    for (final username in knownCanonicalUsernames) {
      if (observed.contains(username)) continue;
      final old = previousStates[username];
      if (old == null) {
        // Omission is not evidence of a prior relationship.
        states[username] = RelationshipEvidenceState(
          presence: RelationshipPresence.absent,
          firstPositiveImportId: null,
          lastPositiveImportId: null,
          firstCompleteAbsenceImportId: importId,
          latestCompleteAbsenceImportId: importId,
        );
      } else if (old.presence == RelationshipPresence.present) {
        states[username] = RelationshipEvidenceState(
          presence: RelationshipPresence.absent,
          firstPositiveImportId: old.firstPositiveImportId,
          lastPositiveImportId: old.lastPositiveImportId,
          firstCompleteAbsenceImportId:
              old.firstCompleteAbsenceImportId ?? importId,
          latestCompleteAbsenceImportId: importId,
        );
        events.add(
          ReconciliationEvent(
            username: username,
            side: side,
            type: ReconciliationEventType.absenceFirstDetected,
            importId: importId,
            priorEvidenceImportId: old.lastPositiveImportId,
          ),
        );
      } else {
        states[username] = RelationshipEvidenceState(
          presence: RelationshipPresence.absent,
          firstPositiveImportId: old.firstPositiveImportId,
          lastPositiveImportId: old.lastPositiveImportId,
          firstCompleteAbsenceImportId:
              old.firstCompleteAbsenceImportId ?? importId,
          latestCompleteAbsenceImportId: importId,
        );
      }
    }
  }
  return ReconciliationResult(states: states, events: events);
}
