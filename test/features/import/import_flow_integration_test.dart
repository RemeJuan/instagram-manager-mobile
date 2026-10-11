import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinship_mobile/data/app_database.dart';
import 'package:kinship_mobile/data/import_review_repository.dart';
import 'package:kinship_mobile/data/import_repository.dart';
import 'package:kinship_mobile/data/relationship_read_repository.dart';
import 'package:kinship_mobile/domain/relationship.dart';
import 'package:kinship_mobile/features/import/import_workspace.dart';

void main() {
  test('synthetic baseline import survives file database reopen', () async {
    final directory = await Directory.systemTemp.createTemp(
      'import-flow-integration-',
    );
    final databaseFile = File('${directory.path}/history.sqlite');
    final workspaceDirectory = Directory('${directory.path}/workspace');
    await workspaceDirectory.create();
    final fixtureBytes = await File('fixtures/baseline.zip').readAsBytes();
    var database = AppDatabase.openFile(databaseFile);

    try {
      final workspace = ImportWorkspace(
        pickFiles: () async => [
          XFile.fromData(
            Uint8List.fromList(fixtureBytes),
            name: 'synthetic-baseline.zip',
          ),
        ],
        temporaryDirectory: () async => workspaceDirectory,
      );

      final preview = await workspace.pickAndParse();
      expect(preview, isNotNull);
      expect(preview!.recognizedFileCount, greaterThan(0));
      expect(preview.sides.keys, containsAll(RelationshipSide.values));
      expect(await workspaceDirectory.list().toList(), isEmpty);

      final choices = <RelationshipSide, Coverage>{
        RelationshipSide.following: Coverage.complete,
        RelationshipSide.followers: Coverage.complete,
      };
      final review = await ImportReviewRepository(database)
          .review(preview: preview, choices: choices);
      final outcome = await ImportReviewRepository(database).commit(
        preview: preview,
        choices: choices,
        expectedLatestImportId: review.expectedLatestImportId,
      );
      expect(outcome.status, CommitStatus.committed);

      await database.close();
      database = AppDatabase.openFile(databaseFile);
      final counts = await RelationshipReadRepository(database).counts();
      expect(counts.mutual, 747);
      expect(counts.followingOnly, 63);
      expect(counts.followerOnly, 36);
      expect(counts.unknown, 0);
      expect(
        counts.mutual +
            counts.followingOnly +
            counts.followerOnly +
            counts.unknown,
        846,
      );
      expect(await workspaceDirectory.list().toList(), isEmpty);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(seconds: 60)));
}
