# Kinship Mobile — Implementation Plan

**Status:** Living implementation plan; Stages 1–4 implemented, Stage 6 policy partly implemented and Stage 7 purchase infrastructure started early (2026-10-10); Stages 5–7 exit criteria unmet
**Product:** iOS-first Flutter application; Android follow-up without architectural rework
**Repository:** `/Users/remelehane/Projects/instagram-manager-mobile`
**Functional reference:** `/Users/remelehane/Projects/instagram-manager-light`

## Executive decisions

- Flutter application is a native mobile implementation, not a port of the Nx/Next.js/NestJS architecture.
- Instagram exports are selected by the user, parsed and reconciled locally. No Instagram login, credentials, private APIs, scraping, upload, or Kinship backend for core app behavior.
- TypeScript application is the behavioral and business-flow reference. Port intended parsing, validation, coverage, reconciliation and result semantics into idiomatic, strongly typed Dart. Do not reproduce TypeScript incidental implementation details or defects.
- Preserve the reference app's security posture and meaningful behavior. Flutter's static types improve internal correctness; they do not remove need to validate untrusted JSON or bound ZIP resource use.
- SQLite stores historical imports and derived local state. Standard device backup remains enabled; no custom cloud backup/export service in v1.
- One non-consumable lifetime product, initial target price $9.99. Use RevenueCat Flutter SDK (`purchases_flutter`); no subscription and no Kinship-hosted backend.
- Dates from Instagram export remain export/source dates. Never present device import time as a follow/unfollow date. When export lacks a timestamp, show date unavailable. Device-local import ordering metadata may be kept for ordering and troubleshooting only, and must be labeled as app import time, never as relationship event time.
- Current supported iOS version at implementation time is minimum target. Physical picker and performance gates may be deferred to private TestFlight, but must pass on a representative/older supported physical iPhone before wider release; record model and OS. Do not treat iPhone 17 Pro as representative without justification.

## 1. Repository inventory and reusable behavior

Inspected sources:

| Source | Existing behavior / value for Kinship |
|---|---|
| `libs/import-format/src/index.ts` | `parseUpload`, ZIP/JSON detection, supported structures, username and URL validation, timestamps, duplicates, warnings, and archive defenses. Port desired behavior into Dart; do not port Node/yauzl implementation. |
| `libs/import-format/src/index.spec.ts` | Parser regression cases, including synthetic ZIP generation, hostile paths, duplicate archive paths, unsupported ZIP, malformed structures, href validation and duplicates. Convert behavioral cases to shared golden fixtures. |
| `libs/contracts/src/index.ts` | `ParsedEntry`, `ParsedSide`, `ParsedUpload`, side enums. Useful conceptual contract; define stronger Dart types and typed errors. |
| `apps/api/src/app.controller.ts` | Preview then explicit per-side coverage selection then commit; rejects complete coverage if side has invalid entries. Server preview token, HTTP translation and upload limits are not mobile architecture. |
| `apps/api/src/relationship.service.ts` | Transactional history/reconciliation; idempotent content+coverage; partial imports never imply absence; complete imports reconcile omissions; unknown is distinct from absent; category queries and history. |
| `apps/api/src/relationship-migrations.ts` | Existing relational entity concepts and schema tests. Mobile starts its own schema version; do not copy hosted `owner_id` or its whole-database rebuild approach. |
| `apps/api/src/relationship.service.spec.ts` | Tenant-isolation-derived behavior, coverage, idempotency, transaction rollback, unknown states, pagination and preferences. Ignore hosted-only tenancy concerns. |
| `apps/api/src/relationship-migrations.spec.ts` | Migration preservation, reopen, rollback, FK and future-version test ideas. |
| `apps/api/src/app.integration.spec.ts` | Full preview/commit/history regression oracle using synthetic fixture. |
| `fixtures/generate.mjs`, `fixtures/README.md`, `fixtures/instagram-export/` | Synthetic fixture baseline: 810 following, 783 followers, 747 mutual, 63 following-only, 36 follower-only; split follower files, partial, duplicate, case variant and malformed JSON. |
| `docs/wiki/instagram-relationship-manager.md` | Product semantics: per-side completeness, partial safety, supported structures, timestamps, privacy and expected UX. |

There is **no meaningful implementation** in `libs/relationship-core/src/index.ts` today; it contains only `export {}`. The reference logic currently resides in `RelationshipService.commit`, not in a portable shared core.

Reference semantics to preserve:

