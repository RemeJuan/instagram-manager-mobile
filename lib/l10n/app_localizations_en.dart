// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Kinship';

  @override
  String get appStartupError =>
      'Kinship could not start. Please restart the app.';

  @override
  String get privateByDesign => 'PRIVATE BY DESIGN';

  @override
  String get navHome => 'Home';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get homeHeadline => 'Your connections,\nin context.';

  @override
  String get homeIntro => 'A quieter way to understand your Instagram exports.';

  @override
  String get savedAccounts => 'Saved accounts';

  @override
  String get savedAccountsIntro =>
      'Results come from saved imports, not a pending preview.';

  @override
  String get working => 'Working';

  @override
  String get yourConnections => 'Your connections';

  @override
  String get savedCountsNote => 'Counts reflect saved history only.';

  @override
  String get exploreAccounts => 'Explore saved accounts';

  @override
  String get searchSavedUsernames => 'Search saved usernames';

  @override
  String get usernameHint => 'Username';

  @override
  String get searchAction => 'Search';

  @override
  String get filterAll => 'All';

  @override
  String get loadingSavedResults => 'Loading saved results…';

  @override
  String get noSavedResults => 'No saved results in this view yet.';

  @override
  String showingResults(int start, int end, int total) {
    return 'Showing $start–$end of $total';
  }

  @override
  String get previousPage => 'Previous';

  @override
  String get nextPage => 'Next';

  @override
  String get aboutResults => 'About your results';

  @override
  String get snapshotCaveat =>
      'An export is a snapshot, not a record of follow or unfollow times. Export and import timestamps are not event times. Missing or partial sides cannot establish absence; a snapshot cannot prove a block, rename or deletion.';

  @override
  String get privacyDisclosure =>
      'Kinship does not upload your selected export. Parsed history is stored locally and may be included in device backup.';

  @override
  String get addAnotherExport => 'Add another export';

  @override
  String get startWithExport => 'Start with your export';

  @override
  String get exportReady => 'Export ready for review';

  @override
  String get compactExportDescription =>
      'Add a ZIP or JSON export. No upload; saved history may be backed up by your device.';

  @override
  String get exportDescription =>
      'Choose an Instagram export ZIP or JSON. No upload; saved history may be backed up by your device.';

  @override
  String get chooseExport => 'Choose export';

  @override
  String get chooseAnotherExport => 'Choose another export';

  @override
  String get accountsStat => 'Accounts';

  @override
  String get mutual => 'Mutual';

  @override
  String get followingOnly => 'Following only';

  @override
  String get followerOnly => 'Follower only';

  @override
  String get unknown => 'Unknown';

  @override
  String get unavailable => 'unavailable';

  @override
  String statSemantics(String label, String count) {
    return '$label: $count';
  }

  @override
  String filterWithCount(String label, String count) {
    return '$label $count';
  }

  @override
  String get reviewBeforeSaving => 'Review before saving';

  @override
  String get partialSaferDefault =>
      'Partial is the safer default. Confirm coverage separately for each side.';

  @override
  String get completeCoverageExplanation =>
      'Complete means export covers this entire side; ZIP alone does not prove it.';

  @override
  String recognizedSummary(int files, int invalid, int duplicates) {
    return 'Recognized files: $files  ·  Invalid rows: $invalid  ·  Duplicate rows: $duplicates';
  }

  @override
  String warningPrefix(String message) {
    return '!  $message';
  }

  @override
  String get reviewImpact => 'Review impact';

  @override
  String get confirmSavedChanges => 'Confirm saved changes';

  @override
  String get partialNoAbsence =>
      'Partial or missing sides add observations only. No absence is proposed.';

  @override
  String get confirmSaveLocally => 'Confirm and save locally';

  @override
  String get sideFollowing => 'Following';

  @override
  String get sideFollowers => 'Followers';

  @override
  String get sideFollowingLower => 'following';

  @override
  String get sideFollowersLower => 'followers';

  @override
  String missingSide(String side) {
    return '$side: missing · unknown, not zero';
  }

  @override
  String sideObservations(String side, int observed, int rows) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: 'rows',
      one: 'row',
    );
    return '$side · $observed observed of $rows $_temp0';
  }

  @override
  String sideInvalidDuplicates(int invalid, int duplicates) {
    return '$invalid invalid · $duplicates duplicate';
  }

  @override
  String get coveragePartial => 'Partial';

  @override
  String get coverageComplete => 'Complete';

  @override
  String get coveragePartialLower => 'partial';

  @override
  String get coverageCompleteLower => 'complete';

  @override
  String get coverageUnknownLower => 'unknown';

  @override
  String get coverageMissingLower => 'missing';

  @override
  String get completeUnavailable =>
      'Complete unavailable: invalid rows need review in a new export.';

  @override
  String acknowledgeSide(String side, String coverage) {
    return 'I confirm $side is $coverage in this export';
  }

  @override
  String completeSideSnapshot(String side) {
    return 'Complete $side snapshot';
  }

  @override
  String previouslyPresentAbsence(int count, String side) {
    return '$count previously present → not present in this complete $side snapshot.';
  }

  @override
  String previouslyUnknownAbsence(int count, String side) {
    return '$count previously unknown → not present in this complete $side snapshot.';
  }

  @override
  String sampleAccounts(String accounts) {
    return 'Sample (up to 10): $accounts';
  }

  @override
  String detailsFor(String username) {
    return 'Details for @$username';
  }

  @override
  String openProfileFor(String username) {
    return 'Open @$username profile';
  }

  @override
  String usernameDisplay(String username) {
    return '@$username';
  }

  @override
  String get snapshotEvidenceNote =>
      'Snapshot evidence is not a follow or unfollow time.';

  @override
  String get copyUsername => 'Copy username';

  @override
  String get openProfile => 'Open profile';

  @override
  String notPresentFollowers(String importId) {
    return 'Not present in complete followers snapshot (import #$importId)';
  }

  @override
  String notPresentFollowing(String importId) {
    return 'Not present in complete following snapshot (import #$importId)';
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
    return '$evidence · Latest coverage: $following, $followers';
  }

  @override
  String get warningInvalidRows => 'Some rows could not be read.';

  @override
  String get warningDuplicateRows => 'Repeated rows were combined.';

  @override
  String get warningConflictingDuplicate =>
      'Repeated rows had conflicting details.';

  @override
  String get readExportFailed =>
      'Could not read this export. Nothing was saved.';

  @override
  String get exportTooLarge =>
      'Export exceeds the local size limit. Nothing was saved.';

  @override
  String get exportSafetyLimit =>
      'Export exceeds a safety limit. Nothing was saved.';

  @override
  String get noRelationshipData =>
      'No supported relationship data found. Nothing was saved.';

  @override
  String get tempCleanupFailed =>
      'A temporary import copy may remain. Retry or remove it from app temporary storage.';

  @override
  String get exportValidationFailed =>
      'Export could not be validated safely. Nothing was saved.';

  @override
  String get prepareReviewFailed =>
      'Could not prepare this review. Nothing was saved.';

  @override
  String get importSaved => 'Import saved on this device.';

  @override
  String get importAlreadySaved => 'This import is already saved.';

  @override
  String get savedDataChanged =>
      'Saved data changed. Review this import again before confirming.';

  @override
  String get importRejected =>
      'Import could not be saved. Check coverage and try again.';

  @override
  String get importSaveFailed =>
      'Import could not be saved. Nothing was changed.';

  @override
  String get savedResultsUnavailable =>
      'Saved results are unavailable right now.';

  @override
  String get usernameCopied => 'Username copied.';

  @override
  String get openProfileFailed => 'Could not open the profile.';

  @override
  String get proTitle => 'Kinship Pro';

  @override
  String get proHeadline => 'A little more Kinship.';

  @override
  String get proIntro =>
      'Support an independent, quieter way to understand your connections. One lifetime purchase, no subscription.';

  @override
  String get proFreeNote =>
      'Imports, safety review and account totals remain free. See up to 10 usernames in each category; Pro unlocks complete lists, search and evidence details.';

  @override
  String get proActive => 'Kinship Pro is active on this account.';

  @override
  String get proInactive => 'Kinship Pro is not active on this account.';

  @override
  String get proStatusUnknown =>
      'Pro status could not be checked right now. You can try restoring your purchase.';

  @override
  String proLifetimePrice(String price) {
    return 'Lifetime access · $price';
  }

  @override
  String get proViewOffer => 'View lifetime offer';

  @override
  String get proOfferUnavailable =>
      'The lifetime offer is unavailable right now. Try again later; your imports still work.';

  @override
  String get proRestore => 'Restore purchases';

  @override
  String get proRestored => 'Kinship Pro restored.';

  @override
  String get proNothingToRestore =>
      'No Kinship Pro purchase found for this store account.';

  @override
  String get proRestoreFailed =>
      'Could not restore purchases. Check your connection and try again.';

  @override
  String get proPurchaseFailed =>
      'Purchase could not be completed. Please try again.';

  @override
  String get proNotConfirmed =>
      'Pro is not confirmed yet. Check your store account or try restoring.';

  @override
  String get proPrivacy =>
      'Exports and relationship lists are stored locally and may be included in device backups. They are not sent to RevenueCat. RevenueCat receives purchase history and an anonymous SDK ID.';

  @override
  String get sampleHeading => 'A glimpse of your connections';

  @override
  String get sampleDescription =>
      'The first 10 usernames in each category are free. Unlock complete lists, search and evidence details with Pro.';

  @override
  String get sampleUnknown =>
      'Pro status could not be verified. Showing a limited sample until access is confirmed; imports and totals are still available.';

  @override
  String get sampleUnlock => 'Explore Kinship Pro';

  @override
  String sampleShowing(int shown, int total) {
    return 'Showing first $shown of $total in this category';
  }
}

