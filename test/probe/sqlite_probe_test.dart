import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/probe/sqlite_probe.dart';

void main() {
  late Directory directory;
  late SqliteProbe probe;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('kinship_sqlite_probe_');
    probe = SqliteProbe(databasePath: '${directory.path}/probe.db');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test(
    'writes batch, reopens file, rolls back invalid row, rejects future schema',
    () async {
      const rows = [
        ProbeObservation(
          id: 'synthetic-1',
          side: 'following',
          value: 'value-a',
        ),
        ProbeObservation(
          id: 'synthetic-2',
          side: 'followers',
          value: 'value-b',
        ),
      ];

      final result = await probe.run(sampleRows: rows);

      expect(result.initialRows, rows);
      expect(result.reopenedRows, rows);
      expect(result.rollbackPreservedRows, isTrue);
      expect(result.futureSchemaRejected, isTrue);
      expect(await File(result.databasePath).exists(), isTrue);
      await probe.deleteDatabase();
      expect(await File(result.databasePath).exists(), isFalse);
    },
  );

  test('rejects invalid input before creating database', () async {
    expect(
      () => probe.run(
        sampleRows: const [
          ProbeObservation(id: '', side: 'following', value: 'synthetic'),
        ],
      ),
      throwsArgumentError,
    );
    expect(await File(probe.databasePath).exists(), isFalse);
  });
}
