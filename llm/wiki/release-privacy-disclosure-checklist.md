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
- [ ] Confirm proposed `https://kinship.click/privacy` and `/support` are live and controlled before linking or claiming they are hosted.
- [ ] Copyright may say © 2026 Kinship; confirm separately whether legal owner/entity requires a different attribution.
