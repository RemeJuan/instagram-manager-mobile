import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/domain/relationship.dart';

UsernameIdentity id(String value) => UsernameIdentity.tryParse(value)!;
RelationshipObservation observation(String value, int? timestamp) =>
    RelationshipObservation(identity: id(value), sourceTimestamp: timestamp);

void main() {
  group('username identity', () {
    test('normalizes canonical identity and preserves display spelling', () {
      final first = id('  @Alice.Name ');
      expect(first.canonical, 'alice.name');
      expect(first.display, 'Alice.Name');
      expect(first, id('ALICE.NAME'));
    });

    test('rejects invalid identities', () {
      for (final value in ['', '@', '.alice', 'alice.', 'a b', 'x' * 31]) {
        expect(UsernameIdentity.tryParse(value), isNull);
      }
    });
  });

  group('relationship classification', () {
    test('missing side remains unknown', () {
      final result = classifyRelationships(
        RelationshipSnapshot(
          following: [observation('a', null)],
          followers: [],
          followingCoverage: Coverage.complete,
          followersCoverage: Coverage.missing,
        ),
      );
      expect(result.followingOnly, isEmpty);
      expect(result.unclassified, {id('a')});
    });

    test('partial omission never implies absence', () {
      final result = classifyRelationships(
        RelationshipSnapshot(
          following: [observation('a', 10), observation('b', null)],
          followers: [observation('a', 20)],
          followingCoverage: Coverage.partial,
          followersCoverage: Coverage.partial,
        ),
      );
      expect(result.mutual, {id('a')});
      expect(result.followingOnly, isEmpty);
      expect(result.unclassified, {id('b')});
    });

    test('complete opposite side enables absence-based categories', () {
      final result = classifyRelationships(
        RelationshipSnapshot(
          following: [observation('a', 0), observation('b', 12)],
          followers: [observation('a', null), observation('c', 23)],
          followingCoverage: Coverage.complete,
          followersCoverage: Coverage.complete,
        ),
      );
      expect(result.mutual, {id('a')});
      expect(result.followingOnly, {id('b')});
      expect(result.followerOnly, {id('c')});
      expect(result.unclassified, isEmpty);
    });

    test('preserves per-observation timestamps and immutable maps', () {
      final input = [observation('a', 17), observation('b', null)];
      final snapshot = RelationshipSnapshot(
        following: input,
        followers: const <RelationshipObservation>[],
        followingCoverage: Coverage.partial,
        followersCoverage: Coverage.missing,
      );
      input.clear();
      expect(snapshot.following.keys, {id('a'), id('b')});
      expect(snapshot.following[id('a')]!.sourceTimestamp, 17);
      expect(snapshot.following[id('b')]!.sourceTimestamp, isNull);
      expect(() => snapshot.following.clear(), throwsUnsupportedError);
    });

    test('rejects duplicate canonical identities rather than overwriting', () {
      expect(
        () => RelationshipSnapshot(
          following: [observation('Alice', 1), observation('alice', 2)],
          followers: const <RelationshipObservation>[],
          followingCoverage: Coverage.complete,
          followersCoverage: Coverage.missing,
        ),
        throwsArgumentError,
      );
    });
  });
}