1. Follower JSON: top-level row array or supported `followers`, `followers_N` wrapper. Following JSON: `relationships_following` wrapper. Ignore known unrelated Instagram relationship wrappers (`relationships_blocked_users`, `relationships_follow_requests_sent`, `relationships_unfollowed_users`) without treating them as evidence for either side; malformed supported wrappers and unknown same-side variants still fail validation.
2. Detect sides from validated JSON structures, not file names. Combine split follower files.
3. Normalize username by trimming, removing one optional leading `@`, validating length 1–30 and `[A-Za-z0-9._]+`, disallowing leading/trailing dot, canonicalizing lowercase while retaining display spelling.
4. Following identity can come from value/title/valid Instagram href; if multiple exist, they must agree. Allow HTTPS Instagram hosts and supported profile or `/_u/` paths only; reject credentials, query, fragment, bad/reserved paths and spoofed hosts.
5. Invalid relationship items are counted and surfaced. A malformed item invalidates its containing row. Invalid/missing export timestamp becomes null, not an invalid identity.
6. Dedupe within side by normalized username; keep first entry and warn about duplicate/conflicting metadata.
7. Partial snapshot updates positive observations only. It cannot establish absence or generate removal events.
8. Complete snapshot omission can establish absence for known accounts. Missing side remains unknown. Cross-side categories require the relevant complete baseline before absence is inferred.
9. Categories: mutual = present in both; following-only = user follows but absent from a complete follower snapshot; follower-only = present in followers but absent from complete following snapshot. An unknown side does not count as absent.
10. Change events describe first observed, newly present after evidence of absence, or no longer present in a complete snapshot. They do not establish exact Instagram event time or reason.
11. Same canonical content and same per-side coverage is idempotent. Coverage change is a different import operation.
12. Never infer rename, deletion, blocking or other Instagram behavior from username-only export evidence.

Current parser security limits to retain unless measured evidence and deliberate product decision approve change:

| Limit | Existing import parser |
|---|---:|
| Aggregate uploaded bytes | 50 MiB |
| Aggregate uncompressed ZIP entry sizes | 200 MiB |
| Per standalone JSON / ZIP entry | 20 MiB |
| Uploaded files + ZIP entries | 500 combined |
| Per-entry expansion ratio | 200:1 |
| Decoded valid + invalid relationship rows | 1,000,000 |

The existing HTTP API additionally has 20 files / 25 MiB per uploaded file; those are server boundaries, not core parser semantics. Mobile picker may select one ZIP or multiple JSON files; apply parser-level bounds across all selected inputs.

ZIP protections to retain: reject absolute/drive-prefixed paths, backslashes, `.` and `..` segments; case-insensitive duplicate names; symlinks; encrypted entries; nested ZIPs; suspicious expansion ratios; aggregate and per-entry size violations. Never extract archive-controlled paths to disk. Check central metadata and actual stream output; do not trust declared sizes alone. Fail closed if chosen Dart ZIP library does not expose needed entry metadata or allows unbounded allocation/decompression.

TypeScript is not a source of parser implementation defects to preserve. Flutter parses JSON into validated Dart data types with consistent supported-shape handling and typed parser outcomes. Tests compare intended normalized behavior and security outcomes, not incidental TS error strings or known classifier/decoder inconsistencies.

## 2. Recommended Flutter architecture

```text
lib/
  app/                 bootstrap, app shell, routing and provider setup
  domain/              typed domain values, coverage, change semantics, use cases
  import/              file selection, ZIP inspection, JSON decoding, normalization
  data/                Drift database, migrations, repositories
  entitlements/        capability policy, RevenueCat adapter and state
  features/
    import/            choose, validate, review, confirm
    overview/          counts, coverage, freshness
    relationships/     bounded category lists, profile/copy actions
    history/            snapshot timeline and comparison
    settings/           help, privacy, delete data, purchase restore
test/                  unit, golden, migration, widget tests
integration_test/      device file-picker and StoreKit/RevenueCat flows
```

- **Domain:** pure Dart. No dependency on Flutter widgets, Riverpod, file picker, ZIP library, database or RevenueCat.
- **State/dependency management:** Riverpod, using explicit providers and `AsyncNotifier` where workflows are async. Start without code generation unless repository size warrants it. Providers inject picker, parser, repository and entitlement gateway so domain tests remain isolated.
- **Persistence:** Drift with native SQLite. Relational query typing, migrations, transactions, and observable queries fit import history and evidence views. One database service and repositories, no generic multi-database abstraction.
- **File selection:** `file_selector` as initial iOS option. Validate iOS document-provider behavior, security-scoped access and file lifetime in spike; copy selected data to app-controlled temporary location only when required. Delete transient working copies after success, failure or cancel.
- **ZIP/JSON:** Evaluate current `archive` package and its stream/file-backed interfaces. Confirm defensive limits are enforceable before relying on it. If not, evaluate another maintained library or a small, reviewed native/platform ZIP bridge. Do not implement extraction to arbitrary paths.
- **Compute:** Parse large input off the UI isolate. Avoid copying whole compressed and decompressed archives or enormous object graphs between isolates. Stream/batch records where feasible; profile actual behavior on physical hardware.
- **Navigation/UI:** Flutter native controls and accessible labels; keep initial routing simple.
- **Entitlements:** `purchases_flutter`, RevenueCat offering/product and entitlement configuration, one durable lifetime capability. Platform and purchase details remain behind an entitlement service.
- **Android readiness:** isolate platform file selection, SQLite, URL launch and purchase SDK adapters behind narrow boundaries. Do not build Android first or add speculative platform abstractions.

