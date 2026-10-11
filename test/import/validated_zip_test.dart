import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/import/validated_zip.dart';

void main() {
  late Directory root;
  late Directory staging;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('validated_zip_test_');
    staging = Directory('${root.path}/stage');
  });
  tearDown(() async => root.delete(recursive: true));

  test('stages valid stored entry only during callback', () async {
    for (final method in [0, 8]) {
      final source = File('${root.path}/$method.zip')
        ..writeAsBytesSync(_zip(method));
      final result = await withValidatedZipEntries(source, staging, (
        entries,
      ) async {
        expect(entries, hasLength(1));
        expect(await entries.single.file.readAsString(), 'safe json');
        expect(entries.single.expandedBytes, 9);
        return entries.single.name;
      });
      expect(result, 'folder/data.json');
      expect(await staging.list().toList(), isEmpty);
    }
  });

  test('rejects hostile fixture corpus', () async {
    for (final name in [
      'traversal.zip',
      'casefoldDuplicate.zip',
      'symlink.zip',
      'encrypted.zip',
      'nestedArchive.zip',
      'ratioLimit.zip',
      'sizeLimit.zip',
      'metadataDeception.zip',
    ]) {
      final source = File('fixtures/$name');
      await expectLater(
        withValidatedZipEntries(
          source,
          staging,
          (_) async => fail('callback must not run'),
        ),
        throwsA(
          isA<ValidatedZipException>().having(
            (e) => e.code,
            'code',
            isNotEmpty,
          ),
        ),
        reason: name,
      );
      expect(await staging.list().toList(), isEmpty);
    }
  });

  test(
    'rejects over compressed archive limit before archive parsing',
    () async {
      final over = File('${root.path}/compressed-over.zip');
      final raf = await over.open(mode: FileMode.write);
      await raf.setPosition(validatedZipCompressedLimit);
      await raf.writeByte(0);
      await raf.close();
      await _expectRejected(over, staging, 'compressed_limit');
    },
  );

  test(
    'per-call expanded allowance rejects before staging and cleans up',
    () async {
      final source = File('${root.path}/allowance.zip')
        ..writeAsBytesSync(_zip(0));
      var callbackRan = false;
      await expectLater(
        withValidatedZipEntries(
          source,
          staging,
          (_) async => callbackRan = true,
          maxExpandedBytes: 8,
        ),
        throwsA(
          isA<ValidatedZipException>().having(
            (e) => e.code,
            'code',
            'size_limit',
          ),
        ),
      );
      expect(callbackRan, isFalse);
      expect(await staging.list().toList(), isEmpty);
    },
  );

  test(
    'entry callback count includes directory entries and cap applies pre-stage',
    () async {
      final source = File('${root.path}/directory-count.zip')
        ..writeAsBytesSync(_zip(0, directory: true));
      var count = 0;
      await withValidatedZipEntries(
        source,
        staging,
        (entries) async => expect(entries, isEmpty),
        onEntryCount: (value) => count = value,
      );
      expect(count, 1);
      count = 0;
      await expectLater(
        withValidatedZipEntries(
          source,
          staging,
          (_) async => fail('callback must not run'),
          maxEntryCount: 0,
          onEntryCount: (value) => count = value,
        ),
        throwsA(
          isA<ValidatedZipException>().having(
            (e) => e.code,
            'code',
            'entry_count_limit',
          ),
        ),
      );
      expect(count, 0);
      expect(await staging.list().toList(), isEmpty);
    },
  );

  test('rejects declared per-entry and aggregate expanded overages', () async {
    final tooLargeEntry = _zip(0, content: <int>[65]);
    _setCentralSize(tooLargeEntry, expanded: validatedZipEntryLimit + 1);
    final entrySource = File('${root.path}/entry-over.zip')
      ..writeAsBytesSync(tooLargeEntry);
    await _expectRejected(entrySource, staging, 'entry_size_limit');

    final payloadSize = (validatedZipEntryLimit - 1 + 199) ~/ 200;
    final tooLargeTotal = _multiZip(
      List.generate(11, (_) => List<int>.generate(payloadSize, (i) => i % 251)),
    );
    _setDeclaredExpandedSizes(
      tooLargeTotal,
      List<int>.filled(11, validatedZipEntryLimit - 1),
    );
    final totalSource = File('${root.path}/expanded-over.zip')
      ..writeAsBytesSync(tooLargeTotal);
    await _expectRejected(totalSource, staging, 'size_limit');
  });

  test('accepts exact entry count and rejects one over', () async {
    final exact = File('${root.path}/count-exact.zip')
      ..writeAsBytesSync(
        _multiZip(List.generate(validatedZipEntryCountLimit, (_) => <int>[65])),
      );
    await withValidatedZipEntries(
      exact,
      staging,
      (entries) async =>
          expect(entries, hasLength(validatedZipEntryCountLimit)),
    );
    final over = File('${root.path}/count-over.zip')
      ..writeAsBytesSync(
        _multiZip(
          List.generate(validatedZipEntryCountLimit + 1, (_) => <int>[65]),
        ),
      );
    await _expectRejected(over, staging, 'invalid_directory');
  });

  test('accepts exact 200:1 ratio and rejects ratio overage', () async {
    final exact = File('${root.path}/ratio-exact.zip')
      ..writeAsBytesSync(_zip(0, content: List<int>.filled(200, 65)));
    await withValidatedZipEntries(
      exact,
      staging,
      (entries) async => expect(entries.single.expandedBytes, 200),
    );
    final ratioOver = _zip(8, content: List<int>.filled(201, 65));
    final centralAt = ratioOver.length - 22 - _centralSize(ratioOver);
    ratioOver.setRange(18, 22, _u32(1));
    ratioOver.setRange(centralAt + 20, centralAt + 24, _u32(1));
    final over = File('${root.path}/ratio-over.zip')
      ..writeAsBytesSync(ratioOver);
    await _expectRejected(over, staging, 'ratio_limit');
  });

  test(
    'actual decoded output beyond declared size is bounded and cleaned',
    () async {
      final bytes = _zip(8, content: List<int>.filled(1024, 65));
      final centralAt = bytes.length - 22 - _centralSize(bytes);
      bytes.setRange(centralAt + 24, centralAt + 28, _u32(1));
      bytes.setRange(6 + 8 + 4, 6 + 8 + 4 + 4, _u32(1));
      final source = File('${root.path}/actual-over.zip')
        ..writeAsBytesSync(bytes);
      await expectLater(
        withValidatedZipEntries(source, staging, (_) async => fail('callback')),
        throwsA(isA<ValidatedZipException>()),
      );
      expect(await staging.list().toList(), isEmpty);
    },
  );

  test('accepts valid raw deflate entry', () async {
    final source = File('${root.path}/deflate.zip')..writeAsBytesSync(_zip(8));
    final result = await withValidatedZipEntries(
      source,
      staging,
      (entries) async => await entries.single.file.readAsString(),
    );
    expect(result, 'safe json');
    expect(await staging.list().toList(), isEmpty);
  });

  test('rejects corrupted deflate payload and removes staging', () async {
    final bytes = _zip(8);
    final centralAt = bytes.length - 22 - _centralSize(bytes);
    bytes[30 + utf8.encode('folder/data.json').length] ^= 0xff;
    final source = File('${root.path}/corrupt-deflate.zip')
      ..writeAsBytesSync(bytes);
    await expectLater(
      withValidatedZipEntries(source, staging, (_) async => fail('callback')),
      throwsA(isA<ValidatedZipException>()),
    );
    expect(await staging.list().toList(), isEmpty);
    expect(centralAt, greaterThan(0));
  });

  test(
    'rejects trailing gap, truncation, local metadata mismatch and unsafe name',
    () async {
      final valid = _zip(0);
      for (final bytes in [
        [...valid, 9],
        valid.sublist(0, valid.length - 5),
        _zip(0, wrongLocalCrc: true),
        _zip(0, name: '../bad.json'),
      ]) {
        final source = File('${root.path}/bad.zip')..writeAsBytesSync(bytes);
        await expectLater(
          withValidatedZipEntries(
            source,
            staging,
            (_) async => fail('callback'),
          ),
          throwsA(
            isA<ValidatedZipException>().having(
              (e) => e.code,
              'code',
              isNotEmpty,
            ),
          ),
        );
      }
    },
  );

  test(
    'rejects central local-offset and central CRC corruption distinctly',
    () async {
      final valid = _zip(0);
      final centralAt = valid.length - 22 - (_centralSize(valid));
      final badOffset = [...valid]
        ..setRange(centralAt + 42, centralAt + 46, _u32(1));
      final badCrc = [...valid]
        ..setRange(centralAt + 16, centralAt + 20, _u32(1));
      for (final bytes in [badOffset, badCrc]) {
        final source = File('${root.path}/corrupt.zip')
          ..writeAsBytesSync(bytes);
        await expectLater(
          withValidatedZipEntries(
            source,
            staging,
            (_) async => fail('callback'),
          ),
          throwsA(
            isA<ValidatedZipException>().having(
              (e) => e.code,
              'code',
              isNotEmpty,
            ),
          ),
        );
      }
    },
  );

  test('directory metadata validated but not staged', () async {
    final source = File('${root.path}/dir.zip')
      ..writeAsBytesSync(_zip(0, directory: true));
    final names = await withValidatedZipEntries(
      source,
      staging,
      (entries) async => entries.map((e) => e.name).toList(),
    );
    expect(names, isEmpty);
  });

  test('callback error preserved and private work directory removed', () async {
    final source = File('${root.path}/ok.zip')..writeAsBytesSync(_zip(0));
    final error = StateError('callback failed');
    await expectLater(
      withValidatedZipEntries(source, staging, (_) async => throw error),
      throwsA(same(error)),
    );
    expect(await staging.list().toList(), isEmpty);
  });
}

