import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/data/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late Directory directory;

  setUp(() => directory = Directory.systemTemp.createTempSync('kinship-db-'));
  tearDown(() => directory.deleteSync(recursive: true));

  test('creates v1 tables and reopens intact', () async {
    final file = File('${directory.path}/history.sqlite');
    var db = AppDatabase.openFile(file);
    await db.customSelect('SELECT * FROM imports').get();
    await db.close();
    db = AppDatabase.openFile(file);
    final tableNames =
        (await db
                .customSelect(
                  "SELECT name FROM sqlite_master WHERE type='table'",
                )
                .get())
            .map((row) => row.read<String>('name'))
            .toSet();
    expect(
      tableNames,
      containsAll({
        'imports',
        'import_sides',
        'observed_accounts',
        'import_entries',
        'relationship_states',
        'relationship_changes',
        'import_warnings',
      }),
    );
    expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
    await db.close();
  });

  test('enforces foreign keys and checks', () async {
    final db = AppDatabase.openFile(
      File('${directory.path}/constraints.sqlite'),
    );
    await db.customStatement(
      "INSERT INTO imports (parser_version, digest) VALUES ('v1', 'd')",
    );
    await expectLater(
      db.customStatement(
        "INSERT INTO import_sides VALUES (1, 'wrong', 'complete', 's', 0, 0, 0)",
      ),
      throwsA(anything),
    );
    await expectLater(
      db.customStatement(
        "INSERT INTO import_sides VALUES (99, 'followers', 'complete', 's', 0, 0, 0)",
      ),
      throwsA(anything),
    );
    await db.customStatement(
      "INSERT INTO observed_accounts (canonical_username, first_display_username, first_seen_import_id) VALUES ('user', 'User', 1)",
    );
    await expectLater(
      db.customStatement(
        "INSERT INTO import_entries (import_id, side, account_id, display_username) VALUES (1, 'following', 1, 'User')",
      ),
      throwsA(anything),
    );
    await expectLater(
      db.customStatement(
        "INSERT INTO relationship_changes (import_id, side, account_id, kind) VALUES (1, 'following', 1, 'first_observed')",
      ),
      throwsA(anything),
    );
    await db.close();
  });

  test('permits repeated digest and expected relationship event kinds', () async {
    final db = AppDatabase.openFile(File('${directory.path}/events.sqlite'));
    for (var i = 0; i < 3; i++) {
      await db.customStatement(
        "INSERT INTO imports (parser_version, digest) VALUES ('v1', 'same')",
      );
    }
    await db.customStatement(
      "INSERT INTO observed_accounts (canonical_username, first_display_username, first_seen_import_id) VALUES ('user', 'User', 1)",
    );
    for (var importId = 1; importId <= 3; importId++) {
      await db.customStatement(
        "INSERT INTO import_sides VALUES ($importId, 'followers', 'complete', 's', 0, 0, 0)",
      );
    }
    for (final kind in [
      'first_observed',
      'returned_after_absence',
      'absence_first_detected',
    ]) {
      final importId = switch (kind) {
        'first_observed' => 1,
        'returned_after_absence' => 2,
        _ => 3,
      };
      await db.customStatement(
        "INSERT INTO relationship_changes (import_id, side, account_id, kind) VALUES ($importId, 'followers', 1, '$kind')",
      );
    }
    final count = await db
        .customSelect(
          'SELECT COUNT(*) AS n FROM imports WHERE digest = \'same\'',
        )
        .getSingle();
    expect(count.read<int>('n'), 3);
    await db.close();
  });

  test('stores source timestamp zero with export row kind', () async {
    final db = AppDatabase.openFile(
      File('${directory.path}/timestamps.sqlite'),
    );
    await db.customStatement(
      "INSERT INTO imports (parser_version, digest) VALUES ('v1', 'd')",
    );
    await db.customStatement(
      "INSERT INTO import_sides VALUES (1, 'followers', 'complete', 's', 1, 0, 0)",
    );
    await db.customStatement(
      "INSERT INTO observed_accounts (canonical_username, first_display_username, first_seen_import_id) VALUES ('user', 'User', 1)",
    );
    await db.customStatement(
      "INSERT INTO import_entries (import_id, side, account_id, display_username, source_timestamp_seconds, timestamp_kind) VALUES (1, 'followers', 1, 'User', 0, 'export_row')",
    );
    final row = await db
        .customSelect(
          'SELECT source_timestamp_seconds, timestamp_kind FROM import_entries',
        )
        .getSingle();
    expect(row.read<int>('source_timestamp_seconds'), 0);
    expect(row.read<String>('timestamp_kind'), 'export_row');
    await db.close();
  });

  test('rejects future schema without changing it', () async {
    final file = File('${directory.path}/future.sqlite');
    final raw = sqlite3.open(file.path);
    raw.execute('PRAGMA user_version = 9');
    raw.execute('CREATE TABLE keep_me (value INTEGER)');
    raw.close();
    expect(() => AppDatabase.openFile(file), throwsA(anything));
    final reopened = sqlite3.open(file.path);
    expect(reopened.select('PRAGMA user_version').first.values.first, 9);
    expect(
      reopened.select("SELECT name FROM sqlite_master WHERE name='keep_me'"),
      isNotEmpty,
    );
    reopened.close();
  });

  test('rejects nonempty unknown version zero', () async {
    final file = File('${directory.path}/unknown.sqlite');
    final raw = sqlite3.open(file.path);
    raw.execute('CREATE TABLE unknown_table (value INTEGER)');
    raw.close();
    expect(() => AppDatabase.openFile(file), throwsA(anything));
  });
}
