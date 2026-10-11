# RevenueCat setup and integration guide

## Current implementation status

RevenueCat Flutter SDK packages are installed at `purchases_flutter` and
`purchases_ui_flutter` 10.15.2. The narrow core integration is in
`lib/purchases/purchase_gateway.dart`; its capability policy is in
`lib/purchases/capability_policy.dart`. App wiring now exists in
`lib/features/pro/pro_screen.dart`, `lib/app/app_providers.dart`, and
`lib/features/import/import_home_screen.dart`: Pro entry shows store-localized
lifetime offer and RevenueCat paywall, with restore. Active `kinship_pro` is
intended to unlock full category lists; free or unknown access is capped at 10
per category. Import counts, coverage and restore remain free. Free users have no
All view, search, paging or evidence details; Pro unlocks full lists and list
search/paging. Stage 5 timeline/comparison/evidence remains unbuilt, so Stage 6
exit criteria remain incomplete. Fake-backend tests and an
unsigned iOS build do not establish real purchase, StoreKit, Test Store,
TestFlight or physical-device behavior. No real purchase or TestFlight
validation has occurred; these UI changes do not satisfy Stage 6 or 7 exit
criteria.

Store metadata locales are English (GB) only (not English US), German, Spanish,
French, Italian, Japanese, and Brazilian Portuguese. Fastlane 2.241.0 `deliver`
partially wrote seven iOS locales, then crashed in unconditional
`review_attachment_file` handling. Explicit authorization covered metadata-only
upload; `ios metadata_push` is now disabled because retry may delete review
attachments. GET-only readback verified localized text fields, copyright,
primary category Utilities, and—after URL-only PATCH—privacy/support/marketing
URL fields against root local files. Local secondary category is blank and
remote secondary category unset. No binary, screenshots, or review submission
occurred. `https://kinship.click`, `/privacy`, and `/support` remain
unverified/unreachable; drafts are unpublished. Existing store metadata does
not mean submission-ready. Android app is not scaffolded and no Play upload
occurred. See [durable store release status](../../fastlane/KINSHIP_RELEASE.md).

## Package setup

Use FVM and Pub, not system Flutter:

```sh
fvm flutter pub add purchases_flutter purchases_ui_flutter
```

The implementation in this repository currently uses version 10.15.2 of both
packages. `purchases_ui_flutter` is present for RevenueCat's paywall and
Customer Center APIs; core gateway does not render UI.

## Keys and build configuration

Use only RevenueCat **public SDK keys** in client builds. Never use or commit
RevenueCat secret API keys. Do not put real project keys in source, docs,
screenshots, build logs, or committed configuration.

- Debug/development builds: provide the test public SDK key using
  `--dart-define=REVENUECAT_TEST_API_KEY=test_...`.
- Release builds: provide the Apple public SDK key using
  `--dart-define=REVENUECAT_APPLE_API_KEY=appl_...`.
- Release code selects only the Apple key and rejects a key beginning `test_`.
  Debug prefers the test key and falls back to the Apple key if no test key is
  supplied. Missing key, unsupported platform, or configure error means
  purchases are unavailable; no local paid state is created.
- Never pass a real test key in a checked-in shell script or command history.
  Retrieve it securely in the local/CI environment and supply it at build time.
  Existing release scripts are not configured for these dart-defines and
  remain blocked until securely integrated and validated. A copied Fastlane
  release guard does not prove the dart-defines or release build are configured.
- Current gateway is iOS-only. Android requires its own public SDK key and an
  explicit platform implementation/validation before enabling.

Example local debug invocation, with placeholder replaced in the developer's
private environment (do not commit the value):

```sh
fvm flutter run --dart-define=REVENUECAT_TEST_API_KEY="$REVENUECAT_TEST_API_KEY"
```

Release build configuration must provide `REVENUECAT_APPLE_API_KEY` through
the approved secure build environment. Do not use a test key for release.
Android is not scaffolded; its key and store setup are future work, not enabled
configuration.

## App Store Connect and RevenueCat dashboard

