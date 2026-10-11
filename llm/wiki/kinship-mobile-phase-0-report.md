# Phase 0 spike report

**Status: Conditional GO to proceed to the next phase; not physical-device pass or wider-release approval.** Decision recorded 2026-10-09, based on 31 passing automated tests and the synthetic ZIP baseline oracle. Physical-device gates are deferred to private TestFlight. Critical ZIP safety failures still block progression. ZIP handling targets user-selected offline exports, practical finite resource limits, correct JSON structures and identities, basic integrity checks, and no archive-controlled extraction—not complete hostile-archive integrity. The implementation plan at [Phase 0](kinship-mobile-implementation-plan.md#3-phase-0-technical-spike) is source of truth.

## Environment and synthetic evidence

- Flutter pinned through FVM: **3.47.1** (`.fvmrc`).
- Synthetic baseline ZIP adapter test returns **810 following, 783 followers, 747 mutual, 63 following-only, 36 follower-only**. This is automated integration-test evidence using a synthetic ZIP, not a physical picker test.
- ZIP validator tests cover stored and raw-deflate entries, reject hostile fixtures (including traversal, duplicate/case-folded names, symlink, encryption, nested archive and resource-limit cases), and check corruption/truncation, CRC/size consistency, safe staging cleanup, and unsafe names. They do not establish complete adversarial integrity.
- Recognized malformed JSON in a ZIP is rejected; unrelated valid JSON is skipped. Standalone JSON is integrated through the picker and parsed in an isolate. Unavailable sides remain unknown.
- Disposable SQLite tests cover write/read, close/reopen, rollback preservation and rejection of a future schema. These are test-probe results, not evidence of app force-quit/reopen durability.
- Dart `dart:io` `ZLibDecoder` exposes neither consumed compressed-byte count nor explicit stream-end evidence. User accepts this residual risk for the spike; exact compressed-byte consumption/native bridge proof is not a gate. Do not describe this as full ZIP adversarial integrity. Method-8 handling passes automated tests but remains unverified on a physical device.
- Validation: `make analyze` passed. `make flutter_test` passed, **31 tests passed**.
- These unit/integration tests exercise the adapter and synthetic files; they do not demonstrate actual picker behavior or performance on physical hardware.
- Sentry is a proposal for private TestFlight only, not installed or approved. Subject to privacy review, consider manual allowlisted, sanitized timing/crash telemetry only. Never send export contents, usernames, identifying filenames, relationship lists, SQL, paths, or raw errors. Do not assume Sentry profiling or peak-memory support: current profiling documentation describes iOS/macOS support as alpha for older SDKs, and Sentry v10 removes `profilesSampleRate`. Measure peak memory and responsiveness locally on device in private TestFlight.

## Gate status

| Gate | Status | Evidence / gap |
|---|---|---|
| Synthetic relationship oracle via ZIP adapter | **Pass (automated integration test)** | Synthetic ZIP adapter test returns exact baseline counts. Not a physical picker test. |
| ZIP validation and bounded deflate | **Pass (automated tests)** | Stored/raw-deflate handling and hostile/corrupt fixtures covered; not complete adversarial integrity. |
| Recognized/unrelated ZIP JSON | **Pass (automated integration tests)** | Malformed recognized JSON rejected; unrelated valid JSON skipped. |
| Standalone JSON picker and isolate parse | **Pass (spike scope)** | Synthetic tests cover JSON parsing, unknown sides, limits and safe errors. |
| Disposable SQLite probe | **Pass (test scope)** | Write/read/reopen/rollback/future-schema checks; no physical app lifecycle proof. |
| Practical ZIP limits and path safety | **Pass (automated tests; physical behavior unmeasured)** | Finite compressed/expanded/entry/count/ratio/row budgets, actual expanded-byte bounds, safe-name checks, no archive-controlled extraction, basic size/CRC consistency and cleanup. |
| Physical-device picker/temp-copy cleanup | **Unmeasured; deferred to private TestFlight** | No physical iPhone picker or cleanup evidence. |
| Physical-device performance/responsiveness | **Unmeasured; deferred to private TestFlight** | No elapsed-time, peak-memory or responsiveness measurements. iPhone 17 Pro is not presumed representative; use representative/older supported iPhone. |
| Private real export | **Not performed** | No owner approval for private export use; none used. |
| Physical force-quit/reopen persistence | **Unmeasured; release blocker** | No device evidence; verify in private TestFlight before wider release. |
| Flutter analysis and automated tests | **Pass** | `make analyze`; `make flutter_test` (31 passed). |

No physical measurements exist for device/OS, archive sizes, elapsed time, incremental peak memory, responsiveness, or force-quit/reopen. Do not treat proposed ≤300 MiB incremental peak and ≤15 s synthetic-baseline targets as measured or passed. Repo hard invariants remain: validate untrusted JSON, bound ZIP resource use, never extract archive-controlled paths, fail closed when required protections cannot be enforced, and keep exports/derived data local with no sensitive-data egress.

## Remaining gates before wider release

1. In private TestFlight on a representative/older supported iPhone, verify actual picker behavior and temporary-copy cleanup. Record model and OS; iPhone 17 Pro is not presumed representative.
2. Measure synthetic baseline elapsed time, local on-device peak memory and responsiveness; evaluate proposed ≤300 MiB incremental peak and ≤15 s targets. Do not substitute Sentry or automated tests for local peak-memory measurement.
3. Verify persistence through physical app force quit and reopen, including malformed-import rollback.
4. Reassess gates and record release go/no-go. Critical ZIP safety failures block progression. Private real-export testing remains optional and requires explicit owner approval beforehand; keep export and derived data local, and never record usernames/content.
