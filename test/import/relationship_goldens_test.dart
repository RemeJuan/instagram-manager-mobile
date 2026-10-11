import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/import/relationship_json.dart';

Map<String, Object?> _goldenRecord(RelationshipRecord record) => {
  'identity': record.identity,
  'display': record.displayUsername,
  'profileUrl': record.profileUrl,
  'sourceTimestamp': record.sourceTimestamp,
};

List<Map<String, Object?>> _parseGoldenRecords(
  Iterable<RelationshipRecord> records,
) => records.map(_goldenRecord).toList()
  ..sort(
    (a, b) => (a['identity']! as String).compareTo(b['identity']! as String),
  );

void main() {
  test(
    'split follower and following parser records match complete goldens',
    () {
      final manifest = jsonDecode(
        File('fixtures/manifest.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final goldens = jsonDecode(
        File('fixtures/goldens.json').readAsStringSync(),
      ) as Map<String, dynamic>;

      final followerChunks = <ParsedRelationshipFile>[];
      final followerRows = <dynamic>[];
      for (final name in ['followers_1.json', 'followers_2.json']) {
        final rows =
            jsonDecode(File('fixtures/$name').readAsStringSync()) as List;
        followerRows.addAll(rows);
        followerChunks.add(
          parseRelationshipJson(name, utf8.encode(jsonEncode(rows))),
        );
      }
      final splitFollowers = parseRelationshipJson(
        'followers_split.json',
        utf8.encode(
          jsonEncode({
            'followers_1': jsonDecode(
              File('fixtures/followers_1.json').readAsStringSync(),
            ),
            'followers_2': jsonDecode(
              File('fixtures/followers_2.json').readAsStringSync(),
            ),
          }),
        ),
      );
      final following = parseRelationshipJson(
        'following.json',
        File('fixtures/following.json').readAsBytesSync(),
      );

      final expectedRecords = goldens['records'] as Map<String, dynamic>;
      expect(
        _parseGoldenRecords(splitFollowers.records),
        expectedRecords['followers'],
      );
      expect(
        _parseGoldenRecords(following.records),
        expectedRecords['following'],
      );
      expect(splitFollowers.records.length, followerRows.length);
      expect(
        _parseGoldenRecords(followerChunks.expand((file) => file.records)),
        expectedRecords['followers'],
      );

      final manifestRecords = manifest['records'] as Map<String, dynamic>;
      expect(manifestRecords, expectedRecords);
      final manifestCategories = manifest['categories'] as Map<String, dynamic>;
      expect(manifestCategories, goldens['categories']);

      final summary = summarizeRelationships([
        splitFollowers,
        following,
      ], completeSides: RelationshipSide.values.toSet());
      final categories = goldens['categories'] as Map<String, dynamic>;
      expect(summary.mutual, Set<String>.from(categories['mutual'] as List));
      expect(
        summary.followerOnly,
        Set<String>.from(categories['followerOnly'] as List),
      );
      expect(
        summary.followingOnly,
        Set<String>.from(categories['followingOnly'] as List),
      );
    },
  );

  test('variant fixture missing and invalid timestamps remain unavailable', () {
    final variants = jsonDecode(
      File('fixtures/variants.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final key in ['missingTimestamp', 'invalidTimestamp']) {
      final parsed = parseRelationshipJson(
        '$key.json',
        utf8.encode(jsonEncode(variants[key])),
      );
      expect(parsed.records, hasLength(1), reason: key);
      expect(parsed.records.single.sourceTimestamp, isNull, reason: key);
    }
  });
}