## 3. Phase 0 technical spike

**Goal:** import a user-selected offline Instagram export ZIP on iOS and reproduce important relationship results of the reference implementation. Validate JSON shapes and identities, bound archive resource use, avoid archive-controlled paths, and probe local SQLite viability before committing to complete app. This is a practical threat model for user-selected local files, not a claim of complete adversarial ZIP integrity.

**Build only:** minimal Flutter iOS app with one test screen: pick ZIP or supported JSON, validate/parse, show counts/warnings, run a SQLite write/read/reopen probe. No polished UI, IAP, onboarding or complete history.

**Tasks:**

1. Establish fixture manifest and deterministic expected normalized outputs from existing synthetic tests/reference service.
2. Generate synthetic ZIP containing split `followers_1.json`, `followers_2.json`, and `following.json`; create bounded hostile ZIP cases for limits, unsafe paths, malformed metadata and invalid JSON.
3. Implement iOS file picker, temporary input lifecycle and parser spike using candidate ZIP library.
4. Decode and validate known export structures into Dart types; compute canonical counts and categories.
5. Enforce finite budgets: 50 MiB aggregate compressed input, 200 MiB aggregate expanded output, 20 MiB per JSON entry, 500 combined entries, 200:1 per-entry expansion ratio and 1,000,000 rows. Count actual bytes while decoding; validate names and never extract to archive-controlled paths. Accept ordinary ZIP metadata (unflagged ASCII names, DOS attributes, Unix regular-file attributes, and deflate option bits) without relaxing path or resource protections. Check basic ZIP size/CRC consistency, clean temporary files on success/failure/cancel, and test bounded hostile cases. Encrypted or unsupported entries must fail closed. Exact compressed-byte consumption and decoder stream-end proof are not required for this spike; document residual decoder limitations and do not describe validation as full ZIP adversarial integrity.
6. Write parsed sample into disposable SQLite DB; close/reopen and verify rows, then test invalid import leaves DB unchanged.
7. Cover synthetic maximum-size and hostile cases in automated tests. Critical ZIP safety failures block progression. Physical-device verification may be deferred to private TestFlight; do not claim it passed. A private real export is optional and only permitted locally with explicit owner approval; never commit/upload it or log usernames/content.
8. In private TestFlight, verify picker and temporary-copy cleanup, then measure timing, peak memory and UI responsiveness on a representative/older supported iPhone; record device model, iOS, compressed/expanded sizes, elapsed times and results. An iPhone 17 Pro is not presumed representative.

**Automated gates required for conditional phase progression:**

- Synthetic ZIP adapter test reads valid ZIP/JSON through its test adapter; split followers combine; recognized side counts and normalized identities match golden oracle. This is not evidence of physical picker behavior.
- Synthetic baseline yields exactly 810 following, 783 followers, 747 mutual, 63 following-only and 36 follower-only when both sides are complete.
- Bounded hostile-input cases rejected without DB mutation; no archive-controlled path extraction; actual expanded output bounded, not just header sizes. Basic CRC/size checks and safe cleanup covered. Do not claim complete adversarial ZIP integrity; residual risk from decoder stream-end/consumed-byte limitations is explicitly accepted for this spike.
- Automated tests enforce configured resource budgets, parser behavior and cleanup. Proposed physical targets are ≤300 MiB incremental peak and ≤15 s for synthetic baseline; unmeasured until TestFlight. Do not weaken parser limits to force a pass.
- Unit/integration tests are not physical UI responsiveness, picker/temp-copy lifecycle, or force-quit/reopen evidence. Those remain required before wider release.
- SQLite probe close/reopen and rollback tests pass; physical app force-quit/reopen persistence and malformed-import rollback remain required before wider release.

**Progression decision:** conditional GO to proceed to the next phase is based on 31 passing automated tests and the synthetic ZIP baseline oracle. This is not a physical-device pass or release approval. Critical ZIP safety failures block progression; physical picker/temp-copy cleanup, performance/responsiveness and force-quit/reopen gates block wider release until verified in private TestFlight. Record deferred evidence in the Phase 0 report.

## 4. Dart parser and behavior migration matrix

