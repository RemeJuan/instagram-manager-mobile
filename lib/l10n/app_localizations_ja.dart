// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Kinship';

  @override
  String get appStartupError => 'Kinshipを起動できませんでした。アプリを再起動してください。';

  @override
  String get privateByDesign => 'プライバシーを重視した設計';

  @override
  String get navHome => 'ホーム';

  @override
  String get navAccounts => 'アカウント';

  @override
  String get homeHeadline => 'つながりを、\n背景とともに。';

  @override
  String get homeIntro => 'Instagramのエクスポートを落ち着いて把握できます。';

  @override
  String get savedAccounts => '保存済みアカウント';

  @override
  String get savedAccountsIntro => '結果は保留中のプレビューではなく、保存済みのインポートに基づきます。';

  @override
  String get working => '処理中';

  @override
  String get yourConnections => 'あなたのつながり';

  @override
  String get savedCountsNote => '件数は保存済みの履歴のみを反映します。';

  @override
  String get exploreAccounts => '保存済みアカウントを見る';

  @override
  String get searchSavedUsernames => '保存済みユーザー名を検索';

  @override
  String get usernameHint => 'ユーザー名';

  @override
  String get searchAction => '検索';

  @override
  String get filterAll => 'すべて';

  @override
  String get loadingSavedResults => '保存済みの結果を読み込み中…';

  @override
  String get noSavedResults => 'この表示には保存済みの結果がありません。';

  @override
  String showingResults(int start, int end, int total) {
    return '$total件中$start～$end件を表示';
  }

  @override
  String get previousPage => '前へ';

  @override
  String get nextPage => '次へ';

  @override
  String get aboutResults => '結果について';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get support => 'サポート・お問い合わせ';

  @override
  String get openInfoLinkFailed => 'リンクを開けませんでした。もう一度お試しください。';

  @override
  String get snapshotCaveat =>
      'エクスポートはスナップショットであり、フォローやフォロー解除の時刻を記録したものではありません。エクスポート時刻とインポート時刻もイベント時刻ではありません。欠落または一部のみの側から不在を確定することはできません。スナップショットでブロック、改名、削除を証明することもできません。';

  @override
  String get privacyDisclosure =>
      '選択したエクスポートがKinshipからアップロードされることはありません。解析された履歴は端末内に保存され、デバイスのバックアップに含まれる場合があります。';

  @override
  String get addAnotherExport => '別のエクスポートを追加';

  @override
  String get startWithExport => 'エクスポートから始める';

  @override
  String get exportReady => 'エクスポートの確認準備ができました';

  @override
  String get compactExportDescription =>
      'ZIPまたはJSON形式のエクスポートを追加します。アップロードはありません。保存した履歴はデバイスのバックアップに含まれる場合があります。';

  @override
  String get exportDescription =>
      'InstagramのZIPまたはJSON形式のエクスポートを選択します。アップロードはありません。保存した履歴はデバイスのバックアップに含まれる場合があります。';

  @override
  String get chooseExport => 'エクスポートを選択';

  @override
  String get chooseAnotherExport => '別のエクスポートを選択';

  @override
  String get accountsStat => 'アカウント';

  @override
  String get mutual => '相互';

  @override
  String get followingOnly => 'フォロー中のみ';

  @override
  String get followerOnly => 'フォロワーのみ';

  @override
  String get unknown => '不明';

  @override
  String get unavailable => '利用不可';

  @override
  String statSemantics(String label, String count) {
    return '$label: $count';
  }

  @override
  String filterWithCount(String label, String count) {
    return '$label $count';
  }

  @override
  String get reviewBeforeSaving => '保存前に確認';

  @override
  String get partialSaferDefault => '安全のため、初期設定は「一部」です。各側のカバー範囲を個別に確認してください。';

  @override
  String get completeCoverageExplanation =>
      '「完全」とは、この側全体がエクスポートに含まれることです。ZIPだけではそれを証明できません。';

  @override
  String recognizedSummary(int files, int invalid, int duplicates) {
    return '認識したファイル: $files  ·  無効な行: $invalid  ·  重複した行: $duplicates';
  }

  @override
  String warningPrefix(String message) {
    return '!  $message';
  }

  @override
  String get reviewImpact => '影響を確認';

  @override
  String get confirmSavedChanges => '保存内容の変更を確定';

  @override
  String get partialNoAbsence => '一部または欠落した側から追加されるのは観測情報のみです。不在は提示されません。';

  @override
  String get confirmSaveLocally => '確定して端末に保存';

  @override
  String get sideFollowing => 'フォロー中';

  @override
  String get sideFollowers => 'フォロワー';

  @override
  String get sideFollowingLower => 'フォロー中';

  @override
  String get sideFollowersLower => 'フォロワー';

  @override
  String missingSide(String side) {
    return '$side: 欠落 · 0人ではなく不明';
  }

  @override
  String sideObservations(String side, int observed, int rows) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: 'rows',
      one: 'row',
    );
    return '$side · $rows件中$observed件を確認（$_temp0）';
  }

  @override
  String sideInvalidDuplicates(int invalid, int duplicates) {
    return '無効 $invalid件 · 重複 $duplicates件';
  }

  @override
  String get coveragePartial => '一部';

  @override
  String get coverageComplete => '完全';

  @override
  String get coveragePartialLower => '一部';

  @override
  String get coverageCompleteLower => '完全';

  @override
  String get coverageUnknownLower => '不明';

  @override
  String get coverageMissingLower => '欠落';

  @override
  String get completeUnavailable =>
      '完全なカバー範囲は指定できません。無効な行を確認するには、新しいエクスポートが必要です。';

  @override
  String acknowledgeSide(String side, String coverage) {
    return 'このエクスポートでは$sideが「$coverage」であることを確認します';
  }

  @override
  String completeSideSnapshot(String side) {
    return '$sideの完全なスナップショット';
  }

  @override
  String previouslyPresentAbsence(int count, String side) {
    return '以前存在していた$count件が、この$sideの完全なスナップショットでは確認できません。';
  }

  @override
  String previouslyUnknownAbsence(int count, String side) {
    return '以前は不明だった$count件が、この$sideの完全なスナップショットでは確認できません。';
  }

  @override
  String sampleAccounts(String accounts) {
    return '例（最大10件）: $accounts';
  }

  @override
  String detailsFor(String username) {
    return '@$usernameの詳細';
  }

  @override
  String openProfileFor(String username) {
    return '@$usernameのプロフィールを開く';
  }

  @override
  String usernameDisplay(String username) {
    return '@$username';
  }

  @override
  String get snapshotEvidenceNote => 'スナップショットの情報からフォローまたはフォロー解除の時刻は分かりません。';

  @override
  String get copyUsername => 'ユーザー名をコピー';

  @override
  String get openProfile => 'プロフィールを開く';

  @override
  String notPresentFollowers(String importId) {
    return 'フォロワーの完全なスナップショットに存在しません（インポート #$importId）';
  }

  @override
  String notPresentFollowing(String importId) {
    return 'フォロー中の完全なスナップショットに存在しません（インポート #$importId）';
  }

  @override
  String coverageWithImport(String side, String coverage, int importId) {
    return '$side $coverage（インポート #$importId）';
  }

  @override
  String coverageWithoutImport(String side, String coverage) {
    return '$side $coverage';
  }

  @override
  String rowEvidence(String evidence, String following, String followers) {
    return '$evidence · 最新のカバー範囲: $following, $followers';
  }

  @override
  String get warningInvalidRows => '読み取れない行があります。';

  @override
  String get warningDuplicateRows => '重複した行を統合しました。';

  @override
  String get warningConflictingDuplicate => '重複した行の詳細に矛盾があります。';

  @override
  String get readExportFailed => 'エクスポートを読み取れませんでした。何も保存されていません。';

  @override
  String get exportTooLarge => 'エクスポートが端末内のサイズ上限を超えています。何も保存されていません。';

  @override
  String get exportSafetyLimit => 'エクスポートが安全上の制限を超えています。何も保存されていません。';

  @override
  String get noRelationshipData => '対応する関係データが見つかりませんでした。何も保存されていません。';

  @override
  String get tempCleanupFailed =>
      'インポートの一時コピーが残っている可能性があります。再試行するか、アプリの一時ストレージから削除してください。';

  @override
  String get exportValidationFailed => 'エクスポートを安全に検証できませんでした。何も保存されていません。';

  @override
  String get prepareReviewFailed => '確認画面を準備できませんでした。何も保存されていません。';

  @override
  String get importSaved => 'インポートをこの端末に保存しました。';

  @override
  String get importAlreadySaved => 'このインポートはすでに保存されています。';

  @override
  String get savedDataChanged => '保存済みデータが変更されました。確定する前に、このインポートをもう一度確認してください。';

  @override
  String get importRejected => 'インポートを保存できませんでした。カバー範囲を確認して再試行してください。';

  @override
  String get importSaveFailed => 'インポートを保存できませんでした。変更はありません。';

  @override
  String get savedResultsUnavailable => '現在、保存済みの結果を利用できません。';

  @override
  String get usernameCopied => 'ユーザー名をコピーしました。';

  @override
  String get openProfileFailed => 'プロフィールを開けませんでした。';

  @override
  String get proTitle => 'Kinship Pro';

  @override
  String get proHeadline => 'Kinshipを、もう少し。';

  @override
  String get proIntro =>
      'つながりを落ち着いて理解するための独立したアプリを応援してください。買い切りで、サブスクリプションではありません。';

  @override
  String get proFreeNote =>
      '読み込み、安全性の確認、アカウント数は無料です。各分類の最初の10件を表示できます。全件表示、検索、根拠の詳細はProで利用できます。';

  @override
  String get proActive => 'このアカウントではKinship Proが有効です。';

  @override
  String get proInactive => 'このアカウントではKinship Proは有効ではありません。';

  @override
  String get proStatusUnknown => 'Proの状態を確認できませんでした。購入の復元をお試しください。';

  @override
  String proLifetimePrice(String price) {
    return '買い切り · $price';
  }

  @override
  String get proViewOffer => '買い切りプランを見る';

  @override
  String get proOfferUnavailable =>
      '現在プランを表示できません。後で再度お試しください。読み込みは引き続き利用できます。';

  @override
  String get proRestore => '購入を復元';

  @override
  String get proRestored => 'Kinship Proを復元しました。';

  @override
  String get proNothingToRestore => 'このストアアカウントにKinship Proの購入は見つかりませんでした。';

  @override
  String get proRestoreFailed => '購入を復元できませんでした。接続を確認して再度お試しください。';

  @override
  String get proPurchaseFailed => '購入を完了できませんでした。再度お試しください。';

  @override
  String get proNotConfirmed => 'Proをまだ確認できません。ストアアカウントの確認か購入の復元をお試しください。';

  @override
  String get proPrivacy =>
      'エクスポートと関係リストはローカルに保存され、端末のバックアップに含まれる場合があります。RevenueCatには送信されません。RevenueCatには購入履歴と匿名のSDK IDが送信されます。';

  @override
  String get sampleHeading => 'つながりを少しだけ見る';

  @override
  String get sampleDescription => '各分類の最初の10件は無料です。全件表示、検索、根拠の詳細はProで利用できます。';

  @override
  String get sampleUnknown =>
      'Proの状態を確認できません。アクセスが確認されるまで件数を制限します。読み込みと合計件数は利用できます。';

  @override
  String get sampleUnlock => 'Kinship Proを見る';

  @override
  String sampleShowing(int shown, int total) {
    return 'この分類の$total件中、最初の$shown件を表示';
  }
}
