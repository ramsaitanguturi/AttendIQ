# AttendIQ Historical Attendance Editing — Architecture & Verification

## 1. Requirement & Purpose

Students frequently need to record or correct attendance records on past dates (e.g. retroactive marking of forgotten classes, medical absence updates, cancelled lectures, or late arrivals). 

AttendIQ provides a unified, centralized attendance mutation architecture that allows editing any scheduled or unrecorded class across the entire active semester while guaranteeing immediate recalculation of all statistics, analytics, risk indicators, and home screen widgets.

---

## 2. Architecture: Centralized Mutation Service

Historical attendance changes must **never** be implemented independently in UI screens. AttendIQ channels all modifications through `HistoricalAttendanceService` (`lib/features/attendance/domain/services/historical_attendance_service.dart`) and `AttendanceController.markHistoricalAttendance(...)`.

```
[Calendar Bottom Sheet / Date View]
                 │
                 ▼
[AttendanceController.markHistoricalAttendance()]
                 │
                 ▼
[HistoricalAttendanceService.setAttendanceStatus()]
  ├─► Normalize Date (UTC Midnight)
  ├─► Find or Materialize DailyScheduleOccurrenceLocal
  ├─► Update Occurrence Status & Record updatedAt Timestamp
  ├─► Upsert / Soft-delete AttendanceRecordLocal in Isar
  └─► Return updated DailyScheduleOccurrence
                 │
                 ▼
[Invalidate UI & Analytical Providers]
  ├─► todayScheduleProvider & dayScheduleByKeyProvider
  ├─► allDailyOccurrencesProvider & monthlyCalendarDataProvider
  ├─► subjectAttendanceStatsProvider & allSubjectAttendanceStatsProvider
  ├─► overallAttendancePercentageProvider
  ├─► analyticsControllerProvider & attendanceAnalyticsProvider
  ├─► pendingCheckInsProvider
  └─► WidgetRefreshService.refreshAllWidgets()
```

---

## 3. Transition Matrix & Edge Cases

| Initial Status | Target Action | Occurrence Status | Attendance Record Action |
|---|---|---|---|
| **Unrecorded / Virtual Rule** | Present | `PRESENT` | Create new record (`status: PRESENT`, `markedAt: date`) |
| **Unrecorded / Virtual Rule** | Late | `LATE` | Create new record (`status: LATE`, `markedAt: date`) |
| **Unrecorded / Virtual Rule** | Absent | `ABSENT` | Create new record (`status: ABSENT`, `markedAt: date`) |
| **Unrecorded / Virtual Rule** | Cancelled | `CANCELLED` | No record created (or deleted) |
| **Present** | Absent | `ABSENT` | Update record status to `ABSENT` |
| **Present** | Late | `LATE` | Update record status to `LATE` |
| **Present** | Cancelled | `CANCELLED` | Soft-delete record (`isDeleted: true`) |
| **Absent** | Present | `PRESENT` | Update record status to `PRESENT` |
| **Absent** | Late | `LATE` | Update record status to `LATE` |
| **Absent** | Cancelled | `CANCELLED` | Soft-delete record (`isDeleted: true`) |
| **Late** | Present | `PRESENT` | Update record status to `PRESENT` |
| **Late** | Absent | `ABSENT` | Update record status to `ABSENT` |
| **Cancelled** | Present | `PRESENT` | Create or restore record (`status: PRESENT`) |
| **Any** | Reset (Unmarked) | `UPCOMING` | Delete record, restore occurrence to `UPCOMING` |

---

## 4. UI/UX Implementation in `DateDetailsBottomSheet`

1. **Smoked-Glass Class Cards**: Each scheduled class on the selected date is displayed as an individual card with:
   - Subject Title, Time range, and Room number.
   - Distinct color-coded status badge (`PRESENT` [Green], `LATE` [Amber], `ABSENT` [Red], `CANCELLED` [Grey], `UNMARKED` [Muted]).
   - Display of original status if modified.
2. **Interactive Action Bar**: Compact, touch-friendly buttons (`[Present]`, `[Late]`, `[Absent]`, `[Cancel]`, `[Undo]`) with selected state highlights.
3. **Reactive Re-rendering**: The bottom sheet observes `monthlyCalendarDataProvider`, immediately updating its UI upon state changes without closing or flickering.

---

## 5. Verification & Test Evidence

Verified via real Isar database suite `test/features/historical_attendance_test.dart`:
- `Unrecorded scheduled class modifies to PRESENT`: **PASS**
- `Full status transition cycle (Present -> Absent -> Late -> Cancelled -> Present)`: **PASS**
- `Unrecorded past class modifies directly to ABSENT or CANCELLED`: **PASS**
- `Modification timestamps are accurately recorded`: **PASS**

