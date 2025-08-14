#!/usr/bin/env bash
set -e
echo "==> Checking Flutter..."
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter not found. Install: https://docs.flutter.dev/get-started/install"
  exit 1
fi

echo "==> Creating platform folders (if missing)..."
flutter create .

echo "==> Getting packages..."
flutter pub get

echo "==> Building release APK..."
flutter build apk --release

echo "==> Done. APK: build/app/outputs/flutter-apk/app-release.apk"
