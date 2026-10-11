import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

/// Synthetic record used by the disposable Phase 0 SQLite probe.
class ProbeObservation {
  const ProbeObservation({
    required this.id,
    required this.side,
    required this.value,
  });

  final String id;
  final String side;
  final String value;

  @override
  bool operator ==(Object other) =>
      other is ProbeObservation &&
      id == other.id &&
      side == other.side &&
      value == other.value;

  @override
  int get hashCode => Object.hash(id, side, value);
}

/// Results from a complete create/write/read/close/reopen probe run.
class SqliteProbeResult {
  const SqliteProbeResult({
    required this.initialRows,
    required this.reopenedRows,
    required this.rollbackPreservedRows,
    required this.futureSchemaRejected,
    required this.databasePath,
  });

  final List<ProbeObservation> initialRows;
  final List<ProbeObservation> reopenedRows;
  final bool rollbackPreservedRows;
  final bool futureSchemaRejected;
  final String databasePath;
}

/// Runs a disposable, file-backed SQLite probe in the app documents directory.
/// Caller owns cleanup: [SqliteProbe.deleteDatabase] removes its database file.
class SqliteProbe {
  SqliteProbe({required this.databasePath});

  final String databasePath;

  static Future<SqliteProbe> inApplicationDocuments() async {
    final directory = await getApplicationDocumentsDirectory();
    return SqliteProbe(
      databasePath: '${directory.path}/kinship_sqlite_probe.db',
    );
  }

  /// Exercises persistence and rollback with synthetic rows, then closes the
  /// connection. Never logs the row contents.
  Future<SqliteProbeResult> run({
    required List<ProbeObservation> sampleRows,
  }) async {
    _validateRows(sampleRows);
    final file = File(databasePath);
    await file.parent.create(recursive: true);
    if (await file.exists()) await file.delete();

    var db = sqlite3.open(databasePath);
    try {
      _createSchema(db);
      _insertBatch(db, sampleRows);
      final initial = _readRows(db);

      var rollbackObserved = false;
      try {
        db.execute('BEGIN');
        final insert = db.prepare(
          'INSERT INTO observations (id, side, value) VALUES (?, ?, ?)',
        );
        try {
          for (final row in sampleRows) {
            insert.execute([row.id, row.side, row.value]);
          }
          // Deliberately violate NOT NULL to prove the transaction rolls back.
          db.execute(
            'INSERT INTO observations (id, side, value) VALUES (?, ?, NULL)',
            ['invalid-probe-row', 'following'],
          );
          db.execute('COMMIT');
        } finally {
          insert.close();
        }
      } on SqliteException {
        if (db.autocommit) rethrow;
        db.execute('ROLLBACK');
        rollbackObserved = true;
      }
      final afterRollback = _readRows(db);
      rollbackObserved = rollbackObserved && _sameRows(initial, afterRollback);
      db.close();

      db = sqlite3.open(databasePath);
      final reopened = _readRows(db);
      var futureSchemaRejected = false;
      db.execute('PRAGMA user_version = 2147483647');
      db.close();

      try {
        _openSupportedDatabase(databasePath);
      } on UnsupportedError {
        futureSchemaRejected = true;
      }

      return SqliteProbeResult(
        initialRows: initial,
        reopenedRows: reopened,
        rollbackPreservedRows: rollbackObserved,
        futureSchemaRejected: futureSchemaRejected,
        databasePath: databasePath,
      );
    } finally {
      // Ensure open handle is closed if an earlier probe assertion fails.
      try {
        db.close();
      } on Object {
        // Already closed before reopen/future-version verification.
      }
    }
  }

  Future<void> deleteDatabase() async {
    final file = File(databasePath);
    if (await file.exists()) await file.delete();
  }

  static void _createSchema(Database db) {
    db.execute('''
      CREATE TABLE observations (
        id TEXT PRIMARY KEY NOT NULL,
        side TEXT NOT NULL CHECK (side IN ('following', 'followers')),
        value TEXT NOT NULL
      )
    ''');
    db.execute('PRAGMA user_version = 1');
  }

  static void _insertBatch(Database db, List<ProbeObservation> rows) {
    db.execute('BEGIN');
    final insert = db.prepare(
      'INSERT INTO observations (id, side, value) VALUES (?, ?, ?)',
    );
    try {
      for (final row in rows) {
        insert.execute([row.id, row.side, row.value]);
      }
      db.execute('COMMIT');
    } on Object {
      if (!db.autocommit) db.execute('ROLLBACK');
      rethrow;
    } finally {
      insert.close();
    }
  }

  static List<ProbeObservation> _readRows(Database db) => db
      .select('SELECT id, side, value FROM observations ORDER BY id')
      .map(
        (row) => ProbeObservation(
          id: row['id'] as String,
          side: row['side'] as String,
          value: row['value'] as String,
        ),
      )
      .toList(growable: false);

  static void _validateRows(List<ProbeObservation> rows) {
    final identifiers = <String>{};
    for (final row in rows) {
      if (row.id.trim().isEmpty ||
          row.value.trim().isEmpty ||
          !{'following', 'followers'}.contains(row.side) ||
          !identifiers.add(row.id)) {
        throw ArgumentError('Invalid synthetic probe rows');
      }
    }
  }

  static bool _sameRows(
    List<ProbeObservation> left,
    List<ProbeObservation> right,
  ) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }

  static Database _openSupportedDatabase(String path) {
    final db = sqlite3.open(path);
    final version =
        db.select('PRAGMA user_version').single['user_version'] as int;
    if (version > 1) {
      db.close();
      throw UnsupportedError('Database schema version is unsupported');
    }
    return db;
  }
}
