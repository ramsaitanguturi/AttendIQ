# Features Catalog: AttendIQ

This document lists the detailed feature set, functionalities, user behaviors, inputs, and outputs for the AttendIQ application.

---

## 1. Onboarding & Startup

### Description
Guides new users through the initial configuration of their first academic semester upon first launch.

### Requirements
- **First-Time Flow Trigger**: Detects if no `SemesterLocal` rows are stored in Isar. If none exist, the app directs the user to the Onboarding Flow.
- **Step 1: Active Semester Definition**:
  - Semester Name input (e.g. "Fall 2026").
  - Date Boundaries selection (Start Date and End Date calendars).
- **Step 2: Attendance Target**:
  - Target Attendance Percentage Slider (defaults to 75%, adjustable from 50% to 100%).
- **Step 3: Confirmation & Startup**:
  - Summary review card and instant transition to Dashboard.

---

## 2. Semester & Subject Management

### Description
Allows students to manage active semesters and individual courses. All attendance math is scoped to the active semester.

### Requirements
- **Semester Operations**: Create, Read, Update, Delete (CRUD) semester parameters.
- **Subject Operations**: CRUD within a Semester.
- **Subject Fields**:
  - Name (e.g., "Mathematics IV")
  - Course Code (e.g., "MTH401")
  - Instructor (e.g., "Dr. Alan Turing")
  - Credit hours (e.g., 4)
  - Attendance Target percentage
  - Theme Color Hex: Hex color for UI progress indicators and calendar events.

---

## 3. Weekly Timetable & Event Generator

### Description
Defines the base weekly class template and automates the creation of check-in events in the database.

### Requirements
- **Weekly Scheduler Template**: Grid editor to configure recurring classes for Monday through Sunday.
- **Time Slot fields**: Subject, start time, end time, room, faculty, and notes.
- **Collision Detection**: Real-time validation preventing overlapping slots.
- **Timetable-to-Event Generator**:
  - Converts static recurring slot templates into physical database logs (`EventLocal`).
  - **Generation Window**: Operates on a rolling window.
  - **Triggers**: Executed on onboarding completion, timetable edits, and app launches.

---

## 4. Attendance Logger

### Description
The user transaction system to log check-in metrics.

### Requirements
- **Status Selection**: Present, Absent, Late, Cancelled, Extra Class.
- **Quick Logging**: Swipe right to mark Present, swipe left to mark Absent directly from the Today dashboard carousel.
- **Calendar Logging**: Tap days on the monthly calendar to add/modify logs retrospectively.
- **Extra Class Logging**: Manually log an unscheduled class occurrence (counted towards attendance rates).

---

## 5. Safe Bunk & Must-Attend Calculators

### Description
Real-time mathematical trackers that calculate safety margins.

### Requirements
- **Safe Bunk Calculator**:
  - Displays the consecutive number of classes a student can skip without falling below the target.
- **Must-Attend Calculator**:
  - Computes the minimum number of consecutive classes a student must attend to restore eligibility.

---

## 6. Advanced Analytics & Predictions

### Description
Draws progress rings, charts, and forecasts.

### Requirements
- **Progress Ring**: Dashboard percentage ring colored based on target (Green = Safe, Red = Danger).
- **Trend Charts**: FL Chart rendering weekly changes in attendance rates.
- **End-of-Semester Forecast**: Projects recent attendance habits onto the remaining scheduled class list to project final percentage.

---

## 7. Backup & Restore Engine (.attendiq)

### Description
Comprehensive data ownership and backup framework operating 100% offline.

### Requirements
- **Export**: Packaging all Isar collections into a single JSON container file (`.attendiq`).
- **Import**: Select and validate backup version with choice of **Replace Existing Data** or **Merge Data**.

---

## 8. AI Attendance Advisor

### Description
An interactive advisor that acts as a personalized scheduler.

### Requirements
- **Context Packager**: Packages schedule templates, subject list stats, and attendance data.
- **Gemini Core & Local Fallback Heuristics**: Evaluates rules and provides guidance whether online or offline.

---

## 9. Smart Notifications & Reminders

### Description
Delivers contextual check-in notifications and warning indicators.

### Requirements
- **Rolling Notification Scheduler**: Rolling 7-day queue for class reminders and low attendance alerts.