1. In App Store Connect, create the iOS in-app purchase product identifier
   `kinship_lifetime` as a **non-consumable**. Select the intended one-time price tier
   corresponding to 9.99 in the desired storefront. The StoreKit returns the
   user's localized price string; do not hardcode a currency amount in UI.
2. Complete required product metadata, availability, tax/banking, and review
   information. A product must be available to the app/storefront before live
   purchase validation can succeed.
3. In RevenueCat, configure the iOS app with the correct App Store Connect
   integration and bundle identifier. Create product matching `kinship_lifetime`.
4. Create entitlement exactly named `kinship_pro`; attach the `kinship_lifetime` store
   product to this entitlement. Product and entitlement identifiers intentionally
   match; they remain separate RevenueCat concepts.
5. Create a current/default offering. Add a package of package type **Lifetime**
   and map it to the `kinship_pro` store product. `Lifetime` is package type,
   not product identifier. The gateway reads only
   `offerings.current?.lifetime`; it does not choose arbitrary products or
   offerings. Ensure this exact package exists or purchase presentation has no
   eligible offer.
6. Configure and publish a RevenueCat Paywall for the intended offering in the
   RevenueCat dashboard. Confirm paywall is assigned to current offering.
7. Supply project's public SDK keys through approved secure build environment:
   `test_...` for development/Test Store; `appl_...` for iOS release. Do not
   place supplied keys in repository files, scripts, docs, or command history;
   never use a secret API key.

Lifetime purchase has no subscription renewal. Expiration/renewal copy and
subscription-management UI are therefore not appropriate for this product.

## Gateway integration

The API below reflects current `lib/purchases/purchase_gateway.dart`. Gateway
configuration is once per gateway instance and retries after failed
configuration. `customerInfo()` returns `active`, `inactive`, or `unknown`;
offline/request errors return `unknown`, not false-free. It does not persist a
local permanent paid flag.

Create one gateway at app/service scope and dispose it with that owner:

```dart
final purchases = PurchaseGateway();

final available = await purchases.initialize();
if (!available) {
  // Hide/disable purchase actions; preserve core import and privacy features.
}

final snapshot = await purchases.customerInfo();
switch (snapshot.state) {
  case EntitlementState.active:
    // Pro is active according to CustomerInfo.entitlements.active.
    break;
  case EntitlementState.inactive:
    // Verified customer info has no active kinship_pro entitlement.
    break;
  case EntitlementState.unknown:
    // Could not verify; do not represent as definitely free or paid.
    break;
}

final subscription = purchases.updates.listen((updated) {
  // Rebuild entitlement-dependent app state from SDK-provided updates.
});

// On owner teardown:
await subscription.cancel();
await purchases.dispose();
```

Gateway registers the SDK `CustomerInfoUpdateListener` after successful
configuration and removes the exact callback on `dispose()`. It ignores
callbacks after disposal and closes `updates`. Keep one gateway owner rather
than creating one per widget.

Fetch store-localized lifetime price and purchase the returned package:

```dart
final offer = await purchases.lifetimeOffer();
if (offer == null) {
  // No current lifetime package or offerings unavailable: show safe fallback.
  return;
}

// Display offer.price, which comes from Package.storeProduct.priceString.
final outcome = await purchases.purchase(offer);
if (outcome.cancelled) {
  // User dismissed/aborted payment; normally remain quiet.
} else if (outcome.error != null) {
  // Show the sanitized outcome.error, not raw SDK/PlatformException details.
} else if (outcome.snapshot.isPro) {
  // Purchase result confirms active kinship_pro entitlement.
} else {
  // Purchase call returned without active entitlement; do not grant Pro.
}
```

The gateway maps the SDK cancellation code with
`PurchasesErrorHelper.getErrorCode`. Other purchase errors become a generic
`Purchase failed.` result. Do not log raw exceptions, customer info, user IDs,
or purchase payloads.

Offerings failures return `null`; customer-info failures return `unknown`;
restore failures return sanitized `Restore failed.`. These are different states
from verified inactive access. A successful SDK-cached `CustomerInfo` may be
used as SDK-provided state; app must not invent cached paid status.

## Paywall presentation and restore

The SDK UI package can present the dashboard-configured offering without a
custom paywall widget. Present only after gateway initialization succeeds.
Current RevenueCat UI API:

