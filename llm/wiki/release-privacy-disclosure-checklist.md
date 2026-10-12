# Release Privacy Disclosure Checklist

Owner/reviewer checklist. Complete against release build and current Apple/RevenueCat documentation before publishing store disclosures or policy copy.

- [ ] Verify import path: selected official Instagram export parsed locally; no credentials, scraping, or upload of export contents/usernames/relationship lists.
- [ ] Inspect dependencies, network traffic, SDK configuration, and customer attributes. Confirm any analytics/crash tooling rather than assuming none.
- [ ] Verify RevenueCat SDK version and actual data flows, including anonymous App User ID and purchase/entitlement plus network/device metadata; confirm no export/list data is sent.
- [ ] Describe Apple payment processing and RevenueCat verification accurately; link to current verified vendor privacy policies.
- [ ] Verify SQLite contents, retention, in-app deletion/history controls, reinstall behavior, and what deletion does not remove.
- [ ] Verify iOS device/computer backup behavior and state that backup may include local app data; avoid “never leaves device” guarantees.
- [ ] Do not present optional RevenueCat Customer Center as available until implemented.
- [ ] Complete legal owner, effective date, jurisdiction/children disclosures, privacy contact, and support contact. All owner placeholders must be resolved.
- [ ] Owner validates factual accuracy; legal reviewer reviews applicable law and platform requirements.
- [x] Verify published `https://remejuan.github.io/instagram-manager-mobile/privacy/` and `https://remejuan.github.io/instagram-manager-mobile/support/`: workflow run `38224067074` succeeded; both live HTTPS URLs returned HTTP 200 and content was verified. This confirms availability only, not owner/legal approval or release-build accuracy.
- [x] Independent GET-only `bundle exec fastlane ios metadata_readback` completed 10:56 Oct 12 2026 after guarded URL-only sync to `kinship.click`: all 21 privacy/support/marketing URL fields match local root files across seven locales; non-URL fields match. Readback confirms store-field values, not release approval.
- [ ] Confirm operator-supplied owner/contact details with owner/legal review before treating disclosures as final: Reme Le Hane, South Africa; `google@remej.dev`.
- [x] Verify live custom-domain home/privacy/support HTTPS endpoints and GitHub Pages HTTPS enforcement (`https_enforced=true`); current endpoints returned HTTP 200 and App Store Connect URLs are synced. Optional GitHub account-level TXT ownership verification is a takeover-protection recommendation, not a requirement or release blocker.
- [ ] Complete owner/legal approval, purchase, physical-device, and release-build privacy/data-flow validation before claiming release readiness. Recheck domain control and live HTTPS if URLs or DNS change.
- [ ] Copyright may say © 2026 Kinship; confirm separately whether legal owner/entity requires a different attribution.
