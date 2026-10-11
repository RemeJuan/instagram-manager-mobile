import 'dart:convert';

import 'dart:collection';

import '../domain/relationship.dart' show UsernameIdentity;
import '../domain/relationship.dart' show RelationshipSide;

export '../domain/relationship.dart' show RelationshipSide;

enum RelationshipWarningCode {
  invalidRows,
  duplicateRows,
  conflictingDuplicate,
}

enum RelationshipJsonErrorCode {
  sizeLimitExceeded,
  invalidEncodingOrSyntax,
  unrecognizedStructure,
  malformedRecognizedStructure,
  ambiguousWrappers,
  rowLimitExceeded,
}

class RelationshipRecord {
  const RelationshipRecord({
    required this.identity,
    required this.displayUsername,
    required this.profileUrl,
    required this.sourceTimestamp,
  });
  final String identity;
  final String displayUsername;
  final String profileUrl;
  final int? sourceTimestamp;
}

class ParsedRelationshipFile {
  ParsedRelationshipFile({
    required this.side,
    required Iterable<RelationshipRecord> records,
    required this.invalidCount,
    required this.duplicateCount,
    required this.rowCount,
    required Iterable<String> warnings,
    Iterable<RelationshipWarningCode> warningCodes = const [],
  }) : records = List.unmodifiable(records),
       warnings = List.unmodifiable(warnings),
       warningCodes = List.unmodifiable(warningCodes);
  final RelationshipSide side;
  final List<RelationshipRecord> records;
  final int invalidCount;
  final int duplicateCount;
  final int rowCount;
  final List<String> warnings;
  final List<RelationshipWarningCode> warningCodes;
}

class RelationshipSummary {
  RelationshipSummary({
    required this.following,
    required this.followers,
    required Set<RelationshipSide> completeSides,
  }) : completeSides = Set.unmodifiable(completeSides),
       mutual = Set.unmodifiable(following.intersection(followers)),
       followingOnly = completeSides.contains(RelationshipSide.followers)
           ? Set.unmodifiable(following.difference(followers))
           : null,
       followerOnly = completeSides.contains(RelationshipSide.following)
           ? Set.unmodifiable(followers.difference(following))
           : null;
  final Set<String> following;
  final Set<String> followers;
  final Set<String> mutual;
  final Set<String>? followingOnly;
  final Set<String>? followerOnly;
  final Set<RelationshipSide> completeSides;
}

class RelationshipJsonException implements FormatException {
  RelationshipJsonException(this.message, [this.code]);
  @override
  final String message;
  final RelationshipJsonErrorCode? code;
  @override
  int? get offset => null;
  @override
  dynamic get source => null;
  @override
  String toString() => message;
}

