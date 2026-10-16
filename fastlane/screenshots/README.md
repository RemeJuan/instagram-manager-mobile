# Kinship store screenshots

`base/01_base.jpg` through `05_base.jpg` are clean, textless 3618 × 7866 iOS
sources. `base/01.jpg` through `05.jpg` remain original **text-bearing visual
references**; never render over them or replace them. `layout.yaml` uses only
`*_base.jpg`, with text positions scaled from 920px-wide reference coordinates.

`layout.yaml` places a bold dark heading above the lime rule and a smaller slate
subtitle below it; `copy/en-GB.yaml` contains both text zones. The order in
`upload_order.txt` maps 01 home summary → 02 import review → 03 mutual accounts
→ 04 home overview → 05 following-only accounts. The renderer emits PNG overlays
named `01.png` through `05.png`, independent of source suffix. Fastfile's iOS
staging falls back to sorted filenames for these numbered PNGs; any future upload
requires fresh artwork and privacy review. Older custom layouts with one top-level
heading zone and `passthrough: true` remain supported.

`base/06_base.png` through `10_base.png` are 2064 × 2752 iPad portrait
sources. `formats.ipad` uses its own native-pixel text zones and exactly five
output filenames per locale: `01.png` overview (06 home), `02.png` safe import
(10 partial-coverage export review), `03.png` mutual accounts (08 populated
mutual list), `04.png` snapshot context (09 complete-coverage review and
impact), and `05.png` local privacy (07 saved accounts and privacy policy).
This swaps sources 07 and 10 from numeric order: 07 is an empty accounts view,
while 10 actually shows export review and its no-upload statement. The five
`format: ipad` copy entries in each locale repeat the existing phone headline
and subtitle pairs exactly; untagged phone entries and iOS output remain
separate. The overview and privacy artwork still shows empty-state UI, and
the privacy image does not itself prove local processing. Review artwork,
claim fit, and apparent account handles before release.

Generate all six configured locale sets into ignored Fastlane input using isolated
Pillow and PyYAML dependencies:

```sh
uv run --no-project --with Pillow --with PyYAML \
  python scripts/generate_screenshots.py --formats ios \
  --output-dir fastlane/screenshots/output
```

Output is `fastlane/screenshots/output/ios/<locale>/01.png` through `05.png`
plus `name.txt`. Every PNG is exactly 1206×2622 pixels. Renderer draws overlays
at source resolution, then resizes the complete composite with Pillow LANCZOS.
Regeneration replaces each configured locale directory, preventing stale
3618px output. App-preview sizes do not apply. This prepares files locally only;
it does not upload. Android is not scaffolded. Locale copy config drives each
set; phone mockups intentionally remain English. Source artwork shows apparent
account handles. Confirm provenance, privacy, and release approval before public
upload.

Generate **iPad only** into ignored local output, without touching phone files:

```sh
uv run --no-project --with Pillow --with PyYAML \
  python scripts/generate_screenshots.py --formats ipad \
  --output-dir fastlane/screenshots/output
```

Output is `fastlane/screenshots/output/ipad/<locale>/01.png` through `05.png`
for each of the six locales, at native **2064 × 2752**. This command prepares
local assets only; it does not stage or upload screenshots.
