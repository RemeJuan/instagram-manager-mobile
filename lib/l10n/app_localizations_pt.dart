// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Kinship';

  @override
  String get appStartupError =>
      'Não foi possível iniciar o Kinship. Reinicie o app.';

  @override
  String get privateByDesign => 'PRIVADO POR PROJETO';

  @override
  String get navHome => 'Início';

  @override
  String get navAccounts => 'Contas';

  @override
  String get homeHeadline => 'Suas conexões,\nem contexto.';

  @override
  String get homeIntro =>
      'Uma maneira mais tranquila de entender suas exportações do Instagram.';

  @override
  String get savedAccounts => 'Contas salvas';

  @override
  String get savedAccountsIntro =>
      'Os resultados vêm de importações salvas, não de uma prévia pendente.';

  @override
  String get working => 'Processando';

  @override
  String get yourConnections => 'Suas conexões';

  @override
  String get savedCountsNote =>
      'As contagens refletem apenas o histórico salvo.';

  @override
  String get exploreAccounts => 'Explorar contas salvas';

  @override
  String get searchSavedUsernames => 'Buscar nomes de usuário salvos';

  @override
  String get usernameHint => 'Nome de usuário';

  @override
  String get searchAction => 'Buscar';

  @override
  String get filterAll => 'Todos';

  @override
  String get loadingSavedResults => 'Carregando resultados salvos…';

  @override
  String get noSavedResults =>
      'Ainda não há resultados salvos nesta visualização.';

  @override
  String showingResults(int start, int end, int total) {
    return 'Exibindo $start–$end de $total';
  }

  @override
  String get previousPage => 'Anterior';

  @override
  String get nextPage => 'Próxima';

  @override
  String get aboutResults => 'Sobre seus resultados';

  @override
  String get snapshotCaveat =>
      'Uma exportação é um retrato, não um registro dos horários em que você seguiu ou deixou de seguir alguém. Os horários de exportação e importação não são horários de eventos. Lados ausentes ou parciais não podem comprovar ausência; um retrato não comprova bloqueio, mudança de nome ou exclusão.';

  @override
  String get privacyDisclosure =>
      'O Kinship não envia a exportação selecionada. O histórico processado fica armazenado localmente e pode ser incluído no backup do dispositivo.';

  @override
  String get addAnotherExport => 'Adicionar outra exportação';

  @override
  String get startWithExport => 'Comece com sua exportação';

  @override
  String get exportReady => 'Exportação pronta para revisão';

  @override
  String get compactExportDescription =>
      'Adicione uma exportação ZIP ou JSON. Nada é enviado; o histórico salvo pode ser incluído no backup do dispositivo.';

  @override
  String get exportDescription =>
      'Escolha uma exportação ZIP ou JSON do Instagram. Nada é enviado; o histórico salvo pode ser incluído no backup do dispositivo.';

  @override
  String get chooseExport => 'Escolher exportação';

  @override
  String get chooseAnotherExport => 'Escolher outra exportação';

  @override
  String get accountsStat => 'Contas';

  @override
  String get mutual => 'Mútuos';

  @override
  String get followingOnly => 'Seguindo apenas';

  @override
  String get followerOnly => 'Seguidores apenas';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get unavailable => 'indisponível';

  @override
  String statSemantics(String label, String count) {
    return '$label: $count';
  }

  @override
  String filterWithCount(String label, String count) {
    return '$label $count';
  }

  @override
  String get reviewBeforeSaving => 'Revise antes de salvar';

  @override
  String get partialSaferDefault =>
      'Parcial é a opção mais segura. Confirme a cobertura de cada lado separadamente.';

  @override
  String get completeCoverageExplanation =>
      'Completo significa que a exportação cobre todo este lado; o ZIP sozinho não comprova isso.';

  @override
  String recognizedSummary(int files, int invalid, int duplicates) {
    return 'Arquivos reconhecidos: $files  ·  Linhas inválidas: $invalid  ·  Linhas duplicadas: $duplicates';
  }

  @override
  String warningPrefix(String message) {
    return '!  $message';
  }

  @override
  String get reviewImpact => 'Revisar impacto';

  @override
  String get confirmSavedChanges => 'Confirmar alterações salvas';

  @override
  String get partialNoAbsence =>
      'Lados parciais ou ausentes adicionam apenas observações. Nenhuma ausência é proposta.';

  @override
  String get confirmSaveLocally => 'Confirmar e salvar localmente';

  @override
  String get sideFollowing => 'Seguindo';

  @override
  String get sideFollowers => 'Seguidores';

  @override
  String get sideFollowingLower => 'seguindo';

  @override
  String get sideFollowersLower => 'seguidores';

  @override
  String missingSide(String side) {
    return '$side: ausente · desconhecido, não zero';
  }

  @override
  String sideObservations(String side, int observed, int rows) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: 'rows',
      one: 'row',
    );
    return '$side · $observed observados de $rows $_temp0';
  }

  @override
  String sideInvalidDuplicates(int invalid, int duplicates) {
    return '$invalid inválidas · $duplicates duplicadas';
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
  String get coverageUnknownLower => 'desconhecida';

  @override
  String get coverageMissingLower => 'ausente';

  @override
  String get completeUnavailable =>
      'Cobertura completa indisponível: revise as linhas inválidas em uma nova exportação.';

  @override
  String acknowledgeSide(String side, String coverage) {
    return 'Confirmo que $side está $coverage nesta exportação';
  }

  @override
  String completeSideSnapshot(String side) {
    return 'Retrato completo de $side';
  }

  @override
  String previouslyPresentAbsence(int count, String side) {
    return '$count antes presentes → não estão presentes neste retrato completo de $side.';
  }

  @override
  String previouslyUnknownAbsence(int count, String side) {
    return '$count antes desconhecidos → não estão presentes neste retrato completo de $side.';
  }

  @override
  String sampleAccounts(String accounts) {
    return 'Exemplo (até 10): $accounts';
  }

  @override
  String detailsFor(String username) {
    return 'Detalhes de @$username';
  }

  @override
  String openProfileFor(String username) {
    return 'Abrir perfil de @$username';
  }

  @override
  String usernameDisplay(String username) {
    return '@$username';
  }

  @override
  String get snapshotEvidenceNote =>
      'As evidências do retrato não indicam quando alguém começou ou deixou de seguir uma conta.';

  @override
  String get copyUsername => 'Copiar nome de usuário';

  @override
  String get openProfile => 'Abrir perfil';

  @override
  String notPresentFollowers(String importId) {
    return 'Não consta no retrato completo de seguidores (importação #$importId)';
  }

  @override
  String notPresentFollowing(String importId) {
    return 'Não consta no retrato completo de contas seguidas (importação #$importId)';
  }

  @override
  String coverageWithImport(String side, String coverage, int importId) {
    return '$side $coverage (importação #$importId)';
  }

  @override
  String coverageWithoutImport(String side, String coverage) {
    return '$side $coverage';
  }

  @override
  String rowEvidence(String evidence, String following, String followers) {
    return '$evidence · Cobertura mais recente: $following, $followers';
  }

  @override
  String get warningInvalidRows => 'Não foi possível ler algumas linhas.';

  @override
  String get warningDuplicateRows => 'Linhas repetidas foram agrupadas.';

  @override
  String get warningConflictingDuplicate =>
      'Linhas repetidas tinham informações conflitantes.';

  @override
  String get readExportFailed =>
      'Não foi possível ler esta exportação. Nada foi salvo.';

  @override
  String get exportTooLarge =>
      'A exportação excede o limite de tamanho local. Nada foi salvo.';

  @override
  String get exportSafetyLimit =>
      'A exportação excede um limite de segurança. Nada foi salvo.';

  @override
  String get noRelationshipData =>
      'Nenhum dado de relacionamento compatível foi encontrado. Nada foi salvo.';

  @override
  String get tempCleanupFailed =>
      'Uma cópia temporária da importação pode ter permanecido. Tente novamente ou remova-a do armazenamento temporário do app.';

  @override
  String get exportValidationFailed =>
      'Não foi possível validar a exportação com segurança. Nada foi salvo.';

  @override
  String get prepareReviewFailed =>
      'Não foi possível preparar esta revisão. Nada foi salvo.';

  @override
  String get importSaved => 'Importação salva neste dispositivo.';

  @override
  String get importAlreadySaved => 'Esta importação já está salva.';

  @override
  String get savedDataChanged =>
      'Os dados salvos foram alterados. Revise esta importação novamente antes de confirmar.';

  @override
  String get importRejected =>
      'Não foi possível salvar a importação. Confira a cobertura e tente novamente.';

  @override
  String get importSaveFailed =>
      'Não foi possível salvar a importação. Nenhuma alteração foi feita.';

  @override
  String get savedResultsUnavailable =>
      'Os resultados salvos estão indisponíveis no momento.';

  @override
  String get usernameCopied => 'Nome de usuário copiado.';

  @override
  String get openProfileFailed => 'Não foi possível abrir o perfil.';

  @override
  String get proTitle => 'Kinship Pro';

  @override
  String get proHeadline => 'Um pouco mais de Kinship.';

  @override
  String get proIntro =>
      'Apoie uma forma independente e tranquila de entender suas conexões. Compra vitalícia, sem assinatura.';

  @override
  String get proFreeNote =>
      'Importação, revisão de segurança e totais continuam gratuitos. Até 10 nomes por categoria; o Pro libera listas completas, busca e detalhes.';

  @override
  String get proActive => 'Kinship Pro está ativo nesta conta.';

  @override
  String get proInactive => 'Kinship Pro não está ativo nesta conta.';

  @override
  String get proStatusUnknown =>
      'Não foi possível verificar o status Pro. Você pode tentar restaurar sua compra.';

  @override
  String proLifetimePrice(String price) {
    return 'Acesso vitalício · $price';
  }

  @override
  String get proViewOffer => 'Ver oferta vitalícia';

  @override
  String get proOfferUnavailable =>
      'A oferta está indisponível agora. Tente mais tarde; suas importações continuam funcionando.';

  @override
  String get proRestore => 'Restaurar compras';

  @override
  String get proRestored => 'Kinship Pro restaurado.';

  @override
  String get proNothingToRestore =>
      'Nenhuma compra do Kinship Pro encontrada nesta conta da loja.';

  @override
  String get proRestoreFailed =>
      'Não foi possível restaurar as compras. Verifique sua conexão e tente novamente.';

  @override
  String get proPurchaseFailed =>
      'Não foi possível concluir a compra. Tente novamente.';

  @override
  String get proNotConfirmed =>
      'Pro ainda não foi confirmado. Confira sua conta da loja ou restaure a compra.';

  @override
  String get proPrivacy =>
      'Exportações e listas são armazenadas localmente e podem constar dos backups do dispositivo. Não são enviadas à RevenueCat. A RevenueCat recebe o histórico de compras e um ID anônimo do SDK.';

  @override
  String get sampleHeading => 'Um pouco das suas conexões';

  @override
  String get sampleDescription =>
      'Os primeiros 10 nomes de cada categoria são grátis. O Pro libera listas completas, busca e detalhes de evidências.';

  @override
  String get sampleUnknown =>
      'Não foi possível verificar o Pro. Uma amostra limitada aparece até confirmar o acesso; importações e totais continuam disponíveis.';

  @override
  String get sampleUnlock => 'Conhecer Kinship Pro';

  @override
  String sampleShowing(int shown, int total) {
    return 'Primeiros $shown de $total nesta categoria';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appName => 'Kinship';

  @override
  String get appStartupError =>
      'Não foi possível iniciar o Kinship. Reinicie o app.';

  @override
  String get privateByDesign => 'PRIVADO POR PROJETO';

  @override
  String get navHome => 'Início';

  @override
  String get navAccounts => 'Contas';

  @override
  String get homeHeadline => 'Suas conexões,\nem contexto.';

  @override
  String get homeIntro =>
      'Uma maneira mais tranquila de entender suas exportações do Instagram.';

  @override
  String get savedAccounts => 'Contas salvas';

  @override
  String get savedAccountsIntro =>
      'Os resultados vêm de importações salvas, não de uma prévia pendente.';

  @override
  String get working => 'Processando';

  @override
  String get yourConnections => 'Suas conexões';

  @override
  String get savedCountsNote =>
      'As contagens refletem apenas o histórico salvo.';

  @override
  String get exploreAccounts => 'Explorar contas salvas';

  @override
  String get searchSavedUsernames => 'Buscar nomes de usuário salvos';

  @override
  String get usernameHint => 'Nome de usuário';

  @override
  String get searchAction => 'Buscar';

  @override
  String get filterAll => 'Todos';

  @override
  String get loadingSavedResults => 'Carregando resultados salvos…';

  @override
  String get noSavedResults =>
      'Ainda não há resultados salvos nesta visualização.';

  @override
  String showingResults(int start, int end, int total) {
    return 'Exibindo $start–$end de $total';
  }

  @override
  String get previousPage => 'Anterior';

  @override
  String get nextPage => 'Próxima';

  @override
  String get aboutResults => 'Sobre seus resultados';

  @override
  String get snapshotCaveat =>
      'Uma exportação é um retrato, não um registro dos horários em que você seguiu ou deixou de seguir alguém. Os horários de exportação e importação não são horários de eventos. Lados ausentes ou parciais não podem comprovar ausência; um retrato não comprova bloqueio, mudança de nome ou exclusão.';

  @override
  String get privacyDisclosure =>
      'O Kinship não envia a exportação selecionada. O histórico processado fica armazenado localmente e pode ser incluído no backup do dispositivo.';

  @override
  String get addAnotherExport => 'Adicionar outra exportação';

  @override
  String get startWithExport => 'Comece com sua exportação';

  @override
  String get exportReady => 'Exportação pronta para revisão';

  @override
  String get compactExportDescription =>
      'Adicione uma exportação ZIP ou JSON. Nada é enviado; o histórico salvo pode ser incluído no backup do dispositivo.';

  @override
  String get exportDescription =>
      'Escolha uma exportação ZIP ou JSON do Instagram. Nada é enviado; o histórico salvo pode ser incluído no backup do dispositivo.';

  @override
  String get chooseExport => 'Escolher exportação';

  @override
  String get chooseAnotherExport => 'Escolher outra exportação';

  @override
  String get accountsStat => 'Contas';

  @override
  String get mutual => 'Mútuos';

  @override
  String get followingOnly => 'Seguindo apenas';

  @override
  String get followerOnly => 'Seguidores apenas';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get unavailable => 'indisponível';

  @override
  String statSemantics(String label, String count) {
    return '$label: $count';
  }

  @override
  String filterWithCount(String label, String count) {
    return '$label $count';
  }

  @override
  String get reviewBeforeSaving => 'Revise antes de salvar';

  @override
  String get partialSaferDefault =>
      'Parcial é a opção mais segura. Confirme a cobertura de cada lado separadamente.';

  @override
  String get completeCoverageExplanation =>
      'Completo significa que a exportação cobre todo este lado; o ZIP sozinho não comprova isso.';

  @override
  String recognizedSummary(int files, int invalid, int duplicates) {
    return 'Arquivos reconhecidos: $files  ·  Linhas inválidas: $invalid  ·  Linhas duplicadas: $duplicates';
  }

  @override
  String warningPrefix(String message) {
    return '!  $message';
  }

  @override
  String get reviewImpact => 'Revisar impacto';

  @override
  String get confirmSavedChanges => 'Confirmar alterações salvas';

  @override
  String get partialNoAbsence =>
      'Lados parciais ou ausentes adicionam apenas observações. Nenhuma ausência é proposta.';

  @override
  String get confirmSaveLocally => 'Confirmar e salvar localmente';

  @override
  String get sideFollowing => 'Seguindo';

  @override
  String get sideFollowers => 'Seguidores';

  @override
  String get sideFollowingLower => 'seguindo';

  @override
  String get sideFollowersLower => 'seguidores';

  @override
  String missingSide(String side) {
    return '$side: ausente · desconhecido, não zero';
  }

  @override
  String sideObservations(String side, int observed, int rows) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: 'rows',
      one: 'row',
    );
    return '$side · $observed observados de $rows $_temp0';
  }

  @override
  String sideInvalidDuplicates(int invalid, int duplicates) {
    return '$invalid inválidas · $duplicates duplicadas';
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
  String get coverageUnknownLower => 'desconhecida';

  @override
  String get coverageMissingLower => 'ausente';

  @override
  String get completeUnavailable =>
      'Cobertura completa indisponível: revise as linhas inválidas em uma nova exportação.';

  @override
  String acknowledgeSide(String side, String coverage) {
    return 'Confirmo que $side está $coverage nesta exportação';
  }

  @override
  String completeSideSnapshot(String side) {
    return 'Retrato completo de $side';
  }

  @override
  String previouslyPresentAbsence(int count, String side) {
    return '$count antes presentes → não estão presentes neste retrato completo de $side.';
  }

  @override
  String previouslyUnknownAbsence(int count, String side) {
    return '$count antes desconhecidos → não estão presentes neste retrato completo de $side.';
  }

  @override
  String sampleAccounts(String accounts) {
    return 'Exemplo (até 10): $accounts';
  }

  @override
  String detailsFor(String username) {
    return 'Detalhes de @$username';
  }

  @override
  String openProfileFor(String username) {
    return 'Abrir perfil de @$username';
  }

  @override
  String usernameDisplay(String username) {
    return '@$username';
  }

  @override
  String get snapshotEvidenceNote =>
      'As evidências do retrato não indicam quando alguém começou ou deixou de seguir uma conta.';

  @override
  String get copyUsername => 'Copiar nome de usuário';

  @override
  String get openProfile => 'Abrir perfil';

  @override
  String notPresentFollowers(String importId) {
    return 'Não consta no retrato completo de seguidores (importação #$importId)';
  }

  @override
  String notPresentFollowing(String importId) {
    return 'Não consta no retrato completo de contas seguidas (importação #$importId)';
  }

  @override
  String coverageWithImport(String side, String coverage, int importId) {
    return '$side $coverage (importação #$importId)';
  }

  @override
  String coverageWithoutImport(String side, String coverage) {
    return '$side $coverage';
  }

  @override
  String rowEvidence(String evidence, String following, String followers) {
    return '$evidence · Cobertura mais recente: $following, $followers';
  }

  @override
  String get warningInvalidRows => 'Não foi possível ler algumas linhas.';

  @override
  String get warningDuplicateRows => 'Linhas repetidas foram agrupadas.';

  @override
  String get warningConflictingDuplicate =>
      'Linhas repetidas tinham informações conflitantes.';

  @override
  String get readExportFailed =>
      'Não foi possível ler esta exportação. Nada foi salvo.';

  @override
  String get exportTooLarge =>
      'A exportação excede o limite de tamanho local. Nada foi salvo.';

  @override
  String get exportSafetyLimit =>
      'A exportação excede um limite de segurança. Nada foi salvo.';

  @override
  String get noRelationshipData =>
      'Nenhum dado de relacionamento compatível foi encontrado. Nada foi salvo.';

  @override
  String get tempCleanupFailed =>
      'Uma cópia temporária da importação pode ter permanecido. Tente novamente ou remova-a do armazenamento temporário do app.';

  @override
  String get exportValidationFailed =>
      'Não foi possível validar a exportação com segurança. Nada foi salvo.';

  @override
  String get prepareReviewFailed =>
      'Não foi possível preparar esta revisão. Nada foi salvo.';

  @override
  String get importSaved => 'Importação salva neste dispositivo.';

  @override
  String get importAlreadySaved => 'Esta importação já está salva.';

  @override
  String get savedDataChanged =>
      'Os dados salvos foram alterados. Revise esta importação novamente antes de confirmar.';

  @override
  String get importRejected =>
      'Não foi possível salvar a importação. Confira a cobertura e tente novamente.';

  @override
  String get importSaveFailed =>
      'Não foi possível salvar a importação. Nenhuma alteração foi feita.';

  @override
  String get savedResultsUnavailable =>
      'Os resultados salvos estão indisponíveis no momento.';

  @override
  String get usernameCopied => 'Nome de usuário copiado.';

  @override
  String get openProfileFailed => 'Não foi possível abrir o perfil.';

  @override
  String get proTitle => 'Kinship Pro';

  @override
  String get proHeadline => 'Um pouco mais de Kinship.';

  @override
  String get proIntro =>
      'Apoie uma forma independente e tranquila de entender suas conexões. Compra vitalícia, sem assinatura.';

  @override
  String get proFreeNote =>
      'Importação, revisão de segurança e totais continuam gratuitos. Até 10 nomes por categoria; o Pro libera listas completas, busca e detalhes.';

  @override
  String get proActive => 'Kinship Pro está ativo nesta conta.';

  @override
  String get proInactive => 'Kinship Pro não está ativo nesta conta.';

  @override
  String get proStatusUnknown =>
      'Não foi possível verificar o status Pro. Você pode tentar restaurar sua compra.';

  @override
  String proLifetimePrice(String price) {
    return 'Acesso vitalício · $price';
  }

  @override
  String get proViewOffer => 'Ver oferta vitalícia';

  @override
  String get proOfferUnavailable =>
      'A oferta está indisponível agora. Tente mais tarde; suas importações continuam funcionando.';

  @override
  String get proRestore => 'Restaurar compras';

  @override
  String get proRestored => 'Kinship Pro restaurado.';

  @override
  String get proNothingToRestore =>
      'Nenhuma compra do Kinship Pro encontrada nesta conta da loja.';

  @override
  String get proRestoreFailed =>
      'Não foi possível restaurar as compras. Verifique sua conexão e tente novamente.';

  @override
  String get proPurchaseFailed =>
      'Não foi possível concluir a compra. Tente novamente.';

  @override
  String get proNotConfirmed =>
      'Pro ainda não foi confirmado. Confira sua conta da loja ou restaure a compra.';

  @override
  String get proPrivacy =>
      'Exportações e listas são armazenadas localmente e podem constar dos backups do dispositivo. Não são enviadas à RevenueCat. A RevenueCat recebe o histórico de compras e um ID anônimo do SDK.';

  @override
  String get sampleHeading => 'Um pouco das suas conexões';

  @override
  String get sampleDescription =>
      'Os primeiros 10 nomes de cada categoria são grátis. O Pro libera listas completas, busca e detalhes de evidências.';

  @override
  String get sampleUnknown =>
      'Não foi possível verificar o Pro. Uma amostra limitada aparece até confirmar o acesso; importações e totais continuam disponíveis.';

  @override
  String get sampleUnlock => 'Conhecer Kinship Pro';

  @override
  String sampleShowing(int shown, int total) {
    return 'Primeiros $shown de $total nesta categoria';
  }
}
