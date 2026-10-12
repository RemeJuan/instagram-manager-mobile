import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('en', 'GB'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Kinship'**
  String get appName;

  /// No description provided for @appStartupError.
  ///
  /// In en, this message translates to:
  /// **'Kinship could not start. Please restart the app.'**
  String get appStartupError;

  /// No description provided for @privateByDesign.
  ///
  /// In en, this message translates to:
  /// **'PRIVATE BY DESIGN'**
  String get privateByDesign;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your connections,\nin context.'**
  String get homeHeadline;

  /// No description provided for @homeIntro.
  ///
  /// In en, this message translates to:
  /// **'A quieter way to understand your Instagram exports.'**
  String get homeIntro;

  /// No description provided for @savedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Saved accounts'**
  String get savedAccounts;

  /// No description provided for @savedAccountsIntro.
  ///
  /// In en, this message translates to:
  /// **'Results come from saved imports, not a pending preview.'**
  String get savedAccountsIntro;

  /// No description provided for @working.
  ///
  /// In en, this message translates to:
  /// **'Working'**
  String get working;

  /// No description provided for @yourConnections.
  ///
  /// In en, this message translates to:
  /// **'Your connections'**
  String get yourConnections;

  /// No description provided for @savedCountsNote.
  ///
  /// In en, this message translates to:
  /// **'Counts reflect saved history only.'**
  String get savedCountsNote;

  /// No description provided for @exploreAccounts.
  ///
  /// In en, this message translates to:
  /// **'Explore saved accounts'**
  String get exploreAccounts;

  /// No description provided for @searchSavedUsernames.
  ///
  /// In en, this message translates to:
  /// **'Search saved usernames'**
  String get searchSavedUsernames;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameHint;

  /// No description provided for @searchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchAction;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @loadingSavedResults.
  ///
  /// In en, this message translates to:
  /// **'Loading saved results…'**
  String get loadingSavedResults;

  /// No description provided for @noSavedResults.
  ///
  /// In en, this message translates to:
  /// **'No saved results in this view yet.'**
  String get noSavedResults;

  /// No description provided for @showingResults.
  ///
  /// In en, this message translates to:
  /// **'Showing {start}–{end} of {total}'**
  String showingResults(int start, int end, int total);

  /// No description provided for @previousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextPage;

  /// No description provided for @aboutResults.
  ///
  /// In en, this message translates to:
  /// **'About your results'**
  String get aboutResults;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @openInfoLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link. Please try again.'**
  String get openInfoLinkFailed;

  /// Do not imply that an export proves event times, absence for incomplete sides, block, rename, or deletion.
  ///
  /// In en, this message translates to:
  /// **'An export is a snapshot, not a record of follow or unfollow times. Export and import timestamps are not event times. Missing or partial sides cannot establish absence; a snapshot cannot prove a block, rename or deletion.'**
  String get snapshotCaveat;

  /// Local storage and device backup caveat; do not claim backups are impossible.
  ///
  /// In en, this message translates to:
  /// **'Kinship does not upload your selected export. Parsed history is stored locally and may be included in device backup.'**
  String get privacyDisclosure;

  /// No description provided for @addAnotherExport.
  ///
  /// In en, this message translates to:
  /// **'Add another export'**
  String get addAnotherExport;

  /// No description provided for @startWithExport.
  ///
  /// In en, this message translates to:
  /// **'Start with your export'**
  String get startWithExport;

  /// No description provided for @exportReady.
  ///
  /// In en, this message translates to:
  /// **'Export ready for review'**
  String get exportReady;

  /// No description provided for @compactExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a ZIP or JSON export. No upload; saved history may be backed up by your device.'**
  String get compactExportDescription;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose an Instagram export ZIP or JSON. No upload; saved history may be backed up by your device.'**
  String get exportDescription;

  /// No description provided for @chooseExport.
  ///
  /// In en, this message translates to:
  /// **'Choose export'**
  String get chooseExport;

  /// No description provided for @chooseAnotherExport.
  ///
  /// In en, this message translates to:
  /// **'Choose another export'**
  String get chooseAnotherExport;

  /// No description provided for @accountsStat.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountsStat;

  /// No description provided for @mutual.
  ///
  /// In en, this message translates to:
  /// **'Mutual'**
  String get mutual;

  /// No description provided for @followingOnly.
  ///
  /// In en, this message translates to:
  /// **'Following only'**
  String get followingOnly;

  /// No description provided for @followerOnly.
  ///
  /// In en, this message translates to:
  /// **'Follower only'**
  String get followerOnly;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'unavailable'**
  String get unavailable;

  /// No description provided for @statSemantics.
  ///
  /// In en, this message translates to:
  /// **'{label}: {count}'**
  String statSemantics(String label, String count);

  /// No description provided for @filterWithCount.
  ///
  /// In en, this message translates to:
  /// **'{label} {count}'**
  String filterWithCount(String label, String count);

  /// No description provided for @reviewBeforeSaving.
  ///
  /// In en, this message translates to:
  /// **'Review before saving'**
  String get reviewBeforeSaving;

  /// Partial coverage never establishes absence. Keep separate acknowledgement per side.
  ///
  /// In en, this message translates to:
  /// **'Partial is the safer default. Confirm coverage separately for each side.'**
  String get partialSaferDefault;

  /// A ZIP alone cannot prove complete relationship-side coverage.
  ///
  /// In en, this message translates to:
  /// **'Complete means export covers this entire side; ZIP alone does not prove it.'**
  String get completeCoverageExplanation;

  /// No description provided for @recognizedSummary.
  ///
  /// In en, this message translates to:
  /// **'Recognized files: {files}  ·  Invalid rows: {invalid}  ·  Duplicate rows: {duplicates}'**
  String recognizedSummary(int files, int invalid, int duplicates);

  /// No description provided for @warningPrefix.
  ///
  /// In en, this message translates to:
  /// **'!  {message}'**
  String warningPrefix(String message);

  /// No description provided for @reviewImpact.
  ///
  /// In en, this message translates to:
  /// **'Review impact'**
  String get reviewImpact;

  /// No description provided for @confirmSavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Confirm saved changes'**
  String get confirmSavedChanges;

  /// Partial or missing sides only add positive observations, never propose absence.
  ///
  /// In en, this message translates to:
  /// **'Partial or missing sides add observations only. No absence is proposed.'**
  String get partialNoAbsence;

  /// No description provided for @confirmSaveLocally.
  ///
  /// In en, this message translates to:
  /// **'Confirm and save locally'**
  String get confirmSaveLocally;

  /// No description provided for @sideFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get sideFollowing;

  /// No description provided for @sideFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get sideFollowers;

  /// No description provided for @sideFollowingLower.
  ///
  /// In en, this message translates to:
  /// **'following'**
  String get sideFollowingLower;

  /// No description provided for @sideFollowersLower.
  ///
  /// In en, this message translates to:
  /// **'followers'**
  String get sideFollowersLower;

  /// A missing side is unknown, not zero.
  ///
  /// In en, this message translates to:
  /// **'{side}: missing · unknown, not zero'**
  String missingSide(String side);

  /// No description provided for @sideObservations.
  ///
  /// In en, this message translates to:
  /// **'{side} · {observed} observed of {rows} {rows, plural, =1{row} other{rows}}'**
  String sideObservations(String side, int observed, int rows);

  /// No description provided for @sideInvalidDuplicates.
  ///
  /// In en, this message translates to:
  /// **'{invalid} invalid · {duplicates} duplicate'**
  String sideInvalidDuplicates(int invalid, int duplicates);

  /// No description provided for @coveragePartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get coveragePartial;

  /// No description provided for @coverageComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get coverageComplete;

  /// No description provided for @coveragePartialLower.
  ///
  /// In en, this message translates to:
  /// **'partial'**
  String get coveragePartialLower;

  /// No description provided for @coverageCompleteLower.
  ///
  /// In en, this message translates to:
  /// **'complete'**
  String get coverageCompleteLower;

  /// No description provided for @coverageUnknownLower.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get coverageUnknownLower;

  /// No description provided for @coverageMissingLower.
  ///
  /// In en, this message translates to:
  /// **'missing'**
  String get coverageMissingLower;

  /// No description provided for @completeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Complete unavailable: invalid rows need review in a new export.'**
  String get completeUnavailable;

  /// No description provided for @acknowledgeSide.
  ///
  /// In en, this message translates to:
  /// **'I confirm {side} is {coverage} in this export'**
  String acknowledgeSide(String side, String coverage);

  /// No description provided for @completeSideSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Complete {side} snapshot'**
  String completeSideSnapshot(String side);

  /// Only a complete side snapshot supports absence, not event time.
  ///
  /// In en, this message translates to:
  /// **'{count} previously present → not present in this complete {side} snapshot.'**
  String previouslyPresentAbsence(int count, String side);

  /// Previously unknown is not previously absent.
  ///
  /// In en, this message translates to:
  /// **'{count} previously unknown → not present in this complete {side} snapshot.'**
  String previouslyUnknownAbsence(int count, String side);

  /// No description provided for @sampleAccounts.
  ///
  /// In en, this message translates to:
  /// **'Sample (up to 10): {accounts}'**
  String sampleAccounts(String accounts);

  /// No description provided for @detailsFor.
  ///
  /// In en, this message translates to:
  /// **'Details for @{username}'**
  String detailsFor(String username);

  /// No description provided for @openProfileFor.
  ///
  /// In en, this message translates to:
  /// **'Open @{username} profile'**
  String openProfileFor(String username);

  /// No description provided for @usernameDisplay.
  ///
  /// In en, this message translates to:
  /// **'@{username}'**
  String usernameDisplay(String username);

  /// Do not infer exact follow or unfollow time from export evidence.
  ///
  /// In en, this message translates to:
  /// **'Snapshot evidence is not a follow or unfollow time.'**
  String get snapshotEvidenceNote;

  /// No description provided for @copyUsername.
  ///
  /// In en, this message translates to:
  /// **'Copy username'**
  String get copyUsername;

  /// No description provided for @openProfile.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfile;

  /// Complete followers snapshot only; not proof of unfollow time.
  ///
  /// In en, this message translates to:
  /// **'Not present in complete followers snapshot (import #{importId})'**
  String notPresentFollowers(String importId);

  /// Complete following snapshot only; not proof of unfollow time.
  ///
  /// In en, this message translates to:
  /// **'Not present in complete following snapshot (import #{importId})'**
  String notPresentFollowing(String importId);

  /// No description provided for @coverageWithImport.
  ///
  /// In en, this message translates to:
  /// **'{side} {coverage} (import #{importId})'**
  String coverageWithImport(String side, String coverage, int importId);

  /// No description provided for @coverageWithoutImport.
  ///
  /// In en, this message translates to:
  /// **'{side} {coverage}'**
  String coverageWithoutImport(String side, String coverage);

  /// Coverage describes observed export data, not relationship-event timing.
  ///
  /// In en, this message translates to:
  /// **'{evidence} · Latest coverage: {following}, {followers}'**
  String rowEvidence(String evidence, String following, String followers);

  /// No description provided for @warningInvalidRows.
  ///
  /// In en, this message translates to:
  /// **'Some rows could not be read.'**
  String get warningInvalidRows;

  /// No description provided for @warningDuplicateRows.
  ///
  /// In en, this message translates to:
  /// **'Repeated rows were combined.'**
  String get warningDuplicateRows;

  /// No description provided for @warningConflictingDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Repeated rows had conflicting details.'**
  String get warningConflictingDuplicate;

  /// No description provided for @readExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not read this export. Nothing was saved.'**
  String get readExportFailed;

  /// No description provided for @exportTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Export exceeds the local size limit. Nothing was saved.'**
  String get exportTooLarge;

  /// No description provided for @exportSafetyLimit.
  ///
  /// In en, this message translates to:
  /// **'Export exceeds a safety limit. Nothing was saved.'**
  String get exportSafetyLimit;

  /// No description provided for @noRelationshipData.
  ///
  /// In en, this message translates to:
  /// **'No supported relationship data found. Nothing was saved.'**
  String get noRelationshipData;

  /// No description provided for @tempCleanupFailed.
  ///
  /// In en, this message translates to:
  /// **'A temporary import copy may remain. Retry or remove it from app temporary storage.'**
  String get tempCleanupFailed;

  /// No description provided for @exportValidationFailed.
  ///
  /// In en, this message translates to:
  /// **'Export could not be validated safely. Nothing was saved.'**
  String get exportValidationFailed;

  /// No description provided for @prepareReviewFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not prepare this review. Nothing was saved.'**
  String get prepareReviewFailed;

  /// No description provided for @importSaved.
  ///
  /// In en, this message translates to:
  /// **'Import saved on this device.'**
  String get importSaved;

  /// No description provided for @importAlreadySaved.
  ///
  /// In en, this message translates to:
  /// **'This import is already saved.'**
  String get importAlreadySaved;

  /// No description provided for @savedDataChanged.
  ///
  /// In en, this message translates to:
  /// **'Saved data changed. Review this import again before confirming.'**
  String get savedDataChanged;

  /// No description provided for @importRejected.
  ///
  /// In en, this message translates to:
  /// **'Import could not be saved. Check coverage and try again.'**
  String get importRejected;

  /// No description provided for @importSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Import could not be saved. Nothing was changed.'**
  String get importSaveFailed;

  /// No description provided for @savedResultsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Saved results are unavailable right now.'**
  String get savedResultsUnavailable;

  /// No description provided for @usernameCopied.
  ///
  /// In en, this message translates to:
  /// **'Username copied.'**
  String get usernameCopied;

  /// No description provided for @openProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the profile.'**
  String get openProfileFailed;

  /// No description provided for @proTitle.
  ///
  /// In en, this message translates to:
  /// **'Kinship Pro'**
  String get proTitle;

  /// No description provided for @proHeadline.
  ///
  /// In en, this message translates to:
  /// **'A little more Kinship.'**
  String get proHeadline;

  /// No description provided for @proIntro.
  ///
  /// In en, this message translates to:
  /// **'Support an independent, quieter way to understand your connections. One lifetime purchase, no subscription.'**
  String get proIntro;

  /// No description provided for @proFreeNote.
  ///
  /// In en, this message translates to:
  /// **'Imports, safety review and account totals remain free. See up to 10 usernames in each category; Pro unlocks complete lists, search and evidence details.'**
  String get proFreeNote;

  /// No description provided for @proActive.
  ///
  /// In en, this message translates to:
  /// **'Kinship Pro is active on this account.'**
  String get proActive;

  /// No description provided for @proInactive.
  ///
  /// In en, this message translates to:
  /// **'Kinship Pro is not active on this account.'**
  String get proInactive;

  /// No description provided for @proStatusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Pro status could not be checked right now. You can try restoring your purchase.'**
  String get proStatusUnknown;

  /// No description provided for @proLifetimePrice.
  ///
  /// In en, this message translates to:
  /// **'Lifetime access · {price}'**
  String proLifetimePrice(String price);

  /// No description provided for @proViewOffer.
  ///
  /// In en, this message translates to:
  /// **'View lifetime offer'**
  String get proViewOffer;

  /// No description provided for @proOfferUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The lifetime offer is unavailable right now. Try again later; your imports still work.'**
  String get proOfferUnavailable;

  /// No description provided for @proRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get proRestore;

  /// No description provided for @proRestored.
  ///
  /// In en, this message translates to:
  /// **'Kinship Pro restored.'**
  String get proRestored;

  /// No description provided for @proNothingToRestore.
  ///
  /// In en, this message translates to:
  /// **'No Kinship Pro purchase found for this store account.'**
  String get proNothingToRestore;

  /// No description provided for @proRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not restore purchases. Check your connection and try again.'**
  String get proRestoreFailed;

  /// No description provided for @proPurchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase could not be completed. Please try again.'**
  String get proPurchaseFailed;

  /// No description provided for @proNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Pro is not confirmed yet. Check your store account or try restoring.'**
  String get proNotConfirmed;

  /// No description provided for @proPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Exports and relationship lists are stored locally and may be included in device backups. They are not sent to RevenueCat. RevenueCat receives purchase history and an anonymous SDK ID.'**
  String get proPrivacy;

  /// No description provided for @sampleHeading.
  ///
  /// In en, this message translates to:
  /// **'A glimpse of your connections'**
  String get sampleHeading;

  /// No description provided for @sampleDescription.
  ///
  /// In en, this message translates to:
  /// **'The first 10 usernames in each category are free. Unlock complete lists, search and evidence details with Pro.'**
  String get sampleDescription;

  /// No description provided for @sampleUnknown.
  ///
  /// In en, this message translates to:
  /// **'Pro status could not be verified. Showing a limited sample until access is confirmed; imports and totals are still available.'**
  String get sampleUnknown;

  /// No description provided for @sampleUnlock.
  ///
  /// In en, this message translates to:
  /// **'Explore Kinship Pro'**
  String get sampleUnlock;

  /// No description provided for @sampleShowing.
  ///
  /// In en, this message translates to:
  /// **'Showing first {shown} of {total} in this category'**
  String sampleShowing(int shown, int total);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'GB':
            return AppLocalizationsEnGb();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
