import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/domain/relationship.dart';
import 'package:kinship_mobile/domain/result.dart';
import 'package:kinship_mobile/import/import_preview.dart';

void main() {
  late Directory root;
  setUp(
    () async =>
        root = await Directory.systemTemp.createTemp('import_preview_test_'),
  );
  tearDown(() async => root.delete(recursive: true));

  test('baseline ZIP defaults both sides partial and explicit complete matches categories', () async {
    final preview = await parseImportInputs(['fixtures/baseline.zip']);
    expect(
      preview.sides[RelationshipSide.following]!.observations,
      hasLength(810),
    );
    expect(
      preview.sides[RelationshipSide.followers]!.observations,
      hasLength(783),
    );
    final defaults = (prepareSnapshot(
      preview,
      const {},
    ) as Success<RelationshipSnapshot>).value;
    expect(defaults.followingCoverage, Coverage.partial);
    expect(defaults.followersCoverage, Coverage.partial);
    final complete = (prepareSnapshot(preview, const {
      RelationshipSide.following: Coverage.complete,
      RelationshipSide.followers: Coverage.complete,
    }) as Success<RelationshipSnapshot>).value;
    final categories = classifyRelationships(complete);
    expect(categories.mutual, hasLength(747));
    expect(categories.followingOnly, hasLength(63));
    expect(categories.followerOnly, hasLength(36));
  });

  test('mixed ZIP and renamed standalone preserves deterministic first observation', () async {
    final standalone = File('${root.path}/renamed.data');
    await standalone.writeAsString(
      jsonEncode({
        'relationships_following': [_row('Synthetic_0001', 999)],
      }),
    );
    final baseline = await parseImportInputs(['fixtures/following.json']);
    final expected = baseline.sides[RelationshipSide.following]!.observations
        .firstWhere((item) => item.identity.canonical == 'synthetic_0001');
    final preview = await parseImportInputs([
      'fixtures/baseline.zip',
      standalone.path,
    ]);
    final observation = preview.sides[RelationshipSide.following]!.observations
        .firstWhere((item) => item.identity.canonical == 'synthetic_0001');
    expect(observation.sourceTimestamp, expected.sourceTimestamp);
    expect(
      preview.warningCodes,
      contains(ImportWarningCode.conflictingDuplicate),
    );
  });

  test(
    'within-file duplicate preserves first timestamp including zero',
    () async {
      final file = File('${root.path}/duplicates.json')
        ..writeAsStringSync(
          jsonEncode({
            'relationships_following': [
              _row('duplicate', 0),
              _row('duplicate', 9),
            ],
          }),
        );

      final preview = await parseImportInputs([file.path]);

      expect(
        preview
            .sides[RelationshipSide.following]!
            .observations
            .single
            .sourceTimestamp,
        0,
      );
      expect(
        preview.warningCodes,
        contains(ImportWarningCode.conflictingDuplicate),
      );
    },
  );

  test(
    'malformed UTF-8 JSON-looking ZIP rejects after recognized ZIP',
    () async {
      final recognized = File('${root.path}/recognized.zip')
        ..writeAsBytesSync(
          _storedZip(
            'followers_1.json',
            jsonEncode({
              'relationships_following': [_row('valid', 1)],
            }),
          ),
        );
      final malformed = File('${root.path}/malformed_utf8.zip')
        ..writeAsBytesSync(_storedZipBytes('second.json', [0x7b, 0xff]));

      await expectLater(
        parseImportInputs([recognized.path, malformed.path]),
        throwsA(
          isA<ImportException>().having(
            (error) => error.code,
            'code',
            'invalidEncodingOrSyntax',
          ),
        ),
      );
    },
  );

  test(
    'unsupported same-side wrapper ZIP rejects alongside valid ZIP',
    () async {
      final recognized = File('${root.path}/recognized.zip')
        ..writeAsBytesSync(
          _storedZip(
            'followers_1.json',
            jsonEncode({
              'relationships_following': [_row('valid', 1)],
            }),
          ),
        );
      final unsupported = File('${root.path}/unsupported.zip')
        ..writeAsBytesSync(
          _storedZip(
            'relationships_following_v2.json',
            jsonEncode({
              'relationships_following_v2': [_row('unsupported', 2)],
            }),
          ),
        );

      await expectLater(
        parseImportInputs([recognized.path, unsupported.path]),
        throwsA(isA<ImportException>()),
      );
    },
  );

  test('preview accepts valid sides with unrelated ZIP wrappers, rejects malformed supported', () async {
    final zip = File('${root.path}/unrelated_wrappers.zip')
      ..writeAsBytesSync(
        _storedZipEntries([
          _ZipEntry(
            'relationships_following.json',
            utf8.encode(
              jsonEncode({
                'relationships_following': [_row('following', 1)],
                'relationships_blocked_users': [],
                'relationships_follow_requests_sent': [],
                'relationships_unfollowed_users': [],
              }),
            ),
          ),
          _ZipEntry(
            'followers_1.json',
            utf8.encode(
              jsonEncode({
                'followers': [_row('follower', 2)],
                'relationships_blocked_users': [],
              }),
            ),
          ),
        ]),
      );
    final preview = await parseImportInputs([zip.path]);
    expect(
      preview.sides[RelationshipSide.following]!.observations,
      hasLength(1),
    );
    expect(
      preview.sides[RelationshipSide.followers]!.observations,
      hasLength(1),
    );

    final malformed = File('${root.path}/malformed_supported.zip')
      ..writeAsBytesSync(
        _storedZipEntries([
          _ZipEntry(
            'relationships_following.json',
            utf8.encode(
              jsonEncode({
                'relationships_following': 'not-a-list',
                'relationships_blocked_users': [],
              }),
            ),
          ),
          _ZipEntry(
            'followers_1.json',
            utf8.encode(
              jsonEncode({
                'followers': [_row('follower', 2)],
              }),
            ),
          ),
        ]),
      );
    await expectLater(
      parseImportInputs([malformed.path]),
      throwsA(isA<ImportException>()),
    );
  });

  test(
    'directory-inclusive count across archives accepts 500 and rejects 501',
    () async {
      final accepted = File('${root.path}/accepted.zip')
        ..writeAsBytesSync(
          _storedZipEntries([
            _ZipEntry(
              'relationships_following.json',
              utf8.encode(
                jsonEncode({
                  'relationships_following': [_row('ok', 1)],
                }),
              ),
            ),
          ]),
        );
      final acceptedDirs = File('${root.path}/accepted_dirs.zip')
        ..writeAsBytesSync(
          _storedZipEntries(
            List.generate(
              497,
              (index) => _ZipEntry('dir$index/', const [], directory: true),
            ),
          ),
        );
      final rejected = File('${root.path}/rejected.zip')
        ..writeAsBytesSync(
          _storedZipEntries([
            _ZipEntry(
              'relationships_following.json',
              utf8.encode(
                jsonEncode({
                  'relationships_following': [_row('ok', 1)],
                }),
              ),
            ),
          ]),
        );
      final rejectedDirs = File('${root.path}/rejected_dirs.zip')
        ..writeAsBytesSync(
          _storedZipEntries(
            List.generate(
              498,
              (index) => _ZipEntry('dir$index/', const [], directory: true),
            ),
          ),
        );

      final preview = await parseImportInputs([
        accepted.path,
        acceptedDirs.path,
      ]);
      expect(
        preview.sides[RelationshipSide.following]!.observations,
        hasLength(1),
      );
      await expectLater(
        parseImportInputs([rejected.path, rejectedDirs.path]),
        throwsA(
          isA<ImportException>().having(
            (error) => error.code,
            'code',
            'entry_count_limit',
          ),
        ),
      );
      final leftovers = Directory.systemTemp
          .listSync()
          .whereType<Directory>()
          .where(
            (directory) =>
                directory.path != root.path &&
                directory.path
                    .split(Platform.pathSeparator)
                    .last
                    .startsWith('import_preview_'),
          );
      expect(leftovers, isEmpty);
    },
  );

  test(
    'malformed recognized ZIP JSON rejects and unrelated valid JSON is ignored',
    () async {
      await expectLater(
        parseImportInputs(['fixtures/malformedRelationship.zip']),
        throwsA(isA<ImportException>()),
      );
      final preview = await parseImportInputs(['fixtures/unrelatedJson.zip']);
      expect(preview.recognizedFileCount, 1);
      expect(
        preview.sides[RelationshipSide.following]!.observations,
        hasLength(1),
      );
    },
  );

  test('no recognized relationship input fails safely', () async {
    final unrelated = File('${root.path}/unrelated.json')
      ..writeAsStringSync('{"export_version":1}');
    await expectLater(
      parseImportInputs([unrelated.path]),
      throwsA(
        isA<ImportException>().having(
          (error) => error.code,
          'code',
          'no_relationship_data',
        ),
      ),
    );
  });

  test('ZIP non-JSON entry ignored after validator checks it', () async {
    final zip = File('${root.path}/text_entry.zip')
      ..writeAsBytesSync(_storedZip('note.bin', 'plain text payload'));
    await expectLater(
      parseImportInputs([zip.path]),
      throwsA(
        isA<ImportException>().having(
          (error) => error.code,
          'code',
          'no_relationship_data',
        ),
      ),
    );
    final staging = Directory.systemTemp
        .listSync()
        .whereType<Directory>()
        .where(
          (directory) =>
              directory.path != root.path &&
              directory.path
                  .split(Platform.pathSeparator)
                  .last
                  .startsWith('import_preview_'),
        );
    expect(staging, isEmpty);
  });

  test(
    'invalid rows on following side block only following complete coverage',
    () async {
      final one = File('${root.path}/following.json');
      final two = File('${root.path}/followers.json');
      await one.writeAsString(
        jsonEncode({
          'relationships_following': [_row('ok', 1), {}],
        }),
      );
      await two.writeAsString(
        jsonEncode({
          'followers': [_row('also_ok', 2)],
        }),
      );
      final preview = await parseImportInputs([one.path, two.path]);
      expect(
        prepareSnapshot(preview, const {
          RelationshipSide.following: Coverage.complete,
        }),
        isA<Failure<RelationshipSnapshot>>(),
      );
      expect(
        prepareSnapshot(preview, const {
          RelationshipSide.followers: Coverage.complete,
        }),
        isA<Success<RelationshipSnapshot>>(),
      );
      expect(
        prepareSnapshot(preview, const {
          RelationshipSide.followers: Coverage.missing,
        }),
        isA<Failure<RelationshipSnapshot>>(),
      );
    },
  );

  test(
    'invalid PK signature, input count/byte limits and cleanup use safe errors',
    () async {
      final badZip = File('${root.path}/bad.zip')
        ..writeAsBytesSync([0x50, 0x4b, 0, 0]);
      await expectLater(
        parseImportInputs([badZip.path]),
        throwsA(isA<ImportException>()),
      );
      final small = File('${root.path}/small.json')..writeAsStringSync('[]');
      await expectLater(
        parseImportInputs(List.filled(501, small.path)),
        throwsA(isA<ImportException>()),
      );
      final big = File('${root.path}/big.bin')
        ..writeAsBytesSync(List.filled(50 * 1024 * 1024, 0));
      await expectLater(
        parseImportInputs([small.path, big.path]),
        throwsA(isA<ImportException>()),
      );
      await parseImportInputs(['fixtures/baseline.zip']);
      final leftovers = Directory.systemTemp
          .listSync()
          .whereType<Directory>()
          .where(
            (directory) =>
                directory.path != root.path &&
                directory.path
                    .split(Platform.pathSeparator)
                    .last
                    .startsWith('import_preview_'),
          );
      expect(leftovers, isEmpty);
    },
  );
}

