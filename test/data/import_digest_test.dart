import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/data/import_digest.dart';
import 'package:kinship_mobile/domain/relationship.dart';

UsernameIdentity identity(String name) => UsernameIdentity.tryParse(name)!;

RelationshipObservation observation(String name, [int? timestamp]) =>
    RelationshipObservation(
      identity: identity(name),
      sourceTimestamp: timestamp,
    );

RelationshipSnapshot snapshot({
  Iterable<RelationshipObservation> following = const [],
  Iterable<RelationshipObservation> followers = const [],
  Coverage followingCoverage = Coverage.missing,
  Coverage followersCoverage = Coverage.missing,
}) => RelationshipSnapshot(
  following: following,
  followers: followers,
  followingCoverage: followingCoverage,
  followersCoverage: followersCoverage,
);

void main() {
  group('digestImport', () {
    test('ignores observation input order', () {
      final first = snapshot(
        following: [observation('Alpha', 10), observation('Beta', 20)],
        followingCoverage: Coverage.complete,
      );
      final reordered = snapshot(
        following: [observation('Beta', 20), observation('Alpha', 10)],
        followingCoverage: Coverage.complete,
      );
      expect(
        digestImport(first, parserVersion: '1'),
        digestImport(reordered, parserVersion: '1'),
      );
    });

    test(
      'changes with coverage, timestamp, display spelling, parser version',
      () {
        final base = snapshot(
          following: [observation('Alice', 123)],
          followingCoverage: Coverage.partial,
        );
        String digest(RelationshipSnapshot value, [String version = '1']) =>
            digestImport(value, parserVersion: version);

        expect(
          digest(base),
          isNot(
            digest(
              snapshot(
                following: [observation('Alice', 123)],
                followingCoverage: Coverage.complete,
              ),
            ),
          ),
        );
        expect(
          digest(base),
          isNot(
            digest(
              snapshot(
                following: [observation('Alice', 124)],
                followingCoverage: Coverage.partial,
              ),
            ),
          ),
        );
        expect(
          digest(base),
          isNot(
            digest(
              snapshot(
                following: [observation('ALICE', 123)],
                followingCoverage: Coverage.partial,
              ),
            ),
          ),
        );
        expect(digest(base), isNot(digest(base, '2')));
      },
    );

    test(
      'A to B to A content produces equal digest, not global uniqueness',
      () {
        final original = snapshot(
          followers: [observation('Alex', 7)],
          followersCoverage: Coverage.complete,
        );
        final changed = snapshot(
          followers: [observation('Blair', 8)],
          followersCoverage: Coverage.complete,
        );
        final restored = snapshot(
          followers: [observation('Alex', 7)],
          followersCoverage: Coverage.complete,
        );
        expect(
          digestImport(original, parserVersion: '1'),
          isNot(digestImport(changed, parserVersion: '1')),
        );
        expect(
          digestImport(original, parserVersion: '1'),
          digestImport(restored, parserVersion: '1'),
        );
      },
    );
  });

  group('digestPresentSides', () {
    test('includes empty present sides and excludes missing sides', () {
      final value = snapshot(followingCoverage: Coverage.partial);
      final digests = digestPresentSides(value, parserVersion: '1');
      expect(digests.keys, {RelationshipSide.following});
      expect(
        digestPresentSides(
          snapshot(followersCoverage: Coverage.complete),
          parserVersion: '1',
        ).keys,
        {RelationshipSide.followers},
      );
    });

    test('a side remains stable when only opposite side changes', () {
      final first = snapshot(
        following: [observation('A', 1)],
        followers: [observation('B', 2)],
        followingCoverage: Coverage.partial,
        followersCoverage: Coverage.complete,
      );
      final changedOtherSide = snapshot(
        following: [observation('A', 1)],
        followers: [observation('C', 3)],
        followingCoverage: Coverage.partial,
        followersCoverage: Coverage.complete,
      );
      expect(
        digestPresentSides(
          first,
          parserVersion: '1',
        )[RelationshipSide.following],
        digestPresentSides(
          changedOtherSide,
          parserVersion: '1',
        )[RelationshipSide.following],
      );
      expect(
        digestPresentSides(
          first,
          parserVersion: '1',
        )[RelationshipSide.followers],
        isNot(
          digestPresentSides(
            changedOtherSide,
            parserVersion: '1',
          )[RelationshipSide.followers],
        ),
      );
    });
  });
}
