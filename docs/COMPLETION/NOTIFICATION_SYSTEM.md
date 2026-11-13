# AttendIQ Notification Subsystem — Production Specification & Completion Report

## 1. Overview & Architecture

The AttendIQ Notification Subsystem is an offline-first, highly reliable background scheduling and action-handling engine designed to guarantee class punctuality, attendance accuracy, and proactive academic management.

### Key Capabilities
- **Deterministic 32-bit Android Notification IDs**: Generated deterministically from canonical occurrence keys or hash codes, completely preventing ID collisions, integer overflows, or task ID overwrites.
- **Interactive Action Buttons (Headless & Foreground)**:
  - `PRESENT`
  - `LATE`
  - `ABSENT`
  - `CANCELLED`
- **Headless Background Execution**: Supported via `@pragma('vm:entry-point') void notificationTapBackground(NotificationResponse response)` and `NotificationActionHandler`, updating real Isar database occurrences and attendance records atomically even when the Flutter UI is terminated.
- **Unanswered Class Check-In Persistence**: Android OS notifications swiped away or cleared by system-level "Clear all" do not delete pending attendance entries. An internal persistent `PendingCheckInService` tracks all past unrecorded scheduled classes and presents them via reactive UI banners and calendar badges.
- **Graceful Android 14+ Degradation**: Automatically catches `SecurityException` when `SCHEDULE_EXACT_ALARM` is restricted, immediately falling back to inexact alarms and notifying the user.

---

## 2. Notification Data Flow

```
[Local Database / Weekly Rules]
           │
           ▼
[NotificationScheduler.rescheduleRollingWindow()]
           │
           ▼ (Enriched body: Subject, Time, Room, Safe Bunks / Target %)
[LocalNotificationServiceImpl.scheduleNotification()]
           │
           ▼ (Android System Tray: Action Buttons)
     ┌─────┴──────────────────┐
     ▼                        ▼
[Foreground Tap]       [Background Action Tap]
     │                        │
     ▼                        ▼
[NotificationActionHandler.handleAction()]
     │
     ├─► 1. Atomically materialize DailyScheduleOccurrenceLocal
     ├─► 2. Persist AttendanceRecordLocal (PRESENT / LATE / ABSENT / CANCELLED)
     ├─► 3. Invalidate Subject & Semester Analytics Providers
     └─► 4. Refresh Android Home Screen AppWidgets
```

---

## 3. Action Buttons & Payload Specification

### Payload Structure
Payloads are transmitted as JSON strings or canonical slot keys:
```json
{
  "occurrenceId": 42,
  "slotKey": "REGULAR|sub:101|20261115|09:00-10:00",
  "subjectId": 101,
  "date": "2026-11-15T00:00:00.000Z",
  "startTime": "09:00",
  "endTime": "10:00",
  "title": "Compiler Design",
  "room": "Lab 3"
}
```

### Action Processing Logic
- `ACTION_PRESENT`: Occurrence marked `PRESENT`, `AttendanceRecordLocal` inserted with status `PRESENT`.
- `ACTION_LATE`: Occurrence marked `LATE`, `AttendanceRecordLocal` inserted with status `LATE` (weighted according to user policy).
- `ACTION_ABSENT`: Occurrence marked `ABSENT`, `AttendanceRecordLocal` inserted with status `ABSENT`.
- `ACTION_CANCELLED`: Occurrence marked `CANCELLED`, any active `AttendanceRecordLocal` soft-deleted so it does not penalize student statistics.
- **Debounce Guard**: 2000ms in-memory cache per slotKey prevents accidental double-tap processing.

---

## 4. Pending Check-Ins Subsystem

### Service Contract: `PendingCheckInService`
- **Lookback Window**: Default 7 days (configurable).
- **Suppression Filter**: Holiday exceptions and cancelled timetable exceptions automatically suppress pending alerts.
- **Reactive UI**: `pendingCheckInsProvider` streams live updates to `PendingCheckInsBanner` and `DateDetailsBottomSheet`.

---

## 5. Test Verification

| Test Suite | Coverage | Status |
|---|---|---|
| `notification_action_handler_test.dart` | Action buttons, atomic Isar writes, payload decoding, debouncing | **PASS (5/5)** |
| `notification_persistence_test.dart` | 32-bit ID generation, deduplication, restart survival | **PASS (9/9)** |
| `notification_lifecycle_test.dart` | Stream coalescing, listener disposal, exact alarm fallback | **PASS (14/14)** |
| `pending_check_in_service_test.dart` | Past unrecorded classes, holiday suppression, resolution | **PASS (3/3)** |