```dart
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

final available = await purchases.initialize();
if (available) {
  final result = await RevenueCatUI.presentPaywallIfNeeded('kinship_pro');
  // Do not grant access based only on the paywall result. Re-read gateway state.
  final snapshot = await purchases.customerInfo();
  // Update app access only if snapshot.state == EntitlementState.active.
}
```

For explicit restore action, call the gateway and use the returned entitlement
state; do not infer success from completion alone:

```dart
final outcome = await purchases.restore();
if (outcome.error != null) {
  // Show sanitized outcome.error.
} else if (outcome.snapshot.isPro) {
  // Restore confirmed kinship_pro.
} else {
  // Restore completed, but no active entitlement returned.
}
```

Keep restore accessible regardless of Pro state. Do not gate import,
validation, coverage warnings, privacy controls, or restore behind Pro. `unknown`
must remain visibly distinct from verified `inactive` when app state conveys
entitlement status.

### Optional Customer Center

Customer Center is optional; this one-time non-consumable does not need
subscription cancellation or renewal management. Defer it unless support flows
such as viewing purchase history or requesting refunds are specifically
required. If adopted, use `purchases_ui_flutter`'s current
`RevenueCatUI.presentCustomerCenter()` API and handle its result/errors without
logging customer data. Confirm dashboard configuration and product behavior
before exposing it.

## Validation and store testing

The unit tests use a fake `PurchaseBackend`. They test entitlement decisions,
configuration retry, listener lifecycle, purchase cancellation/failure,
restore, and unknown/offline handling. They do not invoke Apple or RevenueCat
services and do not prove a real transaction works.

Run repository validation through FVM Make targets:

```sh
make analyze
make flutter_test
```

For initial development, use RevenueCat Test Store with a `test_` public key.
For Apple product verification, use StoreKit configuration where suitable,
then a signed TestFlight build using the `appl_` public key and the real App
Store Connect product. StoreKit configuration is a local simulation, not proof
of a real App Store transaction. Test purchase, app restart, restore,
cancellation, offline behavior, and localized price on physical iOS devices
before release. An unsigned iOS build is not TestFlight validation. No RevenueCat
Test Store or real StoreKit/TestFlight purchase validation has yet been
performed. Android is out of scope until its app scaffold, separate store
product/key and platform validation are added.

## Privacy, legal, and release blockers

Purchase SDK traffic sends transaction/customer data to RevenueCat and Apple;
this is separate from local Instagram-export processing. Review RevenueCat and
Apple data handling, privacy disclosures, account/app privacy labels, and
applicable consent/terms with the project owner before release. Do not send
Instagram exports, relationship lists, or import contents to purchase services.

Support/contact URL, privacy-policy URL, and finalized privacy disclosure have
drafts, but `https://kinship.click`, `/privacy`, and `/support` remain
unverified/unreachable and unpublished; verify destinations before submission.
Although store URL fields match local root files, this does not establish live
URLs or submission readiness. Fastlane 2.241.0 partially wrote iOS metadata and
crashed in review-attachment handling; metadata push is disabled. No binary,
screenshots, or review submission occurred. Release scripts' secure dart-define
configuration remains unverified. Physical-device, signed TestFlight, and real
purchase validation remain outstanding; no release readiness or live URLs are
asserted. See [durable store release status](../../fastlane/KINSHIP_RELEASE.md).

## Official references

- [RevenueCat Flutter SDK](https://www.revenuecat.com/docs/getting-started/installation/flutter)
- [RevenueCat Flutter purchases](https://www.revenuecat.com/docs/getting-started/making-purchases)
- [RevenueCat entitlements](https://www.revenuecat.com/docs/getting-started/entitlements)
- [RevenueCat offerings](https://www.revenuecat.com/docs/offerings/overview)
- [RevenueCat Paywalls Flutter](https://www.revenuecat.com/docs/tools/paywalls/displaying-paywalls)
- [RevenueCat Customer Center](https://www.revenuecat.com/docs/tools/customer-center)
- [Flutter SDK v10 API source](https://github.com/RevenueCat/purchases-flutter/tree/10.15.2)
