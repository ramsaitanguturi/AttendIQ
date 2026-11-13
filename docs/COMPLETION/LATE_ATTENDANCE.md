# AttendIQ Late Attendance Implementation — Design & Mathematical Specification

## 1. Requirement & Overview

Academic institutions and universities handle late arrivals in diverse ways:
1. Some institutions treat Late as an affirmative attendance (full credit: 1.0).
2. Others treat Late as an absence (zero credit: 0.0).
3. Many adopt a weighted credit policy (e.g., 0.5 or 50% credit per late session).

AttendIQ supports all three paradigms cleanly, natively integrating Late attendance into domain entities, database persistence, calculation algorithms, analytical models, and UI controls.

---

## 2. Mathematical Attendance Model

Let:
- $P$ = Total Present count (including Extra Present)
- $A$ = Total Absent count (including Extra Absent)
- $L$ = Total Late count
- $W_l \in [0.0, 1.0]$ = Configured weight for late attendance (default: $0.5$)
- $C$ = Cancelled classes (excluded from total sessions)

### Effective Attended Sessions ($A_{eff}$)
$$A_{eff} = P + (L \times W_l)$$

### Total Conducted Sessions ($S_{total}$)
$$S_{total} = P + A + L$$

### Attendance Percentage ($\%$)
$$\% = \begin{cases} 
100.0 & \text{if } S_{total} == 0 \\
\min\left(100.0, \frac{A_{eff}}{S_{total}} \times 100\right) & \text{if } S_{total} > 0
\end{cases}$$

---

## 3. Implementation Details

### Domain & Data Model
- `AttendanceStatus.LATE` added to `lib/features/attendance/domain/entities/attendance_record.dart`.
- `OccurrenceStatus.LATE` added to `lib/features/timetable/domain/entities/daily_schedule_occurrence.dart`.
- `UserPreferencesLocal`:
  - `lateAttendanceWeight`: `double` (clamped $0.0$ to $1.0$, default $0.5$).
  - `lateAttendancePolicy`: `String` (`'weighted'`, `'present'`, `'absent'`).

### Attendance & Analytics Engines
- `AttendanceCalculator.calculatePercentage(num attended, num total)` updated to accept `num` types, seamlessly handling fractional attended totals ($A_{eff}$).
- `AnalyticsCalculator` updated across subject-level and semester-level computations:
  - `SubjectAnalytics` records `lateCount` and applies `lateWeight`.
  - `AttendanceAnalytics` computes overall semester attendance percentage using aggregated effective attended sessions.
- `subjectAttendanceStatsProvider` recalculates stats with the active user's weight policy.

### User Interface Controls
- **Settings Page**: Interactive slider (10% to 90%) and dropdown selector (`Weighted`, `Full Present`, `Absent`).
- **Class Action Buttons**: Added `Late` [Amber] button to:
  - Android Notifications (System Tray)
  - `TodayScheduleCard` (Home/Dashboard)
  - `PendingCheckInsBanner`
  - `DateDetailsBottomSheet` (Academic Calendar)

---

## 4. Test Verification

Verified via `test/core/late_attendance_test.dart`:
- `AttendanceCalculator calculates fractional attended correctly`: **PASS**
- `AnalyticsCalculator incorporates late count with 0.5 weight`: **PASS**
- `AnalyticsCalculator treats late as full present when weight = 1.0`: **PASS**
- `AnalyticsCalculator treats late as absent when weight = 0.0`: **PASS**
- Notification action `ACTION_LATE` test in `notification_action_handler_test.dart`: **PASS**
- Historical editing test in `historical_attendance_test.dart`: **PASS**

