# Kinship landing page plan

Plan and publication gates for the single-page static teaser on orphan `gh-pages`, built with Eleventy/Nunjucks and CSS. Branch existence does not establish GitHub Pages live deployment. No verified custom domain, live support/privacy destination, or product launch status is implied.

## Purpose and audience

Give prospective iOS users a calm, accurate introduction to Kinship: a local-first tool for reviewing relationship history from a user-selected official Instagram data export. Explain boundaries and uncertainty before directing visitors to any verified product destination. Keep page useful as a teaser without pretending app availability or support channels are confirmed.

## Information architecture

- **Home (`/`)**: concise product description, how it works, data-handling summary, limitations, and links only to destinations verified before publication.
- **Privacy (`/privacy/`)**: public page at `https://remejuan.github.io/instagram-manager-mobile/privacy/`; owner/legal approval and release-build accuracy validation remain outstanding.
- **Support (`/support/`)**: public page at `https://remejuan.github.io/instagram-manager-mobile/support/`; owner/legal approval and support-contact verification remain outstanding.
- **Store destinations**: omit until each official listing URL and availability are verified. No fabricated badges or placeholder links.

Home links the verified public policy and support pages. Avoid contact forms, analytics, embedded third-party assets, and collection of visitor data in the static site.

## Messaging and content direction

Use restrained, plain-language copy. Lead with what product does, not relationship anxiety or claims of certainty. Suggested framing: “Review changes across your Instagram data exports.” Describe a user-selected official export, local parsing, and locally stored history only as confirmed against release behavior.

State important limits nearby: exports are snapshots; partial imports add positive observations and do not prove omitted accounts are absent; missing sides remain unknown; even complete-side omissions do not establish why a relationship changed. Kinship cannot determine rename, deletion, blocking, or exact follow/unfollow time. Avoid surveillance, “who unfollowed you” certainty, account access, or guaranteed outcomes.

State nonaffiliation clearly: Kinship is independent and is not affiliated with, endorsed by, or sponsored by Instagram or Meta. Use Instagram name only to identify supported export source; no logos or trade dress implying endorsement. Explain that no Instagram login, credentials, scraping, or upload of export contents/usernames/relationship lists is part of the intended import flow, after confirming release build.

Visual direction: quiet editorial product explainer, readable type, ample whitespace, restrained palette, minimal decoration, and no fabricated app screenshots or testimonials. Favor original abstract diagrams or verified product captures. Avoid alarmist colors, growth promises, or implying access to Instagram systems.

## Scope

### Now: static teaser plan

- Responsive home, privacy, and support pages; concise explanation, how-it-works steps, boundaries, nonaffiliation, and links only when destination verified.
- Eleventy/Nunjucks and simple CSS, following the sample site's static Eleventy/Nunjucks structure and GitHub Actions Pages deployment pattern. Pages currently use independent templates rather than a shared layout. Reuse concepts, not its domain, content, assets, or deployment assumptions.
- Deploy from orphan `gh-pages` branch using GitHub Actions. Configure repository Pages source as **GitHub Actions**, not branch/folder publishing.
- Live URLs: home `https://remejuan.github.io/instagram-manager-mobile/`, privacy `https://remejuan.github.io/instagram-manager-mobile/privacy/`, support `https://remejuan.github.io/instagram-manager-mobile/support/`. Deployment recorded from successful workflow run `38224067074`; all three live HTTPS URLs returned HTTP 200 and content was verified. No custom domain yet; a later domain change requires owner control and URL verification. Public reachability does not equal privacy/legal or release approval.

### Later, gated

- Publish `/privacy/` and `/support/` only after owner, legal, technical, contact, and URL checks below. The existing drafts are inputs, not approved or published policies.
- Add app-store links only after official listing destinations and availability are verified. Recheck copy whenever release behavior, SDKs, data flows, or support process changes.
- Any analytics, form, external service, or custom domain requires separate data-flow/privacy review and owner approval before addition.

## URL, metadata, and Pages setup

- Confirm repository name, GitHub Pages project URL, repository visibility/Pages eligibility, and exact URL in repository settings. Do not presume `kinship.click` or any other domain works or is controlled; no custom domain/CNAME for this phase.
- Set one canonical base URL from verified Pages configuration. Ensure canonical, Open Graph, sitemap, and internal links use correct project path; omit or leave metadata unset rather than publishing guessed URLs. Do not emit misleading organization address, contact, store, privacy, or support links.
- Use descriptive page title and summary, stable relative URLs, favicon only if approved/original, and no unsupported claims in social preview. Add sitemap only when URLs are stable and public.
- Enable Pages deployment workflow with least necessary permissions (`contents: read`, Pages write, deployment write), build from `gh-pages`, upload generated output, deploy via official Pages Actions. Protect workflow changes through normal repository review. Verify Pages source says GitHub Actions and deployment environment/URL after setup.
- Confirm generated artifact excludes source-only/private files, drafts not approved for publication, local data, and dependencies. Static teaser should have no secrets or user-derived data.

