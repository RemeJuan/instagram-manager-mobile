import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/features/spike/parse_adapter.dart';
import 'package:kinship_mobile/features/spike/spike_screen.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('spike-parser-test-');
  });
  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  Future<String> writeInput(
    List<int> bytes, {
    String fileName = 'input',
  }) async {
    final file = File('${root.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  test(
    'parses standalone followers JSON and leaves missing sides unknown',
    () async {
      final path = await writeInput(
        '{"followers":[{"string_list_data":[{"value":"sample_user"}]}]}'
            .codeUnits,
      );

      final result = await parseSpikeInput(path);

      expect(result.followers, 1);
      expect(result.following, isNull);
      expect(result.mutual, isNull);
      expect(result.followingOnly, isNull);
      expect(result.followerOnly, isNull);
    },
  );

  test('malformed JSON fails with safe input error', () async {
    final path = await writeInput('{malformed}'.codeUnits);

    await expectLater(
      parseSpikeInput(path),
      throwsA(
        isA<SpikeInputException>().having(
          (error) => error.message,
          'message',
          'Invalid relationship JSON. No results were saved.',
        ),
      ),
    );
  });

  test(
    'rejects malformed ZIP signature regardless of filename extension',
    () async {
      final path = await writeInput([
        0x50,
        0x4b,
        0x03,
        0x04,
        0x00,
        0x00,
      ], fileName: 'input.json');

      await expectLater(
        parseSpikeInput(path),
        throwsA(
          isA<SpikeInputException>().having(
            (error) => error.message,
            'message',
            'Unable to validate this ZIP export. No results were saved.',
          ),
        ),
      );
    },
  );

  test('parses baseline ZIP with both complete sides', () async {
    final fixture = File('fixtures/baseline.zip');
    final path = await writeInput(
      await fixture.readAsBytes(),
      fileName: 'baseline.zip',
    );

    final result = await parseSpikeInput(path);

    expect(result.following, 810);
    expect(result.followers, 783);
    expect(result.mutual, 747);
    expect(result.followingOnly, 63);
    expect(result.followerOnly, 36);
    expect(
      result.warnings,
      contains(contains('assume the selected export is complete')),
    );
  });

  test('rejects structurally malformed recognized JSON entry in ZIP', () async {
    final path = await writeInput(
      await File('fixtures/malformedRelationship.zip').readAsBytes(),
      fileName: 'malformed.zip',
    );

    await expectLater(
      parseSpikeInput(path),
      throwsA(
        isA<SpikeInputException>().having(
          (error) => error.message,
          'message',
          'Invalid relationship JSON. No results were saved.',
        ),
      ),
    );
  });

  test('skips unrelated valid JSON entry in ZIP', () async {
    final path = await writeInput(
      await File('fixtures/unrelatedJson.zip').readAsBytes(),
      fileName: 'unrelated.zip',
    );

    final result = await parseSpikeInput(path);

    expect(result.following, 1);
    expect(result.followers, isNull);
  });
}
