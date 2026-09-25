# Fast Ai

هوش مصنوعی همه‌کاره (مثل Grok) برای اندروید و iOS

## قابلیت‌ها
- چت هوشمند با حافظه گفتگوهای قبلی
- ساخت عکس با Grok Imagine
- ساخت ویدیو با Grok Imagine Video
- رابط کاربری تاریک و مدرن
- ذخیره محلی تاریخچه چت‌ها

## پیش‌نیازها
1. نصب [Flutter](https://flutter.dev/docs/get-started/install)
2. داشتن API Key از [console.x.ai](https://console.x.ai)

## ساخت APK

```bash
# کلون یا دانلود پروژه
cd FastAi

# نصب پکیج‌ها
flutter pub get

# ساخت APK
flutter build apk --release
```

فایل APK در مسیر زیر ساخته می‌شود:
`build/app/outputs/flutter-apk/app-release.apk`

## تنظیم آیکون برنامه
آیکون فعلی در `assets/icons/app_icon.png` قرار دارد.
برای تنظیم آیکون رسمی اندروید می‌توانید از پکیج `flutter_launcher_icons` استفاده کنید.

## نکته مهم درباره API
- مدل‌ها و endpointهای xAI ممکن است تغییر کنند. آخرین مستندات را از docs.x.ai چک کنید.
- برای استفاده واقعی، API Key خود را در تنظیمات اپ وارد کنید.
- هرگز API Key را داخل کد هاردکد نکنید.

## ساختار پروژه
```
lib/
  main.dart
  screens/
    home_screen.dart
    chat_screen.dart
    settings_screen.dart
  services/
    chat_service.dart
    storage_service.dart
assets/
  icons/
    app_icon.png
```
