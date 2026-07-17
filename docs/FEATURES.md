# Features Catalog: AttendIQ

This document lists the detailed feature set, functionalities, user behaviors, inputs, and outputs planned for the AttendIQ application.

---

## 1. Onboarding & Session Setup

### Description
Guides newly authenticated users through the initial configuration of their academic profile. This is a critical standalone feature designed to gather semester variables and set up their first set of subjects before they access the core dashboard.

### Requirements
- **First-Time Flow Trigger**: Detects if the logged-in user has no `Semester` rows stored in Isar. If none exist, the app forces redirection to the Onboarding Flow and blocks dashboard access.
- **Step 1: Active Semester Definition**:
  - Semester Name input (e.g. "Semester 5" or "Fall 2026").
  - Date Boundaries selection (Start Date and End Date calendars).
  - Target Attendance Percentage Slider (e.g., defaults to 75%, adjustable from 50% to 100%).
- **Step 2: Subject Registration**:
  - Guided list builder to add at least 3 initial subjects (fields: Name, Course Code, Credits, UI Color theme).
- **Session Caching**: Caches Firebase authentication tokens and profiles locally inside the Isar database. Allows subsequent launches to bypass the splash authentication checks instantly and work offline.

---

## 2. Semester & Subject Management

### Description
Allows students to manage their active semesters and individual courses. All attendance math is scoped to the active semester.

### Requirements
- **Semester Operations**: Create, Read, Update, Delete (CRUD) semester parameters. Semesters cannot overlap in dates.
- **Subject Operations**: CRUD within a Semester.
- **Subject Fields**:
  - Name (e.g., "Mathematics IV")
  - Course Code (e.g., "MTH401")
  - Instructor (e.g., "Dr. Alan Turing")
  - Credit hours (e.g., 4) - used for weightings in GPA/attendance calculations.
  - Required Attendance Override (optional, e.g., 85% instead of the default 75% semester target).
  - Theme Color Hex: Hex color for UI progress indicators and calendar events.

---

## 3. Weekly Timetable & Timetable-to-Event Generator

### Description
Defines the base weekly class template and automates the creation of check-in events in the database.

### Requirements
- **Weekly Scheduler Template**: Grid editor to configure recurring classes for Monday through Sunday.
- **Time Slot fields**: Subject, start time, end time, and room name/number.
- **Collision Detection**: Prevent overlapping slots.
- **Timetable-to-Event Generator**:
  - Converts static recurring slot templates into physical database logs (`AttendanceRecord` with status = `unlogged`).
  - **Generation Window**: Operates on a **rolling 14-day window** (generates events 7 days in the past to catch unlogged dates and 7 days in the future to show upcoming calendars).
  - **Triggers**: Executed on onboarding complete, timetable edits, and daily app launches.
  - **Unlogged Event Behavior**: Generated events default to status `"unlogged"`. Unlogged events are excluded from the attendance percentage math, but are flagged on the Today Page to prompt logs.

---

## 4. Attendance Logger

### Description
The user transaction system to log check-in metrics.

### Requirements
- **Status Selection**: Present, Absent, Late, Cancelled, Extra Class.
- **Quick Logging**: Swipe right to mark Present, swipe left to mark Absent directly from the Today dashboard carousel.
- **Calendar Logging**: Tap days on the monthly calendar to add/modify logs retrospectively.
- **Extra Class Logging**: Manually log an unscheduled class occurrence (counted towards attendance rates).
- **Remarks Field**: Attach optional text notes to any record (e.g., "Late due to rain").

---

## 5. Safe Bunk & Must-Attend Calculators

### Description
Real-time mathematical trackers that calculate safety margins.

### Requirements
- **Safe Bunk Calculator**:
  - Displays the consecutive number of classes a student can skip without falling below the target.
  - Interactive simulator slider: "If I miss the next X classes, my attendance will be Y%."
- **Must-Attend Calculator**:
  - Computes the minimum number of consecutive classes a student must attend to restore their eligibility.
  - Handles the target rate boundary condition ($100\%$ target yields a warning that $100\%$ is mathematically unreachable if a class is missed).

---

## 6. Advanced Analytics & Predictions

### Description
Draws progress rings, charts, and forecasts.

### Requirements
- **Progress Ring**: Dashboard percentage ring colored based on target (Green = Safe, Yellow = Warn, Red = Danger).
- **Trend Charts**: FL Chart rendering weekly changes in attendance rates.
- **End-of-Semester Forecast**: Projects the user's recent 30-day attendance habits onto the remaining scheduled class list to project their final percentage.

---

## 7. AI Attendance Advisor (Post-Core Feature)

### Description
An interactive, generative AI advisor that acts as a personalized scheduler.
> [!IMPORTANT]
> The AI Advisor is scheduled for development **strictly after all core features are completed and verified** (Phase 4).

### Requirements
- **Context Packager**: Packages schedule templates, subject list stats, and exam dates to a structured JSON context.
- **Gemini Core Connector**: Securely transceives context to the Gemini 1.5 Flash endpoint, receiving structured recommendation cards.
- **Local Fallback Heuristics**: If the system is offline, a local rule-based advisor automatically parses Isar and renders warnings locally without hitting remote APIs.

---

## 8. Smart Notifications & Reminders

### Description
Delivers contextual check-in notifications and warning indicators. The notification engine is designed to adapt to operating system limitations.

### Requirements
- **Rolling Notification Scheduler**:
  - Because iOS/Android restrict active scheduled alerts to a maximum of 64, the app uses a **rolling 7-day scheduled notifications queue**.
  - Background workers reset and schedule alerts for the upcoming 7 days on app launch, timetable changes, or sync events.
- **Before-Class Reminders**: Push notification alarm triggered 5 minutes before a scheduled class. Tapping the reminder launches the app directly to the Today log view.
- **Bunk Threshold Warning**: Notification triggered if a logging event drops a subject's rate within 2.5% of the target threshold.
- **Sunday Weekly Digest**: Fires on Sunday evenings, summarizing the week's statistics and predicting safe bunks for the upcoming week.
