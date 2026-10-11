import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/features/import/import_workspace.dart';
import 'package:kinship_mobile/import/import_preview.dart';

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('import-workspace-test-');
  });

  tearDown(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  test('picker cancellation returns null without workspace', () async {
    var requestedTemp = false;
    final service = ImportWorkspace(
      pickFiles: () async => null,
      temporaryDirectory: () async {
        requestedTemp = true;
        return root;
      },
    );

    expect(await service.pickAndParse(), isNull);
    expect(requestedTemp, isFalse);
    expect(await root.list().toList(), isEmpty);
  });

  test(
    'copies multiple selected inputs with app-owned paths then cleans up',
    () async {
      final files = await _sourceFiles(root, [
        List<int>.filled(2, 0x31),
        List<int>.filled(3, 0x32),
      ]);
      List<String>? parsedPaths;
      final service = ImportWorkspace(
        pickFiles: () async => files,
        temporaryDirectory: () async => root,
        parse: (paths) async {
          parsedPaths = paths;
          expect(paths.map((path) => path.split('/').last), [
            'input-0',
            'input-1',
          ]);
          expect(await File(paths[0]).readAsBytes(), List<int>.filled(2, 0x31));
          expect(await File(paths[1]).readAsBytes(), List<int>.filled(3, 0x32));
          return _emptyParsed();
        },
      );

      expect(await service.pickAndParse(), isA<ParsedImport>());
      expect(parsedPaths, hasLength(2));
      expect((await root.list().toList()), hasLength(2)); // Source files only.
    },
  );

  test(
    'default parser returns ParsedImport from synthetic baseline ZIP',
    () async {
      final source = File('fixtures/baseline.zip');
      final service = ImportWorkspace(
        pickFiles: () async => [XFile(source.path)],
        temporaryDirectory: () async => root,
      );

      final parsed = await service.pickAndParse();
      expect(parsed, isA<ParsedImport>());
      expect(parsed!.recognizedFileCount, greaterThan(0));
      expect(parsed.sides, isNotEmpty);
      expect(await root.list().length, 0);
    },
  );

  test('accepts exact aggregate byte boundary', () async {
    final files = await _sourceFiles(root, [
      List<int>.filled(importWorkspaceMaxBytes ~/ 2, 1),
      List<int>.filled(
        importWorkspaceMaxBytes - importWorkspaceMaxBytes ~/ 2,
        2,
      ),
    ]);
    final service = ImportWorkspace(
      pickFiles: () async => files,
      temporaryDirectory: () async => root,
      parse: (_) async => _emptyParsed(),
    );

    expect(await service.pickAndParse(), isA<ParsedImport>());
    expect(await root.list().length, 2);
  });

  test('rejects aggregate size over limit and removes workspace', () async {
    final files = await _sourceFiles(root, [
      List<int>.filled(importWorkspaceMaxBytes, 1),
      [2],
    ]);
    final service = ImportWorkspace(
      pickFiles: () async => files,
      temporaryDirectory: () async => root,
      parse: (_) async => fail('Parser must not run'),
    );

    await expectLater(
      service.pickAndParse(),
      throwsA(isA<ImportWorkspaceException>()),
    );
    expect(await root.list().length, 2);
  });

  test('cleans workspace after parser failure', () async {
    final files = await _sourceFiles(root, [
      [1],
    ]);
    final service = ImportWorkspace(
      pickFiles: () async => files,
      temporaryDirectory: () async => root,
      parse: (_) async => throw StateError('private parser failure'),
    );

    await expectLater(service.pickAndParse(), throwsStateError);
    expect(await root.list().length, 1);
  });

  test(
    'cleanup failure after successful parse fails with sanitized code',
    () async {
      final files = await _sourceFiles(root, [
        [1],
      ]);
      final service = ImportWorkspace(
        pickFiles: () async => files,
        temporaryDirectory: () async => root,
        parse: (_) async => _emptyParsed(),
        cleanup: (_) async => throw StateError('private path and content'),
      );

      await expectLater(
        service.pickAndParse(),
        throwsA(
          isA<ImportWorkspaceException>().having(
            (error) => error.code,
            'code',
            'cleanup_failed',
          ),
        ),
      );
      expect(await root.list().length, 1);
    },
  );

  test('cleanup failure after parser failure takes precedence', () async {
    final files = await _sourceFiles(root, [
      [1],
    ]);
    final service = ImportWorkspace(
      pickFiles: () async => files,
      temporaryDirectory: () async => root,
      parse: (_) async => throw StateError('private parser failure'),
      cleanup: (_) async => throw StateError('private cleanup failure'),
    );

    await expectLater(
      service.pickAndParse(),
      throwsA(
        isA<ImportWorkspaceException>().having(
          (error) => error.code,
          'code',
          'cleanup_failed',
        ),
      ),
    );
    expect(await root.list().length, 1);
  });

  test('rejects too many selected files before workspace creation', () async {
    var requestedTemp = false;
    final files = List<XFile>.generate(
      importWorkspaceMaxFiles + 1,
      (_) => XFile('unused'),
    );
    final service = ImportWorkspace(
      pickFiles: () async => files,
      temporaryDirectory: () async {
        requestedTemp = true;
        return root;
      },
    );

    await expectLater(
      service.pickAndParse(),
      throwsA(isA<ImportWorkspaceException>()),
    );
    expect(requestedTemp, isFalse);
  });
}

Future<List<XFile>> _sourceFiles(
  Directory root,
  List<List<int>> contents,
) async {
  final result = <XFile>[];
  for (var i = 0; i < contents.length; i++) {
    final file = File('${root.path}/source-$i');
    await file.writeAsBytes(contents[i]);
    result.add(XFile(file.path));
  }
  return result;
}

ParsedImport _emptyParsed() => ParsedImport(
  sides: const {},
  warningCodes: const [],
  recognizedFileCount: 1,
);