| Concern | Flutter implementation | Coverage required |
|---|---|---|
| ZIP/JSON type detection | Detect archive signature; structurally classify typed JSON; never rely on filename | Renamed inputs, bad signatures, unrelated files |
| Limits | Enforce 50 MiB aggregate compressed, 200 MiB aggregate expanded, 20 MiB per JSON entry, 500 combined file/entry count, 200:1 entry ratio, 1,000,000 rows; use actual bytes consumed/emitted | exact boundary and overage; multiple archives; deceptive metadata; truncation |
| Path handling | Validate names; read selected JSON entries without extracting to archive-controlled paths; reject absolute, drive-prefixed, slash/backslash traversal, dot segments and casefold duplicates | each unsafe name, duplicate variants, nested path; confirm no outside writes |
| Basic ZIP consistency | Check supported methods/flags, entry sizes and CRC; fail closed on encrypted or unsupported entries. For method 8, document that Dart decoder does not expose consumed compressed bytes or explicit stream-end proof; this residual risk is accepted for Phase 0 and is not a full-integrity guarantee | stored/deflate valid entries; corruption, truncation, size/CRC mismatch; bounded expansion |
| JSON shape | Typed decoding of supported follower arrays/wrappers and following wrapper; reject malformed recognized structures consistently | valid formats, malformed JSON, empty/ambiguous shapes, new wrappers |
| Username / URL | Typed normalizer with exact rules above, identity agreement checks, canonical profile URL | length/character/dot edges; URL spoofing, reserved path, mismatch |
| Duplicates | Per-side canonical username map; deterministic retained row; duplicate/conflict warnings | exact duplicate, case variant, conflicting timestamp/href |
| Partial imports | Per-side coverage default partial; positive evidence only | omission never creates absence/change |
| Complete imports | Require explicit confirmation per imported side; block complete coverage when invalid rows exist | complete invalid blocked; opposite side unchanged |
| Format evolution | Unsupported/malformed content surfaced as actionable warning/error; persist parser version | unknown schema, missing fields, malformed row |
| Replay/idempotency | Canonical normalized content + coverage digest; transactionally avoid duplicate snapshots/events | order-invariant digest; same coverage replay; changed coverage distinct |
| Error/warning behavior | Typed error codes and safe human-readable messages; show recognized files/counts, invalid/duplicate totals, warnings and proposed omissions before commit | unit and widget assertions; no sensitive diagnostics or data egress |
| Timestamp fields | Preserve source timestamp and kind when valid; null when absent/invalid; label “timestamp in export”; never invent relationship event times | zero, missing, negative, non-finite/string and sort/display cases |

Security checks apply even when the chosen archive has no recognized relationship data. File extension does not grant trust. Avoid logging content, names or usernames. Raw archive is not retained after parsing/commit.

## 5. Local SQLite schema proposal

Start at `user_version = 1` with additive, transactional version-by-version migrations. Do not copy hosted ownership columns. Keep only necessary historical/evidence data; raw archive not persisted.

**Durable schema/replay decision (Stage 3):** A content digest is not globally unique: an A→B→A sequence is valid history. Replay with one import ID requires every requested side to match its latest committed digest **and** that import to contain exactly those sides; otherwise save a new snapshot. Digests include parser version, coverage, canonical/retained display values and source timestamps. A missing side leaves its prior state untouched. Partial omissions add positive observations only; complete omissions may establish absence, but never an exact event date. Saving requires an explicit coverage choice for each present side, even though preview defaults to partial. Do not fabricate a v2 migration solely to satisfy a test expectation: test v1 creation/reopen, future-version rejection, foreign keys and rollback now; add real v1→v2 migration tests when v2 exists.

| Table | Proposed fields and constraints |
|---|---|
| `imports` | Auto-increment `id` is local monotonic sequence; optional `imported_at` device time for operational ordering only, `digest` indexed but not unique, text `parser_version`. Committed rows only; device time is never a relationship date. |
| `import_sides` | `(import_id, side)` primary key; explicit complete/partial coverage, side digest, row/invalid/duplicate counts. No row means missing. |
| `observed_accounts` | `id`, unique canonical username, first display spelling, first-seen import reference. Username is not a verified stable account identity. |
| `import_entries` | `(import_id, side, account_id)` primary key; observed display spelling, nullable integer export-row timestamp in seconds and paired kind. Immutable positive evidence snapshot. |
| `relationship_states` | `(account_id, side)` primary key; `present`/`absent` status (no row means unknown), first/last positive import IDs, first/latest complete-absence evidence import IDs. Projection of import evidence, not a relationship-event clock. |
| `relationship_changes` | Import/account/side, kind (`first_observed`, `returned_after_absence`, `absence_first_detected`), optional prior evidence import ID; composite FK to imported side. No exact follow/unfollow date. |
| `import_warnings` | Import ID, warning code and count; no username, archive path or raw content in diagnostics. |
| Future only | Notes/preferences or explicit username link if validated product need appears. Do not add speculative tables now. |