/// The translations for English, as used in the United Kingdom (`en_GB`).
class AppLocalizationsEnGb extends AppLocalizationsEn {
  AppLocalizationsEnGb() : super('en_GB');

  @override
  String get appName => 'Kinship';

  @override
  String get appStartupError =>
      'Kinship could not start. Please restart the app.';

  @override
  String get privateByDesign => 'PRIVATE BY DESIGN';

  @override
  String get navHome => 'Home';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get homeHeadline => 'Your connections,\nin context.';

  @override
  String get homeIntro => 'A quieter way to understand your Instagram exports.';

  @override
  String get savedAccounts => 'Saved accounts';

  @override
  String get savedAccountsIntro =>
      'Results come from saved imports, not a pending preview.';

  @override
  String get working => 'Working';

  @override
  String get yourConnections => 'Your connections';

  @override
  String get savedCountsNote => 'Counts reflect saved history only.';

  @override
  String get exploreAccounts => 'Explore saved accounts';

  @override
  String get searchSavedUsernames => 'Search saved usernames';

  @override
  String get usernameHint => 'Username';

  @override
  String get searchAction => 'Search';

  @override
  String get filterAll => 'All';

  @override
  String get loadingSavedResults => 'Loading saved results…';

  @override
  String get noSavedResults => 'No saved results in this view yet.';

