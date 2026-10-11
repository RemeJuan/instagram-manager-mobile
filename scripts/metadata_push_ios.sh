#!/bin/bash
set -euo pipefail
printf '%s\n' 'BLOCKED: iOS metadata push is disabled. Review fastlane/KINSHIP_RELEASE.md.' >&2
exit 1

cd "$(dirname "$0")/.." || exit 1

echo "==> Metadata diff (files to be pushed):"
git --no-pager diff --stat -- fastlane/metadata/ios/

echo ""
echo "==> Pushing iOS metadata to App Store Connect..."
CI=1 EDITOR=true VISUAL=true GIT_EDITOR=true bundle exec fastlane ios metadata_push

echo ""
echo "==> iOS metadata uploaded."
echo "    Changes are live on App Store Connect (not yet submitted for review)."
