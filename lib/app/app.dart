import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinship_mobile/app/app_providers.dart';
import 'package:kinship_mobile/app/kinship_theme.dart';
import 'package:kinship_mobile/data/app_database.dart';
import 'package:kinship_mobile/features/import/import_home_screen.dart';
import 'package:kinship_mobile/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class KinshipApp extends ConsumerWidget {
  const KinshipApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: const [
      Locale('en', 'GB'),
      Locale('de', 'DE'),
      Locale('es', 'ES'),
      Locale('fr', 'FR'),
      Locale('it'),
      Locale('ja'),
      Locale('pt', 'BR'),
    ],
    localeListResolutionCallback: (preferred, supported) {
      final requested = preferred?.firstOrNull;
      // Match supported languages; generated catalogs select regional variants.
      if (requested != null &&
          AppLocalizations.supportedLocales.any(
            (locale) => locale.languageCode == requested.languageCode,
          )) {
        return requested;
      }
      return const Locale('en', 'GB');
    },
    theme: KinshipTheme.light,
    themeMode: ThemeMode.light,
    home: ref
        .watch(appDatabaseProvider)
        .when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) => Scaffold(
            body: Center(
              child: Builder(
                builder: (context) =>
                    Text(AppLocalizations.of(context)!.appStartupError),
              ),
            ),
          ),
          data: (database) => _importHome(ref, database),
        ),
  );

  Widget _importHome(WidgetRef ref, AppDatabase database) => ImportHomeScreen(
    workspace: ref.watch(importWorkspaceProvider),
    review: ref.watch(importReviewRepositoryProvider(database)),
    read: ref.watch(relationshipReadRepositoryProvider(database)),
    openProfile: (uri) => launchUrl(uri, mode: LaunchMode.externalApplication),
    purchaseGateway: ref.watch(purchaseGatewayProvider),
    paywallPresenter: ref.watch(proPaywallPresenterProvider),
  );
}