  @override
  String showingResults(int start, int end, int total) {
    return 'Showing $start–$end of $total';
  }

  @override
  String get previousPage => 'Previous';

  @override
  String get nextPage => 'Next';

  @override
  String get aboutResults => 'About your results';

  @override
  String get snapshotCaveat =>
      'An export is a snapshot, not a record of follow or unfollow times. Export and import timestamps are not event times. Missing or partial sides cannot establish absence; a snapshot cannot prove a block, rename or deletion.';

  @override
  String get privacyDisclosure =>
      'Kinship does not upload your selected export. Parsed history is stored locally and may be included in device backup.';

  @override
  String get addAnotherExport => 'Add another export';

  @override
  String get startWithExport => 'Start with your export';

  @override
  String get exportReady => 'Export ready for review';

  @override
  String get compactExportDescription =>
      'Add a ZIP or JSON export. No upload; saved history may be backed up by your device.';

  @override
  String get exportDescription =>
      'Choose an Instagram export ZIP or JSON. No upload; saved history may be backed up by your device.';

  @override
  String get chooseExport => 'Choose export';

  @override
  String get chooseAnotherExport => 'Choose another export';

  @override
  String get accountsStat => 'Accounts';

  @override
  String get mutual => 'Mutual';

  @override
  String get followingOnly => 'Following only';