Map<String, Object?> _row(String username, int timestamp) => {
  'string_list_data': [
    {'value': username, 'timestamp': timestamp},
  ],
};

List<int> _storedZip(String name, String value) {
  return _storedZipBytes(name, utf8.encode(value));
}

List<int> _storedZipBytes(String name, List<int> bytes) =>
    _storedZipEntries([_ZipEntry(name, bytes)]);

class _ZipEntry {
  const _ZipEntry(this.name, this.data, {this.directory = false});

  final String name;
  final List<int> data;
  final bool directory;
}

List<int> _storedZipEntries(List<_ZipEntry> entries) {
  final locals = <int>[];
  final centrals = <int>[];
  final offsets = <int>[];
  for (final entry in entries) {
    final nameBytes = utf8.encode(entry.name);
    final data = entry.data;
    final crc = _crc32(data);
    offsets.add(locals.length);
    locals.addAll([
      0x50,
      0x4b,
      0x03,
      0x04,
      ..._u16(20),
      ..._u16(0x0800),
      ..._u16(0),
      ..._u16(0),
      ..._u16(0),
      ..._u32(crc),
      ..._u32(data.length),
      ..._u32(data.length),
      ..._u16(nameBytes.length),
      ..._u16(0),
      ...nameBytes,
      ...data,
    ]);
  }
  for (var index = 0; index < entries.length; index++) {
    final entry = entries[index];
    final nameBytes = utf8.encode(entry.name);
    final data = entry.data;
    final crc = _crc32(data);
    final attributes = entry.directory ? 0x41ed0000 : 0x81a40000;
    centrals.addAll([
      0x50,
      0x4b,
      0x01,
      0x02,
      ..._u16(0x0314),
      ..._u16(20),
      ..._u16(0x0800),
      ..._u16(0),
      ..._u16(0),
      ..._u16(0),
      ..._u32(crc),
      ..._u32(data.length),
      ..._u32(data.length),
      ..._u16(nameBytes.length),
      ..._u16(0),
      ..._u16(0),
      ..._u16(0),
      ..._u16(0),
      ..._u32(attributes),
      ..._u32(offsets[index]),
      ...nameBytes,
    ]);
  }
  final eocd = <int>[
    0x50,
    0x4b,
    0x05,
    0x06,
    ..._u16(0),
    ..._u16(0),
    ..._u16(entries.length),
    ..._u16(entries.length),
    ..._u32(centrals.length),
    ..._u32(locals.length),
    ..._u16(0),
  ];
  return [...locals, ...centrals, ...eocd];
}

List<int> _u16(int value) => [value & 0xff, (value >> 8) & 0xff];

List<int> _u32(int value) => [..._u16(value & 0xffff), ..._u16(value >> 16)];

int _crc32(List<int> bytes) {
  var crc = 0xffffffff;
  for (final byte in bytes) {
    crc ^= byte;
    for (var bit = 0; bit < 8; bit++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
    }
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}
