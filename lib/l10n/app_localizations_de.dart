// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Kinship';

  @override
  String get appStartupError =>
      'Kinship konnte nicht gestartet werden. Bitte starte die App neu.';

  @override
  String get privateByDesign => 'VON GRUND AUF PRIVAT';

  @override
  String get navHome => 'Start';

  @override
  String get navAccounts => 'Konten';

  @override
  String get homeHeadline => 'Deine Kontakte,\nim Zusammenhang.';

  @override
  String get homeIntro =>
      'Eine ruhigere Art, deine Instagram-Exporte zu verstehen.';

  @override
  String get savedAccounts => 'Gespeicherte Konten';

  @override
  String get savedAccountsIntro =>
      'Die Ergebnisse stammen aus gespeicherten Importen, nicht aus einer ausstehenden Vorschau.';

  @override
  String get working => 'Wird verarbeitet';

  @override
  String get yourConnections => 'Deine Kontakte';

  @override
  String get savedCountsNote =>
      'Die Anzahl bezieht sich nur auf den gespeicherten Verlauf.';

  @override
  String get exploreAccounts => 'Gespeicherte Konten ansehen';

  @override
  String get searchSavedUsernames => 'Gespeicherte Nutzernamen suchen';

  @override
  String get usernameHint => 'Nutzername';

  @override
  String get searchAction => 'Suchen';

  @override
  String get filterAll => 'Alle';

  @override
  String get loadingSavedResults => 'Gespeicherte Ergebnisse werden geladen …';

  @override
  String get noSavedResults =>
      'In dieser Ansicht gibt es noch keine gespeicherten Ergebnisse.';

  @override
  String showingResults(int start, int end, int total) {
    return '$start–$end von $total';
  }

  @override
  String get previousPage => 'Zurück';

  @override
  String get nextPage => 'Weiter';

  @override
  String get aboutResults => 'Zu deinen Ergebnissen';

  @override
  String get snapshotCaveat =>
      'Ein Export ist eine Momentaufnahme, kein Nachweis für Zeitpunkte von Follow oder Unfollow. Export- und Importzeitpunkte sind keine Ereigniszeitpunkte. Fehlende oder unvollständige Seiten belegen keine Abwesenheit; eine Momentaufnahme beweist weder Blockieren noch Umbenennen oder Löschen.';

  @override
  String get privacyDisclosure =>
      'Kinship lädt deinen ausgewählten Export nicht hoch. Ausgewertete Daten werden lokal gespeichert und können in einem Geräte-Backup enthalten sein.';

  @override
  String get addAnotherExport => 'Weiteren Export hinzufügen';

  @override
  String get startWithExport => 'Mit deinem Export beginnen';

  @override
  String get exportReady => 'Export zur Prüfung bereit';

  @override
  String get compactExportDescription =>
      'ZIP- oder JSON-Export hinzufügen. Kein Upload; gespeicherter Verlauf kann im Geräte-Backup enthalten sein.';

  @override
  String get exportDescription =>
      'Instagram-Export als ZIP oder JSON auswählen. Kein Upload; gespeicherter Verlauf kann im Geräte-Backup enthalten sein.';

  @override
  String get chooseExport => 'Export auswählen';

  @override
  String get chooseAnotherExport => 'Anderen Export auswählen';

  @override
  String get accountsStat => 'Konten';

  @override
  String get mutual => 'Beidseitig';

  @override
  String get followingOnly => 'Nur du folgst';

  @override
  String get followerOnly => 'Folgt nur dir';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get unavailable => 'nicht verfügbar';

  @override
  String statSemantics(String label, String count) {
    return '$label: $count';
  }

  @override
  String filterWithCount(String label, String count) {
    return '$label $count';
  }

  @override
  String get reviewBeforeSaving => 'Vor dem Speichern prüfen';

  @override
  String get partialSaferDefault =>
      'Unvollständig ist die sicherere Standardeinstellung. Bestätige die Abdeckung für jede Seite einzeln.';

  @override
  String get completeCoverageExplanation =>
      'Vollständig bedeutet, dass der Export diese ganze Seite abdeckt; eine ZIP-Datei allein belegt das nicht.';

  @override
  String recognizedSummary(int files, int invalid, int duplicates) {
    return 'Erkannte Dateien: $files  ·  Ungültige Zeilen: $invalid  ·  Doppelte Zeilen: $duplicates';
  }

  @override
  String warningPrefix(String message) {
    return '!  $message';
  }

  @override
  String get reviewImpact => 'Auswirkungen prüfen';

  @override
  String get confirmSavedChanges => 'Gespeicherte Änderungen bestätigen';

  @override
  String get partialNoAbsence =>
      'Unvollständige oder fehlende Seiten fügen nur Beobachtungen hinzu. Abwesenheit wird nicht abgeleitet.';

  @override
  String get confirmSaveLocally => 'Bestätigen und lokal speichern';

  @override
  String get sideFollowing => 'Abonniert';

  @override
  String get sideFollowers => 'Abonnenten';

  @override
  String get sideFollowingLower => 'abonniert';

  @override
  String get sideFollowersLower => 'Abonnenten';

  @override
  String missingSide(String side) {
    return '$side: fehlt · unbekannt, nicht null';
  }

  @override
  String sideObservations(String side, int observed, int rows) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: 'Zeilen',
      one: 'Zeile',
    );
    return '$side · $observed beobachtet von $rows $_temp0';
  }

  @override
  String sideInvalidDuplicates(int invalid, int duplicates) {
    return '$invalid ungültig · $duplicates doppelt';
  }

  @override
  String get coveragePartial => 'Unvollständig';

  @override
  String get coverageComplete => 'Vollständig';

  @override
  String get coveragePartialLower => 'unvollständig';

  @override
  String get coverageCompleteLower => 'vollständig';

  @override
  String get coverageUnknownLower => 'unbekannt';

  @override
  String get coverageMissingLower => 'fehlend';

  @override
  String get completeUnavailable =>
      'Vollständig nicht verfügbar: Ungültige Zeilen müssen in einem neuen Export geprüft werden.';

  @override
  String acknowledgeSide(String side, String coverage) {
    return 'Ich bestätige, dass $side in diesem Export $coverage ist';
  }

  @override
  String completeSideSnapshot(String side) {
    return 'Vollständige Momentaufnahme: $side';
  }

  @override
  String previouslyPresentAbsence(int count, String side) {
    return '$count zuvor vorhanden → in dieser vollständigen Momentaufnahme von $side nicht vorhanden.';
  }

  @override
  String previouslyUnknownAbsence(int count, String side) {
    return '$count zuvor unbekannt → in dieser vollständigen Momentaufnahme von $side nicht vorhanden.';
  }

  @override
  String sampleAccounts(String accounts) {
    return 'Beispiele (bis zu 10): $accounts';
  }

  @override
  String detailsFor(String username) {
    return 'Details zu @$username';
  }

  @override
  String openProfileFor(String username) {
    return 'Profil von @$username öffnen';
  }

  @override
  String usernameDisplay(String username) {
    return '@$username';
  }

  @override
  String get snapshotEvidenceNote =>
      'Eine Momentaufnahme belegt keinen Follow- oder Unfollow-Zeitpunkt.';

  @override
  String get copyUsername => 'Nutzernamen kopieren';

  @override
  String get openProfile => 'Profil öffnen';

  @override
  String notPresentFollowers(String importId) {
    return 'In der vollständigen Abonnenten-Momentaufnahme nicht vorhanden (Import #$importId)';
  }

  @override
  String notPresentFollowing(String importId) {
    return 'In der vollständigen Abonniert-Momentaufnahme nicht vorhanden (Import #$importId)';
  }

  @override
  String coverageWithImport(String side, String coverage, int importId) {
    return '$side $coverage (Import #$importId)';
  }

  @override
  String coverageWithoutImport(String side, String coverage) {
    return '$side $coverage';
  }

  @override
  String rowEvidence(String evidence, String following, String followers) {
    return '$evidence · Letzte Abdeckung: $following, $followers';
  }

  @override
  String get warningInvalidRows =>
      'Einige Zeilen konnten nicht gelesen werden.';

  @override
  String get warningDuplicateRows => 'Doppelte Zeilen wurden zusammengeführt.';

  @override
  String get warningConflictingDuplicate =>
      'Doppelte Zeilen enthielten widersprüchliche Angaben.';

  @override
  String get readExportFailed =>
      'Export konnte nicht gelesen werden. Es wurde nichts gespeichert.';

  @override
  String get exportTooLarge =>
      'Export überschreitet die lokale Größenbegrenzung. Es wurde nichts gespeichert.';

  @override
  String get exportSafetyLimit =>
      'Export überschreitet eine Sicherheitsgrenze. Es wurde nichts gespeichert.';

  @override
  String get noRelationshipData =>
      'Keine unterstützten Kontaktdaten gefunden. Es wurde nichts gespeichert.';

  @override
  String get tempCleanupFailed =>
      'Eine temporäre Importkopie könnte noch vorhanden sein. Versuche es erneut oder entferne sie aus dem temporären App-Speicher.';

  @override
  String get exportValidationFailed =>
      'Export konnte nicht sicher geprüft werden. Es wurde nichts gespeichert.';

  @override
  String get prepareReviewFailed =>
      'Prüfung konnte nicht vorbereitet werden. Es wurde nichts gespeichert.';

  @override
  String get importSaved => 'Import auf diesem Gerät gespeichert.';

  @override
  String get importAlreadySaved => 'Dieser Import ist bereits gespeichert.';

  @override
  String get savedDataChanged =>
      'Gespeicherte Daten wurden geändert. Prüfe diesen Import erneut, bevor du bestätigst.';

  @override
  String get importRejected =>
      'Import konnte nicht gespeichert werden. Prüfe die Abdeckung und versuche es erneut.';

  @override
  String get importSaveFailed =>
      'Import konnte nicht gespeichert werden. Es wurde nichts geändert.';

  @override
  String get savedResultsUnavailable =>
      'Gespeicherte Ergebnisse sind derzeit nicht verfügbar.';

  @override
  String get usernameCopied => 'Nutzername kopiert.';

  @override
  String get openProfileFailed => 'Profil konnte nicht geöffnet werden.';

  @override
  String get proTitle => 'Kinship Pro';

  @override
  String get proHeadline => 'Ein bisschen mehr Kinship.';

  @override
  String get proIntro =>
      'Unterstütze einen unabhängigen, ruhigeren Blick auf deine Kontakte. Einmaliger Kauf auf Lebenszeit, kein Abo.';

  @override
  String get proFreeNote =>
      'Import, Sicherheitsprüfung und Kontozahlen bleiben kostenlos. Bis zu 10 Nutzernamen pro Kategorie; Pro schaltet vollständige Listen, Suche und Belege frei.';

  @override
  String get proActive => 'Kinship Pro ist für dieses Konto aktiv.';

  @override
  String get proInactive => 'Kinship Pro ist für dieses Konto nicht aktiv.';

  @override
  String get proStatusUnknown =>
      'Der Pro-Status konnte nicht geprüft werden. Du kannst deinen Kauf wiederherstellen.';

  @override
  String proLifetimePrice(String price) {
    return 'Dauerhafter Zugang · $price';
  }

  @override
  String get proViewOffer => 'Dauerhaftes Angebot ansehen';

  @override
  String get proOfferUnavailable =>
      'Das Angebot ist derzeit nicht verfügbar. Versuche es später erneut; Importe funktionieren weiterhin.';

  @override
  String get proRestore => 'Käufe wiederherstellen';

  @override
  String get proRestored => 'Kinship Pro wiederhergestellt.';

  @override
  String get proNothingToRestore =>
      'Für dieses Store-Konto wurde kein Kinship-Pro-Kauf gefunden.';

  @override
  String get proRestoreFailed =>
      'Käufe konnten nicht wiederhergestellt werden. Prüfe die Verbindung und versuche es erneut.';

  @override
  String get proPurchaseFailed =>
      'Der Kauf konnte nicht abgeschlossen werden. Versuche es erneut.';

  @override
  String get proNotConfirmed =>
      'Pro ist noch nicht bestätigt. Prüfe dein Store-Konto oder stelle den Kauf wieder her.';

  @override
  String get proPrivacy =>
      'Exporte und Kontaktlisten werden lokal gespeichert und können in Geräte-Backups enthalten sein. Sie gehen nicht an RevenueCat. RevenueCat erhält Kaufverlauf und eine anonyme SDK-ID.';

  @override
  String get sampleHeading => 'Ein Einblick in deine Kontakte';

  @override
  String get sampleDescription =>
      'Die ersten 10 Nutzernamen jeder Kategorie sind kostenlos. Pro schaltet vollständige Listen, Suche und Belege frei.';

  @override
  String get sampleUnknown =>
      'Pro konnte nicht geprüft werden. Bis zur Bestätigung wird ein begrenzter Ausschnitt angezeigt; Import und Zahlen bleiben verfügbar.';

  @override
  String get sampleUnlock => 'Kinship Pro entdecken';

  @override
  String sampleShowing(int shown, int total) {
    return 'Erste $shown von $total in dieser Kategorie';
  }
}
