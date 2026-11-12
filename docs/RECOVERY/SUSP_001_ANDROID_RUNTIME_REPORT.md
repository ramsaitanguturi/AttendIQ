# SUSP-001 — Android Runtime Verification Report (`BUG-008`)

> **Update (`2026-11-12` Post-Fix Addendum):** Sections 1–7 below preserve the **historical baseline run** at `fbf4055` (`OPEN — FAIL`). See **[Section 8 — Post-Fix Verification Addendum (`2026-11-12`)](#8-post-fix-verification-addendum-susp-001-backup-import-fix-2026-11-12)** for the post-fix verification results resolving the `P3-07`/`P3-08` Android backup import failure across API 28, 29, and 34.

**Verification Date:** 2026-11-12

**Target Commit / Baseline:** `HEAD` `fbf4055` (*docs: reconcile BUG-008 recovery audit*, parent of / including `e08440e` scoped storage changes); zero repository source files modified during this verification run (`BUG_AUDIT.md` untouched).

**Overall `SUSP-001` Verdict:** **OPEN — FAIL (NOT CLOSED)**
- **Build & Packaging (4/4 Configurations):** **PASS** (`prodDebug`, `betaDebug`, `prodRelease`, `betaRelease`)
- **Runtime Execution Matrix (`3 API Tiers × 4 Configs`):** Executed on `emulator-5556` (API 28), `emulator-5558` (API 29), and `emulator-5554` (API 34) with simultaneous `prod` + `beta` coexistence and data isolation **PASS**, SAF export & MediaStore `IS_PENDING` (`1 -> 0`) **PASS**, v2 Backup Manager & legacy v1 schema restore **PASS**, PDF/CSV reporting **PASS**, and process-kill / OS-reboot persistence **PASS**.
- **Critical Discovered Failures Blocking Closure:**
  1. **FAIL (`P3-07`, `P3-08`, MediaStore/SAF File Import):** [`BackupService.pickImportFile`](../../lib/core/backup/backup_service.dart#L321-L336) passes `FileType.custom` with `allowedExtensions: ['attendiq', 'json']` to `file_picker` (`8.3.2`).
     - On **API 28** and **API 29**, Android `FilePickerUtils` rejects **both** `'attendiq'` and `'json'` (empty MIME list `[]`), throwing `PlatformException(FilePicker, Unsupported filter...)` and completely blocking SAF file import (`.attendiq` and `.json`).
     - On **API 34**, Android `FilePickerUtils` rejects `'attendiq'` (`Allowed file extensions mimes: [application/json]`), leaving `.attendiq` backups disabled/unselectable in `DocumentsUI` (`PickActivity`) while `.json` succeeds.
  2. **UX Discrepancy Confirmed (Non-Crashing Watchpoint #2):** [`MainActivity.openExportContentUri`](../../android/app/src/main/kotlin/com/ramsa/attendiq/attend_iq/MainActivity.kt#L349-L357) wraps `ACTION_VIEW` in `Intent.createChooser(...)`, which displays Android `ChooserActivity` (`"No apps can perform this action."`) for `.attendiq` across all APIs (and `.json` on API 28/34 without a JSON viewer) instead of throwing `ActivityNotFoundException` to trigger the Dart SnackBar fallback.
  3. **Incomplete Release Log Capture / Post-Exit Gap on API 29:** `emulator-5558` exited and the `Medium_Phone_2` AVD was deleted externally near the end of API 29 testing, leaving `api29_release_logcat.txt` at `0` bytes and leaving API 29 release `adb logcat` archive + API 29 OS reboot check unverified after initial `Beta` isolation checks ran (`Medium_Phone_1` AVD also disappeared externally after API 28 completion).

---

## 1. Environment & Build Verification Details

| Component | Observed Value / Configuration | Source / Verification |
|---|---|---|
| **Host OS & Architecture** | Windows (`10.0.26200.9974`, `AMD64` / `x86_64`), locale `en-IN` | `flutter doctor -v` |
| **Git Repository State** | Branch `main` at `fbf4055`; only `docs/RECOVERY/SUSP_001_ANDROID_RUNTIME_REPORT.md` untracked/modified; `docs/RECOVERY/BUG_AUDIT.md` and all source files unmodified | `git status -s` |
| **Flutter / Dart SDK** | Flutter `3.22.0` (`channel [user-branch]`, `C:\Users\ramsa\Desktop\AttendIQ\flutter_sdk`), Dart `3.4.0` | `flutter.bat --version`, `flutter doctor -v` |
| **Java / Android Toolchain** | OpenJDK Temurin `17.0.19+10`, Android SDK `36.0.0`, `All Android licenses accepted.` | `flutter doctor -v` |
| **App Identifiers & Flavors** | `prod`: `com.ramsa.attendiq.attend_iq` (`AttendIQ`, scheme `attendiq`)<br>`beta`: `com.ramsa.attendiq.attend_iq.beta` (`AttendIQ Beta`, scheme `attendiq-beta`) | `android/app/build.gradle`, `aapt2 dump permissions` |
| **Permission Surface** | Only `INTERNET`, `POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`, `ACCESS_NETWORK_STATE`, `VIBRATE`, `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`, `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. Zero `MANAGE_EXTERNAL_STORAGE` / `READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE`. | `aapt2 dump permissions` (all 4 fresh APKs) |

### Phase 2 APK Builds (Sequential, Exit Code `0`)

| Config ID | Artifact Path | Exact Size (Bytes) | Build Time / Timestamp | Status |
|---|---|---|---|---|
| **P2-B01 (`prodDebug`)** | `build\app\outputs\flutter-apk\app-prod-debug.apk` | `469,217,431` | `116.9s` (`12-11-2026 00:15:17`) | **PASS** |
| **P2-B02 (`betaDebug`)** | `build\app\outputs\flutter-apk\app-beta-debug.apk` | `445,923,962` | `43.7s` (`12-11-2026 00:16:04`) | **PASS** |
| **P2-B03 (`prodRelease`)** | `build\app\outputs\flutter-apk\app-prod-release.apk` (and `app-release.apk`) | `68,766,305` | `12.6s` (`12-11-2026 00:16:23`) | **PASS** |
| **P2-B04 (`betaRelease`)** | `build\app\outputs\flutter-apk\app-beta-release.apk` | `68,766,320` | `10.4s` (`12-11-2026 00:16:34`) | **PASS** |
| **P2-B05 (Manifest / Perms)** | All 4 fresh APKs (`prod` & `beta`) | N/A | `aapt2 dump permissions` | **PASS** |

---

## 2. Device & `3 × 4` Build-Configuration Runtime Matrix

### 2.1 Emulator Inventory Verified Before Testing

| Emulator Serial | AVD Name | Android Version | API Level | CPU ABI | Boot & Storage Status |
|---|---|---|---|---|---|
| `emulator-5556` | `Medium_Phone_1` | Android 9 | `28` | `x86_64,x86` | `sys.boot_completed=1`, `/data` `9.1G` free |
| `emulator-5558` | `Medium_Phone_2` | Android 10 | `29` | `x86_64,x86` | `sys.boot_completed=1`, `/data` `9.4G` free |
| `emulator-5554` | `Medium_Phone_3` | Android 14 | `34` | `x86_64,arm64-v8a` | `sys.boot_completed=1`, `/data/user/0` `7.9G` free |

> **Resource Contention Note:** Running all 3 emulators concurrently on this 16 GB RAM host left ~1.7 GB free RAM and triggered `System UI isn't responding` ANRs. Execution was switched to strictly sequential single-emulator runs per Requirement 9. Note also that `Medium_Phone_1` (API 28) and `Medium_Phone_2` (API 29) AVDs disappeared externally from `%USERPROFILE%\.android\avd` around `01:05`.

### 2.2 Complete `3 × 4` Configuration Execution Matrix

| Build Config | Android 9 (API 28) — `emulator-5556` | Android 10 (API 29) — `emulator-5558` | Android 14 (API 34) — `emulator-5554` |
|---|---|---|---|
| **`prodDebug`** | **FAIL (Partial — `P3-07`/`P3-08` Failed)**<br>PID `8567`. Install, cold start, onboarding (`Fall 2026`), Task (`Lab Assignment 1`), Subject (`CS201 DATA STRUCTURES`), Present mark, app-private `.attendiq` (`4337` B), SAF `.json`/`Save Copy`/PDF (`4709` B)/CSV (`71` B) to `/sdcard/Download/`, `Open File` chooser, `Share File` sheet, `cache/export_share/` (`71` B), SAF cancel/re-export, invalid `{}` rejection, `HOME`, `always_finish_activities=1`, and `am force-stop` relaunch (`5683ms`) **PASS**. `Import Backup / Data File` threw `PlatformException(FilePicker, Unsupported filter...)` (**FAIL**). | **FAIL (Partial — `P3-07`/`P3-08` Failed)**<br>PID `5590` (`9633ms`). Install, cold start, onboarding (`Fall 2026`), app-private & MediaStore `.attendiq` (`1323` B), MediaStore `.json` duplicate `(1).json` (`1323` B), `is_pending=0`, PDF (`3228` B) & CSV (`29` B) in `Documents/AttendIQ/Reports/`, `cache/export_share/` bounded (`1` file), `Open File` (`WebView Browser Tester`), `Share File` sheet, and `am force-stop` relaunch (`5642ms`) **PASS**. `Import Backup / Data File` threw `PlatformException(FilePicker, Unsupported filter...)` (**FAIL**). | **FAIL (Partial — `.attendiq` Import Failed)**<br>PID `13613`/`25777`. `POST_NOTIFICATIONS` granted (`Allow`), onboarded `Fall 2026`, MediaStore `.attendiq` (`1291` B) & duplicate `(1).json` (`1291` B), `is_pending=0`, `cache/export_share/` bounded, `Open File` chooser, `Share File` sheet, `am force-stop` (`4614ms`) **PASS**. `Import Backup / Data File`: `.json` staged to `cache/file_picker/` and opened `Select Restore Mode`, but `FilePickerUtils` ignored `'attendiq'`, disabling `.attendiq` files (**FAIL**). |
| **`betaDebug`** | **PASS** (Coexistence + `P3-06`)<br>PID `13659` (`7171ms`), UID `u0_a86` alongside `prodDebug` (`u0_a85`). Onboarded `Beta Seem 2026`; isolated `app_flutter/backups/AttendIQ_Beta_Backup_Beta_Seem_2026_2026-11-12.attendiq` (`1296` B). `P3-06` (`pm disable-user --user 0 com.android.documentsui`) cleanly fell back to `app_flutter/AttendIQ Beta/Exports/AttendIQ_Beta_Data_Beta_Seem_2026_2026-11-12.json` (`1296` B). | **PASS** (Coexistence)<br>PID `6440` (`6532ms`). Installed simultaneously alongside `prodDebug`; verified isolated `Documents/AttendIQ Beta/Backups` & `Exports` (`1288` B). | **PASS** (Coexistence)<br>`5311ms`. `POST_NOTIFICATIONS` granted (`Allow`); onboarded `Beta34`; verified isolated `Documents/AttendIQ Beta/Backups/AttendIQ_Beta_Backup_Beta34_2026-11-12.attendiq` (`1283` B) & `Exports/` (`1283` B). |
| **`prodRelease`** | **PASS** (Coexistence)<br>PID `14448` (`1297ms`). Co-installed after uninstalling debug builds (`INSTALL_FAILED_UPDATE_INCOMPATIBLE` when overwriting debug keys). Onboarded `ProdRel28`, exported `.attendiq` & SAF `.json` cleanly; `api28_release_logcat.txt` clean (zero AttendIQ crashes). | **INCOMPLETE / PARTIAL PASS**<br>PID `7040` (`1621ms`). Installed, launched, onboarded (`ProdRel29`), exported `.attendiq` to `Documents/AttendIQ/Backups/` (`1295` B); however `emulator-5558` exited & AVD disappeared before `api29_release_logcat.txt` flushed (`0` B) and before API 29 reboot check. | **FAIL (`.attendiq` SAF Import Failed; Full Round-Trip & Reboot PASS)**<br>PID `4364` (`4468ms` cold / `1126ms` warm). Tested `Fall34` + `Lab Assignment 1` + `CS201` Present, `.attendiq` (`4374` B), `.json` (`4374` B), `Save Copy to Device` `(1).attendiq`, `Reports` PDF (`4718` B, `%PDF-1.5`) & CSV (`81` B), invalid `{}` error, `legacy_v1_backup_valid.json` SAF Replace (`P3-08`), Backup Manager `.attendiq` Replace (`P5-03`/`P5-04`/`P5-05`), and full `adb reboot` persistence (`P6-06`) — all **PASS**. `Import Backup / Data File` blocked `.attendiq` (`FilePickerUtils: Custom file type attendiq is unsupported`, `mimes: [application/json]`) (**FAIL**). |
| **`betaRelease`** | **PASS** (Coexistence)<br>PID `14973` (`1165ms`), UID `u0a88`. Co-installed simultaneously with `prodRelease`. Onboarded `BetaRel28`, exported `.attendiq` & SAF `.json` cleanly; verified zero AttendIQ crashes in `api28_release_logcat.txt`. | **INCOMPLETE / PARTIAL PASS**<br>PID `7448` (`1317ms`). Co-installed simultaneously with `prodRelease`, launched, onboarded (`BetaRel29`), verified `Documents/AttendIQ Beta/Backups` (`1290` B) isolation; `api29_release_logcat.txt` left at `0` B on external emulator exit. | **PASS** (Coexistence + Reboot Isolation)<br>PID `7926` (`2686ms` cold / `5940ms` post-reboot). `POST_NOTIFICATIONS` granted, onboarded `BetaRel34`, exported `.attendiq` (`1291` B) & `.json` (`1291` B) into `Documents/AttendIQ Beta/`, verified `MediaProvider` `IS_PENDING` `1 -> 0`, and confirmed isolated `BetaRel34` state alongside `Fall34` after OS reboot. |

---

## 3. Detailed Phases 2–7 Test Case Results

### Phase 2 — Runtime Smoke Checks (`P2-R01`–`P2-R05`)

| ID | Case Description | API 28 | API 29 | API 34 | Overall Status & Actual Evidence |
|---|---|---|---|---|---|
| **P2-R01** | Install `prod` & `beta` APKs (debug & release pairs) | **PASS** | **PASS** | **PASS** | All 4 APKs installed cleanly on all 3 emulators; debug-to-release cleanly required uninstalling debug APKs first (`INSTALL_FAILED_UPDATE_INCOMPATIBLE`). |
| **P2-R02** | Launch application cold start | **PASS** | **PASS** | **PASS** | `prodDebug`/`betaDebug`: `5683ms`/`7171ms` (API 28), `9633ms`/`6532ms` (API 29), `5311ms` beta (API 34). `prodRelease`/`betaRelease`: `1297ms`/`1165ms` (API 28), `1621ms`/`1317ms` (API 29), `4468ms`/`2686ms` (API 34). |
| **P2-R03** | Verify Isar initialization & startup persistence | **PASS** | **PASS** | **PASS** | Onboarding, subjects, tasks, and attendance records persisted cleanly across cold restarts & `am force-stop`. |
| **P2-R04** | Open `BackupPage` (`/backup`) & render backup list | **PASS** | **PASS** | **PASS** | Rendered actions, quota/storage explanation, and `Backup Manager` item list (`4.3 KB` for `AttendIQ_Backup_Fall34_2026-11-12.attendiq`) across APIs. |
| **P2-R05** | Verify zero immediate native / JNI / MethodChannel crashes on boot | **PASS** | **PASS** | **PASS** | `libisar.so` (`x86_64`) loaded without `UnsatisfiedLinkError` across all 3 emulators; zero AttendIQ crash traces in `api28_release_logcat.txt` and `api34_release_logcat.txt`. |

### Phase 3 — Android API 23–28 SAF & File Import Flows (`API 28` + Cross-API Import)

| ID | Scenario | Status | Actual Runtime Result & Evidence |
|---|---|---|---|
| **P3-01** | Export backup (`.attendiq`) using normal export (prompt-free) | **PASS** | On API 28 (`prodDebug`), `Export Backup (.attendiq)` saved prompt-free without opening SAF picker; `ExportSuccessDialog` opened immediately (`api28_export_backup_dialog.png`). |
| **P3-02** | Verify valid `.attendiq` generated in app-private `backups/` | **PASS** | Verified `app_flutter/backups/AttendIQ_Backup_Fall_2026_2026-11-12.attendiq` (`4337` B on `prodDebug`; `1296` B in `betaDebug`). |
| **P3-03** | Verify SAF `ACTION_CREATE_DOCUMENT` (`Export Data`, `Save Copy to Device`, PDF/CSV) | **PASS** | All four flows launched `com.android.documentsui` `ACTION_CREATE_DOCUMENT` on API 28 (`api28_saf_create_document.png`). |
| **P3-04** | Select destination in SAF document picker & complete write | **PASS** | Tapping `SAVE` wrote non-empty `.attendiq`, `.json`, PDF (`4709` B), and CSV (`71` B) files to `/sdcard/Download/` with updated `ExportSuccessDialog` (`api28_saf_saved_dialog.png`). |
| **P3-05** | Cancel SAF picker -> clean cancel, no 0-byte orphan file | **PASS** | Pressing `KEYCODE_BACK` in `DocumentsUI` (`PickActivity`) cleanly returned to `BackupPage` with zero crash, zero error snackbar, zero 0-byte file in `/sdcard/Download/`. |
| **P3-06** | Unavailable SAF picker fallback | **PASS** | Temporarily disabled `com.android.documentsui` (`pm disable-user --user 0`) in API 28 `betaDebug`; `Export Data (.json)` fell back to `app_flutter/AttendIQ Beta/Exports/AttendIQ_Beta_Data_Beta_Seem_2026_2026-11-12.json` (`1296` B; `api28_p306_saf_fallback.png`), then re-enabled `com.android.documentsui`. |
| **P3-07** | Import backup via `Import Backup / Data File` (`file_picker` SAF) | **FAIL** | **Reproducible defect across API 28, 29, and 34:** API 28 & 29 rejected **both** `'attendiq'` and `'json'` (`mimes: []` -> `PlatformException(FilePicker, Unsupported filter...)`, never opening picker). API 34 rejected `'attendiq'` (`mimes: [application/json]`), disabling `.attendiq` in `DocumentsUI` while allowing `.json`. |
| **P3-08** | Import legacy v1 backup via SAF & pasted JSON | **PARTIAL FAIL** | On API 28/29, SAF `.attendiq`/`.json` import **FAILED** (`P3-07`). On API 34 (`prodRelease`), SAF import of `/sdcard/Download/legacy_v1_backup_valid.json` (`2281` B) **PASSED** (`Select Restore Mode` -> `Replace Existing Data` -> `"Database restored successfully!"`, showing `Legacy V1 Sem` & `Legacy Algorithms`). Also verified schema validation error detection when `events[0].status` was invalid (`COMPLETED`). Note: `.attendiq` file selection via SAF failed on API 34 too. |
| **P3-09** | Open exported file (`Open File` -> `openExportUri`) | **PASS (Watchpoint #2 Confirmed)** | On API 28 & 34, `.attendiq` (`application/octet-stream`) opened `android/com.android.internal.app.ChooserActivity` displaying `"No apps can perform this action."` (`api28_open_attendiq.png`) rather than Dart SnackBar fallback; on API 29 `.json` opened `ChooserActivity -> WebView Browser Tester` (`api34_open_json.png` showed no JSON viewer on API 34). No crashes. |
| **P3-10** | Share exported backup (`Share File` / Backup Manager `Share`) | **PASS** | Both `ExportSuccessDialog` `Share File` and Backup Manager `Share` opened Android Sharesheet (`Gmail`, `Save to Drive`; `api28_share_sheet.png`, `api34_share_sheet.png`) with zero `FileUriExposedException`. |
| **P3-11** | Verify `content://` URIs never passed directly to `dart:io File` | **PASS** | Statically guarded; on API 34 JSON SAF import, logcat confirmed `FilePickerUtils` cached `content://com.android.providers.downloads.documents/document/msf%3A1000000044` to `/data/user/0/com.ramsa.attendiq.attend_iq/cache/file_picker/.../legacy_v1_backup_valid.json` before Dart read it. |

### Phase 4 — Android API 29+ MediaStore Testing (`API 29` & `API 34`)

| ID | Scenario | API 29 | API 34 | Actual Runtime Result & Evidence |
|---|---|---|---|---|
| **P4-01** | Export JSON backup (`Export Data (.json)`) via `MediaStore.Files` | **PASS** | **PASS** | Wrote cleanly via `MethodChannel` `saveViaMediaStore` without storage permissions or SAF prompt. |
| **P4-02** | Verify files appear in `Documents/AttendIQ/{Backups,Exports,Reports}` | **PASS** | **PASS** | Verified on API 29 (`1323` B `.attendiq`/`.json`, `3228` B PDF, `29` B CSV) and API 34 (`4374` B `.attendiq`/`.json`, `4718` B PDF `%PDF-1.5`, `81` B CSV). |
| **P4-03** | Verify `beta` flavor exports target `Documents/AttendIQ Beta/...` | **PASS** | **PASS** | Verified `AttendIQ Beta/Backups` & `Exports` (`1288` B debug / `1295`–`1290` B API 29; `1283` B debug / `1291` B release API 34) strictly isolated from `Documents/AttendIQ/`. |
| **P4-04** | Verify `IS_PENDING` `1 -> 0` transition | **PASS** | **PASS** | `content query --uri content://media/external/file` confirmed `is_pending=0` on all AttendIQ rows (API 29 & 34); API 34 `MediaProvider` logcat recorded atomic `.pending-*` rename to final `.attendiq`/`.json`/`.pdf`/`.csv`. |
| **P4-05** | Verify saved MediaStore file contains valid, complete backup JSON | **PASS** | **PASS** | Pulled via `adb exec-out` and parsed with `json.loads`; API 34 `Fall34` backup (`4374` B) contained valid UTF-8 JSON for all test records. |
| **P4-06** | Duplicate filename disambiguation | **PASS** | **PASS** | Exporting twice produced `AttendIQ_Data_Fall_2026_2026-11-12 (1).json` (API 29) and `AttendIQ_Backup_Fall34_2026-11-12 (1).attendiq` (API 34) with `MediaProvider` moving `.pending-*` to `(1)`. |
| **P4-07** | Non-fatal MediaStore fallback / app-private safety | **PASS** | **PASS** | App-private `backups/` file created independently and preserved before/alongside public copy. |
| **P4-08** | Error handling / invalid import cancellation | **PASS** | **PASS** | Empty `{}` paste cleanly returned `Backup validation error: metadata: Missing required backup metadata object.` without DB/file loss (API 28 & 34); malformed `events[0].status` cleanly rejected (API 34). Direct MediaStore stream fault injection was not separately simulated (`NOT TESTED` for kernel I/O fault). |
| **P4-09** | Open exported file via MediaStore content URI | **PASS** | **PASS** | Launched Android `ChooserActivity` cleanly with `FLAG_GRANT_READ_URI_PERMISSION` (`WebView Browser Tester` on API 29 `.json`; `"No apps can perform this action."` on API 34 `.attendiq`/`.json`). |
| **P4-10** | Share exported file via `share_plus` | **PASS** | **PASS** | Android Sharesheet opened cleanly across `.attendiq`, `.json`, and report exports (`api34_share_sheet.png`). |
| **P4-11** | Temporary share files in `cache/export_share/` cleared & bounded | **PASS** | **PASS** | Verified across API 28 (`1` file, `71` B CSV retained), API 29 (`1` file retained), and API 34 cleanup logic. |

### Phase 5 — Backup Integrity (Runtime on Device)

| ID | Scenario | Status | Actual Runtime Result & Evidence |
|---|---|---|---|
| **P5-01** | Validate exported JSON syntax & UTF-8 integrity | **PASS** | Validated `api28_prod_backup.attendiq` (`4337` B) and `api34_fall34_backup.attendiq` (`4374` B) + MediaStore JSON (`beta` `1291` B) via Python `json.loads`. |
| **P5-02** | Verify `metadata.backupVersion` (`2`), `appVersion` (`1.1.0`), `devicePlatform` (`android`) | **PASS** | API 28 & API 34 pulled `.attendiq` headers verified: `'appVersion': '1.1.0', 'backupVersion': 2, 'devicePlatform': 'android'`. |
| **P5-03** | Backup import/restore (`Merge` & `Replace` on device DB) | **PASS** | Executed `Restore -> Merge Data` UI flow on API 28; executed full **`Replace Data` round-trip** on API 34 (`prodRelease`) overwriting DB with `Legacy V1 Sem`, then restoring `AttendIQ_Backup_Fall34_2026-11-12.attendiq` via Backup Manager. *(Note: full entity merge conflict resolution beyond validation was only exercised via `Replace Data` round-trip on API 34.)* |
| **P5-04** | Verify all expected test entities restored accurately | **PASS** | Verified `Fall34`, `Data Structures` (`CS201`), `PRESENT` status, `1` Total / `1` Present / `0` Absent (`100%`), and `Lab Assignment 1` (`Academic Planner`) all restored cleanly on API 34 (`prodRelease`) after `Replace Data`. Note JSON `counts`: `userPreferences: 1, semesters: 1, subjects: 1, attendance: 1, notifications: 2, weeklyRules: 1, occurrences: 1, tasks: 1`. |
| **P5-05** | Verify app-private backups in `backups/` remain listed and intact | **PASS** | Verified `Backup Manager` card on API 28 & API 34 (`AttendIQ_Backup_Fall34_2026-11-12.attendiq • Nov 12, 2026 • 1:15 AM • 4.3 KB`) stayed intact across invalid imports and replaces. |
| **P5-06** | Verify failed imports do not corrupt DB or app-private backups | **PASS** | Both `{}` paste and invalid `COMPLETED` v1 JSON import aborted cleanly during validation while preserving `Fall34` state and `Backup Manager` entries. |

### Phase 6 — Lifecycle Testing

| ID | Scenario | Status | Actual Runtime Result & Evidence |
|---|---|---|---|
| **P6-01** | App backgrounding (`KEYCODE_HOME` + resume) | **PASS** | Verified on API 28 (`prodDebug`): `ExportSuccessDialog` & exported `.attendiq` file remained intact on foreground resume. |
| **P6-02** | Activity recreation with `Don't keep activities` (`always_finish_activities=1`) during SAF picker | **PASS** | Verified on API 28 (`prodDebug`): enabled `always_finish_activities=1`, ran `Export Data (.json)` through `DocumentsUI` `SAVE`, saved `AttendIQ_Data_Fall_2026_2026-11-12.json (1)` (`4371` B) and displayed `ExportSuccessDialog` without `MainActivity` crash (`api28_p602_dont_keep_activities.png`). |
| **P6-03** | Process termination (`am force-stop`) | **PASS** | Verified on API 28 (`prodDebug`), API 29 (`prodDebug`), and API 34 (`prodDebug`) cleanly. |
| **P6-04** | SAF picker cancellation (`BACK`) and subsequent re-export | **PASS** | Verified on API 28 (`prodDebug`): `KEYCODE_BACK` cancelled cleanly; immediate follow-up `Export Data (.json)` wrote `4337` B cleanly. |
| **P6-05** | Reopening AttendIQ after force-stop & verifying persistence | **PASS** | Verified `Fall 2026` + `CS201 PRESENT` persisted (`5683ms` API 28) and `Fall 2026` persisted (`5642ms` API 29, `4614ms` API 34). |
| **P6-06** | Emulator full OS reboot recovery & backup persistence (`adb reboot`) | **PASS (API 34) / UNAVAILABLE (API 28, 29)** | Verified on API 34 (`emulator-5554`): `adb reboot` -> `sys.boot_completed=1` -> `prodRelease` (`Fall34`, `CS201 PRESENT`) & `betaRelease` (`BetaRel34`, `5940ms`) + all `/sdcard/Documents/AttendIQ/{Backups,Exports,Reports}` files survived intact (`api34_p606_post_reboot_prod.png`). *(API 28 & 29 AVDs disappeared externally prior to reboot step.)* |

### Phase 7 — Native Logs & Diagnostics

| ID | Log Collection Item | Status | Evidence & Notes |
|---|---|---|---|
| **P7-01** | `adb logcat` capture (`MediaProvider`, `FilePicker`, `ActivityManager`, Flutter) | **PARTIAL PASS** | Captured live `logcat` inline across all debug runs (`API 28/29/34`) + archived `api28_release_logcat.txt` (`488,066` B / `1,767` lines) and `api34_release_logcat.txt` (`1,468,364` B / `11,681` lines). `api29_release_logcat.txt` is `0` B due to external `emulator-5558` exit. |
| **P7-02** | Flutter runtime / plugin logs (`FilePicker`, notifications fallback) | **PASS** | Observed `PlatformException(FilePicker, Unsupported filter...)` (API 28/29), `Allowed file extensions mimes: [application/json]` (API 34), and Android 14 `exact_alarms_not_permitted` -> `Inexact notification scheduling fallback succeeded.` |
| **P7-03** | Crash / JNI / URI permission trace audit | **PASS** | Zero AttendIQ crashes, zero `UnsatisfiedLinkError`, zero `FileUriExposedException` across all runs. Two `FATAL EXCEPTION` entries in `api34_release_logcat.txt` (`PID 8042` & `8206`) belonged solely to overlapping `com.android.commands.uiautomator.Launcher` test harness calls (`UiAutomationService already registered!`). |

---

## 4. Captured Visual & Logcat Artifacts (Scratch Evidence)

Stored in conversation scratch directory (`C:\Users\ramsa\.gemini\antigravity\brain\d687ea0d-a740-420b-b6d4-8d6bb4da72d5\scratch\`):
- **API 28 (`emulator-5556`):** `api28_prodDebug_launch.png`, `api28_prodDebug_dashboard.png`, `api28_prodDebug_marked_present.png`, `api28_prodDebug_backup_page.png`, `api28_export_backup_dialog.png`, `api28_saf_create_document.png`, `api28_saf_saved_dialog.png`, `api28_open_attendiq.png`, `api28_share_sheet.png`, `api28_file_picker.png`, `api28_p602_dont_keep_activities.png`, `api28_p306_saf_fallback.png`, `api28_prod_backup.attendiq` (`4337` B), `api28_release_logcat.txt` (`488,066` B).
- **API 34 (`emulator-5554`):** `api34_prodDebug_launch.png`, `api34_prodDebug_dashboard.png`, `api34_mediastore_backup_dialog.png`, `api34_mediastore_dup_dialog.png`, `api34_open_json.png`, `api34_share_sheet.png`, `api34_file_picker.png`, `api34_documentsui_backups.png`, `api34_prodRelease_backup_manager.png`, `api34_download_picker.png`, `api34_p606_post_reboot_prod.png`, `api34_fall34_backup.attendiq` (`4374` B), `api34_release_logcat.txt` (`1,468,364` B).

---

## 5. Observed Logcat Excerpts

### 5.1 Root Cause of `P3-07` / `P3-08` Failure — `file_picker` Custom Extension Rejection

API 28 (`emulator-5556`, `pid 8567`) & API 29 (`emulator-5558`, `pid 5590`):
```text
W FilePickerUtils: Custom file type attendiq is unsupported and will be ignored.
W FilePickerUtils: Custom file type json is unsupported and will be ignored.
D FilePickerUtils: Allowed file extensions mimes: []
I flutter : [MethodChannelFilePicker] Platform exception: PlatformException(FilePicker, Unsupported filter. Make sure that you are only using the extension without the dot, (ie., jpg instead of .jpg). This could also have happened because you are using an unsupported file extension.  If the problem persists, you may want to consider using FileType.any instead., null, null)
```

API 34 (`emulator-5554`, `prodRelease`, `pid 4364`):
```text
11-12 01:17:00.899  4364  4364 W FilePickerUtils: Custom file type attendiq is unsupported and will be ignored.
11-12 01:17:00.900  4364  4364 D FilePickerUtils: Allowed file extensions mimes: [application/json]
11-12 01:17:00.903  4364  4364 D FilePickerDelegate: Selected type */*
11-12 01:18:05.788  4364  7066 I FilePickerUtils: Caching from URI: content://com.android.providers.downloads.documents/document/msf%3A1000000044
11-12 01:18:05.950  4364  7066 D FilePickerUtils: File loaded and cached at:/data/user/0/com.ramsa.attendiq.attend_iq/cache/file_picker/1794426485903/legacy_v1_backup_valid.json
```

### 5.2 API 34 `MediaProvider` `IS_PENDING` (`1 -> 0`) & Prod/Beta Isolation (`api34_release_logcat.txt`)

```text
11-12 01:20:33.566  1474  6207 I MediaProvider: Open with lower FS for /storage/emulated/0/Documents/AttendIQ/Reports/.pending-1795031433-AttendIQ_Attendance_Report_Fall34_2026-11-12.pdf. Uid: 10192
11-12 01:20:33.584  1474  6207 D MediaProvider: Moving /storage/emulated/0/Documents/AttendIQ/Reports/.pending-1795031433-AttendIQ_Attendance_Report_Fall34_2026-11-12.pdf to /storage/emulated/0/Documents/AttendIQ/Reports/AttendIQ_Attendance_Report_Fall34_2026-11-12.pdf
11-12 01:21:12.607  1474  6207 I MediaProvider: Open with lower FS for /storage/emulated/0/Documents/AttendIQ/Backups/.pending-1795031472-AttendIQ_Backup_Fall34_2026-11-12.attendiq. Uid: 10192
11-12 01:21:12.646  1474  6207 D MediaProvider: Moving /storage/emulated/0/Documents/AttendIQ/Backups/.pending-1795031472-AttendIQ_Backup_Fall34_2026-11-12.attendiq to /storage/emulated/0/Documents/AttendIQ/Backups/AttendIQ_Backup_Fall34_2026-11-12 (1).attendiq
11-12 01:22:43.618  1474  1509 I MediaProvider: Open with lower FS for /storage/emulated/0/Documents/AttendIQ Beta/Backups/.pending-1795031563-AttendIQ_Beta_Backup_BetaRel34_2026-11-12.attendiq. Uid: 10193
11-12 01:22:43.689  1474  1509 D MediaProvider: Moving /storage/emulated/0/Documents/AttendIQ Beta/Backups/.pending-1795031563-AttendIQ_Beta_Backup_BetaRel34_2026-11-12.attendiq to /storage/emulated/0/Documents/AttendIQ Beta/Backups/AttendIQ_Beta_Backup_BetaRel34_2026-11-12.attendiq
```

### 5.3 API 34 Android 14 Exact Alarm Fallback (`api34_release_logcat.txt`)

```text
11-12 01:18:19.477  4364  4394 I flutter : Exact notification scheduling failed (e.g., SecurityException on Android 14+): PlatformException(exact_alarms_not_permitted, Exact alarms are not permitted, null, null)
11-12 01:18:19.477  4364  4394 I flutter : Attempting fallback to inexact notification scheduling...
11-12 01:18:19.484  4364  4394 I flutter : Inexact notification scheduling fallback succeeded.
```

---

## 6. Discovered Failures & Root Causes (Reported Prior to Any Code Changes)

1. **CRITICAL — [`BackupService.pickImportFile`](../../lib/core/backup/backup_service.dart#L321-L336) Fails `.attendiq` (API 28/29/34) and `.json` (API 28/29) Imports on Android**
   - **Code Location:** `lib/core/backup/backup_service.dart#L327-L331`:
     ```dart
     final result = await FilePicker.platform.pickFiles(
       type: FileType.custom,
       allowedExtensions: ['attendiq', 'json'],
       withData: kIsWeb,
     );
     ```
   - **Root Cause:** `file_picker` (`8.3.2`) translates `allowedExtensions` via `MimeTypeMap.getSingleton().getMimeTypeFromExtension(...)` on Android (`FilePickerUtils`):
     - `'attendiq'` is not a standard Android MIME mapping in any API level, so `FilePickerUtils` logs `Custom file type attendiq is unsupported and will be ignored.` across API 28, 29, and 34.
     - API 28 and API 29 emulator `MimeTypeMap` instances also lack `json` -> `application/json` mapping, producing `Allowed file extensions mimes: []` and throwing `PlatformException(FilePicker, Unsupported filter...)` so `DocumentsUI` never opens at all.
     - API 34 has `json` -> `application/json`, so `DocumentsUI` opens with `[application/json]`, allowing `.json` files while keeping `.attendiq` (`application/octet-stream`) disabled and unselectable.
   - **Recommended Fix (Not Applied Yet Per Instructions):** Use `FileType.any` (and validate the selected file extension / JSON schema in Dart via `BackupValidator`), or implement a native Android `ACTION_OPEN_DOCUMENT` (`*/*` or `application/json` + `application/octet-stream` MIME extras) MethodChannel helper matching the existing `MainActivity.kt` SAF pattern.

2. **MEDIUM / UX Discrepancy — [`MainActivity.openExportContentUri`](../../android/app/src/main/kotlin/com/ramsa/attendiq/attend_iq/MainActivity.kt#L349-L357) `Intent.createChooser` Bypasses `ActivityNotFoundException`**
   - **Code Location:** `android/app/src/main/kotlin/com/ramsa/attendiq/attend_iq/MainActivity.kt#L349-L357` (`Intent.createChooser(viewIntent, "Open File")`).
   - **Root Cause:** Wrapping `ACTION_VIEW` inside `Intent.createChooser(...)` always resolves Android's system `ChooserActivity`, so tapping `Open File` on `.attendiq` displays the system sheet `"No apps can perform this action."` rather than throwing `ActivityNotFoundException` for Dart's fallback message in [`ExportSuccessDialog`](../../lib/core/widgets/export_success_dialog.dart).
   - **Recommended Fix (Not Applied Yet Per Instructions):** Call `viewIntent.resolveActivity(packageManager)` (or `queryIntentActivities`) before `startActivity(createChooser(...))` and return `ActivityNotFoundException` / `false` when zero handlers exist.

---

## 7. Final Recommendation

- **`SUSP-001` MUST REMAIN OPEN / FAIL** per Requirement 13 until:
  1. `BackupService.pickImportFile()` is fixed to support importing `.attendiq` and `.json` files via Android SAF across API 28, API 29, and API 34 (and verified at runtime).
  2. API 28 and API 29 release checks (re-creating `Medium_Phone_1` & `Medium_Phone_2` AVDs if deleted, capturing full `api29_release_logcat.txt` and API 28/29 reboot persistence) are re-verified after the import fix.
- `docs/RECOVERY/BUG_AUDIT.md` remains unmodified awaiting fix approval and closure verification.

---

## 8. Post-Fix Verification Addendum (`SUSP-001` Backup Import Fix, `2026-11-12`)

**Post-Fix Verdict (`P3-07` / `P3-08` Android Backup Import):** **PASS — RESOLVED & VERIFIED**

**Scope of Code Change:** Dart-only fix in [`lib/core/backup/backup_service.dart`](../../lib/core/backup/backup_service.dart#L315-L431) plus regression suite [`test/core/backup/backup_import_picker_test.dart`](../../test/core/backup/backup_import_picker_test.dart); [`MainActivity.kt`](../../android/app/src/main/kotlin/com/ramsa/attendiq/attend_iq/MainActivity.kt) and unrelated features untouched.

### 8.1 Root Cause & Implemented Fix

- **Root Cause (`file_picker` `8.3.2` Android MIME filtering):** `BackupService.pickImportFile()` previously invoked `FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['attendiq', 'json'], withData: kIsWeb)`. On Android, `file_picker` `8.3.2` resolves `allowedExtensions` via `MimeTypeMap.getSingleton().getMimeTypeFromExtension(...)` (`FileUtils.getMimeTypes`), which rejects `'attendiq'` on API `28`/`29`/`34` and `'json'` on API `28`/`29` (`PlatformException(FilePicker, Unsupported filter...)`), while disabling `.attendiq` selection in `DocumentsUI` on API `34`.
- **Implemented Fix ([`BackupService.pickImportFile`](../../lib/core/backup/backup_service.dart#L332-L431)):**
  - Uses `FileType.any` (`allowedExtensions: null`, `withData: kIsWeb`) when running on Android (`!kIsWeb && (_isAndroidOverride ?? Platform.isAndroid)`), while preserving `FileType.custom` (`['attendiq', 'json']`) on non-Android/web platforms.
  - Enforces strict post-selection extension validation via `_validateSupportedImportExtension` / `_extractExtension` (case-insensitive `.attendiq` or `.json`; rejects unsupported, dot-only, trailing-dot, and extensionless filenames with `FormatException`).
  - Preserves `content://` and `file://` filesystem URI guards (never passing `content://` URIs to `dart:io File`), reads cached paths via `_readRawFileContent` (supporting `file.bytes == null` when cached path is valid), falls back to `_decodeBackupBytes(file.bytes!)` only when `bytes != null`, and throws `FileSystemException` when neither local path nor bytes is available.
  - Preserves size limits (`> 0` and `<= 20 MB`), UTF-8 decoding, `BackupValidator.decodeRawJson`, `v1`/`v2` schema/version validation, and `Merge`/`Replace` semantics.

### 8.2 Post-Fix Static & Automated Test Verification

| Check | Command | Result |
|---|---|---|
| **New Regression Suite** | `flutter test test/core/backup/backup_import_picker_test.dart` | **PASS (`9/9`)** — covers `.attendiq` & `.json` selection (`FileType.any` on Android, `FileType.custom` on non-Android), legacy `v1` import, malformed JSON, unsupported extensions/content, cancellation, unavailable paths (`null`/empty/`content://`/`file://`/missing), `null` bytes, and `BackupPage` `Merge` & `Replace` flows |
| **Focused Backup Suite** | `flutter test test/core/backup/` | **PASS (`58/58`)** |
| **Full Flutter Suite** | `flutter test -j 1` | **PASS (`239/239`)** *(prior default parallel run hit 1 transient Windows temp-dir file lock `PathAccessException` in unrelated `test/features/semester_management_test.dart:738`; sequential `-j 1` passed `239/239`)* |
| **Focused Dart Analyzer** | `flutter analyze lib/core/backup/backup_service.dart test/core/backup/backup_import_picker_test.dart` | **PASS (`No issues found`)** *(full-repo `flutter analyze` retains `335` pre-existing unrelated issues under `BUG-030`)* |
| **Formatting & Diff Check** | `dart format --output=none --set-exit-if-changed lib/core/backup/backup_service.dart test/core/backup/backup_import_picker_test.dart` & `git diff --check` | **PASS (`0 changed`, exit code `0`)** |

### 8.3 Post-Fix Android APK Builds (`4/4` PASS)

| Configuration | Artifact Path | Exact Size (Bytes) | Build Time | Status |
|---|---|---:|---:|---|
| **`prodDebug`** | `build\app\outputs\flutter-apk\app-prod-debug.apk` | `469,210,643` | `50.4s` | **PASS** |
| **`betaDebug`** | `build\app\outputs\flutter-apk\app-beta-debug.apk` | `445,973,361` | `23.3s` | **PASS** |
| **`prodRelease`** | `build\app\outputs\flutter-apk\app-prod-release.apk` (`app-release.apk`) | `68,766,288` | `90.3s` | **PASS** |
| **`betaRelease`** | `build\app\outputs\flutter-apk\app-beta-release.apk` | `68,766,313` | `79.1s` | **PASS** |

### 8.4 Post-Fix Android Runtime Import Matrix (`12/12` PASS)

Executed sequentially against freshly built APKs (`prod` and `beta` tested separately) on `AttendIQ_API28` (API `28`), `AttendIQ_API29` (API `29`), and `Medium_Phone_3` (API `34`). Every cell verified `DocumentsUI` (`ACTION_OPEN_DOCUMENT` `*/*`) selection from `Downloads` and verified all 5 runtime import cases:
1. `unsupported_notes.txt` rejected (`Unsupported backup file "unsupported_notes.txt". Please select a .attendiq or .json file.`).
2. `malformed_runtime.json` rejected (`Invalid JSON format`).
3. `legacy_v1_runtime.json` imported via `Replace Existing Data` -> Dashboard restored `Legacy V1 Sem`.
4. `valid_v2_runtime.attendiq` selectable/enabled in `DocumentsUI` and imported via `Replace Existing Data` -> Dashboard restored `Runtime V2 Fall`.
5. `valid_v2_runtime.json` imported via `Merge Data` -> restored cleanly into isolated flavor DB.

| Build Config | API 28 (`AttendIQ_API28`) | API 29 (`AttendIQ_API29`) | API 34 (`Medium_Phone_3`) |
|---|---|---|---|
| **`prodDebug`** | **PASS (`5/5`)** — `FilePickerDelegate: Selected type */*`, cached to `cache/file_picker/...`, 0 crashes | **PASS (`5/5`)** — `msf%3A11/12/13` cached cleanly, 0 crashes | **PASS (`5/5`)** — `.attendiq` & `.json` selectable, 0 crashes |
| **`betaDebug`** | **PASS (`5/5`)** — isolated `.beta` cache & Isar DB, 0 crashes | **PASS (`5/5`)** — isolated `.beta` cache & Isar DB, 0 crashes | **PASS (`5/5`)** — isolated `.beta` cache & Isar DB, 0 crashes |
| **`prodRelease`** | **PASS (`5/5`)** — `com.mr.flutter.plugin.filepicker` release caching verified, 0 crashes | **PASS (`5/5`)** — release `logcat` verified cleanly, 0 crashes | **PASS (`5/5`)** — release `.attendiq` & `.json` verified, 0 crashes |
| **`betaRelease`** | **PASS (`5/5`)** — isolated `.beta` release verified, 0 crashes | **PASS (`5/5`)** — isolated `.beta` release `logcat` verified cleanly, 0 crashes | **PASS (`5/5`)** — isolated `.beta` release verified, 0 crashes |

### 8.5 Historical Test IDs: Re-Verified vs. Not Rerun After Dart-Only Fix

- **Re-verified after the Dart-only `BackupService.pickImportFile()` fix (`12/12` API × config matrix):**
  - **`P3-07`** (SAF import of `.attendiq` and `.json` via `file_picker`), **`P3-08`** (legacy `v1` backup import via SAF), **`P3-11`** (`content://` URIs cached by `FilePickerUtils` and never passed directly to `dart:io File`), **`P5-01`–`P5-06`** (JSON/UTF-8 validation, `Merge` & `Replace` restore, failed-import DB preservation across SAF imports), and **`P7-01`–`P7-03`** (live `FilePicker` / crash `logcat` capture across API `28`, `29`, and `34` debug & release builds).
- **Historical baseline checks NOT rerun after the Dart-only picker fix (unchanged since `fbf4055`):**
  - **`P2-R01`–`P2-R05`** (standalone smoke/Backup Manager listing focus), **`P3-01`–`P3-06`** (export `.attendiq`, `ACTION_CREATE_DOCUMENT`, SAF cancel, unavailable SAF fallback), **`P3-09`** (`Open File`), **`P3-10`** (`Share File`), **`P4-01`–`P4-11`** (MediaStore export, `IS_PENDING`, duplicate naming, `export_share/` cleanup), and **`P6-01`–`P6-06`** (`HOME` backgrounding, `always_finish_activities=1`, `am force-stop`, `adb reboot`).

### 8.6 Remaining Separate Watchpoints & Scope Boundaries

1. **Separate UX Watchpoint (`P3-09` Watchpoint #2 — `MainActivity.openExportContentUri`):** Wrapping `ACTION_VIEW` in `Intent.createChooser(...)` in [`MainActivity.kt`](../../android/app/src/main/kotlin/com/ramsa/attendiq/attend_iq/MainActivity.kt#L349-L357) displays Android's system chooser (`"No apps can perform this action."`) for `.attendiq` instead of throwing `ActivityNotFoundException` to trigger the Dart SnackBar fallback. Left untouched per `MainActivity.kt` restriction; non-crashing UX improvement.
2. **Home Screen Widgets Runtime Verification (`BUG-027` / `SUSP-003`):** Home Screen Widget runtime behavior and beta deep-link routing remain tracked separately under [`BUG_AUDIT.md`](BUG_AUDIT.md) (`BUG-027` / `SUSP-003`) and are **not** claimed complete under `SUSP-001`.
