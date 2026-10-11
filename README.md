# آکادمی کیک یوسف · CakeYousef

<p align="center">
  <img src="assets/images/app_icon.png" alt="CakeYousef" width="120" />
</p>

<p align="center">
  <b>اپلیکیشن موبایل آکادمی آنلاین کیک و شیرینی</b><br/>
  آموزش تخصصی · فروشگاه · پیام‌رسان · ابزارهای کاربردی
</p>

<p align="center">
  <a href="https://www.cakeyousef.ir"><img src="https://img.shields.io/badge/Website-cakeyousef.ir-D4A843?style=flat-square" alt="Website" /></a>
  <a href="https://github.com/Pouya-Mohammadi-Parsa/cakeyousef/releases/latest"><img src="https://img.shields.io/github/v/release/Pouya-Mohammadi-Parsa/cakeyousef?style=flat-square&color=B8912E" alt="Latest release" /></a>
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=flat-square" alt="Platform" />
</p>

---

## درباره پروژه

**کیک‌یوسف** اپ رسمی آکادمی کیک یوسف است؛ رابط کاربری فارسی (RTL) با تم روشن/تاریک، متصل به وب‌سایت و API برای دوره‌ها، محصولات، حساب کاربری و محتوای آموزشی.

| | |
|---|---|
| **وب‌سایت** | [www.cakeyousef.ir](https://www.cakeyousef.ir) |
| **آخرین نسخه** | [Releases](https://github.com/Pouya-Mohammadi-Parsa/cakeyousef/releases/latest) |
| **پکیج** | `com.cakeyousef.cakeyousef` |

---

## امکانات

- **خانه** — استوری، بنر/اسلایدر، دسترسی سریع، بخش‌های محتوا
- **دوره‌های آموزشی** — لیست، جزئیات، پخش ویدیو داخل اپ
- **فروشگاه** — محصولات فیزیکی، جزئیات و خرید از وب
- **پیام‌رسان / چت** — ارتباط پشتیبانی و گفتگو
- **پروفایل و احراز هویت** — ورود وب / رمز، کیف پول، سفارش‌ها
- **ابزارها** — ماشین‌حساب مواد، ترکیب رنگ
- **تم روشن و تاریک** — قابل تغییر از منوی کناری
- **بروزرسانی داخل اپ** — تشخیص نسخه جدید از GitHub Releases

---

## تکنولوژی‌ها

| لایه | ابزار |
|------|--------|
| UI | Flutter · Material 3 · فونت Vazirmatn |
| شبکه | `http` · `cached_network_image` |
| رسانه | `video_player` · `chewie` |
| ذخیره محلی | `shared_preferences` |
| دیپ‌لینک | `app_links` |
| آپدیت | GitHub Releases API · `package_info_plus` · نصب APK |

---

## پیش‌نیاز

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (۳.x)
- Android Studio / Xcode (برای شبیه‌ساز یا بیلد)
- اتصال اینترنت برای وابستگی‌ها و API

```bash
flutter doctor
```

---

## راه‌اندازی

```bash
git clone https://github.com/Pouya-Mohammadi-Parsa/cakeyousef.git
cd cakeyousef
flutter pub get
flutter run
```

دستگاه مشخص:

```bash
flutter devices
flutter run -d <device_id>
```

---

## ساختار پوشه‌ها

```text
lib/
  api/          # کلاینت API و احراز هویت
  config/       # آدرس سایت و تنظیمات انتشار
  data/         # منطق محلی (ماشین‌حساب، رنگ، …)
  models/       # مدل‌های داده
  screens/      # صفحات اصلی
  services/     # آپدیت، دیپ‌لینک، …
  state/        # سشن، ریپازیتوری‌ها، تم
  theme/        # رنگ، فونت، ThemeData
  widgets/      # کامپوننت‌های UI
assets/         # تصاویر، فونت، داده
```

---

## بیلد انتشار

### Android (APK)

```bash
flutter build apk --release
```

خروجی پیش‌فرض:

```text
build/app/outputs/flutter-apk/app-release.apk
```

برای Release در GitHub، فایل را با این الگو نام‌گذاری کنید:

```text
cakeyousef-<version>.apk
```

مثال: `cakeyousef-1.0.6.apk`

### iOS

```bash
flutter build ipa --release
```

---

## انتشار نسخه و آپدیت داخل اپ

ریپو باید **Public** باشد تا اپ بدون توکن بتواند آخرین Release را بخواند.

1. نسخه را در `pubspec.yaml` بالا ببرید، مثلاً:
   ```yaml
   version: 1.0.7+8
   ```
2. APK بسازید و به نام `cakeyousef-1.0.7.apk` ذخیره کنید.
3. در GitHub یک Release بسازید:
   - **Tag:** `v1.0.7`
   - **Asset:** فایل APK
   - (اختیاری) در توضیحات Release بنویسید: `minVersion: 1.0.0`
4. اپ‌های نصب‌شده با باز شدن، نسخه جدید را تشخیص می‌دهند و دیالوگ بروزرسانی را نشان می‌دهند.

فایل نمونهٔ fallback: [`app-version.json`](app-version.json)

---

## اسکریپت‌های کمکی

| فایل | کاربرد |
|------|--------|
| `tool/cors_proxy.dart` | پروکسی CORS برای توسعه وب |
| `tool/run_cors_proxy.ps1` | اجرای پروکسی در Windows |
| `tools/make_quick_icons.ps1` | تولید آیکن‌های دسترسی سریع |

---

## مشارکت

1. Branch جدید بسازید: `feature/نام-فیچر`
2. تغییرات را commit کنید با پیام واضح
3. Push و Pull Request باز کنید

---

## مجوز

پروژه اختصاصی آکادمی کیک یوسف است (`publish_to: none`).  
استفاده تجاری یا بازنشر بدون مجوز صاحب پروژه مجاز نیست.

---

<p align="center">
  ساخته‌شده با Flutter برای <a href="https://www.cakeyousef.ir">آکادمی کیک یوسف</a>
</p>
