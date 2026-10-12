import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/import/relationship_json.dart';

Map<String, Object?> _row(
  String username, {
  Object? timestamp = 1,
  String? href,
}) => {
  'string_list_data': [
    {
      'value': username,
      'href': href ?? 'https://www.instagram.com/$username/',
      'timestamp': timestamp,
    },
  ],
};
List<int> _bytes(Object? value) => utf8.encode(jsonEncode(value));

void main() {
  test('fixture oracle matches normalized identities and counts', () {
    final following = parseRelationshipJson(
      'following.json',
      File('fixtures/following.json').readAsBytesSync(),
    );
    final followers = <ParsedRelationshipFile>[];
    for (final file in Directory('fixtures').listSync().whereType<File>().where(
      (file) =>
          RegExp(r'followers_\d+\.json$').hasMatch(file.uri.pathSegments.last),
    )) {
      final rows = jsonDecode(file.readAsStringSync()) as List<dynamic>;
      followers.add(
        parseRelationshipJson(file.uri.pathSegments.last, _bytes(rows)),
      );
    }
    final summary = summarizeRelationships([
      following,
      ...followers,
    ], completeSides: RelationshipSide.values.toSet());
    final golden = jsonDecode(
      File('fixtures/goldens.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final counts = golden['expectedCounts'] as Map<String, dynamic>;
    expect(following.invalidCount, 0);
    expect(following.records, isNotEmpty);
    expect(summary.following, hasLength(counts['following'] as int));
    expect(summary.followers, hasLength(counts['followers'] as int));
    expect(summary.mutual, hasLength(counts['mutual'] as int));
    expect(summary.followingOnly, hasLength(counts['followingOnly'] as int));
    expect(summary.followerOnly, hasLength(counts['followerOnly'] as int));
    final categories = golden['categories'] as Map<String, dynamic>;
    expect(summary.mutual, Set<String>.from(categories['mutual'] as List));
    expect(
      summary.followingOnly,
      Set<String>.from(categories['followingOnly'] as List),
    );
    expect(
      summary.followerOnly,
      Set<String>.from(categories['followerOnly'] as List),
    );
    final records = golden['records'] as Map<String, dynamic>;
    for (final record in following.records) {
      expect(record.identity, record.displayUsername.toLowerCase());
    }
    expect(
      following.records.map((record) => record.identity).toSet(),
      Set<String>.from(
        (records['following'] as List).map((row) => (row as Map)['identity']),
      ),
    );
    expect(
      followers
          .expand((file) => file.records)
          .map((record) => record.identity)
          .toSet(),
      Set<String>.from(
        (records['followers'] as List).map((row) => (row as Map)['identity']),
      ),
    );
  });

  test('invalid rows counted; canonical duplicates retain first; timestamp is source-only', () {
    final parsed = parseRelationshipJson(
      'followers.json',
      _bytes([
        _row('User.Name', timestamp: -1),
        _row('user.name', timestamp: 4),
        {'bad': true},
      ]),
    );
    expect(parsed.invalidCount, 1);
    expect(parsed.records.single.identity, 'user.name');
    expect(parsed.records.single.displayUsername, 'User.Name');
    expect(parsed.records.single.sourceTimestamp, isNull);
    expect(parsed.invalidCount, 1);
    expect(parsed.duplicateCount, 1);
  });

  test('rejects malformed recognized shape and URL spoofing', () {
    expect(
      () => parseRelationshipJson(
        'f.json',
        _bytes({'relationships_followers': {}}),
      ),
      throwsFormatException,
    );
    expect(
      parseRelationshipJson(
        'f.json',
        _bytes({'relationships_following': []}),
      ).side,
      RelationshipSide.following,
    );
    final parsed = parseRelationshipJson(
      'f.json',
      _bytes([
        _row('account', href: 'https://www.instagram.com.evil/account/'),
      ]),
    );
    expect(parsed.invalidCount, 1);
  });

  test('strict UTF-8 decode', () {
    expect(
      () => parseRelationshipJson('f.json', [0xff]),
      throwsFormatException,
    );
  });

  test('supports named wrappers, splits, @ normalization, and sourceName-independent typing', () {
    final split = parseRelationshipJson(
      'not_a_follower.json',
      _bytes({
        'followers_1': [_row('@Name', href: 'https://instagram.com/_u/Name/')],
        'followers_2': [_row('name')],
      }),
    );
    expect(split.side, RelationshipSide.followers);
    expect(split.records.single.identity, 'name');
    expect(split.duplicateCount, 1);
    expect(
      parseRelationshipJson(
        'following.json',
        _bytes({
          'followers': [_row('user')],
        }),
      ).side,
      RelationshipSide.followers,
    );
  });

  test('extracts following identity from title or href and rejects identity disagreement', () {
    final parsed = parseRelationshipJson(
      'arbitrary',
      _bytes({
        'relationships_following': [
          {
            'title': 'TitleUser',
            'string_list_data': [
              {'href': 'https://instagram.com/_u/TitleUser/'},
            ],
          },
          {
            'string_list_data': [
              {'value': 'first', 'href': 'https://www.instagram.com/second/'},
            ],
          },
        ],
      }),
    );
    expect(parsed.records.single.identity, 'titleuser');
    expect(parsed.invalidCount, 1);
  });

  test('does not infer only categories until opposite side complete; casing may differ cross-side', () {
    final following = parseRelationshipJson(
      'f',
      _bytes({
        'relationships_following': [_row('Account')],
      }),
    );
    final followers = parseRelationshipJson(
      'x',
      _bytes({
        'followers': [_row('account')],
      }),
    );
    final partial = summarizeRelationships([following]);
    expect(partial.followingOnly, isNull);
    expect(partial.followerOnly, isNull);
    final complete = summarizeRelationships([
      following,
      followers,
    ], completeSides: RelationshipSide.values.toSet());
    expect(complete.mutual, {'account'});
    expect(complete.followingOnly, isEmpty);
  });

  test('allows consecutive dots; leading/trailing dot remain invalid', () {
    final parsed = parseRelationshipJson(
      'x',
      _bytes([_row('a..b'), _row('.bad'), _row('bad.')]),
    );
    expect(parsed.records.single.identity, 'a..b');
    expect(parsed.invalidCount, 2);
  });

  test(
    'timestamp values preserve zero and reject missing, negative, and strings',
    () {
      final parsed = parseRelationshipJson(
        'x',
        _bytes([
          _row('zero', timestamp: 0),
          {
            'string_list_data': [
              {'value': 'missing'},
            ],
          },
          _row('negative', timestamp: -1),
          _row('string', timestamp: '1'),
        ]),
      );
      expect(parsed.records.map((r) => r.sourceTimestamp), [
        0,
        null,
        null,
        null,
      ]);
    },
  );

  test('validates all items and retains first duplicate observation', () {
    final invalidExtra = parseRelationshipJson(
      'x',
      _bytes([
        {
          'string_list_data': [
            {'value': 'good', 'timestamp': 0},
            {'value': 'not valid!'},
          ],
        },
      ]),
    );
    expect(invalidExtra.invalidCount, 1);
    final duplicate = parseRelationshipJson(
      'x',
      _bytes([_row('same', timestamp: 0), _row('SAME', timestamp: 9)]),
    );
    expect(duplicate.records.single.sourceTimestamp, 0);
    expect(duplicate.duplicateCount, 1);
    expect(
      duplicate.warningCodes,
      contains(RelationshipWarningCode.conflictingDuplicate),
    );
  });

  test('split follower wrappers iterate many parts linearly', () {
    final wrappers = <String, Object?>{
      for (var i = 0; i < 20000; i++) 'followers_$i': [_row('user$i')],
    };
    final stopwatch = Stopwatch()..start();
    final parsed = parseRelationshipJson('x', _bytes(wrappers));
    stopwatch.stop();
    expect(parsed.rowCount, 20000);
    expect(parsed.records, hasLength(20000));
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
  });

  test(
    'rejects unsupported relationship wrapper keys but tolerates metadata',
    () {
      for (final value in [
        {'followers': [], 'followers_v2': []},
        {'relationships_following': [], 'relationships_following_v2': []},
        {'followers_v2': []},
      ]) {
        expect(
          () => parseRelationshipJson('x', _bytes(value)),
          throwsA(isA<RelationshipJsonException>()),
        );
      }
      expect(
        () => parseRelationshipJson('x', _bytes({'exported_at': 'today'})),
        throwsA(
          isA<RelationshipJsonException>().having(
            (error) => error.code,
            'code',
            RelationshipJsonErrorCode.unrecognizedStructure,
          ),
        ),
      );
    },
  );

  test('rejects ambiguous wrapper kinds with typed error', () {
    try {
      parseRelationshipJson(
        'x',
        _bytes({'followers': [], 'relationships_following': []}),
      );
      fail('expected wrapper ambiguity');
    } on RelationshipJsonException catch (error) {
      expect(error.code, RelationshipJsonErrorCode.ambiguousWrappers);
    }
  });

  test(
    'ignores allowlisted unrelated wrappers but rejects mixed and unknown',
    () {
      final parsed = parseRelationshipJson(
        'following.json',
        _bytes({
          'relationships_following': [_row('valid')],
          'relationships_blocked_users': [],
          'relationships_follow_requests_sent': [],
          'relationships_unfollowed_users': [],
        }),
      );
      expect(parsed.records.single.identity, 'valid');
      for (final wrapper in [
        'relationships_following_v2',
        'relationships_followers',
      ]) {
        expect(
          () => parseRelationshipJson(
            'following.json',
            _bytes({
              'relationships_following': [_row('valid')],
              wrapper: [],
            }),
          ),
          throwsA(isA<RelationshipJsonException>()),
        );
      }
      expect(
        () => parseRelationshipJson(
          'following.json',
          _bytes({
            'relationships_following': 'malformed',
            'relationships_blocked_users': [],
          }),
        ),
        throwsA(isA<RelationshipJsonException>()),
      );
    },
  );

  test('accepts exactly one million rows', () {
    final parsed = parseRelationshipJson(
      'x',
      _bytes(List<Object?>.filled(1000000, null)),
    );
    expect(parsed.rowCount, 1000000);
    expect(parsed.invalidCount, 1000000);
  });
}
