# Rehber Fleet App (Flutter)

Bu proje, şirket içi araç takibi için (Kiralama/İade/Rezervasyon/Raporlar) oluşturulmuş bir **Flutter** uygulama iskeletidir.
Samet'in isteklerine göre sayfa kırılımları ve basitleştirilmiş ücretlendirme içerir.

## Kurulum
1) Flutter kurulu olmalı: https://docs.flutter.dev/get-started/install
2) Proje klasöründe çalıştırın:
```
flutter pub get
flutter run
```
3) **APK üretmek** için:
```
flutter build apk --release
```
APK çıktısı: `build/app/outputs/flutter-apk/app-release.apk`

## Öne Çıkanlar
- Çok sayfalı yapı: Ana Sayfa, Kiralama, İade, Rezervasyon, Raporlar, Ayarlar
- “Başlanan gün tam sayılır” ücretlendirme (Günlük fiyat KDV dahil)
- Aylık fiyatlar: Net + KDV ayrı gösterim
- Yaklaşan iadeler için liste ve WhatsApp paylaşım metni
- Haftalık özet Excel/PDF dışa aktarım (iskelet)
- Offline mantığı: `shared_preferences` üzerinden yerel saklama (örnek)
- Fatura PDF ekle/görüntüle/indir için alanlar (örnek akış)

> Not: Bu bir **iskelet** projedir; üretim için veri modeli ve UI detayları genişletilebilir.


## Tek komutla kurulum & APK (çok basit)
### Windows (PowerShell)
```
Set-ExecutionPolicy -Scope Process Bypass; ./build_android_windows.ps1
```

### macOS (Terminal)
```
chmod +x build_android_macos.sh && ./build_android_macos.sh
```

> Scriptler ne yapar?
> 1) `flutter create .` (platform klasörlerini üretir)
> 2) `flutter pub get`
> 3) `flutter build apk --release`
> APK çıktısı: `build/app/outputs/flutter-apk/app-release.apk`

