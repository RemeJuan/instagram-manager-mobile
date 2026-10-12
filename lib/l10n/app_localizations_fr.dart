// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Kinship';

  @override
  String get appStartupError =>
      'Kinship n’a pas pu démarrer. Veuillez redémarrer l’application.';

  @override
  String get privateByDesign => 'LA VIE PRIVÉE, PAR CONCEPTION';

  @override
  String get navHome => 'Accueil';

  @override
  String get navAccounts => 'Comptes';

  @override
  String get homeHeadline => 'Vos relations,\nmises en contexte.';

  @override
  String get homeIntro =>
      'Une approche plus sereine pour comprendre vos exports Instagram.';

  @override
  String get savedAccounts => 'Comptes enregistrés';

  @override
  String get savedAccountsIntro =>
      'Les résultats proviennent des imports enregistrés, pas d’un aperçu en attente.';

  @override
  String get working => 'Traitement en cours';

  @override
  String get yourConnections => 'Vos relations';

  @override
  String get savedCountsNote =>
      'Les chiffres reflètent uniquement l’historique enregistré.';

  @override
  String get exploreAccounts => 'Parcourir les comptes enregistrés';

  @override
  String get searchSavedUsernames =>
      'Rechercher parmi les noms d’utilisateur enregistrés';

  @override
  String get usernameHint => 'Nom d’utilisateur';

  @override
  String get searchAction => 'Rechercher';

  @override
  String get filterAll => 'Tout';

  @override
  String get loadingSavedResults => 'Chargement des résultats enregistrés…';

  @override
  String get noSavedResults =>
      'Aucun résultat enregistré dans cette vue pour le moment.';

  @override
  String showingResults(int start, int end, int total) {
    return 'Affichage de $start à $end sur $total';
  }

  @override
  String get previousPage => 'Précédent';

  @override
  String get nextPage => 'Suivant';

  @override
  String get aboutResults => 'À propos de vos résultats';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get support => 'Aide et contact';

  @override
  String get openInfoLinkFailed => 'Impossible d’ouvrir le lien. Réessayez.';

  @override
  String get snapshotCaveat =>
      'Un export est un instantané, pas un relevé des dates de suivi ou de désabonnement. Les dates d’export et d’import ne sont pas les dates des événements. Les sections manquantes ou partielles ne permettent pas d’établir une absence ; un instantané ne prouve ni blocage, ni changement de nom, ni suppression.';

  @override
  String get privacyDisclosure =>
      'Kinship ne téléverse pas l’export que vous avez sélectionné. L’historique traité est stocké localement et peut être inclus dans la sauvegarde de l’appareil.';

  @override
  String get addAnotherExport => 'Ajouter un autre export';

  @override
  String get startWithExport => 'Commencer avec votre export';

  @override
  String get exportReady => 'Export prêt à être vérifié';

  @override
  String get compactExportDescription =>
      'Ajoutez un export ZIP ou JSON. Aucun téléversement ; l’historique enregistré peut être inclus dans la sauvegarde de l’appareil.';

  @override
  String get exportDescription =>
      'Choisissez un export Instagram au format ZIP ou JSON. Aucun téléversement ; l’historique enregistré peut être inclus dans la sauvegarde de l’appareil.';

  @override
  String get chooseExport => 'Choisir un export';

  @override
  String get chooseAnotherExport => 'Choisir un autre export';

  @override
  String get accountsStat => 'Comptes';

  @override
  String get mutual => 'Réciproques';

  @override
  String get followingOnly => 'Abonnements uniquement';

  @override
  String get followerOnly => 'Abonnés uniquement';

  @override
  String get unknown => 'Inconnu';

  @override
  String get unavailable => 'indisponible';

  @override
  String statSemantics(String label, String count) {
    return '$label : $count';
  }

  @override
  String filterWithCount(String label, String count) {
    return '$label $count';
  }

  @override
  String get reviewBeforeSaving => 'Vérifier avant d’enregistrer';

  @override
  String get partialSaferDefault =>
      'Partielle est l’option la plus prudente par défaut. Confirmez séparément la couverture de chaque section.';

  @override
  String get completeCoverageExplanation =>
      'Complète signifie que l’export couvre toute cette section ; le ZIP seul ne le prouve pas.';

  @override
  String recognizedSummary(int files, int invalid, int duplicates) {
    return 'Fichiers reconnus : $files  ·  Lignes invalides : $invalid  ·  Lignes en double : $duplicates';
  }

  @override
  String warningPrefix(String message) {
    return '!  $message';
  }

  @override
  String get reviewImpact => 'Vérifier les conséquences';

  @override
  String get confirmSavedChanges => 'Confirmer les modifications enregistrées';

  @override
  String get partialNoAbsence =>
      'Les sections partielles ou manquantes ajoutent uniquement des observations. Aucune absence n’est déduite.';

  @override
  String get confirmSaveLocally => 'Confirmer et enregistrer localement';

  @override
  String get sideFollowing => 'Abonnements';

  @override
  String get sideFollowers => 'Abonnés';

  @override
  String get sideFollowingLower => 'abonnements';

  @override
  String get sideFollowersLower => 'abonnés';

  @override
  String missingSide(String side) {
    return '$side : manquante · inconnue, pas égale à zéro';
  }

  @override
  String sideObservations(String side, int observed, int rows) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: 'lignes',
      one: 'ligne',
    );
    return '$side · $observed observés sur $rows $_temp0';
  }

  @override
  String sideInvalidDuplicates(int invalid, int duplicates) {
    return '$invalid invalides · $duplicates en double';
  }

  @override
  String get coveragePartial => 'Partielle';

  @override
  String get coverageComplete => 'Complète';

  @override
  String get coveragePartialLower => 'partielle';

  @override
  String get coverageCompleteLower => 'complète';

  @override
  String get coverageUnknownLower => 'inconnue';

  @override
  String get coverageMissingLower => 'manquante';

  @override
  String get completeUnavailable =>
      'Couverture complète indisponible : vérifiez les lignes invalides dans un nouvel export.';

  @override
  String acknowledgeSide(String side, String coverage) {
    return 'Je confirme que $side est $coverage dans cet export';
  }

  @override
  String completeSideSnapshot(String side) {
    return 'Instantané complet des $side';
  }

  @override
  String previouslyPresentAbsence(int count, String side) {
    return '$count auparavant présents → absents de cet instantané complet des $side.';
  }

  @override
  String previouslyUnknownAbsence(int count, String side) {
    return '$count auparavant inconnus → absents de cet instantané complet des $side.';
  }

  @override
  String sampleAccounts(String accounts) {
    return 'Exemple (jusqu’à 10) : $accounts';
  }

  @override
  String detailsFor(String username) {
    return 'Détails de @$username';
  }

  @override
  String openProfileFor(String username) {
    return 'Ouvrir le profil de @$username';
  }

  @override
  String usernameDisplay(String username) {
    return '@$username';
  }

  @override
  String get snapshotEvidenceNote =>
      'Un instantané n’indique pas la date d’abonnement ou de désabonnement.';

  @override
  String get copyUsername => 'Copier le nom d’utilisateur';

  @override
  String get openProfile => 'Ouvrir le profil';

  @override
  String notPresentFollowers(String importId) {
    return 'Absent de l’instantané complet des abonnés (import #$importId)';
  }

  @override
  String notPresentFollowing(String importId) {
    return 'Absent de l’instantané complet des abonnements (import #$importId)';
  }

  @override
  String coverageWithImport(String side, String coverage, int importId) {
    return '$side $coverage (import #$importId)';
  }

  @override
  String coverageWithoutImport(String side, String coverage) {
    return '$side $coverage';
  }

  @override
  String rowEvidence(String evidence, String following, String followers) {
    return '$evidence · Dernière couverture : $following, $followers';
  }

  @override
  String get warningInvalidRows => 'Certaines lignes n’ont pas pu être lues.';

  @override
  String get warningDuplicateRows => 'Les lignes répétées ont été regroupées.';

  @override
  String get warningConflictingDuplicate =>
      'Les lignes répétées contenaient des informations contradictoires.';

  @override
  String get readExportFailed =>
      'Impossible de lire cet export. Rien n’a été enregistré.';

  @override
  String get exportTooLarge =>
      'L’export dépasse la limite de taille locale. Rien n’a été enregistré.';

  @override
  String get exportSafetyLimit =>
      'L’export dépasse une limite de sécurité. Rien n’a été enregistré.';

  @override
  String get noRelationshipData =>
      'Aucune donnée relationnelle prise en charge trouvée. Rien n’a été enregistré.';

  @override
  String get tempCleanupFailed =>
      'Une copie temporaire de l’import peut subsister. Réessayez ou supprimez-la du stockage temporaire de l’application.';

  @override
  String get exportValidationFailed =>
      'Impossible de valider l’export en toute sécurité. Rien n’a été enregistré.';

  @override
  String get prepareReviewFailed =>
      'Impossible de préparer cette vérification. Rien n’a été enregistré.';

  @override
  String get importSaved => 'Import enregistré sur cet appareil.';

  @override
  String get importAlreadySaved => 'Cet import est déjà enregistré.';

  @override
  String get savedDataChanged =>
      'Les données enregistrées ont changé. Vérifiez à nouveau cet import avant de confirmer.';

  @override
  String get importRejected =>
      'Impossible d’enregistrer l’import. Vérifiez la couverture et réessayez.';

  @override
  String get importSaveFailed =>
      'Impossible d’enregistrer l’import. Aucune modification n’a été effectuée.';

  @override
  String get savedResultsUnavailable =>
      'Les résultats enregistrés sont momentanément indisponibles.';

  @override
  String get usernameCopied => 'Nom d’utilisateur copié.';

  @override
  String get openProfileFailed => 'Impossible d’ouvrir le profil.';

  @override
  String get proTitle => 'Kinship Pro';

  @override
  String get proHeadline => 'Un peu plus de Kinship.';

  @override
  String get proIntro =>
      'Soutenez une façon indépendante et apaisée de comprendre vos liens. Un achat à vie, sans abonnement.';

  @override
  String get proFreeNote =>
      'L’import, les contrôles de sécurité et les totaux restent gratuits. Jusqu’à 10 noms par catégorie ; Pro débloque les listes, la recherche et les détails.';

  @override
  String get proActive => 'Kinship Pro est actif sur ce compte.';

  @override
  String get proInactive => 'Kinship Pro n’est pas actif sur ce compte.';

  @override
  String get proStatusUnknown =>
      'Impossible de vérifier le statut Pro. Vous pouvez tenter de restaurer votre achat.';

  @override
  String proLifetimePrice(String price) {
    return 'Accès à vie · $price';
  }

  @override
  String get proViewOffer => 'Voir l’offre à vie';

  @override
  String get proOfferUnavailable =>
      'L’offre est indisponible pour le moment. Réessayez plus tard ; les imports restent possibles.';

  @override
  String get proRestore => 'Restaurer les achats';

  @override
  String get proRestored => 'Kinship Pro restauré.';

  @override
  String get proNothingToRestore =>
      'Aucun achat Kinship Pro trouvé pour ce compte de boutique.';

  @override
  String get proRestoreFailed =>
      'Impossible de restaurer les achats. Vérifiez votre connexion et réessayez.';

  @override
  String get proPurchaseFailed => 'Impossible de terminer l’achat. Réessayez.';

  @override
  String get proNotConfirmed =>
      'Pro n’est pas encore confirmé. Vérifiez votre compte de boutique ou restaurez l’achat.';

  @override
  String get proPrivacy =>
      'Les exports et listes sont stockés localement et peuvent figurer dans les sauvegardes de l’appareil. Ils ne sont pas envoyés à RevenueCat. RevenueCat reçoit l’historique des achats et un identifiant SDK anonyme.';

  @override
  String get sampleHeading => 'Un aperçu de vos liens';

  @override
  String get sampleDescription =>
      'Les 10 premiers noms de chaque catégorie sont gratuits. Pro débloque les listes complètes, la recherche et les détails des preuves.';

  @override
  String get sampleUnknown =>
      'Statut Pro non vérifié. Un aperçu limité est affiché jusqu’à confirmation ; imports et totaux restent disponibles.';

  @override
  String get sampleUnlock => 'Découvrir Kinship Pro';

  @override
  String sampleShowing(int shown, int total) {
    return 'Premiers $shown sur $total dans cette catégorie';
  }
}
