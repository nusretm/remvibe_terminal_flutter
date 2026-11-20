#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != Linux ]]; then
  echo "Run this test on an Ubuntu/Linux host." >&2
  exit 1
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

flutter doctor -v
flutter pub get
flutter analyze
flutter test

cd example
# Generate runner IN THIS checkout, never as a parallel verification clone.
flutter create . --platforms=linux
flutter pub get
flutter analyze

echo "TERM-01G-C Ubuntu UI TEST: example uses an EXPLICIT mock handler."
echo "NO Linux PTY native implementation or real shell is claimed."
flutter run -d linux