  @override
  String get followerOnly => 'Follower only';

  @override
  String get unknown => 'Unknown';

  @override
  String get unavailable => 'unavailable';

  @override
  String statSemantics(String label, String count) {
    return '$label: $count';
  }

  @override
  String filterWithCount(String label, String count) {
    return '$label $count';
  }

  @override
  String get reviewBeforeSaving => 'Review before saving';

  @override
  String get partialSaferDefault =>
      'Partial is the safer default. Confirm coverage separately for each side.';

  @override
  String get completeCoverageExplanation =>
      'Complete means export covers this entire side; ZIP alone does not prove it.';

  @override
  String recognizedSummary(int files, int invalid, int duplicates) {
    return 'Recognised files: $files  ·  Invalid rows: $invalid  ·  Duplicate rows: $duplicates';
  }

  @override
  String warningPrefix(String message) {
    return '!  $message';
  }

  @override
  String get reviewImpact => 'Review impact';

  @override
  String get confirmSavedChanges => 'Confirm saved changes';

  @override
  String get partialNoAbsence =>
      'Partial or missing sides add observations only. No absence is proposed.';

  @override
  String get confirmSaveLocally => 'Confirm and save locally';

  @override
  String get sideFollowing => 'Following';

  @override
  String get sideFollowers => 'Followers';

  @override
  String get sideFollowingLower => 'following';

  @override
  String get sideFollowersLower => 'followers';

  @override
  String missingSide(String side) {
    return '$side: missing · unknown, not zero';
  }

  @override
  String sideObservations(String side, int observed, int rows) {
    String _temp0 = intl.Intl.pluralLogic(
      rows,
      locale: localeName,
      other: 'rows',
      one: 'row',
    );
    return '$side · $observed observed of $rows $_temp0';
  }

  @override
  String sideInvalidDuplicates(int invalid, int duplicates) {
    return '$invalid invalid · $duplicates duplicate';
  }

  @override
  String get coveragePartial => 'Partial';

  @override
  String get coverageComplete => 'Complete';

  @override
  String get coveragePartialLower => 'partial';

  @override
  String get coverageCompleteLower => 'complete';

  @override
  String get coverageUnknownLower => 'unknown';

  @override
  String get coverageMissingLower => 'missing';

  @override
  String get completeUnavailable =>
      'Complete unavailable: invalid rows need review in a new export.';

  @override
  String acknowledgeSide(String side, String coverage) {
    return 'I confirm $side is $coverage in this export';
  }

  @override
  String completeSideSnapshot(String side) {
    return 'Complete $side snapshot';
  }

  @override
  String previouslyPresentAbsence(int count, String side) {
    return '$count previously present → not present in this complete $side snapshot.';
  }

  @override
  String previouslyUnknownAbsence(int count, String side) {
    return '$count previously unknown → not present in this complete $side snapshot.';
  }

  @override
  String sampleAccounts(String accounts) {
    return 'Sample (up to 10): $accounts';
  }

  @override
  String detailsFor(String username) {
    return 'Details for @$username';
  }

  @override
  String openProfileFor(String username) {
    return 'Open @$username profile';
  }

  @override
  String usernameDisplay(String username) {
    return '@$username';
  }

  @override
  String get snapshotEvidenceNote =>
      'Snapshot evidence is not a follow or unfollow time.';

  @override
  String get copyUsername => 'Copy username';

  @override
  String get openProfile => 'Open profile';

  @override
  String notPresentFollowers(String importId) {
    return 'Not present in complete followers snapshot (import #$importId)';
  }