ParsedRelationshipFile parseRelationshipJson(
  String sourceName,
  List<int> bytes,
) {
  if (bytes.length > 20 * 1024 * 1024) {
    throw RelationshipJsonException(
      'Relationship JSON exceeds size limit.',
      RelationshipJsonErrorCode.sizeLimitExceeded,
    );
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(utf8.decode(bytes, allowMalformed: false));
  } on FormatException {
    throw RelationshipJsonException(
      'Invalid relationship JSON encoding or syntax.',
      RelationshipJsonErrorCode.invalidEncodingOrSyntax,
    );
  }
  if (decoded is List) return _parseRows(RelationshipSide.followers, decoded);
  if (decoded is! Map) {
    throw RelationshipJsonException(
      'Unrecognized relationship JSON structure.',
      RelationshipJsonErrorCode.unrecognizedStructure,
    );
  }
  final hasFollowing = decoded.containsKey('relationships_following');
  final hasFollowers = decoded.containsKey('followers');
  final splitKeys = decoded.keys
      .whereType<String>()
      .where((key) => RegExp(r'^followers_\d+$').hasMatch(key))
      .toList();
  final unsupportedWrapperKeys = decoded.keys
      .whereType<String>()
      .where(
        (key) =>
            key.startsWith('relationships_') &&
                key != 'relationships_following' ||
            RegExp(r'^followers(?:_.*)?$').hasMatch(key) &&
                key != 'followers' &&
                !RegExp(r'^followers_\d+$').hasMatch(key),
      )
      .toList();
  if (unsupportedWrapperKeys.isNotEmpty) {
    throw RelationshipJsonException(
      'Unsupported or ambiguous relationship JSON wrapper.',
      RelationshipJsonErrorCode.ambiguousWrappers,
    );
  }
  final kinds =
      (hasFollowing ? 1 : 0) +
      (hasFollowers ? 1 : 0) +
      (splitKeys.isNotEmpty ? 1 : 0);
  if (kinds > 1) {
    throw RelationshipJsonException(
      'Ambiguous relationship JSON wrappers.',
      RelationshipJsonErrorCode.ambiguousWrappers,
    );
  }
  if (hasFollowing) {
    final rows = decoded['relationships_following'];
    if (rows is! List) {
      throw RelationshipJsonException(
        'Malformed recognized relationship structure.',
        RelationshipJsonErrorCode.malformedRecognizedStructure,
      );
    }
    return _parseRows(RelationshipSide.following, rows);
  }
  if (hasFollowers) {
    final rows = decoded['followers'];
    if (rows is! List) {
      throw RelationshipJsonException(
        'Malformed recognized relationship structure.',
        RelationshipJsonErrorCode.malformedRecognizedStructure,
      );
    }
    return _parseRows(RelationshipSide.followers, rows);
  }
  if (splitKeys.isNotEmpty) {
    splitKeys.sort();
    var count = 0;
    for (final key in splitKeys) {
      final part = decoded[key];
      if (part is! List) {
        throw RelationshipJsonException(
          'Malformed recognized relationship structure.',
          RelationshipJsonErrorCode.malformedRecognizedStructure,
        );
      }
      count += part.length;
      if (count > _rowLimit) _throwRowLimit();
    }
    return _parseRows(
      RelationshipSide.followers,
      _JoinedRows(decoded, splitKeys, count),
    );
  }
  if (decoded.keys.every(
    (key) => key == 'title' || key == 'string_list_data',
  )) {
    return _parseRows(RelationshipSide.followers, [decoded]);
  }
  throw RelationshipJsonException(
    'Unrecognized relationship JSON structure.',
    RelationshipJsonErrorCode.unrecognizedStructure,
  );
}

const _rowLimit = 1000000;
Never _throwRowLimit() => throw RelationshipJsonException(
  'Relationship row limit exceeded.',
  RelationshipJsonErrorCode.rowLimitExceeded,
);

final class _JoinedRows extends ListBase<dynamic> {
  _JoinedRows(this.source, this.keys, this._length);
  final Map source;
  final List<String> keys;
  final int _length;
  @override
  int get length => _length;
  @override
  set length(int value) => throw UnsupportedError('fixed length');
  @override
  dynamic operator [](int index) {
    for (final key in keys) {
      final part = source[key] as List;
      if (index < part.length) return part[index];
      index -= part.length;
    }
    throw RangeError.index(index, this);
  }

  @override
  void operator []=(int index, dynamic value) =>
      throw UnsupportedError('fixed length');
}