Consider `observed_accounts` as a clearer table name than `accounts` if it helps communicate username-only identity. Add indexes for import sequence, side/account entries, normalized username and change history. Enforce foreign keys, side/coverage enums, and atomic transaction for commit. Initial v1 tests cover creation/reopen, rollback, FK check and unsupported newer version; add v1→v2 preservation tests when v2 migration exists.

## 6. MVP boundary and trust UX

Commercially credible MVP:

- Import Instagram export ZIP; support standalone JSON only if it preserves first-run usefulness without confusing users.
- Preview validation results, recognized sides/files, coverage, warnings, invalid/duplicate counts and possible removals before save.
- Explicit complete/partial decision per side; partial is default. Clarify that complete means user asserts export covers that side; archive alone does not prove it.
- Followers/following summary; mutual, following-only and follower-only relationships.
- Bounded category lists (up to 10 entries per category), copy username, open canonical Instagram profile. Search, All view, paging and evidence are not currently implemented.
- Re-import local snapshot; compare snapshots and show gained/lost observations with evidence and limitations.
- Import history and timeline; show source export timestamps as export timestamps, and unavailable when absent.
- Local persistence, settings, export instructions, privacy explanation, delete local data.
- Free/paywall boundary; $9.99 lifetime unlock and restore.

**Language rules:** “Not present in this complete followers snapshot” rather than “unfollowed you.” “First detected in export on [date]” only if supported by a source timestamp and its semantics are understood; otherwise “first observed in import [sequence] (date unavailable).” “Username changed” requires supportable identity evidence; otherwise show two usernames and state Kinship cannot link them. Do not state account deleted, blocked or deactivated.

Defer notes, advanced filters, automated rename resolution, charts, social features, AI, and custom export/backup. Multiple-account schema/entitlement can be added after primary flow; do not force it into v1 absent requirement.

## 7. Free vs lifetime boundary

Initial experiment (adjustable via one `EntitlementPolicy`, not per-widget product logic):

**Free:** import and validate a real export; see account totals, parsed sides, coverage and warnings; see up to 10 results per category. Import counts, coverage details and restore remain free regardless of entitlement state.

**Lifetime unlock (intended policy, not fully wired):** complete relationship lists; snapshot history and comparison/change detection; evidence/audit details; multiple accounts if shipped; advanced filtering if shipped. Current full lists are not gated by entitlement yet.

Do not paywall validation, parser/security warnings, partial/complete explanations, privacy controls or confirmation needed to avoid false conclusions. No subscription or time expiry. Configure product price in store; display localized store price. $9.99 is target, not a hardcoded display string.

## 8. RevenueCat lifetime IAP

- Configure Apple non-consumable product `kinship_lifetime` and corresponding RevenueCat entitlement `kinship_pro`; configure a current offering with a Lifetime package mapped to that product. The app accepts that package only; supply the iOS release public SDK key (`appl_...`) securely at build time.
- Integrate `purchases_flutter`; initialize once at startup with public platform SDK keys. No custom Kinship account or login requirement. Use RevenueCat anonymous App User ID initially; do not collect usernames or export data in customer attributes.
- Use current SDK purchase API for selected package/product; handle cancellation, pending, unavailable product, network/store errors and success.
- Grant features only when returned `CustomerInfo` contains configured active entitlement. Subscribe to customer-info updates; query cached customer info on launch for offline usability, then refresh when network/store available.
- Provide Restore Purchases. Explain that restoring across devices is tied to store/RevenueCat identity and platform availability; no Kinship password required.
- StoreKit sandbox + TestFlight validation for buy, cancel, restore, reinstall, offline launch, store failure and refund/revocation refresh. Android later maps equivalent Play non-consumable to same capability.
- RevenueCat is the deliberate purchase-verification/receipt service dependency; it does not receive Instagram archive contents or relationship lists. Disclose purchase data processing in privacy policy. Keep all import/history functionality on-device.

## 9. Privacy and device backup

- No Instagram credentials, account creation, archive upload, hosted relationship database, ads or advertising SDKs.
- No analytics SDK in MVP. No crash vendor by default; if later required, collect only app/version, OS/device class and sanitized error/performance codes. Never usernames, archive filenames if identifying, follower lists, archive bytes or content.
- Keep parsed history in local SQLite. Standard iCloud/device backup follows OS/app defaults; no custom backup integration. Users can remove data by deleting local app data. Privacy/help text explains that enabled OS-level device backup may include app data and is governed by platform settings.
- RevenueCat receives purchase/entitlement information only, not Instagram export data.

## 10. Testing and fixture strategy

Build a versioned, synthetic fixture corpus in a format consumable by TypeScript and Dart. Include manifest fields for input fixture, side coverage, expected normalized sorted records, source timestamps, invalid/duplicate counts, warning codes, summary and sequential reconciliation result. Generate initial goldens from the reference implementation, manually review, then commit; Dart tests consume goldens without launching TypeScript.

