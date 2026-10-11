#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

IOS_DIR="fastlane/metadata/ios"
ANDROID_DIR="fastlane/metadata/android"

HAS_ERRORS=false

char_count() {
  python3 - "$1" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
print(len(path.read_text(encoding="utf-8")))
PY
}

check_max_length() {
  local path=$1
  local max=$2

  if [ ! -f "$path" ]; then
    return
  fi

  local count
  count=$(char_count "$path")
  if [ "$count" -gt "$max" ]; then
    echo "TOO LONG: $path ($count chars, max $max)"
    HAS_ERRORS=true
  fi
}

check_max_bytes() {
  local path=$1
  local max=$2

  if [ ! -f "$path" ]; then
    return
  fi

  local count
  count=$(wc -c < "$path" | tr -d '[:space:]')
  if [ "$count" -gt "$max" ]; then
    echo "TOO LONG: $path ($count bytes, max $max)"
    HAS_ERRORS=true
  fi
}

check_locale() {
  local dir=$1
  local locale=$2
  shift 2
  local files=("$@")
  local missing=0

  for f in "${files[@]}"; do
    local path="$dir/$locale/$f"
    if [ ! -f "$path" ]; then
      echo "MISSING: $path"
      HAS_ERRORS=true
      missing=$((missing + 1))
    elif grep -Eiq 'TODO([[:space:]_-]+TRANSLATE)?|TODO:' "$path" 2>/dev/null; then
      echo "UNTRANSLATED: $path"
      HAS_ERRORS=true
      missing=$((missing + 1))
    fi
  done

  if [ "$missing" -eq 0 ]; then
    echo "  OK: $locale ($missing issues)"
  else
    echo "  ISSUES: $locale ($missing issues)"
  fi
}

echo "=== Validating iOS metadata ==="
IOS_LOCALES=(en-GB de-DE es-ES fr-FR it ja pt-BR)
for path in "$IOS_DIR"/*/; do
  [ -d "$path" ] || continue
  locale=${path%/}
  locale=${locale##*/}
  known=false
  for expected in "${IOS_LOCALES[@]}"; do
    [ "$locale" = "$expected" ] && known=true
  done
  if [ "$known" = false ] && [ "$locale" != "review_information" ]; then
    echo "UNKNOWN iOS LOCALE: $IOS_DIR/$locale"
    HAS_ERRORS=true
  fi
done

for locale in "${IOS_LOCALES[@]}"; do
  check_locale "$IOS_DIR" "$locale" \
    name.txt subtitle.txt description.txt keywords.txt promotional_text.txt

  check_max_length "$IOS_DIR/$locale/name.txt" 30
  check_max_length "$IOS_DIR/$locale/subtitle.txt" 30
  check_max_bytes "$IOS_DIR/$locale/keywords.txt" 100
  check_max_length "$IOS_DIR/$locale/promotional_text.txt" 170
  check_max_length "$IOS_DIR/$locale/description.txt" 4000
  if [ -f "$IOS_DIR/$locale/release_notes.txt" ]; then
    check_max_length "$IOS_DIR/$locale/release_notes.txt" 4000
    if grep -Eiq 'TODO([[:space:]_-]+TRANSLATE)?|TODO:' "$IOS_DIR/$locale/release_notes.txt"; then
      echo "UNTRANSLATED: $IOS_DIR/$locale/release_notes.txt"
      HAS_ERRORS=true
    fi
  fi
done

echo ""
echo "=== Validating Android metadata ==="
ANDROID_LOCALES=(en-GB de-DE es-ES fr-FR it-IT ja-JP pt-BR)
for locale_dir in "$ANDROID_DIR"/*/; do
  [ -d "$locale_dir" ] || continue
  locale=${locale_dir%/}
  locale=${locale##*/}
  known=false
  for expected in "${ANDROID_LOCALES[@]}"; do
    [ "$locale" = "$expected" ] && known=true
  done
  if [ "$known" = false ]; then
    echo "UNKNOWN Android LOCALE: $ANDROID_DIR/$locale"
    HAS_ERRORS=true
  fi
done

for locale in "${ANDROID_LOCALES[@]}"; do
  locale_files=(title.txt short_description.txt full_description.txt)

  if [ -d "$ANDROID_DIR/$locale/changelogs" ] && [ -f "$ANDROID_DIR/$locale/changelogs/default.txt" ]; then
    locale_files+=(changelogs/default.txt)
    check_max_length "$ANDROID_DIR/$locale/changelogs/default.txt" 500
  fi

  check_locale "$ANDROID_DIR" "$locale" "${locale_files[@]}"

  check_max_length "$ANDROID_DIR/$locale/title.txt" 30
  check_max_length "$ANDROID_DIR/$locale/short_description.txt" 80
  check_max_length "$ANDROID_DIR/$locale/full_description.txt" 4000
done

echo ""
if [ "$HAS_ERRORS" = true ]; then
  echo "!! Issues found. Fix before pushing metadata."
  exit 1
else
  echo "Local metadata is present, translated, and within configured length limits. Validation passed. This checks local files only; iOS metadata was already partially uploaded, metadata_push is disabled, and store submission/release remain blocked."
fi
