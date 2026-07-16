# Technology Stack: AttendIQ

This document lists the specific technologies, versions, packages, and tools selected for the development of AttendIQ.

---

## 1. Core Platform & SDK Requirements

| Component | Technology | Version / Range | Description |
|---|---|---|---|
| Framework | **Flutter** | `>= 3.22.0` | Cross-platform UI development framework |
| Language | **Dart** | `>= 3.4.0` | Object-oriented client-optimized language |
| Target Platforms | **iOS** | `>= 13.0` | Core deployment target for Apple devices |
| Target Platforms | **Android** | `Min SDK 21, Target SDK 34` | Android Lollipop to Android 14 compatibility |

---

## 2. Core Dependencies (pubspec.yaml)

### 2.1 State Management & Routing
- **`flutter_riverpod` (v2.5.x)**: Comprehensive state management and caching framework.
- **`riverpod_annotation` (v2.3.x)**: Annotations for Riverpod code generation.
- **`go_router` (v14.x.x)**: Declarative routing system supporting nested navigation (App Shell structure).

### 2.2 Local Database (Offline-First)
- **`isar` (v4.0.0-dev.14+)**: Ultra-fast NoSQL database with native relations.
- **`isar_flutter_libs` (v4.0.0-dev.14+)**: Native library bindings for running Isar on mobile targets.

### 2.3 Backend Integration (Firebase)
- **`firebase_core` (v3.x.x)**: Initializer for Firebase services.
- **`cloud_firestore` (v5.x.x)**: Cloud document database client.
- **`firebase_auth` (v5.x.x)**: User management and authentication.
- **`google_sign_in` (v6.x.x)**: OAuth client for Google Authentication.
- **`firebase_messaging` (v15.x.x)**: Remote push notification handler.

### 2.4 AI Integration
- **`google_generative_ai` (v0.4.x)**: First-party Dart client for Gemini API, enabling the AttendIQ AI Advisor.

### 2.5 Utilities & Networking
- **`connectivity_plus` (v6.x.x)**: Stream internet connectivity changes (Mobile, WiFi, None) to trigger synchronization.
- **`workmanager` (v0.5.x)**: Native Android/iOS background task runner for periodic sync execution.
- **`uuid` (v4.x.x)**: Generate unique local document identifiers mapping to Firestore IDs.

### 2.6 UI & Animations
- **`google_fonts` (v6.x.x)**: Dynamically loads the *Outfit* and *Inter* font weights.
- **`fl_chart` (v0.68.x)**: High-performance line and bar chart rendering.
- **`lucide_icons` (v0.370.x)**: Consistent vector icon set.
- **`shimmer` (v3.x.x)**: Skeleton loading states for widgets.
- **`animations` (v2.x.x)**: Pre-built Material motion transitions (open/container transforms).

---

## 3. Development & Generation Tools (dev_dependencies)

Because we use code-generation packages, the `build_runner` compiler is mandatory.

- **`build_runner`**: Tool to compile code annotations into generated files.
- **`riverpod_generator`**: Auto-generates type-safe providers, dependencies, and autodispose logic.
- **`isar_generator`**: Compiles Isar schemas (`@collection`) into database adapters.
- **`json_serializable`**: Auto-generates `toJson()` and `fromJson()` mappings for DTO models.
- **`mocktail`**: Mocking framework for unit testing.
- **`flutter_lints`**: Standard Flutter lint configurations (customized via `analysis_options.yaml`).
