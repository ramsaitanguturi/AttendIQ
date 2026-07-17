# AttendIQ Release Checklist

Use this checklist to prepare and verify AttendIQ for production releases.

---

## Before Release

- [ ] **Tests Pass**: Run the test suite using `flutter test` and confirm 0 failures.
- [ ] **Static Analysis**: Run `flutter analyze` and confirm 0 errors or warnings.
- [ ] **Firebase Rules Verified**: Ensure Firestore rules are deployed to Firestore Console (refer to `docs/FIREBASE_SECURITY.md`).
- [ ] **API Keys Removed**: Verify that no keys are hardcoded in the repository (e.g. check `gemini_ai_provider.dart` and `ai_chat_controller.dart` only consume `const String.fromEnvironment('GEMINI_API_KEY')`).
- [ ] **Version Updated**: Update version name and build number in `pubspec.yaml` (e.g. `version: 1.0.0+1`).

---

## Android Release

### Compiling Release Binaries
1. **Build APK**:
   ```bash
   flutter build apk --flavor prod -t lib/main.dart --release
   ```
2. **Build App Bundle (AAB)** (required for Google Play Store upload):
   ```bash
   flutter build appbundle --flavor prod -t lib/main.dart --release
   ```

### Signing Configuration
1. Generate a upload keystore (if not already done):
   ```bash
   keytool -genkey -v -keystore C:\Users\ramsa\Desktop\AttendIQ\android\app\upload-keystore.jks -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties` (never commit this file to Git):
   ```properties
   storePassword=<your-store-password>
   keyPassword=<your-key-password>
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```
3. Ensure signing configs in `android/app/build.gradle` read `key.properties` dynamically to sign the release build.

---

## Store Preparation

- [ ] **App Screenshots**: Prepare high-res screenshots for 6.5" and 5.5" phones.
- [ ] **App Description**: Draft short description (max 80 chars) and full description (max 4000 chars).
- [ ] **Privacy Policy**: Link to the host privacy policy URL.
- [ ] **Feature List**: Summarize key highlights:
  - Smart Attendance Logging (Present, Absent, Late, Cancelled)
  - Weekly Schedule Timetable Grid with automated event generation
  - Analytics Dashboard (percentage tracking, bunk forecasting)
  - Cloud Synchronization (ACID-compliant offline outbox queue)
  - Automated Notifications (pre-class reminders, weekly reports)
  - AI Generative Advisor (Gemini integration with local offline rules engine)