Future<void> _expectRejected(
  File source,
  Directory staging,
  String code,
) async {
  await expectLater(
    withValidatedZipEntries(
      source,
      staging,
      (_) async => fail('callback must not run'),
    ),
    throwsA(isA<ValidatedZipException>().having((e) => e.code, 'code', code)),
  );
  if (await staging.exists()) {
    expect(await staging.list().toList(), isEmpty);
  }
}

List<int> _zip(
  int method, {
  String name = 'folder/data.json',
  bool wrongLocalCrc = false,
  bool directory = false,
  List<int>? content,
}) {
  final rawName = utf8.encode(directory ? 'folder/' : name);
  final data = directory ? <int>[] : (content ?? utf8.encode('safe json'));
  final payload = method == 8 ? ZLibEncoder(raw: true).convert(data) : data;
  final crc = _crc(data);
  final localCrc = wrongLocalCrc ? crc ^ 1 : crc;
  final local = <int>[
    0x50,
    0x4b,
    0x03,
    0x04,
    ..._u16(20),
    ..._u16(0x0800),
    ..._u16(method),
    ..._u16(0),
    ..._u16(0),
    ..._u32(localCrc),
    ..._u32(payload.length),
    ..._u32(data.length),
    ..._u16(rawName.length),
    ..._u16(0),
    ...rawName,
    ...payload,
  ];
  final attrs = directory ? 0x41ed0000 : 0x81a40000;
  final central = <int>[
    0x50,
    0x4b,
    0x01,
    0x02,
    ..._u16(0x0314),
    ..._u16(20),
    ..._u16(0x0800),
    ..._u16(method),
    ..._u16(0),
    ..._u16(0),
    ..._u32(crc),
    ..._u32(payload.length),
    ..._u32(data.length),
    ..._u16(rawName.length),
    ..._u16(0),
    ..._u16(0),
    ..._u16(0),
    ..._u16(0),
    ..._u32(attrs),
    ..._u32(0),
    ...rawName,
  ];
  final eocd = <int>[
    0x50,
    0x4b,
    0x05,
    0x06,
    ..._u16(0),
    ..._u16(0),
    ..._u16(1),
    ..._u16(1),
    ..._u32(central.length),
    ..._u32(local.length),
    ..._u16(0),
  ];
  return [...local, ...central, ...eocd];
}

