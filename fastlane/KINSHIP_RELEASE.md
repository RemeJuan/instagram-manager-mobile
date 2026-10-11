# Kinship store metadata and release status

**Status:** iOS metadata-only upload was explicitly authorized and partially completed. Store submission and release remain blocked. This document is durable project guidance; Fastlane's generated `README.md` is not a source of truth.

## iOS metadata

Fastlane 2.241.0's `deliver` partially wrote seven iOS locales, then crashed in its unconditional `review_attachment_file` handling. The iOS `metadata_push` lane is disabled because retrying could delete review attachments; do not retry it. No credentials, private review information, or remote write operations belong in this status record.

GET-only `ios metadata_readback` verified name, subtitle, description, keywords, and promotional text against local files for `en-GB`, `de-DE`, `es-ES`, `fr-FR`, `it`, `ja`, and `pt-BR`. It also verified copyright and primary category `Utilities`. After the URL-only PATCH, readback verified privacy, support, and marketing URLs match the root local files for all seven locales. These are store-field comparisons, not confirmation the URL destinations work or are published.

English locale is **GB only**; there is no English (US) listing. `fastlane/metadata/ios/secondary_category.txt` is blank and remote secondary category is unset; no secondary category was uploaded. No binary, screenshots, or review submission was uploaded.

The local metadata validator checks presence, translation markers, and length limits. A pass means local metadata passes those checks only; it does not authorize another upload or establish submission readiness.

## Submission and release blockers

- `https://kinship.click`, `https://kinship.click/privacy`, and `https://kinship.click/support` remain unverified/unreachable. Draft pages are not published. Existing store URL fields do not mean the destinations are live or that the listing is ready for submission.
- No binary or screenshots were uploaded; no review submission occurred.
- Real purchase behavior for non-consumable `kinship_lifetime`, which should grant RevenueCat entitlement `kinship_pro`, has not been validated. Fake-backend tests and unsigned builds are not purchase validation.
- Android app is not scaffolded and no Google Play upload occurred.
- Physical-device and TestFlight gates remain outstanding as recorded in the implementation plan.

Do not claim release readiness until blockers are resolved and the applicable store, purchase, privacy, URL, and device checks are verified. No live Fastlane operation is authorized by this document.
