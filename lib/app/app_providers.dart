import 'dart:io';
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinship_mobile/data/app_database.dart';
import 'package:kinship_mobile/data/import_review_repository.dart';
import 'package:kinship_mobile/data/relationship_read_repository.dart';
import 'package:kinship_mobile/features/import/import_workspace.dart';
import 'package:kinship_mobile/features/pro/pro_screen.dart';
import 'package:kinship_mobile/purchases/purchase_gateway.dart';
import 'package:path_provider/path_provider.dart';

final appDatabaseProvider = FutureProvider<AppDatabase>((ref) async {
  final supportDirectory = await getApplicationSupportDirectory();
  await supportDirectory.create(recursive: true);
  final database = AppDatabase.openFile(
    File('${supportDirectory.path}/kinship.db'),
  );
  ref.onDispose(() => database.close());
  return database;
});

final importWorkspaceProvider = Provider<ImportWorkspace>(
  (ref) => const ImportWorkspace(),
);

final purchaseGatewayProvider = Provider<PurchaseGateway>((ref) {
  final gateway = PurchaseGateway();
  unawaited(gateway.initialize());
  ref.onDispose(() {
    gateway.dispose();
  });
  return gateway;
});

final proPaywallPresenterProvider = Provider<ProPaywallPresenter>(
  (ref) => const RevenueCatPaywallPresenter(),
);

final importReviewRepositoryProvider =
    Provider.family<ImportReviewRepository, AppDatabase>(
      (ref, database) => ImportReviewRepository(database),
    );

final relationshipReadRepositoryProvider =
    Provider.family<RelationshipReadRepository, AppDatabase>(
      (ref, database) => RelationshipReadRepository(database),
    );
