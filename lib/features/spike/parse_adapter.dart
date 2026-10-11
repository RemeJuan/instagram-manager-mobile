import 'dart:io';
import 'dart:isolate';
import 'dart:convert';

import 'package:kinship_mobile/features/spike/spike_screen.dart';
import 'package:kinship_mobile/import/validated_zip.dart';
import 'package:kinship_mobile/import/relationship_json.dart';

const int _maxJsonBytes = 20 * 1024 * 1024;
const int _zipSignaturePrefixLength = 4;
const String _completenessWarning =
    'Category differences assume the selected export is complete and are not persisted absence evidence. Exports do not establish relationship-event timing.';

/// Parses standalone relationship JSON or bounded entries from a validated ZIP.
Future<SpikeSummary> parseSpikeInput(String workingPath) async {
  final file = File(workingPath);
  try {
    final prefix = await file
        .openRead(0, _zipSignaturePrefixLength)
        .fold<List<int>>(<int>[], (bytes, chunk) => bytes..addAll(chunk));
    if (_hasZipSignature(prefix)) {
      return await Isolate.run(() async {
        final tempRoot = Directory(File(workingPath).parent.path);
        return await withValidatedZipEntries(
          File(workingPath),
          tempRoot,
          (entries) async => _parseZipEntries(entries),
        );
      });
    }
    if (prefix.length >= 4 && prefix[0] == 0x50 && prefix[1] == 0x4b) {
      throw const SpikeInputException(
        'Unable to validate this ZIP export. No results were saved.',
      );
    }
    final length = await file.length();
    if (length > _maxJsonBytes) {
      throw const SpikeInputException(
        'JSON import exceeds the 20 MiB limit. No results were saved.',
      );
    }
    return await Isolate.run(() async {
      final bytes = await File(workingPath).readAsBytes();
      if (bytes.length > _maxJsonBytes) {
        throw const SpikeInputException(
          'JSON import exceeds the 20 MiB limit. No results were saved.',
        );
      }
      return _parseJsonBytes(bytes);
    });
  } on SpikeInputException {
    rethrow;
  } on RelationshipJsonException {
    throw const SpikeInputException(
      'Invalid relationship JSON. No results were saved.',
    );
  } on ValidatedZipException {
    throw const SpikeInputException(
      'Unable to validate this ZIP export. No results were saved.',
    );
  } on Object {
    throw const SpikeInputException(
      'Unable to read this JSON file. No results were saved.',
    );
  }
}

SpikeSummary _parseZipEntries(List<StagedZipEntry> entries) {
  final parsed = <ParsedRelationshipFile>[];
  final seenSides = <RelationshipSide>{};
  for (final entry in entries) {
    if (!_looksLikeJson(entry.file)) continue;
    final bytes = entry.file.readAsBytesSync();
    try {
      final result = parseRelationshipJson('', bytes);
      parsed.add(result);
      seenSides.add(result.side);
    } on RelationshipJsonException {
      if (_hasRecognizedRelationshipShape(bytes)) rethrow;
    }
  }
  if (seenSides.isEmpty) {
    throw const SpikeInputException(
      'No recognized relationship data found in ZIP export. No results were saved.',
    );
  }
  final summary = summarizeRelationships(parsed, completeSides: seenSides);
  final warnings = <String>[
    _completenessWarning,
    ...parsed.expand((file) => file.warnings),
  ];
  return SpikeSummary(
    following: seenSides.contains(RelationshipSide.following)
        ? summary.following.length
        : null,
    followers: seenSides.contains(RelationshipSide.followers)
        ? summary.followers.length
        : null,
    mutual: seenSides.length == 2 ? summary.mutual.length : null,
    followingOnly: summary.followingOnly?.length,
    followerOnly: summary.followerOnly?.length,
    warnings: warnings,
  );
}

bool _looksLikeJson(File file) {
  final bytes = file.readAsBytesSync();
  final text = String.fromCharCodes(bytes).trimLeft();
  return text.startsWith('{') || text.startsWith('[');
}

bool _hasRecognizedRelationshipShape(List<int> bytes) {
  try {
    final decoded = jsonDecode(utf8.decode(bytes, allowMalformed: false));
    if (decoded is List) return true;
    if (decoded is! Map) return false;
    return decoded.containsKey('relationships_following') ||
        decoded.containsKey('followers') ||
        decoded.keys.any(
          (key) => key is String && RegExp(r'^followers_\d+$').hasMatch(key),
        ) ||
        decoded.keys.every(
          (key) => key == 'title' || key == 'string_list_data',
        );
  } on Object {
    final text = utf8.decode(bytes, allowMalformed: true);
    return text.contains('"relationships_following"') ||
        text.contains('"followers"') ||
        RegExp(r'"followers_\d+"').hasMatch(text);
  }
}

bool _hasZipSignature(List<int> bytes) =>
    bytes.length >= 4 &&
    bytes[0] == 0x50 &&
    bytes[1] == 0x4b &&
    ((bytes[2] == 0x03 && bytes[3] == 0x04) ||
        (bytes[2] == 0x05 && bytes[3] == 0x06) ||
        (bytes[2] == 0x07 && bytes[3] == 0x08));

SpikeSummary _parseJsonBytes(List<int> bytes) {
  final parsed = parseRelationshipJson('', bytes);
  final sides = {parsed.side};
  final summary = summarizeRelationships([parsed], completeSides: sides);
  return SpikeSummary(
    following: sides.contains(RelationshipSide.following)
        ? summary.following.length
        : null,
    followers: sides.contains(RelationshipSide.followers)
        ? summary.followers.length
        : null,
    mutual: sides.length == 2 ? summary.mutual.length : null,
    followingOnly: null,
    followerOnly: null,
    warnings: parsed.warnings,
  );
}