List<int> _multiZip(List<List<int>> contents) {
  final locals = <int>[];
  final centrals = <int>[];
  for (var i = 0; i < contents.length; i++) {
    final name = utf8.encode('entry_$i.json');
    final data = contents[i];
    final crc = _crc(data);
    final offset = locals.length;
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
      ..._u16(name.length),
      ..._u16(0),
      ...name,
      ...data,
    ]);
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
      ..._u16(name.length),
      ..._u16(0),
      ..._u16(0),
      ..._u16(0),
      ..._u16(0),
      ..._u32(0x81a40000),
      ..._u32(offset),
      ...name,
    ]);
  }
  final eocd = <int>[
    0x50,
    0x4b,
    0x05,
    0x06,
    ..._u16(0),
    ..._u16(0),
    ..._u16(contents.length),
    ..._u16(contents.length),
    ..._u32(centrals.length),
    ..._u32(locals.length),
    ..._u16(0),
  ];
  return [...locals, ...centrals, ...eocd];
}

void _setCentralSize(List<int> zip, {required int expanded}) {
  final centralAt = zip.length - 22 - _centralSize(zip);
  zip.setRange(centralAt + 24, centralAt + 28, _u32(expanded));
}

void _setDeclaredExpandedSizes(List<int> zip, List<int> sizes) {
  var localAt = 0;
  var centralAt = zip.length - 22 - _centralSize(zip);
  for (final size in sizes) {
    final localNameLength = zip[localAt + 26] | (zip[localAt + 27] << 8);
    final compressed = _readU32(zip, localAt + 18);
    zip.setRange(localAt + 22, localAt + 26, _u32(size));
    localAt += 30 + localNameLength + compressed;
    zip.setRange(centralAt + 24, centralAt + 28, _u32(size));
    final nameLength = zip[centralAt + 28] | (zip[centralAt + 29] << 8);
    centralAt += 46 + nameLength;
  }
}

int _readU32(List<int> bytes, int offset) =>
    bytes[offset] |
    (bytes[offset + 1] << 8) |
    (bytes[offset + 2] << 16) |
    (bytes[offset + 3] << 24);

List<int> _u16(int n) => [n & 255, (n >> 8) & 255];
List<int> _u32(int n) => [..._u16(n & 0xffff), ..._u16((n >> 16) & 0xffff)];
int _crc(List<int> bytes) {
  var crc = 0xffffffff;
  for (final b in bytes) {
    crc ^= b;
    for (var i = 0; i < 8; i++) {
      crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xedb88320 : crc >> 1;
    }
  }
  return (crc ^ 0xffffffff) & 0xffffffff;
}

int _centralSize(List<int> archive) {
  final eocd = archive.length - 22;
  return archive[eocd + 12] |
      (archive[eocd + 13] << 8) |
      (archive[eocd + 14] << 16) |
      (archive[eocd + 15] << 24);
}