Cover:

- Parser unit tests for every structure, normalization rule, timestamp, URL, duplicate and failure mode.
- ZIP hostile tests for size/ratio, entry count, traversal, absolute paths, backslashes, duplicate names, symlink, encryption, nested archives, corrupt central directory and misleading metadata.
- Reconciliation tests: baseline → partial omission → complete omission → reappearance → identical replay → coverage-changed replay; unknown side; single-side refresh retaining other side.
- Database schema/migration tests, transaction rollback, FK integrity, reopen and import atomicity.
- Widget tests for preview, explicit coverage, invalid-complete block, clear category naming, uncertainty/evidence wording and paywall boundaries.
- RevenueCat sandbox/StoreKit tests for customer info, purchase, restore, offline cached unlock, cancellation and service failures.
- Private TestFlight device tests on representative/older supported iPhone and near-limit archives; validate picker access/temp-copy lifecycle, local peak memory, time, responsiveness, relaunch and backup assumptions before wider release. No assumed Sentry profiling or peak-memory support.
- TestFlight tests for App Store Connect product configuration and real sandbox purchase/restore.

Golden parity means same intended normalized domain output and evidence semantics. Dart errors need not match TypeScript strings or preserve its parser bugs.

## 11. Staged implementation sequence

Effort estimates are developer working days, excluding App Store review and external account setup.

| Stage | Goal; major modules | Dependencies and tests | Exit criteria | Estimate |
|---|---|---|---|---:|
| 0. Import spike | Minimal iOS Flutter shell, picker adapter, typed parser prototype, bounded ZIP, disposable SQLite probe | Existing synthetic fixtures; automated hostile archive tests; physical evidence deferred | 31 automated tests and synthetic baseline pass; conditional GO recorded. Physical gates remain release blockers | 4–7 d |
| 1. Domain/app foundation | Pure-Dart domain types/use cases, Riverpod wiring, app shell, error/result contracts | 0; conditional GO; unit tests and `flutter analyze` | Domain has no Flutter/provider dependency; CI baseline works | 2–3 d |
| 2. Parser parity | Production typed Dart parser, normalizer, ZIP adapter, warnings and limits | 1; golden + hostile fixture suite | Intended parser outputs match reference; all safety tests pass | 4–7 d |
| 3. SQLite/history | Drift schema/migrations/repos, atomic commit, idempotency, coverage reconciliation | 2; migration/reopen/rollback and sequential reconciliation tests | History durable; partial/unknown semantics correct | 4–6 d |
| 4. Import and core lists | Preview/confirm flow, dashboard counts, categories, search, profile/copy | 3; widget/device tests | User sees results and uncertainty before commit; no false absence | 4–6 d |
| 5. Snapshot comparison/evidence | Timeline, compare imports, gained/lost observations, evidence details | 4; domain/widget evidence tests | Each conclusion traces to dated or undated source snapshots and coverage | 4–6 d |
| 6. Free/paid policy | Central entitlement capabilities and bounded free result sample | 4–5; free/paid widget tests | Paywall adjustable centrally; warnings and safe import stay free | 1–2 d |
| 7. RevenueCat lifetime | RevenueCat adapter, offering, purchase, restore, entitlement cache | 6; sandbox/StoreKit and offline tests | Verified lifetime entitlement unlocks across relaunch; graceful failures | 3–5 d |
| 8. Export guidance/settings | Help, privacy, delete local data, purchase restore entry | 4, 7; accessibility/manual tests | First-time export path comprehensible and data deletable | 2–3 d |
| 9. Hardening/store prep | Memory, accessibility, safety audit, copy, store disclosures | 2–8; full suite and device matrix | No unresolved critical import/security issue; clean release build | 3–5 d |
| 10. TestFlight validation | TestFlight distribution, purchase/restore/offline validation, issue triage | 9; physical devices and App Store Connect | Sign-off on import correctness and commercial purchase lifecycle | 2–4 d |
| 11. Android follow-up assessment | File picker, SQLite, platform backup, RevenueCat/Play Billing gaps | 10; platform review | Written platform delta and estimate; no architecture rewrite needed | 1–2 d |

**Stage 1 foundation status (2026-10-09):** Pure-Dart identity, per-record source timestamps, explicit per-side coverage and uncertainty-aware classification live in `lib/domain/`; a small sealed result/error contract covers domain outcomes. `lib/app/` now supplies a Riverpod provider boundary and app shell while retaining the Phase 0 spike screen. `make format`, `make analyze` and `make flutter_test` pass (42 tests). This establishes foundation only: production import flow, database/history, reconciliation and polished app UI remain later stages. Physical-device checks remain deferred to private TestFlight before wider release.