ParsedRelationshipFile _parseRows(
  RelationshipSide side,
  Iterable<dynamic> rows,
) {
  final records = <RelationshipRecord>[];
  final seen = <String>{};
  final firstByIdentity = <String, RelationshipRecord>{};
  var invalid = 0, duplicates = 0;
  var conflictingDuplicates = 0;
  var rowCount = 0;
  for (final row in rows) {
    if (rowCount == _rowLimit) _throwRowLimit();
    rowCount++;
    final record = _parseRow(row);
    if (record == null) {
      invalid++;
      continue;
    }
    if (!seen.add(record.identity)) {
      duplicates++;
      final first = firstByIdentity[record.identity]!;
      if (first.displayUsername != record.displayUsername ||
          first.profileUrl != record.profileUrl ||
          first.sourceTimestamp != record.sourceTimestamp) {
        conflictingDuplicates++;
      }
      continue;
    }
    firstByIdentity[record.identity] = record;
    records.add(record);
  }
  final warnings = <String>[];
  final warningCodes = <RelationshipWarningCode>[];
  if (invalid > 0) {
    warnings.add('$invalid invalid relationship row(s) in input.');
    warningCodes.add(RelationshipWarningCode.invalidRows);
  }
  if (duplicates > 0) {
    warnings.add('$duplicates duplicate relationship row(s) in input.');
    warningCodes.add(RelationshipWarningCode.duplicateRows);
  }
  if (conflictingDuplicates > 0) {
    warnings.add(
      '$conflictingDuplicates conflicting duplicate relationship row(s) in input.',
    );
    warningCodes.add(RelationshipWarningCode.conflictingDuplicate);
  }
  return ParsedRelationshipFile(
    side: side,
    records: records,
    invalidCount: invalid,
    duplicateCount: duplicates,
    rowCount: rowCount,
    warnings: warnings,
    warningCodes: warningCodes,
  );
}

RelationshipRecord? _parseRow(Object? value) {
  if (value is! Map || value['string_list_data'] is! List) return null;
  final data = value['string_list_data'] as List;
  if (data.isEmpty) return null;
  final title = value['title'];
  if (title != null && title is! String) return null;
  String? identity;
  String? display;
  for (var i = 0; i < data.length; i++) {
    final raw = data[i];
    if (raw is! Map) return null;
    final candidates = <String>[];
    for (final source in [raw['value'], if (i == 0) title]) {
      if (source != null) {
        if (source is! String) return null;
        if (source.trim().isNotEmpty) candidates.add(source.trim());
      }
    }
    if (raw['href'] != null) {
      final hrefIdentity = _usernameFromHref(raw['href']);
      if (hrefIdentity == null) return null;
      candidates.add(hrefIdentity);
    }
    if (candidates.isEmpty) return null;
    final parsed = candidates.map(UsernameIdentity.tryParse).toList();
    if (parsed.any((item) => item == null) ||
        parsed.map((item) => item!.canonical).toSet().length != 1) {
      return null;
    }
    final current = parsed.first!.canonical;
    if (identity != null && identity != current) return null;
    identity ??= current;
    if (i == 0) display = parsed.first!.display;
  }
  final firstItem = data.first as Map;
  final timestamp = firstItem['timestamp'];
  return RelationshipRecord(
    identity: identity!,
    displayUsername: display!,
    profileUrl: 'https://www.instagram.com/$display/',
    sourceTimestamp: timestamp is int && timestamp >= 0 ? timestamp : null,
  );
}

String? _usernameFromHref(Object? value) {
  if (value is! String) return null;
  final uri = Uri.tryParse(value);
  if (uri == null ||
      uri.scheme != 'https' ||
      !{'www.instagram.com', 'instagram.com'}.contains(uri.host) ||
      uri.userInfo.isNotEmpty ||
      uri.hasPort ||
      uri.hasQuery ||
      uri.hasFragment) {
    return null;
  }
  final match = RegExp(r'^/(?:_u/)?([A-Za-z0-9._]+)/?$').firstMatch(uri.path);
  if (match == null ||
      const {
        'accounts',
        'explore',
        'direct',
        'reel',
        'reels',
        'stories',
        'p',
      }.contains(match.group(1)!.toLowerCase())) {
    return null;
  }
  return match.group(1);
}

RelationshipSummary summarizeRelationships(
  Iterable<ParsedRelationshipFile> files, {
  Set<RelationshipSide> completeSides = const {},
}) {
  final following = <String>{}, followers = <String>{};
  var total = 0;
  for (final file in files) {
    total += file.rowCount;
    if (total > _rowLimit) _throwRowLimit();
    final target = file.side == RelationshipSide.following
        ? following
        : followers;
    target.addAll(file.records.map((record) => record.identity));
  }
  return RelationshipSummary(
    following: Set.unmodifiable(following),
    followers: Set.unmodifiable(followers),
    completeSides: completeSides,
  );
}
