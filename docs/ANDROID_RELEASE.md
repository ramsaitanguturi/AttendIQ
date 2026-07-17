# Android Release & Signing Guide: AttendIQ

This document guides developers through the process of generating an upload keystore, configuring Gradle for release builds, and executing compilation commands to build production-ready Android artifacts (APKs and App Bundles).

---

## 🔑 1. Generate an Upload Keystore

To sign your release application for submission to the Google Play Store, you need a Java Keystore (`.jks` or `.keystore` file). 

If you do not have an existing keystore, generate one using the `keytool` command-line utility (pre-packaged with the Java Development Kit):

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -storetype PKCS12 -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

During keystore generation, you will be prompted to:
1.  Create and confirm a secure password (for both the keystore itself and the key alias).
2.  Provide organizational information (name, department, company, city, state, country).

> [!WARNING]
> Keep your keystore password secure and back up the `upload-keystore.jks` file. If you lose this key, you will not be able to publish updates to existing listings on the Google Play Store.

---

## 📝 2. Configure Signing Credentials

We use a local, un-tracked properties file `android/key.properties` to map keystore credentials into the build runner. This avoids hardcoding passwords or committing credentials to source control.

### Step 2.1: Create `key.properties`
Create a new file named `android/key.properties` (this file is ignored by Git through `.gitignore`).

Add the following configuration lines:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD_HERE
keyPassword=YOUR_ALIAS_PASSWORD_HERE
keyAlias=upload
storeFile=upload-keystore.jks
```

### Step 2.2: Ensure Gradle Integration
The `android/app/build.gradle` file is pre-configured to look for `key.properties`. If found, it reads these keys to sign release builds using the `release` configuration:

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias = keystoreProperties['keyAlias']
            keyPassword = keystoreProperties['keyPassword']
            storeFile = keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword = keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.release
            } else {
                signingConfig = signingConfigs.debug
            }
        }
    }
}
```

---

## 🚀 3. Build Commands

After setting up the properties and ensuring the keystore file (`upload-keystore.jks`) is in the `android/app/` directory, compile the release assets:

### 1. Build Android App Bundle (AAB)
This is the preferred format for publishing on Google Play Store, as Google uses it to generate optimized split APKs for different device architectures:
```bash
flutter build appbundle --release --dart-define=GEMINI_API_KEY="YOUR_API_KEY"
```

### 2. Build Single Release APK
Useful for testing staging builds on physical test devices directly without store delivery:
```bash
flutter build apk --release --dart-define=GEMINI_API_KEY="YOUR_API_KEY"
```

The compiled binaries will be output to:
*   **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`
*   **APK**: `build/app/outputs/flutter-apk/app-release.apk`

---

## 🛠️ 4. Troubleshooting JDK & Gradle Compatibility

If you run into compilation errors such as `Unsupported class file major version 68` when executing Gradle tasks or building the app, it means your default system Java version (e.g. Java 24) is incompatible with the project's Gradle version (Gradle 7.6.3).

To resolve this:
1. Ensure Java 17 is installed (e.g., Eclipse Adoptium JDK 17).
2. Set your `JAVA_HOME` environment variable to Java 17 in your terminal session before running build commands:
   ```powershell
   $env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot"
   ```
3. Configure the Flutter SDK to use this JDK:
   ```bash
   flutter config --jdk-dir "C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot"
   ```