**Stage 2 parser status (2026-10-09):** `lib/import/import_preview.dart` parses standalone JSON and validated ZIP inputs into immutable per-side observations, counts and warning codes; present sides default partial, missing sides stay missing, and explicit complete selection is rejected when that side contains invalid rows. Parser preserves source timestamps and first canonical duplicate, rejects malformed or unsupported relationship structures, and applies shared selected-input, directory-inclusive entry, expanded-byte and row budgets. Synthetic full-record goldens, the ZIP baseline (810/783; 747/63/36 after explicit complete selection), hostile input and coverage regressions pass. `make format`, `make analyze` and `make flutter_test` pass (68 tests). This is a production **parser boundary**, not persisted history: at this stage app still displayed Phase 0 spike. Stage 3 must transactionally enforce coverage and preserve parser/version evidence; Stage 4 must provide explicit per-side confirmation before commit. Large exact-size boundary tests and physical-device resource/picker gates remain outstanding; accepted Deflate decoder stream-end limitation remains documented above.

**Stage 3 history status (2026-10-09):** `lib/data/` contains a v1 Drift database, versioned import/side digests and a transactional repository; `lib/domain/reconciliation.dart` records positive and complete-absence evidence without manufacturing relationship-event dates. Per-side replay, A→B→A, partial omission, complete omission, reappearance, missing-side preservation, first-ever absence, source timestamp `0`, FK constraints, committed-history reopen, rollback/reopen and future-schema refusal have automated coverage. `make format`, `make analyze` and `make flutter_test` pass (93 tests). No v2 migration exists yet; test preservation when a real v2 schema change occurs. At this stage history was not wired to the user-facing import flow; Stage 4 implementation below adds preview, per-side explicit coverage confirmation and safe commit. Large on-device memory/time, physical picker/cleanup and force-quit/reopen remain private TestFlight gates before wider release; automated reopen is not a device substitute.

**Stage 4 status (implemented 2026-10-09):** `lib/features/import/import_workspace.dart` stages picker selections as bounded app-owned temporary copies, parses JSON/ZIP off the UI isolate, and cleans transient copies. `lib/features/import/import_home_screen.dart` wires preview, impact review and local commit to persisted history: every present side requires explicit partial/complete confirmation (partial default; complete blocked for invalid rows), missing sides remain unknown, and review proposals distinguish previously-present from previously-unknown omissions. Commit uses an expected-history revision; stale review is rejected and must be refreshed. Saved results show category counts and capped lists; rows support username copy and opt-in profile opening. There is no All view, search, paging or evidence display. Stage 5 timeline/comparison/evidence remains unbuilt. Physical picker/temp-copy cleanup, performance, responsiveness and force-quit/reopen remain private TestFlight release gates; private real-export verification remains optional with owner approval.

**Stage 4 visual design (implemented):** Use the user-supplied Material 3 light Kinship palette: canvas `#F8F9F6`, white `#FFFFFF`, ink `#172B35`, heading `#193039`, secondary `#21333C`, muted `#78878A`, terracotta `#D97859`, line `#E6E9E4`, mint `#DBECE4`, soft mint `#DFEFE7`, sage `#E9EDE6`, peach `#F9E7DD`, success `#35654B` / `#E7F3E8`, error `#A14734` / `#FFF0EA`, warning `#FBF3E7`. Bundle Manrope for headings, statistics and wordmark; DM Sans for body and controls. No runtime font requests; both typefaces use SIL Open Font License 1.1, with source/license references in `assets/fonts/README.md` and bundled license files. Keep Home/Accounts in native bottom navigation, use cards and statistic tiles for summary, and show account details in an on-demand native bottom sheet. Dark mode is a separate design decision, not automatic palette inversion. Preserve readable scaling and accessible touch targets as text/system scale changes; do not trade usability for fixed visual dimensions.

**Stage 6 policy and Stage 7 purchase infrastructure (2026-10-10):** Stage 6 policy partly exists: active `kinship_pro` entitlement is intended to unlock full category lists; free or unknown access is capped at 10 per category. Import counts, coverage and restore remain free. The one-time non-consumable App Store/RevenueCat product identifier is `kinship_lifetime`; its RevenueCat entitlement identifier is `kinship_pro`. These are distinct identifiers, while the RevenueCat `Lifetime` package type remains a separate offering/package concept. Current UI has no All view, search, paging or evidence display; Stage 5 timeline/comparison/evidence is still unbuilt. `purchases_flutter` and `purchases_ui_flutter` 10.15.2 are installed; `lib/purchases/` provides an injectable RevenueCat gateway, entitlement-state model and central capability policy. Pro entry/paywall and restore are wired through `lib/features/pro/pro_screen.dart`, `lib/app/app_providers.dart`, and `lib/features/import/import_home_screen.dart`; Pro entry displays store-localized lifetime offer and RevenueCat paywall. Fake-backend tests and an unsigned iOS build do not establish real purchase, StoreKit, Test Store, TestFlight or physical-device behavior. No real purchase or TestFlight validation has occurred. Stage 6/7 exit criteria remain unmet; do not describe purchases as release-ready or lifetime access as validated across relaunch.

