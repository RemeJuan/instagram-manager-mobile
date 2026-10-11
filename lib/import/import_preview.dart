import 'dart:convert';
import 'dart:io';

import '../domain/relationship.dart';
import '../domain/result.dart';
import 'relationship_json.dart' as json_parser;
import 'validated_zip.dart';

enum ImportWarningCode { invalidRows, duplicateRows, conflictingDuplicate }

final class ParsedImportSide {
  ParsedImportSide({
    required Iterable<RelationshipObservation> observations,
    required this.rowCount,
    required this.invalidCount,
    required this.duplicateCount,
  }) : observations = List.unmodifiable(observations);

  final List<RelationshipObservation> observations;
  final int rowCount;
  final int invalidCount;
  final int duplicateCount;
}

final class ParsedImport {
  ParsedImport({
    required Map<RelationshipSide, ParsedImportSide> sides,
    required Iterable<ImportWarningCode> warningCodes,
    required this.recognizedFileCount,
  }) : sides = Map.unmodifiable(sides),
       warningCodes = List.unmodifiable(warningCodes);

  final Map<RelationshipSide, ParsedImportSide> sides;
  final List<ImportWarningCode> warningCodes;
  final int recognizedFileCount;
}

const _aggregateCompressedLimit = 50 * 1024 * 1024;
const _aggregateExpandedLimit = 200 * 1024 * 1024;
const _fileCountLimit = 500;
const _rowLimit = 1000000;

final class ImportException implements Exception {
  const ImportException(this.code);
  final String code;
  @override
  String toString() => 'ImportException($code)';
}

Future<ParsedImport> parseImportInputs(List<String> paths) async {
  var selectedBytes = 0;
  var expandedBytes = 0;
  var inputCount = 0;
  var totalRows = 0;
  final aggregated = <RelationshipSide, _SideAccumulator>{};
  final warningCodes = <ImportWarningCode>{};
  var recognized = 0;

  void accept(json_parser.ParsedRelationshipFile parsed) {
    recognized++;
    final target = aggregated.putIfAbsent(parsed.side, _SideAccumulator.new);
    totalRows += parsed.rowCount;
    if (totalRows > _rowLimit) {
      throw const ImportException('row_limit_exceeded');
    }
    target.rowCount += parsed.rowCount;
    target.invalidCount += parsed.invalidCount;
    target.duplicateCount += parsed.duplicateCount;
    if (parsed.invalidCount > 0) {
      warningCodes.add(ImportWarningCode.invalidRows);
    }
    if (parsed.duplicateCount > 0) {
      warningCodes.add(ImportWarningCode.duplicateRows);
    }
    if (parsed.warningCodes.contains(
      json_parser.RelationshipWarningCode.conflictingDuplicate,
    )) {
      warningCodes.add(ImportWarningCode.conflictingDuplicate);
    }
    for (final record in parsed.records) {
      final id = UsernameIdentity.tryParse(record.displayUsername);
      if (id == null) continue;
      final old = target.observations[id.canonical];
      if (old != null) {
        target.duplicateCount++;
        warningCodes.add(ImportWarningCode.duplicateRows);
        if (old.sourceTimestamp != record.sourceTimestamp) {
          warningCodes.add(ImportWarningCode.conflictingDuplicate);
        }
      } else {
        target.observations[id.canonical] = RelationshipObservation(
          identity: id,
          sourceTimestamp: record.sourceTimestamp,
        );
      }
    }
  }

  try {
    for (final path in paths) {
      final file = File(path);
      final length = await file.length();
      selectedBytes += length;
      if (selectedBytes > _aggregateCompressedLimit) {
        throw const ImportException('compressed_limit_exceeded');
      }
      inputCount++;
      if (inputCount > _fileCountLimit) {
        throw const ImportException('file_count_exceeded');
      }
      final raf = await file.open(mode: FileMode.read);
      final signature = await raf.read(4);
      await raf.close();
      final hasPkSignature =
          signature.length >= 2 && signature[0] == 0x50 && signature[1] == 0x4b;
      final isZip =
          signature.length >= 4 &&
          signature[0] == 0x50 &&
          signature[1] == 0x4b &&
          (signature[2] == 0x03 ||
              signature[2] == 0x05 ||
              signature[2] == 0x07);
      if (hasPkSignature && !isZip) {
        throw const ImportException('invalid_archive_signature');
      }
      if (!isZip) {
        final bytes = await file.readAsBytes();
        if (bytes.length > validatedZipEntryLimit) {
          throw const _ImportLimitException();
        }
        expandedBytes += bytes.length;
        if (expandedBytes > _aggregateExpandedLimit) {
          throw const ImportException('expanded_limit_exceeded');
        }
        try {
          accept(json_parser.parseRelationshipJson('', bytes));
        } on json_parser.RelationshipJsonException catch (e) {
          if (e.code ==
              json_parser.RelationshipJsonErrorCode.unrecognizedStructure) {
            if (_looksLikeJson(bytes)) {
              try {
                jsonDecode(utf8.decode(bytes, allowMalformed: false));
              } on FormatException {
                rethrow;
              }
            }
            continue;
          }
          rethrow;
        }
        continue;
      }
      final staging = await Directory.systemTemp.createTemp('import_preview_');
      try {
        await withValidatedZipEntries(
          file,
          staging,
          (entries) async {
            final zipExpandedBytes = entries.fold<int>(
              0,
              (total, entry) => total + entry.expandedBytes,
            );
            expandedBytes += zipExpandedBytes;
            for (final entry in entries) {
              final bytes = await entry.file.readAsBytes();
              if (!_looksLikeJson(bytes)) {
                continue;
              }
              try {
                accept(json_parser.parseRelationshipJson('', bytes));
              } on json_parser.RelationshipJsonException catch (e) {
                if (e.code ==
                    json_parser
                        .RelationshipJsonErrorCode
                        .unrecognizedStructure) {
                  // Structurally valid but unrelated JSON is ignorable.
                  jsonDecode(utf8.decode(bytes, allowMalformed: false));
                } else {
                  rethrow;
                }
              }
            }
          },
          maxExpandedBytes: _aggregateExpandedLimit - expandedBytes,
          maxEntryCount: _fileCountLimit - inputCount,
          onEntryCount: (count) => inputCount += count,
        );
      } finally {
        if (await staging.exists()) await staging.delete(recursive: true);
      }
    }
  } catch (error) {
    if (error is ImportException) rethrow;
    if (error is _ImportLimitException) {
      throw const ImportException('input_limit_exceeded');
    }
    if (error is ValidatedZipException) throw ImportException(error.code);
    if (error is json_parser.RelationshipJsonException) {
      throw ImportException(error.code?.name ?? 'invalid_json');
    }
    throw const ImportException('input_read_failed');
  }

  if (recognized == 0) {
    throw const ImportException('no_relationship_data');
  }

  return ParsedImport(
    sides: {
      for (final entry in aggregated.entries) entry.key: entry.value.freeze(),
    },
    warningCodes: warningCodes,
    recognizedFileCount: recognized,
  );
}

