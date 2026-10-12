# Kinship store metadata and release status

**Status:** iOS metadata-only upload was explicitly authorized and partially completed. Store submission and release remain blocked. This document is durable project guidance; Fastlane's generated `README.md` is not a source of truth.

## iOS metadata

Fastlane 2.241.0's `deliver` partially wrote seven iOS locales, then crashed in its unconditional `review_attachment_file` handling. The iOS `metadata_push` lane is disabled because retrying could delete review attachments; do not retry it. No credentials, private review information, or remote write operations belong in this status record.

GET-only `ios metadata_readback` verified name, subtitle, description, keywords, and promotional text against local files for `en-GB`, `de-DE`, `es-ES`, `fr-FR`, `it`, `ja`, and `pt-BR`. At 10:34 Oct 12 2026, independent GET-only `bundle exec fastlane ios metadata_readback` verified all 21 privacy, support, and marketing URL fields match local root files across seven locales; non-URL fields also match. It also verified copyright and primary category `Utilities`. Earlier that day, URL-only `metadata_complete_urls` updated 21 URL fields; in-process final field checks matched. The URLs are listed in `fastlane/metadata/ios/{privacy_url,support_url,marketing_url}.txt`. Store-field readback confirms values only, not release approval.

English locale is **GB only**; there is no English (US) listing. `fastlane/metadata/ios/secondary_category.txt` is blank and remote secondary category is unset; no secondary category was uploaded. No binary, screenshots, or review submission was uploaded.

The local metadata validator checks presence, translation markers, and length limits. A pass means local metadata passes those checks only; it does not authorize another upload or establish submission readiness.

## Submission and release blockers

- GitHub Pages published home, privacy, and support at `https://remejuan.github.io/instagram-manager-mobile/`, `https://remejuan.github.io/instagram-manager-mobile/privacy/`, and `https://remejuan.github.io/instagram-manager-mobile/support/`. Workflow run `38224067074` succeeded; all three live HTTPS URLs returned HTTP 200 and content was verified. No custom domain is configured; any later custom-domain change requires separate verification. Public availability does not constitute owner/legal approval or release-build accuracy validation of privacy/support disclosures.
- The URL-only `metadata_complete_urls` lane updated 21 App Store Connect URL fields across seven locales on Oct 12 2026; in-process final checks matched. Independent GET-only readback at 10:34 Oct 12 confirmed all 21 URL fields match local root values and non-URL fields match.
- No binary or screenshots were uploaded; no review submission occurred.
- Real purchase behavior for non-consumable `kinship_lifetime`, which should grant RevenueCat entitlement `kinship_pro`, has not been validated. Fake-backend tests and unsigned builds are not purchase validation.
- The operator is Reme Le Hane, South Africa; contact provided: `google@remej.dev`. Owner/legal review and release-build accuracy/privacy/data-flow validation remain required before disclosures are treated as approved. Public policy availability is not release approval.
- Android app is not scaffolded and no Google Play upload occurred.
- Physical-device and TestFlight gates remain outstanding as recorded in the implementation plan.

Do not claim release readiness until blockers are resolved and the applicable store, purchase, privacy, physical-device, and TestFlight checks are verified. URL metadata readback completed as described above. No further live Fastlane operation or App Store metadata upload/update is authorized by this document.