**Store/localization/release preparation status (2026-10-11):** Store metadata uses English (GB) only (not English US), German, Spanish, French, Italian, Japanese, and Brazilian Portuguese. Fastlane 2.241.0 `deliver` partially wrote seven iOS locales, then crashed in unconditional `review_attachment_file`; metadata-only upload had explicit authorization. iOS `metadata_push` is now disabled to avoid retry-related review attachment deletion. GET-only readback verified localized name, subtitle, description, keywords and promotional text for all seven locales, copyright, primary category Utilities, and—after URL-only PATCH—privacy/support/marketing URL fields against root local files. Secondary category remains unset: its local file is blank and it was not uploaded. No binary, screenshots, or review submission occurred. `https://kinship.click` and its `/privacy` and `/support` pages remain unverified/unreachable; drafts are unpublished, so existing store metadata does not imply submission readiness. RevenueCat product `kinship_lifetime` is a non-consumable intended to grant `kinship_pro`; real purchase remains unvalidated. Android is unscaffolded and no Play upload occurred. See [durable store release status](../../fastlane/KINSHIP_RELEASE.md) and [RevenueCat setup guide](kinship-revenuecat-setup.md).

Additional implemented refinements: the app bar, import hero and iOS icon use the supplied `assets/icons/kinship_logo.png` artwork. `assets/branding/generate-ios-icon.swift` renders all iOS icon slots from that asset, compositing its transparent corners over opaque ivory `#F8F9F6` for App Store compliance; system icon masks can make those corners appear different from the in-app transparent image. Keep the privacy and results caveats in a compact expandable “About your results” panel; reduce hero prominence for returning users; use “Your connections” as the current-state Home heading and put search before compact category chips on Accounts. Selected bottom-navigation icons use restrained terracotta. These implementation notes assert no physical-device verification and do not report Stage 5 work.

Estimated total: **30–50 developer days**, excluding review/wait time and major spike failures. Revise after Phase 0 evidence.

## 12. Risks and unresolved decisions

1. **ZIP library capability:** package-level “streaming” may still materialize archive entries or lack reliable metadata. Phase 0 determines suitability; unsafe behavior is blocker, not acceptable tradeoff.
2. **Resource thresholds:** 50 MiB/200 MiB are inherited parser limits. Validate acceptable runtime and memory on oldest practical currently supported iPhone; any limit change requires test corpus and explicit decision.
3. **Timestamp semantics:** retain export timestamps and labels; verify which export fields correspond to follower/following observations. Never infer event time from app import time. Use local sequence for ordering imports when source timestamps cannot reliably order whole snapshots.
4. **Completeness:** user confirmation is required per side; ZIP contents alone do not prove complete coverage. Show proposed losses before commit.
5. **Format drift:** Instagram export shape changes; fail safely and report unsupported structures rather than manufacturing absences.
6. **RevenueCat connectivity:** cached entitlement should permit offline use after established purchase; offline state cannot know later refund/revocation until refreshed. Test and document.
7. **Platform backup:** standard OS backup may include local database. Ensure product privacy copy accurately explains this and avoid unsupported promises about backup behavior.
8. **Reference is behavior oracle, not implementation template:** when a TS implementation detail conflicts with strongly typed safe Dart design, preserve product/business result and security intent, not incidental code behavior.

## 13. Next implementation handoff

Phase 0 automated evidence and conditional GO are recorded in the [spike report](kinship-mobile-phase-0-report.md). Stages 1–4 foundation, parser, history boundary and user-facing import/core-list flow are implemented as recorded above. Stage 5 timeline/comparison/evidence remains unbuilt. Stage 6 policy partly exists: active `kinship_pro` intends full lists, free/unknown capped at 10 per category, while import counts, coverage and restore stay free; there is no All/search/paging/evidence UI. Stage 7 RevenueCat integration does not yet establish real purchase behavior. Fake-backend tests and an unsigned iOS build are not StoreKit/TestFlight validation. Keep critical ZIP safety tests passing; do not treat deferred physical checks or purchase validation as passed or claim release readiness.

### Deferred private TestFlight release gates

- [ ] Verify physical picker, cancellation and temporary-copy cleanup on a representative/older supported iPhone; record model and iOS version.
- [ ] Measure synthetic ZIP import time, local on-device peak memory and UI responsiveness against agreed budgets. Sentry tracing or profiling does not substitute for peak-memory evidence.
- [ ] Verify app force-quit/reopen persistence and malformed-import rollback on device.
- [ ] Record release go/no-go before wider release. Private real-export testing remains optional and requires explicit owner approval; never commit, upload or log private export contents or usernames.
