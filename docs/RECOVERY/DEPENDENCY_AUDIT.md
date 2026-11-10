# Dependency, Build & Environment Audit: AttendIQ

**Audit Date:** 2026-11-10
**Scope:** Flutter/Dart SDKs, `pubspec.yaml`, `pubspec.lock`, `flutter pub outdated`, Android Gradle/AGP/Manifest configuration, Missing Assets/Fonts, Code Generation, and CI/CD.

---

## 1. Toolchain & Environment (`flutter doctor -v`, `--version`)

| Component | Observed Value / Status | Notes / Action Required |
|---|---|---|
| **Flutter SDK** | `3.22.0` (`channel [user-branch]`, unknown source) embedded at `.\flutter_sdk\` | Not on Windows `PATH`; CI expects `3.22.0` (`stable`). Embedded `flutter_sdk/` requires running via `.\flutter_sdk\bin\flutter.bat`. |
| **Dart SDK** | `3.4.0` (`stable`, `windows_x64`) | Matches `pubspec.yaml` SDK constraint `>=3.4.0 <4.0.0`. |
| **Windows OS** | Microsoft Windows `[Version 10.0.26200.9818]` | `[√]` Passes doctor check. |
| **Android SDK / Platform** | Android SDK `36.0.0`, Platform `android-36.1`, `build-tools 36.0.0` at `C:\Users\ramsa\AppData\Local\Android\Sdk` | `[!]` Warning: `Some Android licenses not accepted`. Android build succeeded locally (`assembleProdDebug`). |
| **Java / JDK Toolchain** | Eclipse Adoptium JDK `17.0.19+10` (`C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot`) | Required explicitly via `JAVA_HOME` for Gradle `7.6.3` compatibility; Android Studio bundles JBR 21. |
| **Web Tooling** | Chrome `156.0.8078.80`, Edge `157.0.4341.42` | `[√]` Detected; Web is not targeted natively by Isar `attendiq_isar` + `MethodChannel` storage/widgets. |
| **Android Devices / Emulators** | `adb devices`: empty; `flutter emulators`: none | **No live Android device or emulator available** in workspace; runtime device verification is blocked. |

---

## 2. Dart / Flutter Packages Audit (`pubspec.yaml`, `pubspec.lock`, `pub outdated`)

### 2.1 Direct Dependencies (`pubspec.yaml` -> `pubspec.lock` -> `flutter pub outdated`)

| Package | `pubspec.yaml` Constraint | `pubspec.lock` Resolved | Resolvable | Latest | Status / Risk Assessment |
|---|---|---|---|---|---|
| `isar` | `4.0.0-dev.14` (exact pin) | `4.0.0-dev.14` | — | — | **Pre-release dev dependency**; no stable `4.0.0` release published. Has Dart 3+ quirks (`id = 0` vs `autoIncrement`, `writeAsync`). |
| `isar_flutter_libs` | `4.0.0-dev.14` (exact pin) | `4.0.0-dev.14` | — | — | Pre-release native binaries pinned to `4.0.0-dev.14`; verify 16 KB page-size / Android NDK compatibility before Play Store release. |
| `flutter_riverpod` | `^2.5.1` | `2.6.1` | `2.6.1` | `3.5.0` | Stable 2.x branch; upgrade to 3.x would be breaking. |
| `riverpod_annotation` | `^2.3.5` | `2.6.1` | `2.6.1` | `4.0.8` | Compatible with `riverpod_generator 2.4.0`. |
| `go_router` | `^14.2.1` | `14.8.1` | `15.1.2` | `18.1.4` | Minor/major behind latest; functional on Flutter 3.22. |
| `flutter_local_notifications` | `^17.1.2` | `17.2.4` | `19.5.0` | `23.0.0` | Functional; Android manifest lacks boot receivers and code lacks `default` channel + local timezone setup. |
| `timezone` | `^0.9.4` | `0.9.4` | `0.10.1` | `0.11.2` | Missing native timezone lookup package (e.g. `flutter_timezone`), causing `tz.local` to stay `UTC`. |
| `workmanager` | `^0.5.2` | `0.5.2` | `0.7.0` | `0.10.10` | **Deprecated/old version** (`0.5.2`), forced in `build.gradle` via `androidx.work:work-runtime:2.8.1`. `Workmanager().initialize(...)` is never called. |
| `home_widget` | `^0.6.0` | `0.6.0` | `0.8.1` | `0.10.0` | Functional communication with Kotlin `HomeWidgetProvider`; behind latest. |
| `connectivity_plus` | `^6.0.3` | `6.1.5` | `7.3.1` | `7.3.2` | Functional. |
| `share_plus` | `^10.0.0` | `10.1.4` | `12.0.2` | `13.3.1` | Functional. |
| `file_picker` | `^8.0.0` | `8.3.2` | `8.3.2` | `13.3.2` | Uncommitted addition in working tree (`pubspec.yaml:52`). |
| `package_info_plus` | `^8.0.0` | `8.3.1` | `9.0.1` | `10.2.2` | Uncommitted addition in working tree (`pubspec.yaml:53`). |
| `permission_handler` | `^11.3.1` | `11.3.1` | `11.3.1` | `13.0.2` | Uncommitted addition (`pubspec.yaml:54`); audit confirms it is **imported nowhere in `lib/`**. |
| `fl_chart` | `^0.68.0` | `0.68.0` | `0.71.0` | `1.3.1` | Functional, but triggers runtime crash in `AnalyticsPage` when `points.length == 1`. |
| `pdf` | `^3.11.3` | `3.11.3` | `3.11.3` | `3.13.1` | Built-in `Helvetica` font lacks Unicode glyphs (warnings emitted during tests). |
| `csv` | `^6.0.0` | `6.0.0` | `6.0.0` | `8.0.0` | Functional. |
| `intl` | `^0.19.0` | `0.19.0` | `0.20.2` | `0.20.3` | Pinned indirectly by Flutter `3.22.0` `flutter_localizations`. |
| `path_provider` | `^2.1.5` | `2.1.5` | `2.1.5` | `2.1.6` | Current. |
| `collection` | `^1.18.0` | `1.18.0` | `1.18.0` | `1.19.1` | Current on SDK 3.4. |
| `cupertino_icons` | `^1.0.6` | `1.0.8` | `1.0.8` | `2.0.0` | Current. |

### 2.2 Dev Dependencies & Discontinued Transitive Packages
- `build_runner`: `^2.4.9` (locked `2.4.11`, latest `2.17.1`)
- `riverpod_generator`: `^2.3.9` (locked `2.4.0`, latest `4.0.10`)
- `flutter_lints`: `^3.0.0` (locked `3.0.2`, resolvable `4.0.0`, latest `6.0.0`)
- **Discontinued Transitive Packages** (reported by `flutter pub outdated`):
  - `js`
  - `build_resolvers`
  - `build_runner_core`
- **Documentation Discrepancies**: `docs/TESTING.md` cites `mocktail` (absent from `pubspec.yaml`); `docs/*` cite `firebase_*` / `cloud_firestore` (absent); `AppTextStyles` cites `'Outfit'` and `'Inter'` fonts without `google_fonts` or font assets.

---

## 3. Assets & Fonts Configuration Gap

- [`lib/core/theme/text_styles.dart`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/theme/text_styles.dart#L7-L8) defines:
  - `primaryFont = 'Outfit'`
  - `fallbackFont = 'Inter'`
- [`pubspec.yaml`](file:///c:/Users/ramsa/Desktop/AttendIQ/pubspec.yaml#L80-L116) declares `uses-material-design: true` with **no `fonts:` or `assets:` section**, and `assets/` only contains `assets/screenshots/dashboard_mockup.png` (zero `.ttf`/`.otf` files).
- Result: Custom typography silently falls back to Android system Roboto (`PdfReportGenerator` also falls back to Helvetica with Unicode warnings).

---

## 4. Android & Gradle Configuration Audit

| File | Setting / Configuration | Finding |
|---|---|---|
| [`android/gradle/wrapper/gradle-wrapper.properties`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/gradle/wrapper/gradle-wrapper.properties#L5) | Gradle `7.6.3` | Older Gradle 7.x; requires JDK <=17 (incompatible with JDK 21+/24 system defaults). |
| [`android/settings.gradle`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/settings.gradle#L20-L22) | AGP `7.3.0`, Kotlin `1.8.22` | Older AGP/Kotlin pair; dual `ext.kotlin_version` also declared in `android/build.gradle:2,12`. |
| [`android/app/build.gradle`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/app/build.gradle#L34-L56) | `compileSdk = flutter.compileSdkVersion`, `targetSdk = flutter.targetSdkVersion`, `minSdk = 23` | `compileOptions` sets `JavaVersion.VERSION_1_8` without `coreLibraryDesugaringEnabled`. |
| [`android/app/build.gradle`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/app/build.gradle#L37-L40) | `lintOptions { checkReleaseBuilds false; abortOnError false }` | **Disables Android release lint checks**, hiding manifest/permission/API errors at release build time. |
| [`android/app/build.gradle`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/app/build.gradle#L58-L98) | Release `signingConfigs.release` with fallback `signingConfig = signingConfigs.debug` | Missing `minifyEnabled` / `shrinkResources` / `proguardFiles`; silently signs release builds with **debug keystore** if `key.properties` is absent. |
| [`android/app/build.gradle`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/app/build.gradle#L69-L88) | Product flavors `prod` (`deepLinkScheme: "attendiq"`) & `beta` (`deepLinkScheme: "attendiq-beta"`) | Required `--flavor prod` or `--flavor beta` for builds; Kotlin widget providers hardcode `attendiq://`, breaking `beta` widget deep links. |
| [`android/app/build.gradle`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/app/build.gradle#L118-L123) | Forces `androidx.work:work-runtime:2.8.1` and `work-runtime-ktx:2.8.1` | Hardcoded workaround for old `workmanager ^0.5.2`. |
| [`android/app/src/main/AndroidManifest.xml`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/app/src/main/AndroidManifest.xml#L1-L13) | `MANAGE_EXTERNAL_STORAGE` + `requestLegacyExternalStorage="true"` | **Play Store rejection blocker**; redundant/restricted permission for an academic tracker. |
| [`android/app/src/main/AndroidManifest.xml`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/app/src/main/AndroidManifest.xml#L4-L8) | Missing `RECEIVE_BOOT_COMPLETED` and `flutter_local_notifications` boot/scheduled receivers | Alarms are lost on device reboot. Exact alarms rely on `SCHEDULE_EXACT_ALARM` without Android 14 graceful denial UI guidance. |
| [`android/app/src/main/res/xml/file_paths.xml`](file:///c:/Users/ramsa/Desktop/AttendIQ/android/app/src/main/res/xml/file_paths.xml#L5) | `<root-path name="root" path="." />` | Overly broad FileProvider exposure of entire root filesystem. |

---

## 5. Secrets & Environment Handling

- **Version Control Safety**: `git ls-files` confirmed `android/key.properties`, `.env`, and `*.jks` / `*.keystore` are **not tracked** in Git (`.gitignore` excludes them). Local `android/key.properties` and `android/app/upload-keystore.jks` exist untracked for signing and were not exposed.
- **Gemini API Key (`GEMINI_API_KEY`)**:
  - Read via `const String.fromEnvironment('GEMINI_API_KEY')` in [`ai_chat_controller.dart:100`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/features/ai_assistant/presentation/controllers/ai_chat_controller.dart#L100) — **no hardcoded API key** in source code.
  - `.env.example` exists at repo root, but no `flutter_dotenv` loader exists; keys must be injected via `--dart-define`.
  - **Security flaw**: [`GeminiAIProvider`](file:///c:/Users/ramsa/Desktop/AttendIQ/lib/core/ai/services/gemini_ai_provider.dart#L24) appends `?key=$apiKey` directly in the URL query string rather than using the `x-goog-api-key` HTTP header.

---

## 6. CI/CD Pipeline Status ([`.github/workflows/flutter.yml`](file:///c:/Users/ramsa/Desktop/AttendIQ/.github/workflows/flutter.yml))

1. `flutter pub get` — Passes.
2. `dart format --set-exit-if-changed .` — **FAILS** (`124/197` files unformatted).
3. `dart run build_runner build --delete-conflicting-outputs` — Untested mutating step; 4 `.g.dart` files have older mtimes (`07/20/2026`) than their source `.dart` files (`07/21/2026`).
4. `flutter analyze` — **FAILS** (`268` issues: `2` errors, `28` warnings, `238` infos).
5. `flutter test` — Passes (`116` tests), but with unmocked `path_provider` exceptions and weak fake coverage.
6. **Missing CI Gate**: No Android APK build check (`flutter build apk --debug --flavor prod` or `beta`).

