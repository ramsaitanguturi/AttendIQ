# AttendIQ Android Production Release Audit & Hardening Report

## 1. Executive Summary

This audit assesses the Android configuration, build pipelines, ProGuard/R8 rules, permissions, battery management, and signing configuration of AttendIQ against Google Play Store and Android 14 (API 34) production requirements.

---

## 2. Platform SDK & Compatibility

| Configuration | Specification | Status |
|---|---|---|
| `compileSdk` | Flutter compileSdkVersion (API 34 / Android 14) | **Compliant** |
| `targetSdk` | Flutter targetSdkVersion (API 34 / Android 14) | **Compliant** |
| `minSdk` | 23 (Android 6.0 Marshmallow) | **Compliant** |
| `Java / JVM Target` | Java 17 compatibility (`VERSION_1_8` bytecode target) | **Compliant** |
| `Kotlin Gradle Plugin` | 1.8+ with AndroidX WorkManager KTX integration | **Compliant** |

---

## 3. Signing Security & Hardened Configuration

### Hardening Applied in `android/app/build.gradle`
1. **Zero Secret Leakage in Source Control**: Keystore credentials and file paths are loaded from `key.properties` (ignored by git) or CI/CD environment variables (`STORE_FILE`, `STORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD`).
2. **Environment Variable Precedence**: Enables automated GitHub Actions / GitLab CI release builds without generating temporary key files.
3. **Flavored Build Types**: Separates `prod` (`com.ramsa.attendiq.attend_iq`) from `beta` (`com.ramsa.attendiq.attend_iq.beta`), allowing side-by-side installation on QA devices.

---

## 4. ProGuard / R8 Obfuscation & Shrinking

Rules defined in `android/app/proguard-rules.pro`:
- **Flutter Framework**: Preserves Flutter embedding and plugin registrant classes.
- **Isar Database**: Retains native methods, generated schemas, and JNI bindings (`dev.isar.**`).
- **WorkManager**: Preserves `androidx.work.Worker` and `ListenableWorker` constructors called reflectively by Android OS.
- **AppWidgets**: Retains `AppWidgetProvider` classes (`TodayWidgetProvider`, `WeeklyWidgetProvider`, `MonthWidgetProvider`).
- **Notification Receivers**: Keeps broadcast receivers (`ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver`).

---

## 5. Android Manifest & Permissions Audit

### Declared Permissions
- `android.permission.INTERNET`: Required for optional cloud sync and AI advisory services.
- `android.permission.POST_NOTIFICATIONS`: Android 13+ runtime notification permission.
- `android.permission.SCHEDULE_EXACT_ALARM`: Android 12+ exact alarm scheduling.
- `android.permission.RECEIVE_BOOT_COMPLETED`: Device reboot recovery for class alarms and widgets.

### Exported Components & Security
- `MainActivity`: `exported="true"` with `MAIN`/`LAUNCHER` and deep link intent filters (`attendiq://`).
- `Widget Providers`: `exported="true"` with `APPWIDGET_UPDATE` intent filters.
- `Internal Boot Receivers`: Explicitly set to `exported="false"` to prevent unauthorized intent injection from other apps.

---

## 6. Battery Optimization & Exact Alarms Strategy

On Android 14 (API 34), apps targeting API 33+ are not granted `SCHEDULE_EXACT_ALARM` by default.
AttendIQ implements a two-tier resilience strategy:
1. **Try-Catch Fallback in Notification Service**: When exact alarm scheduling throws `PlatformException(exact_alarms_not_permitted, SecurityException)`, AttendIQ immediately catches the error, falls back to inexact alarms (`AndroidScheduleMode.inexactAllowWhileIdle`), and logs the event without crashing.
2. **Settings Guidance**: Provides UI prompts directing users to disable battery optimization / enable exact alarms when required for minute-accurate classroom reminders.

