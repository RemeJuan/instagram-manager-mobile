// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ImportsTable extends Imports with TableInfo<$ImportsTable, Import> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _parserVersionMeta = const VerificationMeta(
    'parserVersion',
  );
  @override
  late final GeneratedColumn<String> parserVersion = GeneratedColumn<String>(
    'parser_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _digestMeta = const VerificationMeta('digest');
  @override
  late final GeneratedColumn<String> digest = GeneratedColumn<String>(
    'digest',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, parserVersion, digest, importedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'imports';
  @override
  VerificationContext validateIntegrity(
    Insertable<Import> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('parser_version')) {
      context.handle(
        _parserVersionMeta,
        parserVersion.isAcceptableOrUnknown(
          data['parser_version']!,
          _parserVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_parserVersionMeta);
    }
    if (data.containsKey('digest')) {
      context.handle(
        _digestMeta,
        digest.isAcceptableOrUnknown(data['digest']!, _digestMeta),
      );
    } else if (isInserting) {
      context.missing(_digestMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Import map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Import(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      parserVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parser_version'],
      )!,
      digest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}digest'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      ),
    );
  }

  @override
  $ImportsTable createAlias(String alias) {
    return $ImportsTable(attachedDatabase, alias);
  }
}

class Import extends DataClass implements Insertable<Import> {
  final int id;
  final String parserVersion;
  final String digest;
  final DateTime? importedAt;
  const Import({
    required this.id,
    required this.parserVersion,
    required this.digest,
    this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['parser_version'] = Variable<String>(parserVersion);
    map['digest'] = Variable<String>(digest);
    if (!nullToAbsent || importedAt != null) {
      map['imported_at'] = Variable<DateTime>(importedAt);
    }
    return map;
  }

  ImportsCompanion toCompanion(bool nullToAbsent) {
    return ImportsCompanion(
      id: Value(id),
      parserVersion: Value(parserVersion),
      digest: Value(digest),
      importedAt: importedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(importedAt),
    );
  }

  factory Import.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Import(
      id: serializer.fromJson<int>(json['id']),
      parserVersion: serializer.fromJson<String>(json['parserVersion']),
      digest: serializer.fromJson<String>(json['digest']),
      importedAt: serializer.fromJson<DateTime?>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'parserVersion': serializer.toJson<String>(parserVersion),
      'digest': serializer.toJson<String>(digest),
      'importedAt': serializer.toJson<DateTime?>(importedAt),
    };
  }

  Import copyWith({
    int? id,
    String? parserVersion,
    String? digest,
    Value<DateTime?> importedAt = const Value.absent(),
  }) => Import(
    id: id ?? this.id,
    parserVersion: parserVersion ?? this.parserVersion,
    digest: digest ?? this.digest,
    importedAt: importedAt.present ? importedAt.value : this.importedAt,
  );
  Import copyWithCompanion(ImportsCompanion data) {
    return Import(
      id: data.id.present ? data.id.value : this.id,
      parserVersion: data.parserVersion.present
          ? data.parserVersion.value
          : this.parserVersion,
      digest: data.digest.present ? data.digest.value : this.digest,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Import(')
          ..write('id: $id, ')
          ..write('parserVersion: $parserVersion, ')
          ..write('digest: $digest, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, parserVersion, digest, importedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Import &&
          other.id == this.id &&
          other.parserVersion == this.parserVersion &&
          other.digest == this.digest &&
          other.importedAt == this.importedAt);
}

class ImportsCompanion extends UpdateCompanion<Import> {
  final Value<int> id;
  final Value<String> parserVersion;
  final Value<String> digest;
  final Value<DateTime?> importedAt;
  const ImportsCompanion({
    this.id = const Value.absent(),
    this.parserVersion = const Value.absent(),
    this.digest = const Value.absent(),
    this.importedAt = const Value.absent(),
  });
  ImportsCompanion.insert({
    this.id = const Value.absent(),
    required String parserVersion,
    required String digest,
    this.importedAt = const Value.absent(),
  }) : parserVersion = Value(parserVersion),
       digest = Value(digest);
  static Insertable<Import> custom({
    Expression<int>? id,
    Expression<String>? parserVersion,
    Expression<String>? digest,
    Expression<DateTime>? importedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parserVersion != null) 'parser_version': parserVersion,
      if (digest != null) 'digest': digest,
      if (importedAt != null) 'imported_at': importedAt,
    });
  }

  ImportsCompanion copyWith({
    Value<int>? id,
    Value<String>? parserVersion,
    Value<String>? digest,
    Value<DateTime?>? importedAt,
  }) {
    return ImportsCompanion(
      id: id ?? this.id,
      parserVersion: parserVersion ?? this.parserVersion,
      digest: digest ?? this.digest,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (parserVersion.present) {
      map['parser_version'] = Variable<String>(parserVersion.value);
    }
    if (digest.present) {
      map['digest'] = Variable<String>(digest.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportsCompanion(')
          ..write('id: $id, ')
          ..write('parserVersion: $parserVersion, ')
          ..write('digest: $digest, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }
}

class $ImportSidesTable extends ImportSides
    with TableInfo<$ImportSidesTable, ImportSide> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportSidesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<int> importId = GeneratedColumn<int>(
    'import_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverageMeta = const VerificationMeta(
    'coverage',
  );
  @override
  late final GeneratedColumn<String> coverage = GeneratedColumn<String>(
    'coverage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideDigestMeta = const VerificationMeta(
    'sideDigest',
  );
  @override
  late final GeneratedColumn<String> sideDigest = GeneratedColumn<String>(
    'side_digest',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowCountMeta = const VerificationMeta(
    'rowCount',
  );
  @override
  late final GeneratedColumn<int> rowCount = GeneratedColumn<int>(
    'row_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invalidCountMeta = const VerificationMeta(
    'invalidCount',
  );
  @override
  late final GeneratedColumn<int> invalidCount = GeneratedColumn<int>(
    'invalid_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _duplicateCountMeta = const VerificationMeta(
    'duplicateCount',
  );
  @override
  late final GeneratedColumn<int> duplicateCount = GeneratedColumn<int>(
    'duplicate_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    importId,
    side,
    coverage,
    sideDigest,
    rowCount,
    invalidCount,
    duplicateCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_sides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportSide> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    } else if (isInserting) {
      context.missing(_importIdMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('coverage')) {
      context.handle(
        _coverageMeta,
        coverage.isAcceptableOrUnknown(data['coverage']!, _coverageMeta),
      );
    } else if (isInserting) {
      context.missing(_coverageMeta);
    }
    if (data.containsKey('side_digest')) {
      context.handle(
        _sideDigestMeta,
        sideDigest.isAcceptableOrUnknown(data['side_digest']!, _sideDigestMeta),
      );
    } else if (isInserting) {
      context.missing(_sideDigestMeta);
    }
    if (data.containsKey('row_count')) {
      context.handle(
        _rowCountMeta,
        rowCount.isAcceptableOrUnknown(data['row_count']!, _rowCountMeta),
      );
    } else if (isInserting) {
      context.missing(_rowCountMeta);
    }
    if (data.containsKey('invalid_count')) {
      context.handle(
        _invalidCountMeta,
        invalidCount.isAcceptableOrUnknown(
          data['invalid_count']!,
          _invalidCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invalidCountMeta);
    }
    if (data.containsKey('duplicate_count')) {
      context.handle(
        _duplicateCountMeta,
        duplicateCount.isAcceptableOrUnknown(
          data['duplicate_count']!,
          _duplicateCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_duplicateCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {importId, side};
  @override
  ImportSide map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportSide(
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_id'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      coverage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coverage'],
      )!,
      sideDigest: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side_digest'],
      )!,
      rowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_count'],
      )!,
      invalidCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invalid_count'],
      )!,
      duplicateCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duplicate_count'],
      )!,
    );
  }

  @override
  $ImportSidesTable createAlias(String alias) {
    return $ImportSidesTable(attachedDatabase, alias);
  }
}

class ImportSide extends DataClass implements Insertable<ImportSide> {
  final int importId;
  final String side;
  final String coverage;
  final String sideDigest;
  final int rowCount;
  final int invalidCount;
  final int duplicateCount;
  const ImportSide({
    required this.importId,
    required this.side,
    required this.coverage,
    required this.sideDigest,
    required this.rowCount,
    required this.invalidCount,
    required this.duplicateCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['import_id'] = Variable<int>(importId);
    map['side'] = Variable<String>(side);
    map['coverage'] = Variable<String>(coverage);
    map['side_digest'] = Variable<String>(sideDigest);
    map['row_count'] = Variable<int>(rowCount);
    map['invalid_count'] = Variable<int>(invalidCount);
    map['duplicate_count'] = Variable<int>(duplicateCount);
    return map;
  }

  ImportSidesCompanion toCompanion(bool nullToAbsent) {
    return ImportSidesCompanion(
      importId: Value(importId),
      side: Value(side),
      coverage: Value(coverage),
      sideDigest: Value(sideDigest),
      rowCount: Value(rowCount),
      invalidCount: Value(invalidCount),
      duplicateCount: Value(duplicateCount),
    );
  }

  factory ImportSide.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportSide(
      importId: serializer.fromJson<int>(json['importId']),
      side: serializer.fromJson<String>(json['side']),
      coverage: serializer.fromJson<String>(json['coverage']),
      sideDigest: serializer.fromJson<String>(json['sideDigest']),
      rowCount: serializer.fromJson<int>(json['rowCount']),
      invalidCount: serializer.fromJson<int>(json['invalidCount']),
      duplicateCount: serializer.fromJson<int>(json['duplicateCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'importId': serializer.toJson<int>(importId),
      'side': serializer.toJson<String>(side),
      'coverage': serializer.toJson<String>(coverage),
      'sideDigest': serializer.toJson<String>(sideDigest),
      'rowCount': serializer.toJson<int>(rowCount),
      'invalidCount': serializer.toJson<int>(invalidCount),
      'duplicateCount': serializer.toJson<int>(duplicateCount),
    };
  }

  ImportSide copyWith({
    int? importId,
    String? side,
    String? coverage,
    String? sideDigest,
    int? rowCount,
    int? invalidCount,
    int? duplicateCount,
  }) => ImportSide(
    importId: importId ?? this.importId,
    side: side ?? this.side,
    coverage: coverage ?? this.coverage,
    sideDigest: sideDigest ?? this.sideDigest,
    rowCount: rowCount ?? this.rowCount,
    invalidCount: invalidCount ?? this.invalidCount,
    duplicateCount: duplicateCount ?? this.duplicateCount,
  );
  ImportSide copyWithCompanion(ImportSidesCompanion data) {
    return ImportSide(
      importId: data.importId.present ? data.importId.value : this.importId,
      side: data.side.present ? data.side.value : this.side,
      coverage: data.coverage.present ? data.coverage.value : this.coverage,
      sideDigest: data.sideDigest.present
          ? data.sideDigest.value
          : this.sideDigest,
      rowCount: data.rowCount.present ? data.rowCount.value : this.rowCount,
      invalidCount: data.invalidCount.present
          ? data.invalidCount.value
          : this.invalidCount,
      duplicateCount: data.duplicateCount.present
          ? data.duplicateCount.value
          : this.duplicateCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportSide(')
          ..write('importId: $importId, ')
          ..write('side: $side, ')
          ..write('coverage: $coverage, ')
          ..write('sideDigest: $sideDigest, ')
          ..write('rowCount: $rowCount, ')
          ..write('invalidCount: $invalidCount, ')
          ..write('duplicateCount: $duplicateCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    importId,
    side,
    coverage,
    sideDigest,
    rowCount,
    invalidCount,
    duplicateCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportSide &&
          other.importId == this.importId &&
          other.side == this.side &&
          other.coverage == this.coverage &&
          other.sideDigest == this.sideDigest &&
          other.rowCount == this.rowCount &&
          other.invalidCount == this.invalidCount &&
          other.duplicateCount == this.duplicateCount);
}

class ImportSidesCompanion extends UpdateCompanion<ImportSide> {
  final Value<int> importId;
  final Value<String> side;
  final Value<String> coverage;
  final Value<String> sideDigest;
  final Value<int> rowCount;
  final Value<int> invalidCount;
  final Value<int> duplicateCount;
  final Value<int> rowid;
  const ImportSidesCompanion({
    this.importId = const Value.absent(),
    this.side = const Value.absent(),
    this.coverage = const Value.absent(),
    this.sideDigest = const Value.absent(),
    this.rowCount = const Value.absent(),
    this.invalidCount = const Value.absent(),
    this.duplicateCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportSidesCompanion.insert({
    required int importId,
    required String side,
    required String coverage,
    required String sideDigest,
    required int rowCount,
    required int invalidCount,
    required int duplicateCount,
    this.rowid = const Value.absent(),
  }) : importId = Value(importId),
       side = Value(side),
       coverage = Value(coverage),
       sideDigest = Value(sideDigest),
       rowCount = Value(rowCount),
       invalidCount = Value(invalidCount),
       duplicateCount = Value(duplicateCount);
  static Insertable<ImportSide> custom({
    Expression<int>? importId,
    Expression<String>? side,
    Expression<String>? coverage,
    Expression<String>? sideDigest,
    Expression<int>? rowCount,
    Expression<int>? invalidCount,
    Expression<int>? duplicateCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (importId != null) 'import_id': importId,
      if (side != null) 'side': side,
      if (coverage != null) 'coverage': coverage,
      if (sideDigest != null) 'side_digest': sideDigest,
      if (rowCount != null) 'row_count': rowCount,
      if (invalidCount != null) 'invalid_count': invalidCount,
      if (duplicateCount != null) 'duplicate_count': duplicateCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportSidesCompanion copyWith({
    Value<int>? importId,
    Value<String>? side,
    Value<String>? coverage,
    Value<String>? sideDigest,
    Value<int>? rowCount,
    Value<int>? invalidCount,
    Value<int>? duplicateCount,
    Value<int>? rowid,
  }) {
    return ImportSidesCompanion(
      importId: importId ?? this.importId,
      side: side ?? this.side,
      coverage: coverage ?? this.coverage,
      sideDigest: sideDigest ?? this.sideDigest,
      rowCount: rowCount ?? this.rowCount,
      invalidCount: invalidCount ?? this.invalidCount,
      duplicateCount: duplicateCount ?? this.duplicateCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (importId.present) {
      map['import_id'] = Variable<int>(importId.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (coverage.present) {
      map['coverage'] = Variable<String>(coverage.value);
    }
    if (sideDigest.present) {
      map['side_digest'] = Variable<String>(sideDigest.value);
    }
    if (rowCount.present) {
      map['row_count'] = Variable<int>(rowCount.value);
    }
    if (invalidCount.present) {
      map['invalid_count'] = Variable<int>(invalidCount.value);
    }
    if (duplicateCount.present) {
      map['duplicate_count'] = Variable<int>(duplicateCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportSidesCompanion(')
          ..write('importId: $importId, ')
          ..write('side: $side, ')
          ..write('coverage: $coverage, ')
          ..write('sideDigest: $sideDigest, ')
          ..write('rowCount: $rowCount, ')
          ..write('invalidCount: $invalidCount, ')
          ..write('duplicateCount: $duplicateCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObservedAccountsTable extends ObservedAccounts
    with TableInfo<$ObservedAccountsTable, ObservedAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObservedAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _canonicalUsernameMeta = const VerificationMeta(
    'canonicalUsername',
  );
  @override
  late final GeneratedColumn<String> canonicalUsername =
      GeneratedColumn<String>(
        'canonical_username',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
      );
  static const VerificationMeta _firstDisplayUsernameMeta =
      const VerificationMeta('firstDisplayUsername');
  @override
  late final GeneratedColumn<String> firstDisplayUsername =
      GeneratedColumn<String>(
        'first_display_username',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _firstSeenImportIdMeta = const VerificationMeta(
    'firstSeenImportId',
  );
  @override
  late final GeneratedColumn<int> firstSeenImportId = GeneratedColumn<int>(
    'first_seen_import_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    canonicalUsername,
    firstDisplayUsername,
    firstSeenImportId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'observed_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObservedAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('canonical_username')) {
      context.handle(
        _canonicalUsernameMeta,
        canonicalUsername.isAcceptableOrUnknown(
          data['canonical_username']!,
          _canonicalUsernameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalUsernameMeta);
    }
    if (data.containsKey('first_display_username')) {
      context.handle(
        _firstDisplayUsernameMeta,
        firstDisplayUsername.isAcceptableOrUnknown(
          data['first_display_username']!,
          _firstDisplayUsernameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstDisplayUsernameMeta);
    }
    if (data.containsKey('first_seen_import_id')) {
      context.handle(
        _firstSeenImportIdMeta,
        firstSeenImportId.isAcceptableOrUnknown(
          data['first_seen_import_id']!,
          _firstSeenImportIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenImportIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObservedAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObservedAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      canonicalUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_username'],
      )!,
      firstDisplayUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_display_username'],
      )!,
      firstSeenImportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen_import_id'],
      )!,
    );
  }

  @override
  $ObservedAccountsTable createAlias(String alias) {
    return $ObservedAccountsTable(attachedDatabase, alias);
  }
}

class ObservedAccount extends DataClass implements Insertable<ObservedAccount> {
  final int id;
  final String canonicalUsername;
  final String firstDisplayUsername;
  final int firstSeenImportId;
  const ObservedAccount({
    required this.id,
    required this.canonicalUsername,
    required this.firstDisplayUsername,
    required this.firstSeenImportId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['canonical_username'] = Variable<String>(canonicalUsername);
    map['first_display_username'] = Variable<String>(firstDisplayUsername);
    map['first_seen_import_id'] = Variable<int>(firstSeenImportId);
    return map;
  }

  ObservedAccountsCompanion toCompanion(bool nullToAbsent) {
    return ObservedAccountsCompanion(
      id: Value(id),
      canonicalUsername: Value(canonicalUsername),
      firstDisplayUsername: Value(firstDisplayUsername),
      firstSeenImportId: Value(firstSeenImportId),
    );
  }

  factory ObservedAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObservedAccount(
      id: serializer.fromJson<int>(json['id']),
      canonicalUsername: serializer.fromJson<String>(json['canonicalUsername']),
      firstDisplayUsername: serializer.fromJson<String>(
        json['firstDisplayUsername'],
      ),
      firstSeenImportId: serializer.fromJson<int>(json['firstSeenImportId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'canonicalUsername': serializer.toJson<String>(canonicalUsername),
      'firstDisplayUsername': serializer.toJson<String>(firstDisplayUsername),
      'firstSeenImportId': serializer.toJson<int>(firstSeenImportId),
    };
  }

  ObservedAccount copyWith({
    int? id,
    String? canonicalUsername,
    String? firstDisplayUsername,
    int? firstSeenImportId,
  }) => ObservedAccount(
    id: id ?? this.id,
    canonicalUsername: canonicalUsername ?? this.canonicalUsername,
    firstDisplayUsername: firstDisplayUsername ?? this.firstDisplayUsername,
    firstSeenImportId: firstSeenImportId ?? this.firstSeenImportId,
  );
  ObservedAccount copyWithCompanion(ObservedAccountsCompanion data) {
    return ObservedAccount(
      id: data.id.present ? data.id.value : this.id,
      canonicalUsername: data.canonicalUsername.present
          ? data.canonicalUsername.value
          : this.canonicalUsername,
      firstDisplayUsername: data.firstDisplayUsername.present
          ? data.firstDisplayUsername.value
          : this.firstDisplayUsername,
      firstSeenImportId: data.firstSeenImportId.present
          ? data.firstSeenImportId.value
          : this.firstSeenImportId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObservedAccount(')
          ..write('id: $id, ')
          ..write('canonicalUsername: $canonicalUsername, ')
          ..write('firstDisplayUsername: $firstDisplayUsername, ')
          ..write('firstSeenImportId: $firstSeenImportId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    canonicalUsername,
    firstDisplayUsername,
    firstSeenImportId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObservedAccount &&
          other.id == this.id &&
          other.canonicalUsername == this.canonicalUsername &&
          other.firstDisplayUsername == this.firstDisplayUsername &&
          other.firstSeenImportId == this.firstSeenImportId);
}

class ObservedAccountsCompanion extends UpdateCompanion<ObservedAccount> {
  final Value<int> id;
  final Value<String> canonicalUsername;
  final Value<String> firstDisplayUsername;
  final Value<int> firstSeenImportId;
  const ObservedAccountsCompanion({
    this.id = const Value.absent(),
    this.canonicalUsername = const Value.absent(),
    this.firstDisplayUsername = const Value.absent(),
    this.firstSeenImportId = const Value.absent(),
  });
  ObservedAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String canonicalUsername,
    required String firstDisplayUsername,
    required int firstSeenImportId,
  }) : canonicalUsername = Value(canonicalUsername),
       firstDisplayUsername = Value(firstDisplayUsername),
       firstSeenImportId = Value(firstSeenImportId);
  static Insertable<ObservedAccount> custom({
    Expression<int>? id,
    Expression<String>? canonicalUsername,
    Expression<String>? firstDisplayUsername,
    Expression<int>? firstSeenImportId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (canonicalUsername != null) 'canonical_username': canonicalUsername,
      if (firstDisplayUsername != null)
        'first_display_username': firstDisplayUsername,
      if (firstSeenImportId != null) 'first_seen_import_id': firstSeenImportId,
    });
  }

  ObservedAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? canonicalUsername,
    Value<String>? firstDisplayUsername,
    Value<int>? firstSeenImportId,
  }) {
    return ObservedAccountsCompanion(
      id: id ?? this.id,
      canonicalUsername: canonicalUsername ?? this.canonicalUsername,
      firstDisplayUsername: firstDisplayUsername ?? this.firstDisplayUsername,
      firstSeenImportId: firstSeenImportId ?? this.firstSeenImportId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (canonicalUsername.present) {
      map['canonical_username'] = Variable<String>(canonicalUsername.value);
    }
    if (firstDisplayUsername.present) {
      map['first_display_username'] = Variable<String>(
        firstDisplayUsername.value,
      );
    }
    if (firstSeenImportId.present) {
      map['first_seen_import_id'] = Variable<int>(firstSeenImportId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObservedAccountsCompanion(')
          ..write('id: $id, ')
          ..write('canonicalUsername: $canonicalUsername, ')
          ..write('firstDisplayUsername: $firstDisplayUsername, ')
          ..write('firstSeenImportId: $firstSeenImportId')
          ..write(')'))
        .toString();
  }
}

class $ImportEntriesTable extends ImportEntries
    with TableInfo<$ImportEntriesTable, ImportEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<int> importId = GeneratedColumn<int>(
    'import_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES observed_accounts (id)',
    ),
  );
  static const VerificationMeta _displayUsernameMeta = const VerificationMeta(
    'displayUsername',
  );
  @override
  late final GeneratedColumn<String> displayUsername = GeneratedColumn<String>(
    'display_username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceTimestampSecondsMeta =
      const VerificationMeta('sourceTimestampSeconds');
  @override
  late final GeneratedColumn<int> sourceTimestampSeconds = GeneratedColumn<int>(
    'source_timestamp_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timestampKindMeta = const VerificationMeta(
    'timestampKind',
  );
  @override
  late final GeneratedColumn<String> timestampKind = GeneratedColumn<String>(
    'timestamp_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    importId,
    side,
    accountId,
    displayUsername,
    sourceTimestampSeconds,
    timestampKind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    } else if (isInserting) {
      context.missing(_importIdMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('display_username')) {
      context.handle(
        _displayUsernameMeta,
        displayUsername.isAcceptableOrUnknown(
          data['display_username']!,
          _displayUsernameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayUsernameMeta);
    }
    if (data.containsKey('source_timestamp_seconds')) {
      context.handle(
        _sourceTimestampSecondsMeta,
        sourceTimestampSeconds.isAcceptableOrUnknown(
          data['source_timestamp_seconds']!,
          _sourceTimestampSecondsMeta,
        ),
      );
    }
    if (data.containsKey('timestamp_kind')) {
      context.handle(
        _timestampKindMeta,
        timestampKind.isAcceptableOrUnknown(
          data['timestamp_kind']!,
          _timestampKindMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {importId, side, accountId};
  @override
  ImportEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportEntry(
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_id'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      displayUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_username'],
      )!,
      sourceTimestampSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_timestamp_seconds'],
      ),
      timestampKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timestamp_kind'],
      ),
    );
  }

  @override
  $ImportEntriesTable createAlias(String alias) {
    return $ImportEntriesTable(attachedDatabase, alias);
  }
}

class ImportEntry extends DataClass implements Insertable<ImportEntry> {
  final int importId;
  final String side;
  final int accountId;
  final String displayUsername;
  final int? sourceTimestampSeconds;
  final String? timestampKind;
  const ImportEntry({
    required this.importId,
    required this.side,
    required this.accountId,
    required this.displayUsername,
    this.sourceTimestampSeconds,
    this.timestampKind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['import_id'] = Variable<int>(importId);
    map['side'] = Variable<String>(side);
    map['account_id'] = Variable<int>(accountId);
    map['display_username'] = Variable<String>(displayUsername);
    if (!nullToAbsent || sourceTimestampSeconds != null) {
      map['source_timestamp_seconds'] = Variable<int>(sourceTimestampSeconds);
    }
    if (!nullToAbsent || timestampKind != null) {
      map['timestamp_kind'] = Variable<String>(timestampKind);
    }
    return map;
  }

  ImportEntriesCompanion toCompanion(bool nullToAbsent) {
    return ImportEntriesCompanion(
      importId: Value(importId),
      side: Value(side),
      accountId: Value(accountId),
      displayUsername: Value(displayUsername),
      sourceTimestampSeconds: sourceTimestampSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceTimestampSeconds),
      timestampKind: timestampKind == null && nullToAbsent
          ? const Value.absent()
          : Value(timestampKind),
    );
  }

  factory ImportEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportEntry(
      importId: serializer.fromJson<int>(json['importId']),
      side: serializer.fromJson<String>(json['side']),
      accountId: serializer.fromJson<int>(json['accountId']),
      displayUsername: serializer.fromJson<String>(json['displayUsername']),
      sourceTimestampSeconds: serializer.fromJson<int?>(
        json['sourceTimestampSeconds'],
      ),
      timestampKind: serializer.fromJson<String?>(json['timestampKind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'importId': serializer.toJson<int>(importId),
      'side': serializer.toJson<String>(side),
      'accountId': serializer.toJson<int>(accountId),
      'displayUsername': serializer.toJson<String>(displayUsername),
      'sourceTimestampSeconds': serializer.toJson<int?>(sourceTimestampSeconds),
      'timestampKind': serializer.toJson<String?>(timestampKind),
    };
  }

  ImportEntry copyWith({
    int? importId,
    String? side,
    int? accountId,
    String? displayUsername,
    Value<int?> sourceTimestampSeconds = const Value.absent(),
    Value<String?> timestampKind = const Value.absent(),
  }) => ImportEntry(
    importId: importId ?? this.importId,
    side: side ?? this.side,
    accountId: accountId ?? this.accountId,
    displayUsername: displayUsername ?? this.displayUsername,
    sourceTimestampSeconds: sourceTimestampSeconds.present
        ? sourceTimestampSeconds.value
        : this.sourceTimestampSeconds,
    timestampKind: timestampKind.present
        ? timestampKind.value
        : this.timestampKind,
  );
  ImportEntry copyWithCompanion(ImportEntriesCompanion data) {
    return ImportEntry(
      importId: data.importId.present ? data.importId.value : this.importId,
      side: data.side.present ? data.side.value : this.side,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      displayUsername: data.displayUsername.present
          ? data.displayUsername.value
          : this.displayUsername,
      sourceTimestampSeconds: data.sourceTimestampSeconds.present
          ? data.sourceTimestampSeconds.value
          : this.sourceTimestampSeconds,
      timestampKind: data.timestampKind.present
          ? data.timestampKind.value
          : this.timestampKind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportEntry(')
          ..write('importId: $importId, ')
          ..write('side: $side, ')
          ..write('accountId: $accountId, ')
          ..write('displayUsername: $displayUsername, ')
          ..write('sourceTimestampSeconds: $sourceTimestampSeconds, ')
          ..write('timestampKind: $timestampKind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    importId,
    side,
    accountId,
    displayUsername,
    sourceTimestampSeconds,
    timestampKind,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportEntry &&
          other.importId == this.importId &&
          other.side == this.side &&
          other.accountId == this.accountId &&
          other.displayUsername == this.displayUsername &&
          other.sourceTimestampSeconds == this.sourceTimestampSeconds &&
          other.timestampKind == this.timestampKind);
}

class ImportEntriesCompanion extends UpdateCompanion<ImportEntry> {
  final Value<int> importId;
  final Value<String> side;
  final Value<int> accountId;
  final Value<String> displayUsername;
  final Value<int?> sourceTimestampSeconds;
  final Value<String?> timestampKind;
  final Value<int> rowid;
  const ImportEntriesCompanion({
    this.importId = const Value.absent(),
    this.side = const Value.absent(),
    this.accountId = const Value.absent(),
    this.displayUsername = const Value.absent(),
    this.sourceTimestampSeconds = const Value.absent(),
    this.timestampKind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportEntriesCompanion.insert({
    required int importId,
    required String side,
    required int accountId,
    required String displayUsername,
    this.sourceTimestampSeconds = const Value.absent(),
    this.timestampKind = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : importId = Value(importId),
       side = Value(side),
       accountId = Value(accountId),
       displayUsername = Value(displayUsername);
  static Insertable<ImportEntry> custom({
    Expression<int>? importId,
    Expression<String>? side,
    Expression<int>? accountId,
    Expression<String>? displayUsername,
    Expression<int>? sourceTimestampSeconds,
    Expression<String>? timestampKind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (importId != null) 'import_id': importId,
      if (side != null) 'side': side,
      if (accountId != null) 'account_id': accountId,
      if (displayUsername != null) 'display_username': displayUsername,
      if (sourceTimestampSeconds != null)
        'source_timestamp_seconds': sourceTimestampSeconds,
      if (timestampKind != null) 'timestamp_kind': timestampKind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportEntriesCompanion copyWith({
    Value<int>? importId,
    Value<String>? side,
    Value<int>? accountId,
    Value<String>? displayUsername,
    Value<int?>? sourceTimestampSeconds,
    Value<String?>? timestampKind,
    Value<int>? rowid,
  }) {
    return ImportEntriesCompanion(
      importId: importId ?? this.importId,
      side: side ?? this.side,
      accountId: accountId ?? this.accountId,
      displayUsername: displayUsername ?? this.displayUsername,
      sourceTimestampSeconds:
          sourceTimestampSeconds ?? this.sourceTimestampSeconds,
      timestampKind: timestampKind ?? this.timestampKind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (importId.present) {
      map['import_id'] = Variable<int>(importId.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (displayUsername.present) {
      map['display_username'] = Variable<String>(displayUsername.value);
    }
    if (sourceTimestampSeconds.present) {
      map['source_timestamp_seconds'] = Variable<int>(
        sourceTimestampSeconds.value,
      );
    }
    if (timestampKind.present) {
      map['timestamp_kind'] = Variable<String>(timestampKind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportEntriesCompanion(')
          ..write('importId: $importId, ')
          ..write('side: $side, ')
          ..write('accountId: $accountId, ')
          ..write('displayUsername: $displayUsername, ')
          ..write('sourceTimestampSeconds: $sourceTimestampSeconds, ')
          ..write('timestampKind: $timestampKind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelationshipStatesTable extends RelationshipStates
    with TableInfo<$RelationshipStatesTable, RelationshipState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationshipStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES observed_accounts (id)',
    ),
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstPositiveImportIdMeta =
      const VerificationMeta('firstPositiveImportId');
  @override
  late final GeneratedColumn<int> firstPositiveImportId = GeneratedColumn<int>(
    'first_positive_import_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  static const VerificationMeta _lastPositiveImportIdMeta =
      const VerificationMeta('lastPositiveImportId');
  @override
  late final GeneratedColumn<int> lastPositiveImportId = GeneratedColumn<int>(
    'last_positive_import_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  static const VerificationMeta _firstCompleteAbsenceImportIdMeta =
      const VerificationMeta('firstCompleteAbsenceImportId');
  @override
  late final GeneratedColumn<int> firstCompleteAbsenceImportId =
      GeneratedColumn<int>(
        'first_complete_absence_import_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES imports (id)',
        ),
      );
  static const VerificationMeta _latestCompleteAbsenceImportIdMeta =
      const VerificationMeta('latestCompleteAbsenceImportId');
  @override
  late final GeneratedColumn<int> latestCompleteAbsenceImportId =
      GeneratedColumn<int>(
        'latest_complete_absence_import_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES imports (id)',
        ),
      );
  @override
  List<GeneratedColumn> get $columns => [
    accountId,
    side,
    status,
    firstPositiveImportId,
    lastPositiveImportId,
    firstCompleteAbsenceImportId,
    latestCompleteAbsenceImportId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationship_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<RelationshipState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('first_positive_import_id')) {
      context.handle(
        _firstPositiveImportIdMeta,
        firstPositiveImportId.isAcceptableOrUnknown(
          data['first_positive_import_id']!,
          _firstPositiveImportIdMeta,
        ),
      );
    }
    if (data.containsKey('last_positive_import_id')) {
      context.handle(
        _lastPositiveImportIdMeta,
        lastPositiveImportId.isAcceptableOrUnknown(
          data['last_positive_import_id']!,
          _lastPositiveImportIdMeta,
        ),
      );
    }
    if (data.containsKey('first_complete_absence_import_id')) {
      context.handle(
        _firstCompleteAbsenceImportIdMeta,
        firstCompleteAbsenceImportId.isAcceptableOrUnknown(
          data['first_complete_absence_import_id']!,
          _firstCompleteAbsenceImportIdMeta,
        ),
      );
    }
    if (data.containsKey('latest_complete_absence_import_id')) {
      context.handle(
        _latestCompleteAbsenceImportIdMeta,
        latestCompleteAbsenceImportId.isAcceptableOrUnknown(
          data['latest_complete_absence_import_id']!,
          _latestCompleteAbsenceImportIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {accountId, side};
  @override
  RelationshipState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipState(
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      firstPositiveImportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_positive_import_id'],
      ),
      lastPositiveImportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_positive_import_id'],
      ),
      firstCompleteAbsenceImportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_complete_absence_import_id'],
      ),
      latestCompleteAbsenceImportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latest_complete_absence_import_id'],
      ),
    );
  }

  @override
  $RelationshipStatesTable createAlias(String alias) {
    return $RelationshipStatesTable(attachedDatabase, alias);
  }
}

class RelationshipState extends DataClass
    implements Insertable<RelationshipState> {
  final int accountId;
  final String side;
  final String status;
  final int? firstPositiveImportId;
  final int? lastPositiveImportId;
  final int? firstCompleteAbsenceImportId;
  final int? latestCompleteAbsenceImportId;
  const RelationshipState({
    required this.accountId,
    required this.side,
    required this.status,
    this.firstPositiveImportId,
    this.lastPositiveImportId,
    this.firstCompleteAbsenceImportId,
    this.latestCompleteAbsenceImportId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['account_id'] = Variable<int>(accountId);
    map['side'] = Variable<String>(side);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || firstPositiveImportId != null) {
      map['first_positive_import_id'] = Variable<int>(firstPositiveImportId);
    }
    if (!nullToAbsent || lastPositiveImportId != null) {
      map['last_positive_import_id'] = Variable<int>(lastPositiveImportId);
    }
    if (!nullToAbsent || firstCompleteAbsenceImportId != null) {
      map['first_complete_absence_import_id'] = Variable<int>(
        firstCompleteAbsenceImportId,
      );
    }
    if (!nullToAbsent || latestCompleteAbsenceImportId != null) {
      map['latest_complete_absence_import_id'] = Variable<int>(
        latestCompleteAbsenceImportId,
      );
    }
    return map;
  }

  RelationshipStatesCompanion toCompanion(bool nullToAbsent) {
    return RelationshipStatesCompanion(
      accountId: Value(accountId),
      side: Value(side),
      status: Value(status),
      firstPositiveImportId: firstPositiveImportId == null && nullToAbsent
          ? const Value.absent()
          : Value(firstPositiveImportId),
      lastPositiveImportId: lastPositiveImportId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPositiveImportId),
      firstCompleteAbsenceImportId:
          firstCompleteAbsenceImportId == null && nullToAbsent
          ? const Value.absent()
          : Value(firstCompleteAbsenceImportId),
      latestCompleteAbsenceImportId:
          latestCompleteAbsenceImportId == null && nullToAbsent
          ? const Value.absent()
          : Value(latestCompleteAbsenceImportId),
    );
  }

  factory RelationshipState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelationshipState(
      accountId: serializer.fromJson<int>(json['accountId']),
      side: serializer.fromJson<String>(json['side']),
      status: serializer.fromJson<String>(json['status']),
      firstPositiveImportId: serializer.fromJson<int?>(
        json['firstPositiveImportId'],
      ),
      lastPositiveImportId: serializer.fromJson<int?>(
        json['lastPositiveImportId'],
      ),
      firstCompleteAbsenceImportId: serializer.fromJson<int?>(
        json['firstCompleteAbsenceImportId'],
      ),
      latestCompleteAbsenceImportId: serializer.fromJson<int?>(
        json['latestCompleteAbsenceImportId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'accountId': serializer.toJson<int>(accountId),
      'side': serializer.toJson<String>(side),
      'status': serializer.toJson<String>(status),
      'firstPositiveImportId': serializer.toJson<int?>(firstPositiveImportId),
      'lastPositiveImportId': serializer.toJson<int?>(lastPositiveImportId),
      'firstCompleteAbsenceImportId': serializer.toJson<int?>(
        firstCompleteAbsenceImportId,
      ),
      'latestCompleteAbsenceImportId': serializer.toJson<int?>(
        latestCompleteAbsenceImportId,
      ),
    };
  }

  RelationshipState copyWith({
    int? accountId,
    String? side,
    String? status,
    Value<int?> firstPositiveImportId = const Value.absent(),
    Value<int?> lastPositiveImportId = const Value.absent(),
    Value<int?> firstCompleteAbsenceImportId = const Value.absent(),
    Value<int?> latestCompleteAbsenceImportId = const Value.absent(),
  }) => RelationshipState(
    accountId: accountId ?? this.accountId,
    side: side ?? this.side,
    status: status ?? this.status,
    firstPositiveImportId: firstPositiveImportId.present
        ? firstPositiveImportId.value
        : this.firstPositiveImportId,
    lastPositiveImportId: lastPositiveImportId.present
        ? lastPositiveImportId.value
        : this.lastPositiveImportId,
    firstCompleteAbsenceImportId: firstCompleteAbsenceImportId.present
        ? firstCompleteAbsenceImportId.value
        : this.firstCompleteAbsenceImportId,
    latestCompleteAbsenceImportId: latestCompleteAbsenceImportId.present
        ? latestCompleteAbsenceImportId.value
        : this.latestCompleteAbsenceImportId,
  );
  RelationshipState copyWithCompanion(RelationshipStatesCompanion data) {
    return RelationshipState(
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      side: data.side.present ? data.side.value : this.side,
      status: data.status.present ? data.status.value : this.status,
      firstPositiveImportId: data.firstPositiveImportId.present
          ? data.firstPositiveImportId.value
          : this.firstPositiveImportId,
      lastPositiveImportId: data.lastPositiveImportId.present
          ? data.lastPositiveImportId.value
          : this.lastPositiveImportId,
      firstCompleteAbsenceImportId: data.firstCompleteAbsenceImportId.present
          ? data.firstCompleteAbsenceImportId.value
          : this.firstCompleteAbsenceImportId,
      latestCompleteAbsenceImportId: data.latestCompleteAbsenceImportId.present
          ? data.latestCompleteAbsenceImportId.value
          : this.latestCompleteAbsenceImportId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipState(')
          ..write('accountId: $accountId, ')
          ..write('side: $side, ')
          ..write('status: $status, ')
          ..write('firstPositiveImportId: $firstPositiveImportId, ')
          ..write('lastPositiveImportId: $lastPositiveImportId, ')
          ..write(
            'firstCompleteAbsenceImportId: $firstCompleteAbsenceImportId, ',
          )
          ..write(
            'latestCompleteAbsenceImportId: $latestCompleteAbsenceImportId',
          )
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    accountId,
    side,
    status,
    firstPositiveImportId,
    lastPositiveImportId,
    firstCompleteAbsenceImportId,
    latestCompleteAbsenceImportId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelationshipState &&
          other.accountId == this.accountId &&
          other.side == this.side &&
          other.status == this.status &&
          other.firstPositiveImportId == this.firstPositiveImportId &&
          other.lastPositiveImportId == this.lastPositiveImportId &&
          other.firstCompleteAbsenceImportId ==
              this.firstCompleteAbsenceImportId &&
          other.latestCompleteAbsenceImportId ==
              this.latestCompleteAbsenceImportId);
}

class RelationshipStatesCompanion extends UpdateCompanion<RelationshipState> {
  final Value<int> accountId;
  final Value<String> side;
  final Value<String> status;
  final Value<int?> firstPositiveImportId;
  final Value<int?> lastPositiveImportId;
  final Value<int?> firstCompleteAbsenceImportId;
  final Value<int?> latestCompleteAbsenceImportId;
  final Value<int> rowid;
  const RelationshipStatesCompanion({
    this.accountId = const Value.absent(),
    this.side = const Value.absent(),
    this.status = const Value.absent(),
    this.firstPositiveImportId = const Value.absent(),
    this.lastPositiveImportId = const Value.absent(),
    this.firstCompleteAbsenceImportId = const Value.absent(),
    this.latestCompleteAbsenceImportId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RelationshipStatesCompanion.insert({
    required int accountId,
    required String side,
    required String status,
    this.firstPositiveImportId = const Value.absent(),
    this.lastPositiveImportId = const Value.absent(),
    this.firstCompleteAbsenceImportId = const Value.absent(),
    this.latestCompleteAbsenceImportId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : accountId = Value(accountId),
       side = Value(side),
       status = Value(status);
  static Insertable<RelationshipState> custom({
    Expression<int>? accountId,
    Expression<String>? side,
    Expression<String>? status,
    Expression<int>? firstPositiveImportId,
    Expression<int>? lastPositiveImportId,
    Expression<int>? firstCompleteAbsenceImportId,
    Expression<int>? latestCompleteAbsenceImportId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (accountId != null) 'account_id': accountId,
      if (side != null) 'side': side,
      if (status != null) 'status': status,
      if (firstPositiveImportId != null)
        'first_positive_import_id': firstPositiveImportId,
      if (lastPositiveImportId != null)
        'last_positive_import_id': lastPositiveImportId,
      if (firstCompleteAbsenceImportId != null)
        'first_complete_absence_import_id': firstCompleteAbsenceImportId,
      if (latestCompleteAbsenceImportId != null)
        'latest_complete_absence_import_id': latestCompleteAbsenceImportId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RelationshipStatesCompanion copyWith({
    Value<int>? accountId,
    Value<String>? side,
    Value<String>? status,
    Value<int?>? firstPositiveImportId,
    Value<int?>? lastPositiveImportId,
    Value<int?>? firstCompleteAbsenceImportId,
    Value<int?>? latestCompleteAbsenceImportId,
    Value<int>? rowid,
  }) {
    return RelationshipStatesCompanion(
      accountId: accountId ?? this.accountId,
      side: side ?? this.side,
      status: status ?? this.status,
      firstPositiveImportId:
          firstPositiveImportId ?? this.firstPositiveImportId,
      lastPositiveImportId: lastPositiveImportId ?? this.lastPositiveImportId,
      firstCompleteAbsenceImportId:
          firstCompleteAbsenceImportId ?? this.firstCompleteAbsenceImportId,
      latestCompleteAbsenceImportId:
          latestCompleteAbsenceImportId ?? this.latestCompleteAbsenceImportId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (firstPositiveImportId.present) {
      map['first_positive_import_id'] = Variable<int>(
        firstPositiveImportId.value,
      );
    }
    if (lastPositiveImportId.present) {
      map['last_positive_import_id'] = Variable<int>(
        lastPositiveImportId.value,
      );
    }
    if (firstCompleteAbsenceImportId.present) {
      map['first_complete_absence_import_id'] = Variable<int>(
        firstCompleteAbsenceImportId.value,
      );
    }
    if (latestCompleteAbsenceImportId.present) {
      map['latest_complete_absence_import_id'] = Variable<int>(
        latestCompleteAbsenceImportId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipStatesCompanion(')
          ..write('accountId: $accountId, ')
          ..write('side: $side, ')
          ..write('status: $status, ')
          ..write('firstPositiveImportId: $firstPositiveImportId, ')
          ..write('lastPositiveImportId: $lastPositiveImportId, ')
          ..write(
            'firstCompleteAbsenceImportId: $firstCompleteAbsenceImportId, ',
          )
          ..write(
            'latestCompleteAbsenceImportId: $latestCompleteAbsenceImportId, ',
          )
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelationshipChangesTable extends RelationshipChanges
    with TableInfo<$RelationshipChangesTable, RelationshipChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelationshipChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<int> importId = GeneratedColumn<int>(
    'import_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES observed_accounts (id)',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorEvidenceImportIdMeta =
      const VerificationMeta('priorEvidenceImportId');
  @override
  late final GeneratedColumn<int> priorEvidenceImportId = GeneratedColumn<int>(
    'prior_evidence_import_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    importId,
    side,
    accountId,
    kind,
    priorEvidenceImportId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relationship_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RelationshipChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    } else if (isInserting) {
      context.missing(_importIdMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    } else if (isInserting) {
      context.missing(_sideMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('prior_evidence_import_id')) {
      context.handle(
        _priorEvidenceImportIdMeta,
        priorEvidenceImportId.isAcceptableOrUnknown(
          data['prior_evidence_import_id']!,
          _priorEvidenceImportIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {importId, side, accountId},
  ];
  @override
  RelationshipChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelationshipChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_id'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      priorEvidenceImportId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prior_evidence_import_id'],
      ),
    );
  }

  @override
  $RelationshipChangesTable createAlias(String alias) {
    return $RelationshipChangesTable(attachedDatabase, alias);
  }
}

class RelationshipChange extends DataClass
    implements Insertable<RelationshipChange> {
  final int id;
  final int importId;
  final String side;
  final int accountId;
  final String kind;
  final int? priorEvidenceImportId;
  const RelationshipChange({
    required this.id,
    required this.importId,
    required this.side,
    required this.accountId,
    required this.kind,
    this.priorEvidenceImportId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['import_id'] = Variable<int>(importId);
    map['side'] = Variable<String>(side);
    map['account_id'] = Variable<int>(accountId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || priorEvidenceImportId != null) {
      map['prior_evidence_import_id'] = Variable<int>(priorEvidenceImportId);
    }
    return map;
  }

  RelationshipChangesCompanion toCompanion(bool nullToAbsent) {
    return RelationshipChangesCompanion(
      id: Value(id),
      importId: Value(importId),
      side: Value(side),
      accountId: Value(accountId),
      kind: Value(kind),
      priorEvidenceImportId: priorEvidenceImportId == null && nullToAbsent
          ? const Value.absent()
          : Value(priorEvidenceImportId),
    );
  }

  factory RelationshipChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelationshipChange(
      id: serializer.fromJson<int>(json['id']),
      importId: serializer.fromJson<int>(json['importId']),
      side: serializer.fromJson<String>(json['side']),
      accountId: serializer.fromJson<int>(json['accountId']),
      kind: serializer.fromJson<String>(json['kind']),
      priorEvidenceImportId: serializer.fromJson<int?>(
        json['priorEvidenceImportId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'importId': serializer.toJson<int>(importId),
      'side': serializer.toJson<String>(side),
      'accountId': serializer.toJson<int>(accountId),
      'kind': serializer.toJson<String>(kind),
      'priorEvidenceImportId': serializer.toJson<int?>(priorEvidenceImportId),
    };
  }

  RelationshipChange copyWith({
    int? id,
    int? importId,
    String? side,
    int? accountId,
    String? kind,
    Value<int?> priorEvidenceImportId = const Value.absent(),
  }) => RelationshipChange(
    id: id ?? this.id,
    importId: importId ?? this.importId,
    side: side ?? this.side,
    accountId: accountId ?? this.accountId,
    kind: kind ?? this.kind,
    priorEvidenceImportId: priorEvidenceImportId.present
        ? priorEvidenceImportId.value
        : this.priorEvidenceImportId,
  );
  RelationshipChange copyWithCompanion(RelationshipChangesCompanion data) {
    return RelationshipChange(
      id: data.id.present ? data.id.value : this.id,
      importId: data.importId.present ? data.importId.value : this.importId,
      side: data.side.present ? data.side.value : this.side,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      kind: data.kind.present ? data.kind.value : this.kind,
      priorEvidenceImportId: data.priorEvidenceImportId.present
          ? data.priorEvidenceImportId.value
          : this.priorEvidenceImportId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipChange(')
          ..write('id: $id, ')
          ..write('importId: $importId, ')
          ..write('side: $side, ')
          ..write('accountId: $accountId, ')
          ..write('kind: $kind, ')
          ..write('priorEvidenceImportId: $priorEvidenceImportId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, importId, side, accountId, kind, priorEvidenceImportId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelationshipChange &&
          other.id == this.id &&
          other.importId == this.importId &&
          other.side == this.side &&
          other.accountId == this.accountId &&
          other.kind == this.kind &&
          other.priorEvidenceImportId == this.priorEvidenceImportId);
}

class RelationshipChangesCompanion extends UpdateCompanion<RelationshipChange> {
  final Value<int> id;
  final Value<int> importId;
  final Value<String> side;
  final Value<int> accountId;
  final Value<String> kind;
  final Value<int?> priorEvidenceImportId;
  const RelationshipChangesCompanion({
    this.id = const Value.absent(),
    this.importId = const Value.absent(),
    this.side = const Value.absent(),
    this.accountId = const Value.absent(),
    this.kind = const Value.absent(),
    this.priorEvidenceImportId = const Value.absent(),
  });
  RelationshipChangesCompanion.insert({
    this.id = const Value.absent(),
    required int importId,
    required String side,
    required int accountId,
    required String kind,
    this.priorEvidenceImportId = const Value.absent(),
  }) : importId = Value(importId),
       side = Value(side),
       accountId = Value(accountId),
       kind = Value(kind);
  static Insertable<RelationshipChange> custom({
    Expression<int>? id,
    Expression<int>? importId,
    Expression<String>? side,
    Expression<int>? accountId,
    Expression<String>? kind,
    Expression<int>? priorEvidenceImportId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (importId != null) 'import_id': importId,
      if (side != null) 'side': side,
      if (accountId != null) 'account_id': accountId,
      if (kind != null) 'kind': kind,
      if (priorEvidenceImportId != null)
        'prior_evidence_import_id': priorEvidenceImportId,
    });
  }

  RelationshipChangesCompanion copyWith({
    Value<int>? id,
    Value<int>? importId,
    Value<String>? side,
    Value<int>? accountId,
    Value<String>? kind,
    Value<int?>? priorEvidenceImportId,
  }) {
    return RelationshipChangesCompanion(
      id: id ?? this.id,
      importId: importId ?? this.importId,
      side: side ?? this.side,
      accountId: accountId ?? this.accountId,
      kind: kind ?? this.kind,
      priorEvidenceImportId:
          priorEvidenceImportId ?? this.priorEvidenceImportId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<int>(importId.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (priorEvidenceImportId.present) {
      map['prior_evidence_import_id'] = Variable<int>(
        priorEvidenceImportId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelationshipChangesCompanion(')
          ..write('id: $id, ')
          ..write('importId: $importId, ')
          ..write('side: $side, ')
          ..write('accountId: $accountId, ')
          ..write('kind: $kind, ')
          ..write('priorEvidenceImportId: $priorEvidenceImportId')
          ..write(')'))
        .toString();
  }
}

class $ImportWarningsTable extends ImportWarnings
    with TableInfo<$ImportWarningsTable, ImportWarning> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportWarningsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _importIdMeta = const VerificationMeta(
    'importId',
  );
  @override
  late final GeneratedColumn<int> importId = GeneratedColumn<int>(
    'import_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES imports (id)',
    ),
  );
  static const VerificationMeta _sideMeta = const VerificationMeta('side');
  @override
  late final GeneratedColumn<String> side = GeneratedColumn<String>(
    'side',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, importId, side, code, count];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_warnings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportWarning> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('import_id')) {
      context.handle(
        _importIdMeta,
        importId.isAcceptableOrUnknown(data['import_id']!, _importIdMeta),
      );
    } else if (isInserting) {
      context.missing(_importIdMeta);
    }
    if (data.containsKey('side')) {
      context.handle(
        _sideMeta,
        side.isAcceptableOrUnknown(data['side']!, _sideMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportWarning map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportWarning(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      importId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}import_id'],
      )!,
      side: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}side'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $ImportWarningsTable createAlias(String alias) {
    return $ImportWarningsTable(attachedDatabase, alias);
  }
}

class ImportWarning extends DataClass implements Insertable<ImportWarning> {
  final int id;
  final int importId;
  final String? side;
  final String code;
  final int count;
  const ImportWarning({
    required this.id,
    required this.importId,
    this.side,
    required this.code,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['import_id'] = Variable<int>(importId);
    if (!nullToAbsent || side != null) {
      map['side'] = Variable<String>(side);
    }
    map['code'] = Variable<String>(code);
    map['count'] = Variable<int>(count);
    return map;
  }

  ImportWarningsCompanion toCompanion(bool nullToAbsent) {
    return ImportWarningsCompanion(
      id: Value(id),
      importId: Value(importId),
      side: side == null && nullToAbsent ? const Value.absent() : Value(side),
      code: Value(code),
      count: Value(count),
    );
  }

  factory ImportWarning.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportWarning(
      id: serializer.fromJson<int>(json['id']),
      importId: serializer.fromJson<int>(json['importId']),
      side: serializer.fromJson<String?>(json['side']),
      code: serializer.fromJson<String>(json['code']),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'importId': serializer.toJson<int>(importId),
      'side': serializer.toJson<String?>(side),
      'code': serializer.toJson<String>(code),
      'count': serializer.toJson<int>(count),
    };
  }

  ImportWarning copyWith({
    int? id,
    int? importId,
    Value<String?> side = const Value.absent(),
    String? code,
    int? count,
  }) => ImportWarning(
    id: id ?? this.id,
    importId: importId ?? this.importId,
    side: side.present ? side.value : this.side,
    code: code ?? this.code,
    count: count ?? this.count,
  );
  ImportWarning copyWithCompanion(ImportWarningsCompanion data) {
    return ImportWarning(
      id: data.id.present ? data.id.value : this.id,
      importId: data.importId.present ? data.importId.value : this.importId,
      side: data.side.present ? data.side.value : this.side,
      code: data.code.present ? data.code.value : this.code,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportWarning(')
          ..write('id: $id, ')
          ..write('importId: $importId, ')
          ..write('side: $side, ')
          ..write('code: $code, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, importId, side, code, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportWarning &&
          other.id == this.id &&
          other.importId == this.importId &&
          other.side == this.side &&
          other.code == this.code &&
          other.count == this.count);
}

class ImportWarningsCompanion extends UpdateCompanion<ImportWarning> {
  final Value<int> id;
  final Value<int> importId;
  final Value<String?> side;
  final Value<String> code;
  final Value<int> count;
  const ImportWarningsCompanion({
    this.id = const Value.absent(),
    this.importId = const Value.absent(),
    this.side = const Value.absent(),
    this.code = const Value.absent(),
    this.count = const Value.absent(),
  });
  ImportWarningsCompanion.insert({
    this.id = const Value.absent(),
    required int importId,
    this.side = const Value.absent(),
    required String code,
    required int count,
  }) : importId = Value(importId),
       code = Value(code),
       count = Value(count);
  static Insertable<ImportWarning> custom({
    Expression<int>? id,
    Expression<int>? importId,
    Expression<String>? side,
    Expression<String>? code,
    Expression<int>? count,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (importId != null) 'import_id': importId,
      if (side != null) 'side': side,
      if (code != null) 'code': code,
      if (count != null) 'count': count,
    });
  }

  ImportWarningsCompanion copyWith({
    Value<int>? id,
    Value<int>? importId,
    Value<String?>? side,
    Value<String>? code,
    Value<int>? count,
  }) {
    return ImportWarningsCompanion(
      id: id ?? this.id,
      importId: importId ?? this.importId,
      side: side ?? this.side,
      code: code ?? this.code,
      count: count ?? this.count,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (importId.present) {
      map['import_id'] = Variable<int>(importId.value);
    }
    if (side.present) {
      map['side'] = Variable<String>(side.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportWarningsCompanion(')
          ..write('id: $id, ')
          ..write('importId: $importId, ')
          ..write('side: $side, ')
          ..write('code: $code, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ImportsTable imports = $ImportsTable(this);
  late final $ImportSidesTable importSides = $ImportSidesTable(this);
  late final $ObservedAccountsTable observedAccounts = $ObservedAccountsTable(
    this,
  );
  late final $ImportEntriesTable importEntries = $ImportEntriesTable(this);
  late final $RelationshipStatesTable relationshipStates =
      $RelationshipStatesTable(this);
  late final $RelationshipChangesTable relationshipChanges =
      $RelationshipChangesTable(this);
  late final $ImportWarningsTable importWarnings = $ImportWarningsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    imports,
    importSides,
    observedAccounts,
    importEntries,
    relationshipStates,
    relationshipChanges,
    importWarnings,
  ];
}

typedef $$ImportsTableCreateCompanionBuilder = ImportsCompanion Function({
  Value<int> id,
  required String parserVersion,
  required String digest,
  Value<DateTime?> importedAt,
});
typedef $$ImportsTableUpdateCompanionBuilder = ImportsCompanion Function({
  Value<int> id,
  Value<String> parserVersion,
  Value<String> digest,
  Value<DateTime?> importedAt,
});

final class $$ImportsTableReferences
    extends BaseReferences<_$AppDatabase, $ImportsTable, Import> {
  $$ImportsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ImportSidesTable, List<ImportSide>>
  _importSidesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.importSides,
    aliasName: 'imports__id__import_sides__import_id',
  );

  $$ImportSidesTableProcessedTableManager get importSidesRefs {
    final manager = $$ImportSidesTableTableManager(
      $_db,
      $_db.importSides,
    ).filter((f) => f.importId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importSidesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ObservedAccountsTable, List<ObservedAccount>>
  _observedAccountsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.observedAccounts,
    aliasName: 'imports__id__observed_accounts__first_seen_import_id',
  );

  $$ObservedAccountsTableProcessedTableManager get observedAccountsRefs {
    final manager = $$ObservedAccountsTableTableManager(
      $_db,
      $_db.observedAccounts,
    ).filter((f) => f.firstSeenImportId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _observedAccountsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportWarningsTable, List<ImportWarning>>
  _importWarningsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.importWarnings,
    aliasName: 'imports__id__import_warnings__import_id',
  );

  $$ImportWarningsTableProcessedTableManager get importWarningsRefs {
    final manager = $$ImportWarningsTableTableManager(
      $_db,
      $_db.importWarnings,
    ).filter((f) => f.importId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importWarningsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ImportsTableFilterComposer
    extends Composer<_$AppDatabase, $ImportsTable> {
  $$ImportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parserVersion => $composableBuilder(
    column: $table.parserVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get digest => $composableBuilder(
    column: $table.digest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> importSidesRefs(
    Expression<bool> Function($$ImportSidesTableFilterComposer f) f,
  ) {
    final $$ImportSidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importSides,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportSidesTableFilterComposer(
            $db: $db,
            $table: $db.importSides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> observedAccountsRefs(
    Expression<bool> Function($$ObservedAccountsTableFilterComposer f) f,
  ) {
    final $$ObservedAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.firstSeenImportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableFilterComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> importWarningsRefs(
    Expression<bool> Function($$ImportWarningsTableFilterComposer f) f,
  ) {
    final $$ImportWarningsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importWarnings,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportWarningsTableFilterComposer(
            $db: $db,
            $table: $db.importWarnings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportsTable> {
  $$ImportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parserVersion => $composableBuilder(
    column: $table.parserVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get digest => $composableBuilder(
    column: $table.digest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportsTable> {
  $$ImportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parserVersion => $composableBuilder(
    column: $table.parserVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get digest =>
      $composableBuilder(column: $table.digest, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  Expression<T> importSidesRefs<T extends Object>(
    Expression<T> Function($$ImportSidesTableAnnotationComposer a) f,
  ) {
    final $$ImportSidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importSides,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportSidesTableAnnotationComposer(
            $db: $db,
            $table: $db.importSides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> observedAccountsRefs<T extends Object>(
    Expression<T> Function($$ObservedAccountsTableAnnotationComposer a) f,
  ) {
    final $$ObservedAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.firstSeenImportId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> importWarningsRefs<T extends Object>(
    Expression<T> Function($$ImportWarningsTableAnnotationComposer a) f,
  ) {
    final $$ImportWarningsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importWarnings,
      getReferencedColumn: (t) => t.importId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportWarningsTableAnnotationComposer(
            $db: $db,
            $table: $db.importWarnings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ImportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportsTable,
          Import,
          $$ImportsTableFilterComposer,
          $$ImportsTableOrderingComposer,
          $$ImportsTableAnnotationComposer,
          $$ImportsTableCreateCompanionBuilder,
          $$ImportsTableUpdateCompanionBuilder,
          (Import, $$ImportsTableReferences),
          Import,
          PrefetchHooks Function({
            bool importSidesRefs,
            bool observedAccountsRefs,
            bool importWarningsRefs,
          })
        > {
  $$ImportsTableTableManager(_$AppDatabase db, $ImportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> parserVersion = const Value.absent(),
                Value<String> digest = const Value.absent(),
                Value<DateTime?> importedAt = const Value.absent(),
              }) => ImportsCompanion(
                id: id,
                parserVersion: parserVersion,
                digest: digest,
                importedAt: importedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String parserVersion,
                required String digest,
                Value<DateTime?> importedAt = const Value.absent(),
              }) => ImportsCompanion.insert(
                id: id,
                parserVersion: parserVersion,
                digest: digest,
                importedAt: importedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportsTable, Import>(table),
                  $$ImportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                importSidesRefs = false,
                observedAccountsRefs = false,
                importWarningsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (importSidesRefs) db.importSides,
                    if (observedAccountsRefs) db.observedAccounts,
                    if (importWarningsRefs) db.importWarnings,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (importSidesRefs)
                        await $_getPrefetchedData<
                          Import,
                          $ImportsTable,
                          ImportSide
                        >(
                          currentTable: table,
                          referencedTable: $$ImportsTableReferences
                              ._importSidesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportsTableReferences(
                                db,
                                table,
                                p0,
                              ).importSidesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (observedAccountsRefs)
                        await $_getPrefetchedData<
                          Import,
                          $ImportsTable,
                          ObservedAccount
                        >(
                          currentTable: table,
                          referencedTable: $$ImportsTableReferences
                              ._observedAccountsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportsTableReferences(
                                db,
                                table,
                                p0,
                              ).observedAccountsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.firstSeenImportId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importWarningsRefs)
                        await $_getPrefetchedData<
                          Import,
                          $ImportsTable,
                          ImportWarning
                        >(
                          currentTable: table,
                          referencedTable: $$ImportsTableReferences
                              ._importWarningsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ImportsTableReferences(
                                db,
                                table,
                                p0,
                              ).importWarningsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.importId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ImportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportsTable,
      Import,
      $$ImportsTableFilterComposer,
      $$ImportsTableOrderingComposer,
      $$ImportsTableAnnotationComposer,
      $$ImportsTableCreateCompanionBuilder,
      $$ImportsTableUpdateCompanionBuilder,
      (Import, $$ImportsTableReferences),
      Import,
      PrefetchHooks Function({
        bool importSidesRefs,
        bool observedAccountsRefs,
        bool importWarningsRefs,
      })
    >;
typedef $$ImportSidesTableCreateCompanionBuilder =
    ImportSidesCompanion Function({
      required int importId,
      required String side,
      required String coverage,
      required String sideDigest,
      required int rowCount,
      required int invalidCount,
      required int duplicateCount,
      Value<int> rowid,
    });
typedef $$ImportSidesTableUpdateCompanionBuilder =
    ImportSidesCompanion Function({
      Value<int> importId,
      Value<String> side,
      Value<String> coverage,
      Value<String> sideDigest,
      Value<int> rowCount,
      Value<int> invalidCount,
      Value<int> duplicateCount,
      Value<int> rowid,
    });

final class $$ImportSidesTableReferences
    extends BaseReferences<_$AppDatabase, $ImportSidesTable, ImportSide> {
  $$ImportSidesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ImportsTable _importIdTable(_$AppDatabase db) =>
      db.imports.createAlias('import_sides__import_id__imports__id');

  $$ImportsTableProcessedTableManager get importId {
    final $_column = $_itemColumn<int>('import_id')!;

    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportSidesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportSidesTable> {
  $$ImportSidesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverage => $composableBuilder(
    column: $table.coverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sideDigest => $composableBuilder(
    column: $table.sideDigest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get invalidCount => $composableBuilder(
    column: $table.invalidCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportsTableFilterComposer get importId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportSidesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportSidesTable> {
  $$ImportSidesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverage => $composableBuilder(
    column: $table.coverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sideDigest => $composableBuilder(
    column: $table.sideDigest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowCount => $composableBuilder(
    column: $table.rowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get invalidCount => $composableBuilder(
    column: $table.invalidCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportsTableOrderingComposer get importId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportSidesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportSidesTable> {
  $$ImportSidesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get coverage =>
      $composableBuilder(column: $table.coverage, builder: (column) => column);

  GeneratedColumn<String> get sideDigest => $composableBuilder(
    column: $table.sideDigest,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rowCount =>
      $composableBuilder(column: $table.rowCount, builder: (column) => column);

  GeneratedColumn<int> get invalidCount => $composableBuilder(
    column: $table.invalidCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duplicateCount => $composableBuilder(
    column: $table.duplicateCount,
    builder: (column) => column,
  );

  $$ImportsTableAnnotationComposer get importId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportSidesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportSidesTable,
          ImportSide,
          $$ImportSidesTableFilterComposer,
          $$ImportSidesTableOrderingComposer,
          $$ImportSidesTableAnnotationComposer,
          $$ImportSidesTableCreateCompanionBuilder,
          $$ImportSidesTableUpdateCompanionBuilder,
          (ImportSide, $$ImportSidesTableReferences),
          ImportSide,
          PrefetchHooks Function({bool importId})
        > {
  $$ImportSidesTableTableManager(_$AppDatabase db, $ImportSidesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportSidesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportSidesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportSidesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> importId = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<String> coverage = const Value.absent(),
                Value<String> sideDigest = const Value.absent(),
                Value<int> rowCount = const Value.absent(),
                Value<int> invalidCount = const Value.absent(),
                Value<int> duplicateCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportSidesCompanion(
                importId: importId,
                side: side,
                coverage: coverage,
                sideDigest: sideDigest,
                rowCount: rowCount,
                invalidCount: invalidCount,
                duplicateCount: duplicateCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int importId,
                required String side,
                required String coverage,
                required String sideDigest,
                required int rowCount,
                required int invalidCount,
                required int duplicateCount,
                Value<int> rowid = const Value.absent(),
              }) => ImportSidesCompanion.insert(
                importId: importId,
                side: side,
                coverage: coverage,
                sideDigest: sideDigest,
                rowCount: rowCount,
                invalidCount: invalidCount,
                duplicateCount: duplicateCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportSidesTable, ImportSide>(table),
                  $$ImportSidesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({importId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (importId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.importId,
                        referencedTable: $$ImportSidesTableReferences
                            ._importIdTable(db),
                        referencedColumn: $$ImportSidesTableReferences
                            ._importIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportSidesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportSidesTable,
      ImportSide,
      $$ImportSidesTableFilterComposer,
      $$ImportSidesTableOrderingComposer,
      $$ImportSidesTableAnnotationComposer,
      $$ImportSidesTableCreateCompanionBuilder,
      $$ImportSidesTableUpdateCompanionBuilder,
      (ImportSide, $$ImportSidesTableReferences),
      ImportSide,
      PrefetchHooks Function({bool importId})
    >;
typedef $$ObservedAccountsTableCreateCompanionBuilder =
    ObservedAccountsCompanion Function({
      Value<int> id,
      required String canonicalUsername,
      required String firstDisplayUsername,
      required int firstSeenImportId,
    });
typedef $$ObservedAccountsTableUpdateCompanionBuilder =
    ObservedAccountsCompanion Function({
      Value<int> id,
      Value<String> canonicalUsername,
      Value<String> firstDisplayUsername,
      Value<int> firstSeenImportId,
    });

final class $$ObservedAccountsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ObservedAccountsTable, ObservedAccount> {
  $$ObservedAccountsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportsTable _firstSeenImportIdTable(_$AppDatabase db) => db.imports
      .createAlias('observed_accounts__first_seen_import_id__imports__id');

  $$ImportsTableProcessedTableManager get firstSeenImportId {
    final $_column = $_itemColumn<int>('first_seen_import_id')!;

    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_firstSeenImportIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ImportEntriesTable, List<ImportEntry>>
  _importEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.importEntries,
    aliasName: 'observed_accounts__id__import_entries__account_id',
  );

  $$ImportEntriesTableProcessedTableManager get importEntriesRefs {
    final manager = $$ImportEntriesTableTableManager(
      $_db,
      $_db.importEntries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_importEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RelationshipStatesTable, List<RelationshipState>>
  _relationshipStatesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.relationshipStates,
        aliasName: 'observed_accounts__id__relationship_states__account_id',
      );

  $$RelationshipStatesTableProcessedTableManager get relationshipStatesRefs {
    final manager = $$RelationshipStatesTableTableManager(
      $_db,
      $_db.relationshipStates,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _relationshipStatesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RelationshipChangesTable,
    List<RelationshipChange>
  >
  _relationshipChangesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.relationshipChanges,
        aliasName: 'observed_accounts__id__relationship_changes__account_id',
      );

  $$RelationshipChangesTableProcessedTableManager get relationshipChangesRefs {
    final manager = $$RelationshipChangesTableTableManager(
      $_db,
      $_db.relationshipChanges,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _relationshipChangesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObservedAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $ObservedAccountsTable> {
  $$ObservedAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get canonicalUsername => $composableBuilder(
    column: $table.canonicalUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstDisplayUsername => $composableBuilder(
    column: $table.firstDisplayUsername,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportsTableFilterComposer get firstSeenImportId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstSeenImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> importEntriesRefs(
    Expression<bool> Function($$ImportEntriesTableFilterComposer f) f,
  ) {
    final $$ImportEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportEntriesTableFilterComposer(
            $db: $db,
            $table: $db.importEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> relationshipStatesRefs(
    Expression<bool> Function($$RelationshipStatesTableFilterComposer f) f,
  ) {
    final $$RelationshipStatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationshipStates,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipStatesTableFilterComposer(
            $db: $db,
            $table: $db.relationshipStates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> relationshipChangesRefs(
    Expression<bool> Function($$RelationshipChangesTableFilterComposer f) f,
  ) {
    final $$RelationshipChangesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.relationshipChanges,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RelationshipChangesTableFilterComposer(
            $db: $db,
            $table: $db.relationshipChanges,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObservedAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObservedAccountsTable> {
  $$ObservedAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get canonicalUsername => $composableBuilder(
    column: $table.canonicalUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstDisplayUsername => $composableBuilder(
    column: $table.firstDisplayUsername,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportsTableOrderingComposer get firstSeenImportId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstSeenImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObservedAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObservedAccountsTable> {
  $$ObservedAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get canonicalUsername => $composableBuilder(
    column: $table.canonicalUsername,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstDisplayUsername => $composableBuilder(
    column: $table.firstDisplayUsername,
    builder: (column) => column,
  );

  $$ImportsTableAnnotationComposer get firstSeenImportId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstSeenImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> importEntriesRefs<T extends Object>(
    Expression<T> Function($$ImportEntriesTableAnnotationComposer a) f,
  ) {
    final $$ImportEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.importEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> relationshipStatesRefs<T extends Object>(
    Expression<T> Function($$RelationshipStatesTableAnnotationComposer a) f,
  ) {
    final $$RelationshipStatesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.relationshipStates,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RelationshipStatesTableAnnotationComposer(
                $db: $db,
                $table: $db.relationshipStates,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> relationshipChangesRefs<T extends Object>(
    Expression<T> Function($$RelationshipChangesTableAnnotationComposer a) f,
  ) {
    final $$RelationshipChangesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.relationshipChanges,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RelationshipChangesTableAnnotationComposer(
                $db: $db,
                $table: $db.relationshipChanges,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ObservedAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObservedAccountsTable,
          ObservedAccount,
          $$ObservedAccountsTableFilterComposer,
          $$ObservedAccountsTableOrderingComposer,
          $$ObservedAccountsTableAnnotationComposer,
          $$ObservedAccountsTableCreateCompanionBuilder,
          $$ObservedAccountsTableUpdateCompanionBuilder,
          (ObservedAccount, $$ObservedAccountsTableReferences),
          ObservedAccount,
          PrefetchHooks Function({
            bool firstSeenImportId,
            bool importEntriesRefs,
            bool relationshipStatesRefs,
            bool relationshipChangesRefs,
          })
        > {
  $$ObservedAccountsTableTableManager(
    _$AppDatabase db,
    $ObservedAccountsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObservedAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObservedAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObservedAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> canonicalUsername = const Value.absent(),
                Value<String> firstDisplayUsername = const Value.absent(),
                Value<int> firstSeenImportId = const Value.absent(),
              }) => ObservedAccountsCompanion(
                id: id,
                canonicalUsername: canonicalUsername,
                firstDisplayUsername: firstDisplayUsername,
                firstSeenImportId: firstSeenImportId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String canonicalUsername,
                required String firstDisplayUsername,
                required int firstSeenImportId,
              }) => ObservedAccountsCompanion.insert(
                id: id,
                canonicalUsername: canonicalUsername,
                firstDisplayUsername: firstDisplayUsername,
                firstSeenImportId: firstSeenImportId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ObservedAccountsTable, ObservedAccount>(table),
                  $$ObservedAccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                firstSeenImportId = false,
                importEntriesRefs = false,
                relationshipStatesRefs = false,
                relationshipChangesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (importEntriesRefs) db.importEntries,
                    if (relationshipStatesRefs) db.relationshipStates,
                    if (relationshipChangesRefs) db.relationshipChanges,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (firstSeenImportId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.firstSeenImportId,
                            referencedTable: $$ObservedAccountsTableReferences
                                ._firstSeenImportIdTable(db),
                            referencedColumn: $$ObservedAccountsTableReferences
                                ._firstSeenImportIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (importEntriesRefs)
                        await $_getPrefetchedData<
                          ObservedAccount,
                          $ObservedAccountsTable,
                          ImportEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ObservedAccountsTableReferences
                              ._importEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObservedAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).importEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (relationshipStatesRefs)
                        await $_getPrefetchedData<
                          ObservedAccount,
                          $ObservedAccountsTable,
                          RelationshipState
                        >(
                          currentTable: table,
                          referencedTable: $$ObservedAccountsTableReferences
                              ._relationshipStatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObservedAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).relationshipStatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (relationshipChangesRefs)
                        await $_getPrefetchedData<
                          ObservedAccount,
                          $ObservedAccountsTable,
                          RelationshipChange
                        >(
                          currentTable: table,
                          referencedTable: $$ObservedAccountsTableReferences
                              ._relationshipChangesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObservedAccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).relationshipChangesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.accountId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ObservedAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObservedAccountsTable,
      ObservedAccount,
      $$ObservedAccountsTableFilterComposer,
      $$ObservedAccountsTableOrderingComposer,
      $$ObservedAccountsTableAnnotationComposer,
      $$ObservedAccountsTableCreateCompanionBuilder,
      $$ObservedAccountsTableUpdateCompanionBuilder,
      (ObservedAccount, $$ObservedAccountsTableReferences),
      ObservedAccount,
      PrefetchHooks Function({
        bool firstSeenImportId,
        bool importEntriesRefs,
        bool relationshipStatesRefs,
        bool relationshipChangesRefs,
      })
    >;
typedef $$ImportEntriesTableCreateCompanionBuilder =
    ImportEntriesCompanion Function({
      required int importId,
      required String side,
      required int accountId,
      required String displayUsername,
      Value<int?> sourceTimestampSeconds,
      Value<String?> timestampKind,
      Value<int> rowid,
    });
typedef $$ImportEntriesTableUpdateCompanionBuilder =
    ImportEntriesCompanion Function({
      Value<int> importId,
      Value<String> side,
      Value<int> accountId,
      Value<String> displayUsername,
      Value<int?> sourceTimestampSeconds,
      Value<String?> timestampKind,
      Value<int> rowid,
    });

final class $$ImportEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $ImportEntriesTable, ImportEntry> {
  $$ImportEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ObservedAccountsTable _accountIdTable(_$AppDatabase db) => db
      .observedAccounts
      .createAlias('import_entries__account_id__observed_accounts__id');

  $$ObservedAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$ObservedAccountsTableTableManager(
      $_db,
      $_db.observedAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ImportEntriesTable> {
  $$ImportEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get importId => $composableBuilder(
    column: $table.importId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayUsername => $composableBuilder(
    column: $table.displayUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceTimestampSeconds => $composableBuilder(
    column: $table.sourceTimestampSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timestampKind => $composableBuilder(
    column: $table.timestampKind,
    builder: (column) => ColumnFilters(column),
  );

  $$ObservedAccountsTableFilterComposer get accountId {
    final $$ObservedAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableFilterComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportEntriesTable> {
  $$ImportEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get importId => $composableBuilder(
    column: $table.importId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayUsername => $composableBuilder(
    column: $table.displayUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceTimestampSeconds => $composableBuilder(
    column: $table.sourceTimestampSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timestampKind => $composableBuilder(
    column: $table.timestampKind,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObservedAccountsTableOrderingComposer get accountId {
    final $$ObservedAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportEntriesTable> {
  $$ImportEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get importId =>
      $composableBuilder(column: $table.importId, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get displayUsername => $composableBuilder(
    column: $table.displayUsername,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceTimestampSeconds => $composableBuilder(
    column: $table.sourceTimestampSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timestampKind => $composableBuilder(
    column: $table.timestampKind,
    builder: (column) => column,
  );

  $$ObservedAccountsTableAnnotationComposer get accountId {
    final $$ObservedAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportEntriesTable,
          ImportEntry,
          $$ImportEntriesTableFilterComposer,
          $$ImportEntriesTableOrderingComposer,
          $$ImportEntriesTableAnnotationComposer,
          $$ImportEntriesTableCreateCompanionBuilder,
          $$ImportEntriesTableUpdateCompanionBuilder,
          (ImportEntry, $$ImportEntriesTableReferences),
          ImportEntry,
          PrefetchHooks Function({bool accountId})
        > {
  $$ImportEntriesTableTableManager(_$AppDatabase db, $ImportEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> importId = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<String> displayUsername = const Value.absent(),
                Value<int?> sourceTimestampSeconds = const Value.absent(),
                Value<String?> timestampKind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportEntriesCompanion(
                importId: importId,
                side: side,
                accountId: accountId,
                displayUsername: displayUsername,
                sourceTimestampSeconds: sourceTimestampSeconds,
                timestampKind: timestampKind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int importId,
                required String side,
                required int accountId,
                required String displayUsername,
                Value<int?> sourceTimestampSeconds = const Value.absent(),
                Value<String?> timestampKind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportEntriesCompanion.insert(
                importId: importId,
                side: side,
                accountId: accountId,
                displayUsername: displayUsername,
                sourceTimestampSeconds: sourceTimestampSeconds,
                timestampKind: timestampKind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportEntriesTable, ImportEntry>(table),
                  $$ImportEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$ImportEntriesTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$ImportEntriesTableReferences
                            ._accountIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportEntriesTable,
      ImportEntry,
      $$ImportEntriesTableFilterComposer,
      $$ImportEntriesTableOrderingComposer,
      $$ImportEntriesTableAnnotationComposer,
      $$ImportEntriesTableCreateCompanionBuilder,
      $$ImportEntriesTableUpdateCompanionBuilder,
      (ImportEntry, $$ImportEntriesTableReferences),
      ImportEntry,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$RelationshipStatesTableCreateCompanionBuilder =
    RelationshipStatesCompanion Function({
      required int accountId,
      required String side,
      required String status,
      Value<int?> firstPositiveImportId,
      Value<int?> lastPositiveImportId,
      Value<int?> firstCompleteAbsenceImportId,
      Value<int?> latestCompleteAbsenceImportId,
      Value<int> rowid,
    });
typedef $$RelationshipStatesTableUpdateCompanionBuilder =
    RelationshipStatesCompanion Function({
      Value<int> accountId,
      Value<String> side,
      Value<String> status,
      Value<int?> firstPositiveImportId,
      Value<int?> lastPositiveImportId,
      Value<int?> firstCompleteAbsenceImportId,
      Value<int?> latestCompleteAbsenceImportId,
      Value<int> rowid,
    });

final class $$RelationshipStatesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RelationshipStatesTable,
          RelationshipState
        > {
  $$RelationshipStatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ObservedAccountsTable _accountIdTable(_$AppDatabase db) => db
      .observedAccounts
      .createAlias('relationship_states__account_id__observed_accounts__id');

  $$ObservedAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$ObservedAccountsTableTableManager(
      $_db,
      $_db.observedAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportsTable _firstPositiveImportIdTable(_$AppDatabase db) =>
      db.imports.createAlias(
        'relationship_states__first_positive_import_id__imports__id',
      );

  $$ImportsTableProcessedTableManager? get firstPositiveImportId {
    final $_column = $_itemColumn<int>('first_positive_import_id');
    if ($_column == null) return null;
    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _firstPositiveImportIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportsTable _lastPositiveImportIdTable(_$AppDatabase db) => db
      .imports
      .createAlias('relationship_states__last_positive_import_id__imports__id');

  $$ImportsTableProcessedTableManager? get lastPositiveImportId {
    final $_column = $_itemColumn<int>('last_positive_import_id');
    if ($_column == null) return null;
    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _lastPositiveImportIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportsTable _firstCompleteAbsenceImportIdTable(_$AppDatabase db) =>
      db.imports.createAlias(
        'relationship_states__first_complete_absence_import_id__imports__id',
      );

  $$ImportsTableProcessedTableManager? get firstCompleteAbsenceImportId {
    final $_column = $_itemColumn<int>('first_complete_absence_import_id');
    if ($_column == null) return null;
    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _firstCompleteAbsenceImportIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportsTable _latestCompleteAbsenceImportIdTable(_$AppDatabase db) =>
      db.imports.createAlias(
        'relationship_states__latest_complete_absence_import_id__imports__id',
      );

  $$ImportsTableProcessedTableManager? get latestCompleteAbsenceImportId {
    final $_column = $_itemColumn<int>('latest_complete_absence_import_id');
    if ($_column == null) return null;
    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _latestCompleteAbsenceImportIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RelationshipStatesTableFilterComposer
    extends Composer<_$AppDatabase, $RelationshipStatesTable> {
  $$RelationshipStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  $$ObservedAccountsTableFilterComposer get accountId {
    final $$ObservedAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableFilterComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableFilterComposer get firstPositiveImportId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstPositiveImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableFilterComposer get lastPositiveImportId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastPositiveImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableFilterComposer get firstCompleteAbsenceImportId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstCompleteAbsenceImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableFilterComposer get latestCompleteAbsenceImportId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.latestCompleteAbsenceImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $RelationshipStatesTable> {
  $$RelationshipStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObservedAccountsTableOrderingComposer get accountId {
    final $$ObservedAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableOrderingComposer get firstPositiveImportId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstPositiveImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableOrderingComposer get lastPositiveImportId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastPositiveImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableOrderingComposer get firstCompleteAbsenceImportId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstCompleteAbsenceImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableOrderingComposer get latestCompleteAbsenceImportId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.latestCompleteAbsenceImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelationshipStatesTable> {
  $$RelationshipStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$ObservedAccountsTableAnnotationComposer get accountId {
    final $$ObservedAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableAnnotationComposer get firstPositiveImportId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstPositiveImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableAnnotationComposer get lastPositiveImportId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lastPositiveImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableAnnotationComposer get firstCompleteAbsenceImportId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.firstCompleteAbsenceImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableAnnotationComposer get latestCompleteAbsenceImportId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.latestCompleteAbsenceImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RelationshipStatesTable,
          RelationshipState,
          $$RelationshipStatesTableFilterComposer,
          $$RelationshipStatesTableOrderingComposer,
          $$RelationshipStatesTableAnnotationComposer,
          $$RelationshipStatesTableCreateCompanionBuilder,
          $$RelationshipStatesTableUpdateCompanionBuilder,
          (RelationshipState, $$RelationshipStatesTableReferences),
          RelationshipState,
          PrefetchHooks Function({
            bool accountId,
            bool firstPositiveImportId,
            bool lastPositiveImportId,
            bool firstCompleteAbsenceImportId,
            bool latestCompleteAbsenceImportId,
          })
        > {
  $$RelationshipStatesTableTableManager(
    _$AppDatabase db,
    $RelationshipStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationshipStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelationshipStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelationshipStatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> accountId = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> firstPositiveImportId = const Value.absent(),
                Value<int?> lastPositiveImportId = const Value.absent(),
                Value<int?> firstCompleteAbsenceImportId = const Value.absent(),
                Value<int?> latestCompleteAbsenceImportId =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationshipStatesCompanion(
                accountId: accountId,
                side: side,
                status: status,
                firstPositiveImportId: firstPositiveImportId,
                lastPositiveImportId: lastPositiveImportId,
                firstCompleteAbsenceImportId: firstCompleteAbsenceImportId,
                latestCompleteAbsenceImportId: latestCompleteAbsenceImportId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int accountId,
                required String side,
                required String status,
                Value<int?> firstPositiveImportId = const Value.absent(),
                Value<int?> lastPositiveImportId = const Value.absent(),
                Value<int?> firstCompleteAbsenceImportId = const Value.absent(),
                Value<int?> latestCompleteAbsenceImportId =
                    const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RelationshipStatesCompanion.insert(
                accountId: accountId,
                side: side,
                status: status,
                firstPositiveImportId: firstPositiveImportId,
                lastPositiveImportId: lastPositiveImportId,
                firstCompleteAbsenceImportId: firstCompleteAbsenceImportId,
                latestCompleteAbsenceImportId: latestCompleteAbsenceImportId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RelationshipStatesTable, RelationshipState>(
                    table,
                  ),
                  $$RelationshipStatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                firstPositiveImportId = false,
                lastPositiveImportId = false,
                firstCompleteAbsenceImportId = false,
                latestCompleteAbsenceImportId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$RelationshipStatesTableReferences
                                ._accountIdTable(db),
                            referencedColumn:
                                $$RelationshipStatesTableReferences
                                    ._accountIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (firstPositiveImportId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.firstPositiveImportId,
                            referencedTable: $$RelationshipStatesTableReferences
                                ._firstPositiveImportIdTable(db),
                            referencedColumn:
                                $$RelationshipStatesTableReferences
                                    ._firstPositiveImportIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (lastPositiveImportId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.lastPositiveImportId,
                            referencedTable: $$RelationshipStatesTableReferences
                                ._lastPositiveImportIdTable(db),
                            referencedColumn:
                                $$RelationshipStatesTableReferences
                                    ._lastPositiveImportIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (firstCompleteAbsenceImportId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.firstCompleteAbsenceImportId,
                            referencedTable: $$RelationshipStatesTableReferences
                                ._firstCompleteAbsenceImportIdTable(db),
                            referencedColumn:
                                $$RelationshipStatesTableReferences
                                    ._firstCompleteAbsenceImportIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (latestCompleteAbsenceImportId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.latestCompleteAbsenceImportId,
                            referencedTable: $$RelationshipStatesTableReferences
                                ._latestCompleteAbsenceImportIdTable(db),
                            referencedColumn:
                                $$RelationshipStatesTableReferences
                                    ._latestCompleteAbsenceImportIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$RelationshipStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RelationshipStatesTable,
      RelationshipState,
      $$RelationshipStatesTableFilterComposer,
      $$RelationshipStatesTableOrderingComposer,
      $$RelationshipStatesTableAnnotationComposer,
      $$RelationshipStatesTableCreateCompanionBuilder,
      $$RelationshipStatesTableUpdateCompanionBuilder,
      (RelationshipState, $$RelationshipStatesTableReferences),
      RelationshipState,
      PrefetchHooks Function({
        bool accountId,
        bool firstPositiveImportId,
        bool lastPositiveImportId,
        bool firstCompleteAbsenceImportId,
        bool latestCompleteAbsenceImportId,
      })
    >;
typedef $$RelationshipChangesTableCreateCompanionBuilder =
    RelationshipChangesCompanion Function({
      Value<int> id,
      required int importId,
      required String side,
      required int accountId,
      required String kind,
      Value<int?> priorEvidenceImportId,
    });
typedef $$RelationshipChangesTableUpdateCompanionBuilder =
    RelationshipChangesCompanion Function({
      Value<int> id,
      Value<int> importId,
      Value<String> side,
      Value<int> accountId,
      Value<String> kind,
      Value<int?> priorEvidenceImportId,
    });

final class $$RelationshipChangesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RelationshipChangesTable,
          RelationshipChange
        > {
  $$RelationshipChangesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportsTable _importIdTable(_$AppDatabase db) =>
      db.imports.createAlias('relationship_changes__import_id__imports__id');

  $$ImportsTableProcessedTableManager get importId {
    final $_column = $_itemColumn<int>('import_id')!;

    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ObservedAccountsTable _accountIdTable(_$AppDatabase db) => db
      .observedAccounts
      .createAlias('relationship_changes__account_id__observed_accounts__id');

  $$ObservedAccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$ObservedAccountsTableTableManager(
      $_db,
      $_db.observedAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ImportsTable _priorEvidenceImportIdTable(_$AppDatabase db) =>
      db.imports.createAlias(
        'relationship_changes__prior_evidence_import_id__imports__id',
      );

  $$ImportsTableProcessedTableManager? get priorEvidenceImportId {
    final $_column = $_itemColumn<int>('prior_evidence_import_id');
    if ($_column == null) return null;
    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _priorEvidenceImportIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RelationshipChangesTableFilterComposer
    extends Composer<_$AppDatabase, $RelationshipChangesTable> {
  $$RelationshipChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportsTableFilterComposer get importId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObservedAccountsTableFilterComposer get accountId {
    final $$ObservedAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableFilterComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableFilterComposer get priorEvidenceImportId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.priorEvidenceImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $RelationshipChangesTable> {
  $$RelationshipChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportsTableOrderingComposer get importId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObservedAccountsTableOrderingComposer get accountId {
    final $$ObservedAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableOrderingComposer get priorEvidenceImportId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.priorEvidenceImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelationshipChangesTable> {
  $$RelationshipChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  $$ImportsTableAnnotationComposer get importId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObservedAccountsTableAnnotationComposer get accountId {
    final $$ObservedAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.observedAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObservedAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.observedAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ImportsTableAnnotationComposer get priorEvidenceImportId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.priorEvidenceImportId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RelationshipChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RelationshipChangesTable,
          RelationshipChange,
          $$RelationshipChangesTableFilterComposer,
          $$RelationshipChangesTableOrderingComposer,
          $$RelationshipChangesTableAnnotationComposer,
          $$RelationshipChangesTableCreateCompanionBuilder,
          $$RelationshipChangesTableUpdateCompanionBuilder,
          (RelationshipChange, $$RelationshipChangesTableReferences),
          RelationshipChange,
          PrefetchHooks Function({
            bool importId,
            bool accountId,
            bool priorEvidenceImportId,
          })
        > {
  $$RelationshipChangesTableTableManager(
    _$AppDatabase db,
    $RelationshipChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelationshipChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelationshipChangesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RelationshipChangesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> importId = const Value.absent(),
                Value<String> side = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> priorEvidenceImportId = const Value.absent(),
              }) => RelationshipChangesCompanion(
                id: id,
                importId: importId,
                side: side,
                accountId: accountId,
                kind: kind,
                priorEvidenceImportId: priorEvidenceImportId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int importId,
                required String side,
                required int accountId,
                required String kind,
                Value<int?> priorEvidenceImportId = const Value.absent(),
              }) => RelationshipChangesCompanion.insert(
                id: id,
                importId: importId,
                side: side,
                accountId: accountId,
                kind: kind,
                priorEvidenceImportId: priorEvidenceImportId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RelationshipChangesTable, RelationshipChange>(
                    table,
                  ),
                  $$RelationshipChangesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                importId = false,
                accountId = false,
                priorEvidenceImportId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (importId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.importId,
                            referencedTable:
                                $$RelationshipChangesTableReferences
                                    ._importIdTable(db),
                            referencedColumn:
                                $$RelationshipChangesTableReferences
                                    ._importIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable:
                                $$RelationshipChangesTableReferences
                                    ._accountIdTable(db),
                            referencedColumn:
                                $$RelationshipChangesTableReferences
                                    ._accountIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (priorEvidenceImportId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.priorEvidenceImportId,
                            referencedTable:
                                $$RelationshipChangesTableReferences
                                    ._priorEvidenceImportIdTable(db),
                            referencedColumn:
                                $$RelationshipChangesTableReferences
                                    ._priorEvidenceImportIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$RelationshipChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RelationshipChangesTable,
      RelationshipChange,
      $$RelationshipChangesTableFilterComposer,
      $$RelationshipChangesTableOrderingComposer,
      $$RelationshipChangesTableAnnotationComposer,
      $$RelationshipChangesTableCreateCompanionBuilder,
      $$RelationshipChangesTableUpdateCompanionBuilder,
      (RelationshipChange, $$RelationshipChangesTableReferences),
      RelationshipChange,
      PrefetchHooks Function({
        bool importId,
        bool accountId,
        bool priorEvidenceImportId,
      })
    >;
typedef $$ImportWarningsTableCreateCompanionBuilder =
    ImportWarningsCompanion Function({
      Value<int> id,
      required int importId,
      Value<String?> side,
      required String code,
      required int count,
    });
typedef $$ImportWarningsTableUpdateCompanionBuilder =
    ImportWarningsCompanion Function({
      Value<int> id,
      Value<int> importId,
      Value<String?> side,
      Value<String> code,
      Value<int> count,
    });

final class $$ImportWarningsTableReferences
    extends BaseReferences<_$AppDatabase, $ImportWarningsTable, ImportWarning> {
  $$ImportWarningsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ImportsTable _importIdTable(_$AppDatabase db) =>
      db.imports.createAlias('import_warnings__import_id__imports__id');

  $$ImportsTableProcessedTableManager get importId {
    final $_column = $_itemColumn<int>('import_id')!;

    final manager = $$ImportsTableTableManager(
      $_db,
      $_db.imports,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_importIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportWarningsTableFilterComposer
    extends Composer<_$AppDatabase, $ImportWarningsTable> {
  $$ImportWarningsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  $$ImportsTableFilterComposer get importId {
    final $$ImportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableFilterComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportWarningsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportWarningsTable> {
  $$ImportWarningsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get side => $composableBuilder(
    column: $table.side,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  $$ImportsTableOrderingComposer get importId {
    final $$ImportsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableOrderingComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportWarningsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportWarningsTable> {
  $$ImportWarningsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get side =>
      $composableBuilder(column: $table.side, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  $$ImportsTableAnnotationComposer get importId {
    final $$ImportsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.importId,
      referencedTable: $db.imports,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportsTableAnnotationComposer(
            $db: $db,
            $table: $db.imports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportWarningsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportWarningsTable,
          ImportWarning,
          $$ImportWarningsTableFilterComposer,
          $$ImportWarningsTableOrderingComposer,
          $$ImportWarningsTableAnnotationComposer,
          $$ImportWarningsTableCreateCompanionBuilder,
          $$ImportWarningsTableUpdateCompanionBuilder,
          (ImportWarning, $$ImportWarningsTableReferences),
          ImportWarning,
          PrefetchHooks Function({bool importId})
        > {
  $$ImportWarningsTableTableManager(
    _$AppDatabase db,
    $ImportWarningsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportWarningsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportWarningsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportWarningsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> importId = const Value.absent(),
                Value<String?> side = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<int> count = const Value.absent(),
              }) => ImportWarningsCompanion(
                id: id,
                importId: importId,
                side: side,
                code: code,
                count: count,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int importId,
                Value<String?> side = const Value.absent(),
                required String code,
                required int count,
              }) => ImportWarningsCompanion.insert(
                id: id,
                importId: importId,
                side: side,
                code: code,
                count: count,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImportWarningsTable, ImportWarning>(table),
                  $$ImportWarningsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({importId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (importId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.importId,
                        referencedTable: $$ImportWarningsTableReferences
                            ._importIdTable(db),
                        referencedColumn: $$ImportWarningsTableReferences
                            ._importIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImportWarningsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportWarningsTable,
      ImportWarning,
      $$ImportWarningsTableFilterComposer,
      $$ImportWarningsTableOrderingComposer,
      $$ImportWarningsTableAnnotationComposer,
      $$ImportWarningsTableCreateCompanionBuilder,
      $$ImportWarningsTableUpdateCompanionBuilder,
      (ImportWarning, $$ImportWarningsTableReferences),
      ImportWarning,
      PrefetchHooks Function({bool importId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ImportsTableTableManager get imports =>
      $$ImportsTableTableManager(_db, _db.imports);
  $$ImportSidesTableTableManager get importSides =>
      $$ImportSidesTableTableManager(_db, _db.importSides);
  $$ObservedAccountsTableTableManager get observedAccounts =>
      $$ObservedAccountsTableTableManager(_db, _db.observedAccounts);
  $$ImportEntriesTableTableManager get importEntries =>
      $$ImportEntriesTableTableManager(_db, _db.importEntries);
  $$RelationshipStatesTableTableManager get relationshipStates =>
      $$RelationshipStatesTableTableManager(_db, _db.relationshipStates);
  $$RelationshipChangesTableTableManager get relationshipChanges =>
      $$RelationshipChangesTableTableManager(_db, _db.relationshipChanges);
  $$ImportWarningsTableTableManager get importWarnings =>
      $$ImportWarningsTableTableManager(_db, _db.importWarnings);
}
