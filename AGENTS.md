# Kinship Mobile agent guide

## Repository state and source of truth
- This repository is currently a planning shell. `llm/wiki/kinship-mobile-implementation-plan.md` is the product and technical source of truth; do not treat proposed architecture or later phases as implemented.
- Phase 0 has a recorded conditional GO to proceed to the next phase based on 31 passing automated tests and the synthetic ZIP baseline oracle. Physical-device gates are deferred to private TestFlight and block wider release, not conditional phase progression. Critical ZIP safety failures still block progression.
- The TypeScript reference describes intended behavior, not architecture. Port semantics into safe, idiomatic Dart; do not copy incidental implementation details or defects.
- Keep plans and durable technical decisions versioned in the repository. Do not invent existing paths or docs.

## Commands and verification
- Pin Flutter through FVM (`.fvmrc`). Makefile targets are the shared command interface: `setup`, `format`, `analyze`, and `flutter_test`.
- Once Flutter scaffolding exists, use those targets; default verification order is analyze, then tests (`make analyze` → `make flutter_test`). Run setup when dependencies require it. Do not substitute system Flutter/Dart for FVM.
- Until Flutter scaffolding exists, Flutter commands/tests are not runnable. Do not claim they passed; report this limitation.
- Add or change tests with behavior. Use synthetic fixtures for deterministic parser and reconciliation coverage. Preserve migration tests and verify data preservation, rollback, reopen, and unsupported future schema behavior when persistence is introduced.

## Product and safety invariants
- Imports stay local: no Instagram login, credentials, private APIs, scraping, or upload. Validate untrusted JSON and bound ZIP resource use; never extract archive-controlled paths. Fail closed if archive protections cannot be enforced.
- Phase 0 includes synthetic ZIP/JSON fixtures, bounded-input/security checks, and SQLite write/read/reopen probing. Physical iPhone picker/temp-copy cleanup, force-quit/reopen persistence, parse time, memory and responsiveness remain unmeasured and must be verified in private TestFlight before wider release; record device and OS. Critical ZIP safety failures block progression.
- Preserve uncertainty in user-facing conclusions: exports do not prove rename, deletion, blocking, or exact follow/unfollow time.

## Future conventions (activate when scaffolded)
- Shared UI design system: reuse established shared widgets, tokens, and semantic colors before introducing local styling. Add reusable patterns centrally rather than duplicating them. Apply only after a real system exists.
- Test infrastructure: centralize reusable widget/integration setup and fake dependencies once tests exist; keep migration and startup regression coverage as persistence evolves.
- Localization: when ARB localization is configured, user-facing copy belongs in source ARB files; update all supported locales, regenerate generated output using the configured workflow, and never edit generated localization files by hand. Keep developer-only strings out of localization.
- Store release workflow: metadata scripts and Fastlane foundation may be imported later. Once present, adapt them to Kinship's actual locales, store listings, credentials and privacy disclosures; validate before publishing. Do not invoke or document copied commands as working until their files and configuration exist.
- Architecture choices such as Riverpod, Drift, and RevenueCat remain proposals in the plan, not existing dependencies or required paths. Adopt only at the planned phase and after relevant gates/decisions.
- Keep docs and plans versioned and update relevant existing documentation when behavior or technical decisions change. Do not reference nonexistent documentation as required reading.

## Planning and task workflow
- When a ClickUp task exists for the work, keep its status and implementation progress current; set start date when work begins, move completed work to review, and record time or leave a concise completion comment if time tracking is unavailable.
- Keep detailed specifications and decisions in repository docs; link tasks rather than duplicating full specs. Add a task ID to a doc only when that doc is linked to a real task.
- Do not create roadmap or tracker obligations when no corresponding task exists.