bool _looksLikeJson(List<int> bytes) {
  for (final byte in bytes) {
    if (byte == 0x20 || byte == 0x09 || byte == 0x0a || byte == 0x0d) {
      continue;
    }
    return byte == 0x7b || byte == 0x5b;
  }
  return false;
}

Result<RelationshipSnapshot> prepareSnapshot(
  ParsedImport preview,
  Map<RelationshipSide, Coverage> choices,
) {
  final following = preview.sides[RelationshipSide.following];
  final followers = preview.sides[RelationshipSide.followers];
  for (final side in RelationshipSide.values) {
    final data = preview.sides[side];
    final coverage =
        choices[side] ?? (data == null ? Coverage.missing : Coverage.partial);
    if (data == null && coverage != Coverage.missing ||
        data != null && coverage == Coverage.missing ||
        coverage == Coverage.complete && data!.invalidCount > 0) {
      return const Failure(
        DomainFailure(DomainFailureCategory.unsupportedCoverage),
      );
    }
  }
  final followingCoverage =
      choices[RelationshipSide.following] ??
      (following == null ? Coverage.missing : Coverage.partial);
  final followersCoverage =
      choices[RelationshipSide.followers] ??
      (followers == null ? Coverage.missing : Coverage.partial);
  return Success(
    RelationshipSnapshot(
      following: following?.observations ?? const [],
      followers: followers?.observations ?? const [],
      followingCoverage: followingCoverage,
      followersCoverage: followersCoverage,
    ),
  );
}

final class _SideAccumulator {
  final observations = <String, RelationshipObservation>{};
  int rowCount = 0;
  int invalidCount = 0;
  int duplicateCount = 0;

  ParsedImportSide freeze() => ParsedImportSide(
    observations: observations.values,
    rowCount: rowCount,
    invalidCount: invalidCount,
    duplicateCount: duplicateCount,
  );
}

final class _ImportLimitException implements Exception {
  const _ImportLimitException();
}