  @override
  String notPresentFollowing(String importId) {
    return 'Not present in complete following snapshot (import #$importId)';
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
    return '$evidence · Latest coverage: $following, $followers';
  }

  @override
  String get warningInvalidRows => 'Some rows could not be read.';

  @override
  String get warningDuplicateRows => 'Repeated rows were combined.';

  @override
  String get warningConflictingDuplicate =>
      'Repeated rows had conflicting details.';

  @override
  String get readExportFailed =>
      'Could not read this export. Nothing was saved.';

  @override
  String get exportTooLarge =>
      'Export exceeds the local size limit. Nothing was saved.';

  @override
  String get exportSafetyLimit =>
      'Export exceeds a safety limit. Nothing was saved.';

  @override
  String get noRelationshipData =>
      'No supported relationship data found. Nothing was saved.';

  @override
  String get tempCleanupFailed =>
      'A temporary import copy may remain. Retry or remove it from app temporary storage.';

  @override
  String get exportValidationFailed =>
      'Export could not be validated safely. Nothing was saved.';

  @override
  String get prepareReviewFailed =>
      'Could not prepare this review. Nothing was saved.';

  @override
  String get importSaved => 'Import saved on this device.';

  @override
  String get importAlreadySaved => 'This import is already saved.';

  @override
  String get savedDataChanged =>
      'Saved data changed. Review this import again before confirming.';

  @override
  String get importRejected =>
      'Import could not be saved. Check coverage and try again.';

  @override
  String get importSaveFailed =>
      'Import could not be saved. Nothing was changed.';

  @override
  String get savedResultsUnavailable =>
      'Saved results are unavailable right now.';

  @override
  String get usernameCopied => 'Username copied.';

  @override
  String get openProfileFailed => 'Could not open the profile.';

  @override
  String get proTitle => 'Kinship Pro';

  @override
  String get proHeadline => 'A little more Kinship.';

  @override
  String get proIntro =>
      'Support an independent, quieter way to understand your connections. One lifetime purchase, no subscription.';

  @override
  String get proFreeNote =>
      'Imports, safety review and account totals remain free. See up to 10 usernames in each category; Pro unlocks complete lists, search and evidence details.';

  @override
  String get proActive => 'Kinship Pro is active on this account.';

  @override
  String get proInactive => 'Kinship Pro is not active on this account.';

  @override
  String get proStatusUnknown =>
      'Pro status could not be checked right now. You can try restoring your purchase.';

  @override
  String proLifetimePrice(String price) {
    return 'Lifetime access · $price';
  }

  @override
  String get proViewOffer => 'View lifetime offer';

  @override
  String get proOfferUnavailable =>
      'The lifetime offer is unavailable right now. Try again later; your imports still work.';

  @override
  String get proRestore => 'Restore purchases';

  @override
  String get proRestored => 'Kinship Pro restored.';

  @override
  String get proNothingToRestore =>
      'No Kinship Pro purchase found for this store account.';

  @override
  String get proRestoreFailed =>
      'Could not restore purchases. Check your connection and try again.';

  @override
  String get proPurchaseFailed =>
      'Purchase could not be completed. Please try again.';

  @override
  String get proNotConfirmed =>
      'Pro is not confirmed yet. Check your store account or try restoring.';

  @override
  String get proPrivacy =>
      'Exports and relationship lists are stored locally and may be included in device backups. They are not sent to RevenueCat. RevenueCat receives purchase history and an anonymous SDK ID.';

  @override
  String get sampleHeading => 'A glimpse of your connections';

  @override
  String get sampleDescription =>
      'The first 10 usernames in each category are free. Unlock complete lists, search and evidence details with Pro.';

  @override
  String get sampleUnknown =>
      'Pro status could not be verified. Showing a limited sample until access is confirmed; imports and totals are still available.';

  @override
  String get sampleUnlock => 'Explore Kinship Pro';

  @override
  String sampleShowing(int shown, int total) {
    return 'Showing first $shown of $total in this category';
  }
}
