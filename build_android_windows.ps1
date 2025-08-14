# builds Flutter Android APK in one go
Write-Host "==> Checking Flutter..."
flutter --version
if ($LASTEXITCODE -ne 0) { Write-Error "Flutter not found. Install from https://docs.flutter.dev/get-started/install"; exit 1 }

Write-Host "==> Creating platform folders (if missing)..."
flutter create .

Write-Host "==> Getting packages..."
flutter pub get

Write-Host "==> Building release APK..."
flutter build apk --release

Write-Host "==> Done. Find APK at: build/app/outputs/flutter-apk/app-release.apk"
