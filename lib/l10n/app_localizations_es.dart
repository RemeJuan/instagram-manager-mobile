// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Kinship';

  @override
  String get appStartupError =>
      'No se pudo iniciar Kinship. Reinicia la aplicación.';

  @override
  String get privateByDesign => 'PRIVACIDAD DESDE EL DISEÑO';

  @override
  String get navHome => 'Inicio';

  @override
  String get navAccounts => 'Cuentas';

  @override
  String get homeHeadline => 'Tus conexiones,\nen contexto.';

  @override
  String get homeIntro =>
      'Una forma más tranquila de entender tus exportaciones de Instagram.';

  @override
  String get savedAccounts => 'Cuentas guardadas';

  @override
  String get savedAccountsIntro =>
      'Los resultados proceden de importaciones guardadas, no de una vista previa pendiente.';

  @override
  String get working => 'Procesando';

  @override
  String get yourConnections => 'Tus conexiones';

  @override
  String get savedCountsNote =>
      'El recuento solo refleja el historial guardado.';

  @override
  String get exploreAccounts => 'Explorar cuentas guardadas';

  @override
  String get searchSavedUsernames => 'Buscar nombres de usuario guardados';

  @override
  String get usernameHint => 'Nombre de usuario';

  @override
  String get searchAction => 'Buscar';

  @override
  String get filterAll => 'Todas';

  @override
  String get loadingSavedResults => 'Cargando resultados guardados…';

  @override
  String get noSavedResults => 'Aún no hay resultados guardados en esta vista.';

  @override
  String showingResults(int start, int end, int total) {
    return 'Mostrando $start–$end de $total';
  }

  @override
  String get previousPage => 'Anterior';

  @override
  String get nextPage => 'Siguiente';

  @override
  String get aboutResults => 'Acerca de tus resultados';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get support => 'Ayuda y contacto';

  @override
  String get openInfoLinkFailed =>
      'No se pudo abrir el enlace. Inténtalo de nuevo.';

  @override
  String get snapshotCaveat =>
      'Una exportación es una instantánea, no un registro de cuándo se siguió o dejó de seguir a alguien. Las fechas de exportación e importación no son fechas de los eventos. Las secciones ausentes o parciales no permiten confirmar una ausencia; una instantánea no demuestra un bloqueo, cambio de nombre ni eliminación.';

  @override
  String get privacyDisclosure =>
      'Kinship no sube la exportación que seleccionas. El historial procesado se guarda localmente y puede incluirse en la copia de seguridad del dispositivo.';

  @override
  String get addAnotherExport => 'Añadir otra exportación';

  @override
  String get startWithExport => 'Empieza con tu exportación';

  @override
  String get exportReady => 'Exportación lista para revisar';

  @override
  String get compactExportDescription =>
      'Añade una exportación ZIP o JSON. No se sube; el historial guardado puede incluirse en la copia de seguridad del dispositivo.';

  @override
  String get exportDescription =>
      'Elige una exportación de Instagram en ZIP o JSON. No se sube; el historial guardado puede incluirse en la copia de seguridad del dispositivo.';

  @override
  String get chooseExport => 'Elegir exportación';

  @override
  String get chooseAnotherExport => 'Elegir otra exportación';

  @override
  String get accountsStat => 'Cuentas';

  @override
  String get mutual => 'Mutua';

  @override
  String get followingOnly => 'Solo sigues';

  @override
  String get followerOnly => 'Solo te sigue';

  @override
  String get unknown => 'Desconocido';

  @override
  String get unavailable => 'no disponible';

  @override
  String statSemantics(String label, String count) {
    return '$label: $count';
  }

  @override
  String filterWithCount(String label, String count) {
    return '$label $count';
  }

  @override
  String get reviewBeforeSaving => 'Revisar antes de guardar';

  @override
  String get partialSaferDefault =>
      'La cobertura parcial es la opción más segura por defecto. Confirma la cobertura de cada sección por separado.';

  @override
  String get completeCoverageExplanation =>
      'Completa significa que la exportación cubre toda esta sección; el ZIP por sí solo no lo demuestra.';

  @override
  String recognizedSummary(int files, int invalid, int duplicates) {
    return 'Archivos reconocidos: $files  ·  Filas no válidas: $invalid  ·  Filas duplicadas: $duplicates';
  }

  @override
  String warningPrefix(String message) {
    return '!  $message';
  }

  @override
  String get reviewImpact => 'Revisar el impacto';

  @override
  String get confirmSavedChanges => 'Confirmar cambios guardados';

  @override
  String get partialNoAbsence =>
      'Las secciones parciales o ausentes solo añaden observaciones. No se deduce ninguna ausencia.';

  @override
  String get confirmSaveLocally => 'Confirmar y guardar localmente';

  @override
  String get sideFollowing => 'Siguiendo';

  @override
  String get sideFollowers => 'Seguidores';

  @override
  String get sideFollowingLower => 'siguiendo';

  @override
  String get sideFollowersLower => 'seguidores';

  @override
  String missingSide(String side) {
    return '$side: falta · desconocida, no es cero';
  }

  @override
  String sideObservations(String side, int observed, int rows) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: 'filas',
      one: 'fila',
    );
    return '$side · $observed observados de $rows $_temp0';
  }

  @override
  String sideInvalidDuplicates(int invalid, int duplicates) {
    return '$invalid no válidas · $duplicates duplicadas';
  }

  @override
  String get coveragePartial => 'Parcial';

  @override
  String get coverageComplete => 'Completa';

  @override
  String get coveragePartialLower => 'parcial';

  @override
  String get coverageCompleteLower => 'completa';

  @override
  String get coverageUnknownLower => 'desconocida';

  @override
  String get coverageMissingLower => 'ausente';

  @override
  String get completeUnavailable =>
      'No se puede confirmar que sea completa: revisa las filas no válidas en una nueva exportación.';

  @override
  String acknowledgeSide(String side, String coverage) {
    return 'Confirmo que $side está $coverage en esta exportación';
  }

  @override
  String completeSideSnapshot(String side) {
    return 'Instantánea completa de $side';
  }

  @override
  String previouslyPresentAbsence(int count, String side) {
    return '$count antes presentes → no presentes en esta instantánea completa de $side.';
  }

  @override
  String previouslyUnknownAbsence(int count, String side) {
    return '$count antes desconocidas → no presentes en esta instantánea completa de $side.';
  }

  @override
  String sampleAccounts(String accounts) {
    return 'Muestra (hasta 10): $accounts';
  }

  @override
  String detailsFor(String username) {
    return 'Detalles de @$username';
  }

  @override
  String openProfileFor(String username) {
    return 'Abrir el perfil de @$username';
  }

  @override
  String usernameDisplay(String username) {
    return '@$username';
  }

  @override
  String get snapshotEvidenceNote =>
      'La instantánea no indica cuándo se siguió o dejó de seguir a alguien.';

  @override
  String get copyUsername => 'Copiar nombre de usuario';

  @override
  String get openProfile => 'Abrir perfil';

  @override
  String notPresentFollowers(String importId) {
    return 'No aparece en la instantánea completa de seguidores (importación #$importId)';
  }

  @override
  String notPresentFollowing(String importId) {
    return 'No aparece en la instantánea completa de seguidos (importación #$importId)';
  }

  @override
  String coverageWithImport(String side, String coverage, int importId) {
    return '$side $coverage (importación #$importId)';
  }

  @override
  String coverageWithoutImport(String side, String coverage) {
    return '$side $coverage';
  }

  @override
  String rowEvidence(String evidence, String following, String followers) {
    return '$evidence · Última cobertura: $following, $followers';
  }

  @override
  String get warningInvalidRows => 'No se pudieron leer algunas filas.';

  @override
  String get warningDuplicateRows => 'Se combinaron las filas repetidas.';

  @override
  String get warningConflictingDuplicate =>
      'Las filas repetidas contenían datos contradictorios.';

  @override
  String get readExportFailed =>
      'No se pudo leer esta exportación. No se guardó nada.';

  @override
  String get exportTooLarge =>
      'La exportación supera el límite de tamaño local. No se guardó nada.';

  @override
  String get exportSafetyLimit =>
      'La exportación supera un límite de seguridad. No se guardó nada.';

  @override
  String get noRelationshipData =>
      'No se encontraron datos de relaciones compatibles. No se guardó nada.';

  @override
  String get tempCleanupFailed =>
      'Puede quedar una copia temporal de la importación. Reintenta o elimínala del almacenamiento temporal de la aplicación.';

  @override
  String get exportValidationFailed =>
      'No se pudo validar la exportación de forma segura. No se guardó nada.';

  @override
  String get prepareReviewFailed =>
      'No se pudo preparar esta revisión. No se guardó nada.';

  @override
  String get importSaved => 'Importación guardada en este dispositivo.';

  @override
  String get importAlreadySaved => 'Esta importación ya está guardada.';

  @override
  String get savedDataChanged =>
      'Los datos guardados han cambiado. Revisa de nuevo esta importación antes de confirmarla.';

  @override
  String get importRejected =>
      'No se pudo guardar la importación. Comprueba la cobertura e inténtalo de nuevo.';

  @override
  String get importSaveFailed =>
      'No se pudo guardar la importación. No se modificó nada.';

  @override
  String get savedResultsUnavailable =>
      'Los resultados guardados no están disponibles ahora mismo.';

  @override
  String get usernameCopied => 'Nombre de usuario copiado.';

  @override
  String get openProfileFailed => 'No se pudo abrir el perfil.';

  @override
  String get proTitle => 'Kinship Pro';

  @override
  String get proHeadline => 'Un poco más de Kinship.';

  @override
  String get proIntro =>
      'Apoya una forma independiente y tranquila de entender tus conexiones. Una compra de por vida, sin suscripción.';

  @override
  String get proFreeNote =>
      'Importar, revisar la seguridad y ver totales sigue siendo gratis. Hasta 10 nombres por categoría; Pro desbloquea listas completas, búsqueda y detalles.';

  @override
  String get proActive => 'Kinship Pro está activo en esta cuenta.';

  @override
  String get proInactive => 'Kinship Pro no está activo en esta cuenta.';

  @override
  String get proStatusUnknown =>
      'No se pudo comprobar el estado de Pro. Puedes intentar restaurar tu compra.';

  @override
  String proLifetimePrice(String price) {
    return 'Acceso de por vida · $price';
  }

  @override
  String get proViewOffer => 'Ver oferta de por vida';

  @override
  String get proOfferUnavailable =>
      'La oferta no está disponible ahora. Inténtalo más tarde; tus importaciones siguen funcionando.';

  @override
  String get proRestore => 'Restaurar compras';

  @override
  String get proRestored => 'Kinship Pro restaurado.';

  @override
  String get proNothingToRestore =>
      'No se encontró ninguna compra de Kinship Pro en esta cuenta de la tienda.';

  @override
  String get proRestoreFailed =>
      'No se pudieron restaurar las compras. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get proPurchaseFailed =>
      'No se pudo completar la compra. Inténtalo de nuevo.';

  @override
  String get proNotConfirmed =>
      'Pro aún no está confirmado. Comprueba tu cuenta de la tienda o restaura la compra.';

  @override
  String get proPrivacy =>
      'Los archivos y listas se almacenan localmente y pueden incluirse en copias de seguridad del dispositivo. No se envían a RevenueCat. RevenueCat recibe el historial de compras y un ID anónimo del SDK.';

  @override
  String get sampleHeading => 'Un vistazo a tus conexiones';

  @override
  String get sampleDescription =>
      'Los primeros 10 nombres de cada categoría son gratis. Pro desbloquea listas completas, búsqueda y detalles de evidencia.';

  @override
  String get sampleUnknown =>
      'No se pudo comprobar Pro. Se muestra una muestra limitada hasta confirmar el acceso; las importaciones y los totales siguen disponibles.';

  @override
  String get sampleUnlock => 'Explorar Kinship Pro';

  @override
  String sampleShowing(int shown, int total) {
    return 'Primeros $shown de $total en esta categoría';
  }
}
