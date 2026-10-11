import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

part 'app_database.g.dart';

class Imports extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get parserVersion => text()();
  TextColumn get digest => text()();
  DateTimeColumn get importedAt => dateTime().nullable()();

  List<Index> get indexes => [Index('imports_digest_idx', 'digest')];
}

class ImportSides extends Table {
  IntColumn get importId => integer().references(Imports, #id)();
  TextColumn get side => text()();
  TextColumn get coverage => text()();
  TextColumn get sideDigest => text()();
  IntColumn get rowCount => integer()();
  IntColumn get invalidCount => integer()();
  IntColumn get duplicateCount => integer()();

  @override
  Set<Column> get primaryKey => {importId, side};

  @override
  List<String> get customConstraints => [
    "CHECK (side IN ('followers', 'following'))",
    "CHECK (coverage IN ('complete', 'partial'))",
    'CHECK (row_count >= 0 AND invalid_count >= 0 AND duplicate_count >= 0)',
  ];
}

class ObservedAccounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get canonicalUsername => text().unique()();
  TextColumn get firstDisplayUsername => text()();
  IntColumn get firstSeenImportId => integer().references(Imports, #id)();
}

class ImportEntries extends Table {
  IntColumn get importId => integer()();
  TextColumn get side => text()();
  IntColumn get accountId => integer().references(ObservedAccounts, #id)();
  TextColumn get displayUsername => text()();
  IntColumn get sourceTimestampSeconds => integer().nullable()();
  TextColumn get timestampKind => text().nullable()();

  @override
  Set<Column> get primaryKey => {importId, side, accountId};

  @override
  List<String> get customConstraints => [
    "CHECK (side IN ('followers', 'following'))",
    'FOREIGN KEY (import_id, side) REFERENCES import_sides (import_id, side) ON DELETE CASCADE',
    "CHECK ((source_timestamp_seconds IS NULL AND timestamp_kind IS NULL) OR (source_timestamp_seconds IS NOT NULL AND timestamp_kind = 'export_row'))",
  ];

  List<Index> get indexes => [
    Index('import_entries_side_account_idx', 'side, account_id'),
  ];
}

class RelationshipStates extends Table {
  IntColumn get accountId => integer().references(ObservedAccounts, #id)();
  TextColumn get side => text()();
  TextColumn get status => text()();
  IntColumn get firstPositiveImportId =>
      integer().nullable().references(Imports, #id)();
  IntColumn get lastPositiveImportId =>
      integer().nullable().references(Imports, #id)();
  IntColumn get firstCompleteAbsenceImportId =>
      integer().nullable().references(Imports, #id)();
  IntColumn get latestCompleteAbsenceImportId =>
      integer().nullable().references(Imports, #id)();

  @override
  Set<Column> get primaryKey => {accountId, side};

  @override
  List<String> get customConstraints => [
    "CHECK (side IN ('followers', 'following'))",
    "CHECK (status IN ('present', 'absent'))",
  ];
}

class RelationshipChanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get importId => integer().references(Imports, #id)();
  TextColumn get side => text()();
  IntColumn get accountId => integer().references(ObservedAccounts, #id)();
  TextColumn get kind => text()();
  IntColumn get priorEvidenceImportId =>
      integer().nullable().references(Imports, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {importId, side, accountId},
  ];

  @override
  List<String> get customConstraints => [
    "CHECK (side IN ('followers', 'following'))",
    "CHECK (kind IN ('first_observed', 'returned_after_absence', 'absence_first_detected'))",
    'FOREIGN KEY (import_id, side) REFERENCES import_sides (import_id, side) ON DELETE CASCADE',
  ];
}

class ImportWarnings extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get importId => integer().references(Imports, #id)();
  TextColumn get side => text().nullable()();
  TextColumn get code => text()();
  IntColumn get count => integer()();

  @override
  List<String> get customConstraints => [
    "CHECK (side IS NULL OR side IN ('followers', 'following'))",
    'CHECK (count >= 0)',
  ];
}

@DriftDatabase(
  tables: [
    Imports,
    ImportSides,
    ObservedAccounts,
    ImportEntries,
    RelationshipStates,
    RelationshipChanges,
    ImportWarnings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  static AppDatabase openFile(File file) => AppDatabase(_openDatabase(file));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await transaction(() async {
        await m.createAll();
        await customStatement('PRAGMA user_version = 1');
      });
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement(
        'CREATE INDEX IF NOT EXISTS import_entries_account_idx ON import_entries (account_id, side)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS relationship_changes_history_idx ON relationship_changes (account_id, side, import_id)',
      );
    },
  );
}

QueryExecutor _openDatabase(File file) {
  final raw = sqlite.sqlite3.open(file.path);
  try {
    raw.execute('PRAGMA foreign_keys = ON');
    final version = raw.select('PRAGMA user_version').first.values.first as int;
    if (version > 1) throw StateError('Unsupported database version: $version');
    if (version == 0) {
      final tables = raw.select(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      if (tables.isNotEmpty) {
        throw StateError(
          'Refusing nonempty database with unknown schema version 0',
        );
      }
    }
  } finally {
    raw.close();
  }
  return NativeDatabase.createInBackground(
    file,
    setup: (db) {
      db.execute('PRAGMA foreign_keys = ON');
    },
  );
}
