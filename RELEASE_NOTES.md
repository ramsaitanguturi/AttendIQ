# Release Notes - AttendIQ

## Version: v1.1.0 🚀

We are excited to present the production-ready release of **AttendIQ**, a smart attendance tracker and academic advisor built for college students. This version introduces key functionality for offline logging, real-time math predictions, and automated class schedule generation, coupled with AI-driven advisor recommendations.

---

## 🌟 Key Features

*   **Smart Attendance Tracking**: Easily log and edit class status (Present, Absent, Late, Cancelled, Extra Present, Extra Absent) with swift swipe gestures or calendar taps.
*   **Predictive Calculations**: Real-time forecasting algorithms calculate how many classes can be safely skipped or how many consecutive classes must be attended to restore target thresholds.
*   **Weekly Timetable Planner**: Establish recurring class grids with automatic collision detection to prevent overlapping slots.
*   **Smart Notifications**: Background worker manages rolling local alerts, low attendance thresholds, and weekly digests.
*   **AI Academic Advisor**: Leverage Gemini AI integration to receive tailored strategies based on schedule density and current stats (with rule-based fallback if offline).

---

## 🛠️ Technical Highlights

*   **Clean Architecture & Feature-First**: Extremely modular, maintainable, and decoupled codebase divided cleanly into core layers (Domain, Data, Presentation).
*   **Offline-First Sync Engine**: ACID-compliant Isar local persistence combined with a robust Outbox queue that syncs with Cloud Firestore dynamically upon reconnect.
*   **Reactive State Management**: State is handled reactively using Riverpod providers and code-generators.
*   **Unit & Widget Test Coverage**: Core math calculators are backed by 100% unit test coverage to guarantee precision.
*   **Secure API Integrations**: Gemini API and Firebase keys are resolved dynamically using compile-time properties, preventing any secrets from exposure.
