import 'dart:io';
import 'dart:isolate';

import 'package:file_selector/file_selector.dart';
import 'package:kinship_mobile/import/import_preview.dart';
import 'package:path_provider/path_provider.dart';

const int importWorkspaceMaxBytes = 50 * 1024 * 1024;
const int importWorkspaceMaxFiles = 500;

typedef ImportFilePicker = Future<List<XFile>?> Function();
typedef ImportWorkspaceParser = Future<ParsedImport> Function(
  List<String> paths,
);
typedef ImportWorkspaceCleanup = Future<void> Function(Directory workspace);

/// Local file-selection and transient-copy boundary for imports.
///
/// Picker cancellation returns null. All copied inputs are app-named and are
/// removed before this method completes, whether parsing succeeds or fails.
final class ImportWorkspace {
  const ImportWorkspace({
    ImportFilePicker? pickFiles,
    Future<Directory> Function()? temporaryDirectory,
    ImportWorkspaceParser? parse,
    ImportWorkspaceCleanup? cleanup,
  }) : _pickFiles = pickFiles ?? _defaultPicker,
       _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
       _parse = parse ?? _parseOffIsolate,
       _cleanup = cleanup ?? _deleteWorkspace;

  final ImportFilePicker _pickFiles;
  final Future<Directory> Function() _temporaryDirectory;
  final ImportWorkspaceParser _parse;
  final ImportWorkspaceCleanup _cleanup;

  Future<ParsedImport?> pickAndParse() async {
    final selected = await _pickFiles();
    if (selected == null || selected.isEmpty) return null;
    if (selected.length > importWorkspaceMaxFiles) {
      throw const ImportWorkspaceException('file_count_exceeded');
    }

    Directory? workspace;
    Object? operationError;
    StackTrace? operationStack;
    ParsedImport? parsed;
    try {
      workspace = await (await _temporaryDirectory()).createTemp(
        'kinship-import-',
      );
      var aggregateBytes = 0;
      final paths = <String>[];
      for (var i = 0; i < selected.length; i++) {
        final destination = File('${workspace.path}/input-$i');
        final sink = destination.openWrite();
        try {
          await for (final chunk in selected[i].openRead()) {
            aggregateBytes += chunk.length;
            if (aggregateBytes > importWorkspaceMaxBytes) {
              throw const ImportWorkspaceException('input_size_exceeded');
            }
            sink.add(chunk);
          }
          await sink.flush();
        } finally {
          await sink.close();
        }
        paths.add(destination.path);
      }
      parsed = await _parse(List.unmodifiable(paths));
    } catch (error, stackTrace) {
      operationError = error;
      operationStack = stackTrace;
    } finally {
      if (workspace != null) {
        try {
          if (await workspace.exists()) await _cleanup(workspace);
        } catch (_) {
          // Retry once, but cleanup failure remains the public failure.
          try {
            if (await workspace.exists()) {
              await workspace.delete(recursive: true);
            }
          } catch (_) {
            throw const ImportWorkspaceException('cleanup_failed');
          }
          throw const ImportWorkspaceException('cleanup_failed');
        }
      }
    }
    if (operationError != null) {
      Error.throwWithStackTrace(operationError, operationStack!);
    }
    return parsed!;
  }

  static Future<void> _deleteWorkspace(Directory workspace) =>
      workspace.delete(recursive: true);

  static Future<List<XFile>?> _defaultPicker() async {
    final files = await openFiles(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Instagram export ZIP or JSON',
          uniformTypeIdentifiers: ['public.zip-archive', 'public.json'],
        ),
      ],
    );
    return files;
  }

  static Future<ParsedImport> _parseOffIsolate(List<String> paths) =>
      Isolate.run(() => parseImportInputs(paths));
}

final class ImportWorkspaceException implements Exception {
  const ImportWorkspaceException(this.code);
  final String code;

  @override
  String toString() => 'ImportWorkspaceException($code)';
}
