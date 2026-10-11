# Kinship Privacy Policy — Draft

**Draft only. Not published or legally reviewed.** Proposed URL `https://kinship.click/privacy` is not verified or live. Do not represent this page as hosted.

- **Effective date:** [OWNER MUST PROVIDE]
- **Legal owner / data controller:** [OWNER MUST PROVIDE exact legal name and contact details]
- **Product:** Kinship (copyright © 2026 Kinship; this copyright notice does not identify the legal owner)

This draft describes the intended product based on current information. Owner must verify actual app behavior, SDK versions/configuration, platform settings and legal requirements before publication. Do not publish with unresolved placeholders.

## Information processed

Kinship lets you select an Instagram official data export for import. The app parses supported export data and stores relationship history in a local SQLite database on your device. Export files and relationship data may contain usernames and other account information. Kinship does not ask for your Instagram password, log in to Instagram, scrape Instagram, or upload export contents, usernames, or relationship lists to Kinship or RevenueCat.

Kinship does not currently assume analytics collection. This statement must be revisited if analytics, crash reporting, or other SDKs are added.

## Purchases and RevenueCat

Kinship uses Apple for App Store payment processing and RevenueCat's Flutter SDK for purchase and entitlement verification. RevenueCat processes purchase/receipt and entitlement information and an anonymous RevenueCat App User ID. The SDK and its network requests may also process technical/network metadata (for example, IP address and device/app information) needed to provide its service. RevenueCat does not receive Instagram export contents, usernames, or relationship lists from Kinship.

Apple handles payment transactions under Apple's terms and privacy practices. RevenueCat handles purchase-service data under RevenueCat's privacy practices. Review their current policies and SDK documentation before publication and link to verified policy URLs here: [OWNER MUST VERIFY AND ADD LINKS]. Kinship does not control their independent processing.

An optional RevenueCat Customer Center is a possible future feature and is not currently in the app. Do not describe it as available unless implemented.

## Storage, backups, and deletion

Imported history is stored locally in the app's SQLite database. iOS device or computer backups may include app data depending on Apple's behavior and your device, account, and backup settings. Kinship does not make a blanket claim that data never leaves your device: purchase-related data is sent to Apple and RevenueCat as described above.

Before publication, verify exactly which in-app controls currently delete imported history and what each control removes. Do not claim that users can delete history or all app data in a particular way until verified. Removing the app or changing backup settings may not remove copies already present in backups; verify platform behavior and explain applicable limits accurately.

## Retention and security

Local history remains on the device until removed through available app/device controls or otherwise removed by the operating system. Exact retention, backup, and deletion behavior must be verified against the release build. Kinship does not operate a hosted relationship-history database. No absolute security guarantee is made; protect your device and its backups.

## Children and jurisdiction

[OWNER MUST PROVIDE age/children policy and jurisdiction-specific disclosures after legal review. Do not publish this section as a completed policy.]

## Changes and contact

We may update this policy as the app or its services change. The published version should show its effective date and a way to identify material updates.

Privacy questions or requests: [OWNER MUST PROVIDE a monitored contact method, such as a support email, before publishing.]

## Publication checklist

- [ ] Owner/legal reviewer approves policy and completes every placeholder.
- [ ] Verify release-build data flows, SDK versions/configuration, and actual delete/history controls; check RevenueCat's current documentation and privacy terms.
- [ ] Verify Apple and RevenueCat privacy-policy links and applicable disclosures.
- [ ] Confirm backup/deletion wording with tested iOS behavior and current platform requirements.
- [ ] Publish only after the owner verifies and hosts this policy at the intended URL; proposed URL is not currently verified or live.