## Proposed page publication gates

### Privacy page

Use [`draft-privacy-policy.md`](draft-privacy-policy.md) as an unapproved draft. Before publishing, owner must supply and verify legal owner/data controller, effective date, jurisdiction/children disclosures, monitored privacy contact, and legal review. Technical owner must check release-build import, SQLite contents, retention/deletion controls, reinstall and iOS/computer backup behavior, dependencies, network traffic, analytics/crash tooling, RevenueCat SDK/data flows, Apple/RevenueCat processing, and current vendor policy links. Resolve every placeholder; make no blanket “never leaves device” or deletion guarantees.

### Support page

Use [`draft-support-copy.md`](draft-support-copy.md) as unapproved copy. Owner must provide a real monitored contact and verify it works, define safe support intake, and approve what information can be requested. Tell users not to send exports, usernames, relationship lists, passwords, or receipts through unverified channels. Verify import/purchase guidance, live privacy link, app-version instructions, and every claim against release build.

Both pages are live, but their drafts still require owner/legal approval, verified contact details, and release-build accuracy checks before disclosures are treated as approved. Align final copy with [`release-privacy-disclosure-checklist.md`](release-privacy-disclosure-checklist.md) and release record [`KINSHIP_RELEASE.md`](../../fastlane/KINSHIP_RELEASE.md). Public availability is not evidence of release readiness.

## Accessibility and content checks

- Semantic landmarks, one clear H1, ordered heading levels, descriptive link text, keyboard access, visible focus, skip link, meaningful alt text (decorative images empty alt), and no color-only meaning.
- Check contrast, text zoom/reflow, reduced-motion behavior (prefer no animation), touch target usability, and screen-reader reading order at narrow and wide viewports.
- Ensure link labels describe destinations; external links do not imply verified affiliation. Avoid tiny legal text and jargon without explanation.
- Test HTML validity and broken links, including project-path deployment and trailing-slash routes. Verify page title, description, canonical URL, social metadata, robots behavior, and sitemap against the actual deployed URL.

## Evidence and verification checklist

- [ ] Review sample project structure/stack as reference only; keep Kinship paths, URLs, and copy independently verified.
- [ ] Build locally with pinned/declared dependencies; inspect generated output and confirm no unintended files or draft disclosures shipped.
- [ ] Verify GitHub Pages configured to **GitHub Actions**; workflow builds orphan `gh-pages` source and deploys expected artifact.
- [ ] After deployment, open actual Pages URL and every published route; check HTTPS, redirects, asset paths, canonical/social URLs, and no 404s.
- [x] Deployment workflow run `38224067074` succeeded; home, privacy, and support HTTPS URLs returned HTTP 200 and content was verified.
- [x] URL-only App Store Connect update completed Oct 12 2026; independent GET-only readback matched all 21 URL fields across seven locales.
- [ ] Record review evidence for desktop/mobile widths, keyboard, screen reader, zoom/reflow, contrast, and link checks; remediate blockers before publication.
- [ ] Fact-check all product, local-storage, export, purchase, backup, deletion, support, and availability claims against release build and current dependencies.
- [ ] Owner/legal reviewer approves published privacy/support copy; verify owner identity, monitored contacts, vendor policy URLs, and domain control.
- [ ] Confirm no analytics/tracking/forms or third-party requests unless separately reviewed and disclosed.
- [ ] Recheck content and URLs whenever release behavior, store status, policy, SDKs, support contact, or hosting changes.

## Release privacy checklist alignment

Before publishing or linking privacy/support destinations, complete the release checklist: verify local import and no export/list transmission; inspect dependencies, traffic, SDK configuration and analytics/crash tooling; validate RevenueCat and Apple disclosures and current vendor links; verify SQLite retention, deletion, reinstall and backup behavior; resolve owner, effective date, jurisdiction/children, privacy and support contacts; obtain legal/factual review; verify URLs are live and controlled. Do not describe optional RevenueCat Customer Center as available unless implemented. See [`release-privacy-disclosure-checklist.md`](release-privacy-disclosure-checklist.md).

## Current status

The home, privacy, and support pages are published at the URLs above. Workflow run `38224067074` succeeded; all three live HTTPS URLs returned HTTP 200 and content was verified. On Oct 12 2026, URL-only App Store Connect lane updated 21 fields across seven locales with matching in-process checks. Independent GET-only `bundle exec fastlane ios metadata_readback` completed at 10:34 Oct 12: all 21 privacy/support/marketing URL fields match local root files across seven locales, and non-URL fields match. Operator: Reme Le Hane, South Africa; contact provided: `google@remej.dev`. Owner/legal approval, release-build privacy/disclosure accuracy, physical-device/TestFlight gates, and real purchase validation remain outstanding. Public policy availability and URL updates do not constitute release approval. No custom domain is configured. Keep status synchronized with independently verified changes; do not infer wider release readiness from deployment or metadata updates.
