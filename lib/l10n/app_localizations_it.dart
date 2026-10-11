// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Kinship';

  @override
  String get appStartupError =>
      'Kinship non è riuscito ad avviarsi. Riavvia l\'app.';

  @override
  String get privateByDesign => 'PRIVATO PER SCELTA';

  @override
  String get navHome => 'Home';

  @override
  String get navAccounts => 'Account';

  @override
  String get homeHeadline => 'Le tue connessioni,\nnel loro contesto.';

  @override
  String get homeIntro =>
      'Un modo più tranquillo per comprendere i tuoi export di Instagram.';

  @override
  String get savedAccounts => 'Account salvati';

  @override
  String get savedAccountsIntro =>
      'I risultati provengono dagli import salvati, non da un\'anteprima in sospeso.';

  @override
  String get working => 'Elaborazione';

  @override
  String get yourConnections => 'Le tue connessioni';

  @override
  String get savedCountsNote =>
      'I conteggi riflettono solo la cronologia salvata.';

  @override
  String get exploreAccounts => 'Esplora gli account salvati';

  @override
  String get searchSavedUsernames => 'Cerca nomi utente salvati';

  @override
  String get usernameHint => 'Nome utente';

  @override
  String get searchAction => 'Cerca';

  @override
  String get filterAll => 'Tutti';

  @override
  String get loadingSavedResults => 'Caricamento dei risultati salvati…';

  @override
  String get noSavedResults => 'Nessun risultato salvato in questa vista.';

  @override
  String showingResults(int start, int end, int total) {
    return 'Visualizzati $start–$end di $total';
  }

  @override
  String get previousPage => 'Precedente';

  @override
  String get nextPage => 'Successiva';

  @override
  String get aboutResults => 'Informazioni sui risultati';

  @override
  String get snapshotCaveat =>
      'Un export è un\'istantanea, non una registrazione degli orari in cui hai iniziato o smesso di seguire qualcuno. Gli orari di export e import non sono orari degli eventi. I lati mancanti o parziali non possono dimostrare un\'assenza; un\'istantanea non può provare un blocco, un cambio nome o una cancellazione.';

  @override
  String get privacyDisclosure =>
      'Kinship non carica l\'export che selezioni. La cronologia analizzata è archiviata localmente e potrebbe essere inclusa nel backup del dispositivo.';

  @override
  String get addAnotherExport => 'Aggiungi un altro export';

  @override
  String get startWithExport => 'Inizia con il tuo export';

  @override
  String get exportReady => 'Export pronto per la revisione';

  @override
  String get compactExportDescription =>
      'Aggiungi un export ZIP o JSON. Nessun caricamento; la cronologia salvata potrebbe essere inclusa nel backup del dispositivo.';

  @override
  String get exportDescription =>
      'Scegli un export Instagram ZIP o JSON. Nessun caricamento; la cronologia salvata potrebbe essere inclusa nel backup del dispositivo.';

  @override
  String get chooseExport => 'Scegli export';

  @override
  String get chooseAnotherExport => 'Scegli un altro export';

  @override
  String get accountsStat => 'Account';

  @override
  String get mutual => 'Reciproci';

  @override
  String get followingOnly => 'Seguiti soltanto';

  @override
  String get followerOnly => 'Follower soltanto';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get unavailable => 'non disponibile';

  @override
  String statSemantics(String label, String count) {
    return '$label: $count';
  }

  @override
  String filterWithCount(String label, String count) {
    return '$label $count';
  }

  @override
  String get reviewBeforeSaving => 'Controlla prima di salvare';

  @override
  String get partialSaferDefault =>
      'L\'impostazione più prudente è parziale. Conferma separatamente la copertura di ciascun lato.';

  @override
  String get completeCoverageExplanation =>
      'Completo significa che l\'export copre interamente questo lato; il solo ZIP non lo dimostra.';

  @override
  String recognizedSummary(int files, int invalid, int duplicates) {
    return 'File riconosciuti: $files  ·  Righe non valide: $invalid  ·  Righe duplicate: $duplicates';
  }

  @override
  String warningPrefix(String message) {
    return '!  $message';
  }

  @override
  String get reviewImpact => 'Controlla l\'impatto';

  @override
  String get confirmSavedChanges => 'Conferma le modifiche salvate';

  @override
  String get partialNoAbsence =>
      'I lati parziali o mancanti aggiungono solo osservazioni. Non viene proposta alcuna assenza.';

  @override
  String get confirmSaveLocally => 'Conferma e salva sul dispositivo';

  @override
  String get sideFollowing => 'Seguiti';

  @override
  String get sideFollowers => 'Follower';

  @override
  String get sideFollowingLower => 'seguiti';

  @override
  String get sideFollowersLower => 'follower';

  @override
  String missingSide(String side) {
    return '$side: mancante · sconosciuto, non zero';
  }

  @override
  String sideObservations(String side, int observed, int rows) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: 'rows',
      one: 'row',
    );
    return '$side · $observed osservati su $rows $_temp0';
  }

  @override
  String sideInvalidDuplicates(int invalid, int duplicates) {
    return '$invalid non valide · $duplicates duplicate';
  }

  @override
  String get coveragePartial => 'Parziale';

  @override
  String get coverageComplete => 'Completa';

  @override
  String get coveragePartialLower => 'parziale';

  @override
  String get coverageCompleteLower => 'completa';

  @override
  String get coverageUnknownLower => 'sconosciuta';

  @override
  String get coverageMissingLower => 'mancante';

  @override
  String get completeUnavailable =>
      'Copertura completa non disponibile: le righe non valide richiedono una verifica in un nuovo export.';

  @override
  String acknowledgeSide(String side, String coverage) {
    return 'Confermo che $side è $coverage in questo export';
  }

  @override
  String completeSideSnapshot(String side) {
    return 'Istantanea completa di $side';
  }

  @override
  String previouslyPresentAbsence(int count, String side) {
    return '$count prima presenti → non presenti in questa istantanea completa di $side.';
  }

  @override
  String previouslyUnknownAbsence(int count, String side) {
    return '$count prima sconosciuti → non presenti in questa istantanea completa di $side.';
  }

  @override
  String sampleAccounts(String accounts) {
    return 'Esempio (fino a 10): $accounts';
  }

  @override
  String detailsFor(String username) {
    return 'Dettagli per @$username';
  }

  @override
  String openProfileFor(String username) {
    return 'Apri il profilo di @$username';
  }

  @override
  String usernameDisplay(String username) {
    return '@$username';
  }

  @override
  String get snapshotEvidenceNote =>
      'Le prove dell\'istantanea non indicano quando hai iniziato o smesso di seguire qualcuno.';

  @override
  String get copyUsername => 'Copia nome utente';

  @override
  String get openProfile => 'Apri profilo';

  @override
  String notPresentFollowers(String importId) {
    return 'Non presente nell\'istantanea completa dei follower (importazione #$importId)';
  }

  @override
  String notPresentFollowing(String importId) {
    return 'Non presente nell\'istantanea completa dei seguiti (importazione #$importId)';
  }

  @override
  String coverageWithImport(String side, String coverage, int importId) {
    return '$side $coverage (importazione #$importId)';
  }

  @override
  String coverageWithoutImport(String side, String coverage) {
    return '$side $coverage';
  }

  @override
  String rowEvidence(String evidence, String following, String followers) {
    return '$evidence · Copertura più recente: $following, $followers';
  }

  @override
  String get warningInvalidRows => 'Impossibile leggere alcune righe.';

  @override
  String get warningDuplicateRows => 'Le righe ripetute sono state accorpate.';

  @override
  String get warningConflictingDuplicate =>
      'Le righe ripetute contenevano dettagli in conflitto.';

  @override
  String get readExportFailed =>
      'Impossibile leggere questo export. Non è stato salvato nulla.';

  @override
  String get exportTooLarge =>
      'L\'export supera il limite di dimensione locale. Non è stato salvato nulla.';

  @override
  String get exportSafetyLimit =>
      'L\'export supera un limite di sicurezza. Non è stato salvato nulla.';

  @override
  String get noRelationshipData =>
      'Nessun dato supportato sulle relazioni. Non è stato salvato nulla.';

  @override
  String get tempCleanupFailed =>
      'Potrebbe essere rimasta una copia temporanea dell\'importazione. Riprova o rimuovila dalla memoria temporanea dell\'app.';

  @override
  String get exportValidationFailed =>
      'Impossibile convalidare l\'export in sicurezza. Non è stato salvato nulla.';

  @override
  String get prepareReviewFailed =>
      'Impossibile preparare questa revisione. Non è stato salvato nulla.';

  @override
  String get importSaved => 'Importazione salvata su questo dispositivo.';

  @override
  String get importAlreadySaved => 'Questa importazione è già stata salvata.';

  @override
  String get savedDataChanged =>
      'I dati salvati sono cambiati. Rivedi questa importazione prima di confermare.';

  @override
  String get importRejected =>
      'Impossibile salvare l\'importazione. Controlla la copertura e riprova.';

  @override
  String get importSaveFailed =>
      'Impossibile salvare l\'importazione. Non è stata apportata alcuna modifica.';

  @override
  String get savedResultsUnavailable =>
      'I risultati salvati non sono disponibili al momento.';

  @override
  String get usernameCopied => 'Nome utente copiato.';

  @override
  String get openProfileFailed => 'Impossibile aprire il profilo.';

  @override
  String get proTitle => 'Kinship Pro';

  @override
  String get proHeadline => 'Un po’ più Kinship.';

  @override
  String get proIntro =>
      'Sostieni un modo indipendente e più sereno di capire i tuoi contatti. Un acquisto a vita, senza abbonamento.';

  @override
  String get proFreeNote =>
      'Importazione, controlli di sicurezza e totali restano gratuiti. Fino a 10 nomi per categoria; Pro sblocca elenchi completi, ricerca e dettagli.';

  @override
  String get proActive => 'Kinship Pro è attivo su questo account.';

  @override
  String get proInactive => 'Kinship Pro non è attivo su questo account.';

  @override
  String get proStatusUnknown =>
      'Impossibile verificare lo stato Pro. Puoi provare a ripristinare l’acquisto.';

  @override
  String proLifetimePrice(String price) {
    return 'Accesso a vita · $price';
  }

  @override
  String get proViewOffer => 'Vedi offerta a vita';

  @override
  String get proOfferUnavailable =>
      'L’offerta non è disponibile ora. Riprova più tardi; le importazioni funzionano comunque.';

  @override
  String get proRestore => 'Ripristina acquisti';

  @override
  String get proRestored => 'Kinship Pro ripristinato.';

  @override
  String get proNothingToRestore =>
      'Nessun acquisto Kinship Pro trovato per questo account dello store.';

  @override
  String get proRestoreFailed =>
      'Impossibile ripristinare gli acquisti. Controlla la connessione e riprova.';

  @override
  String get proPurchaseFailed => 'Impossibile completare l’acquisto. Riprova.';

  @override
  String get proNotConfirmed =>
      'Pro non è ancora confermato. Controlla l’account dello store o ripristina l’acquisto.';

  @override
  String get proPrivacy =>
      'Esportazioni ed elenchi sono salvati localmente e possono essere inclusi nei backup del dispositivo. Non sono inviati a RevenueCat. RevenueCat riceve cronologia acquisti e un ID SDK anonimo.';

  @override
  String get sampleHeading => 'Uno sguardo ai tuoi contatti';

  @override
  String get sampleDescription =>
      'I primi 10 nomi per categoria sono gratuiti. Pro sblocca elenchi completi, ricerca e dettagli delle prove.';

  @override
  String get sampleUnknown =>
      'Stato Pro non verificato. Mostriamo un campione limitato finché l’accesso non è confermato; importazione e totali restano disponibili.';

  @override
  String get sampleUnlock => 'Scopri Kinship Pro';

  @override
  String sampleShowing(int shown, int total) {
    return 'Primi $shown di $total in questa categoria';
  }
}
