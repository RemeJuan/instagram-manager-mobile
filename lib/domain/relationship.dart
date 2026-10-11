/// Canonical username identity, retaining first observed display spelling.
final class UsernameIdentity {
  UsernameIdentity._(this.canonical, this.display);

  final String canonical;
  final String display;

  static UsernameIdentity? tryParse(String raw) {
    var value = raw.trim();
    if (value.startsWith('@')) value = value.substring(1);
    if (value.isEmpty ||
        value.length > 30 ||
        !RegExp(r'^[A-Za-z0-9._]+$').hasMatch(value) ||
        value.startsWith('.') ||
        value.endsWith('.')) {
      return null;
    }
    return UsernameIdentity._(value.toLowerCase(), value);
  }

  @override
  bool operator ==(Object other) =>
      other is UsernameIdentity && canonical == other.canonical;

  @override
  int get hashCode => canonical.hashCode;
}

enum RelationshipSide { following, followers }

enum Coverage { missing, partial, complete }

/// Positive relationship observation with timestamp from its export row.
final class RelationshipObservation {
  const RelationshipObservation({
    required this.identity,
    required this.sourceTimestamp,
  });

  final UsernameIdentity identity;
  final int? sourceTimestamp;
}

/// Snapshot of positive observations and explicit coverage, per side.
final class RelationshipSnapshot {
  RelationshipSnapshot({
    required Iterable<RelationshipObservation> following,
    required Iterable<RelationshipObservation> followers,
    required this.followingCoverage,
    required this.followersCoverage,
  }) : following = _index(following),
       followers = _index(followers) {
    if (followingCoverage == Coverage.missing && this.following.isNotEmpty ||
        followersCoverage == Coverage.missing && this.followers.isNotEmpty) {
      throw ArgumentError('Missing side cannot contain observations.');
    }
  }

  final Map<UsernameIdentity, RelationshipObservation> following;
  final Map<UsernameIdentity, RelationshipObservation> followers;
  final Coverage followingCoverage;
  final Coverage followersCoverage;

  static Map<UsernameIdentity, RelationshipObservation> _index(
    Iterable<RelationshipObservation> observations,
  ) {
    final result = <UsernameIdentity, RelationshipObservation>{};
    for (final observation in observations) {
      if (result.containsKey(observation.identity)) {
        throw ArgumentError('Duplicate canonical relationship identity.');
      }
      result[observation.identity] = observation;
    }
    return Map.unmodifiable(result);
  }
}

final class RelationshipClassification {
  RelationshipClassification({
    required Iterable<UsernameIdentity> mutual,
    required Iterable<UsernameIdentity> followingOnly,
    required Iterable<UsernameIdentity> followerOnly,
    required Iterable<UsernameIdentity> unclassified,
  }) : mutual = Set.unmodifiable(mutual),
       followingOnly = Set.unmodifiable(followingOnly),
       followerOnly = Set.unmodifiable(followerOnly),
       unclassified = Set.unmodifiable(unclassified);

  final Set<UsernameIdentity> mutual;
  final Set<UsernameIdentity> followingOnly;
  final Set<UsernameIdentity> followerOnly;

  /// Positive observations whose opposite side cannot establish absence.
  final Set<UsernameIdentity> unclassified;
}

RelationshipClassification classifyRelationships(
  RelationshipSnapshot snapshot,
) {
  final following = snapshot.following.keys.toSet();
  final followers = snapshot.followers.keys.toSet();
  final mutual = following.intersection(followers);
  final followingOnly = <UsernameIdentity>{};
  final followerOnly = <UsernameIdentity>{};
  final unclassified = <UsernameIdentity>{};
  for (final identity in following.difference(mutual)) {
    if (snapshot.followersCoverage == Coverage.complete) {
      followingOnly.add(identity);
    } else {
      unclassified.add(identity);
    }
  }
  for (final identity in followers.difference(mutual)) {
    if (snapshot.followingCoverage == Coverage.complete) {
      followerOnly.add(identity);
    } else {
      unclassified.add(identity);
    }
  }
  return RelationshipClassification(
    mutual: mutual,
    followingOnly: followingOnly,
    followerOnly: followerOnly,
    unclassified: unclassified,
  );
}
