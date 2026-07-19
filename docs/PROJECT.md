# Project Specification: AttendIQ

AttendIQ is an offline-first student attendance tracking, forecasting, and AI-driven advisory application. It aims to eliminate academic penalties resulting from low attendance by giving college and university students real-time analytics, prediction formulas, and contextual academic recommendations.

---

## 1. Product Vision

Many colleges and universities enforce a strict attendance threshold (typically 75% or 80%). Falling below this threshold can result in course failure, loss of exam eligibility, or grade reduction. 
Students currently lack tools to:
1. Track their attendance status accurately in an offline environment (e.g., inside lecture halls with poor mobile coverage).
2. Calculate exactly how many classes they can safely skip ("bunk") without dropping below the threshold.
3. Determine how many consecutive classes they need to attend to restore their status if they fall below the threshold.
4. Forecast final attendance based on historical behavior and remaining schedule.
5. Get smart, automated guidance when schedules, exams, and attendance overlap.

AttendIQ fills this gap by combining an offline-first mobile app with mathematical trackers and a local AI advisor.

---

## 2. User Personas

### Persona A: The Borderline Student (e.g., Rohan)
- **Goal**: Maintain exactly the minimum required attendance (e.g., 75%) to balance college projects, internships, or personal life.
- **Pain Point**: Rohan has to manually estimate how many classes he can miss before an exam or interview. One wrong calculation could bar him from examinations.
- **Key Feature Used**: Safe Bunk Calculator, Push Alerts.

### Persona B: The Struggling Student (e.g., Sarah)
- **Goal**: Recover attendance after falling sick or missing two weeks of college.
- **Pain Point**: Needs to know the exact number of consecutive classes she must attend to reach eligibility, and which subjects to prioritize.
- **Key Feature Used**: "Must Attend" Calculator, Priority Analytics.

### Persona C: The Scheduled Student (e.g., Kevin)
- **Goal**: See a unified dashboard of his week, log attendance in one tap, and get a prediction of his final grades/attendance.
- **Pain Point**: Heavy schedule changes, extra classes, and cancelled classes make paper/spreadsheet trackers obsolete.
- **Key Feature Used**: Interactive Timetable, Attendance Forecaster.

---

## 3. Core Business & Mathematical Rules

To ensure mathematical precision, AttendIQ uses standardized definitions and formulas for all tracking metrics.

### 3.1 Attendance Status Definitions
Each scheduled class occurrence can be marked with one of five statuses:
- **Present**: The student attended the class.
- **Absent**: The student missed the class.
- **Late**: The student arrived late. (In settings, users can configure if Late counts as a full Present, an Absent, or a fractional attendance, e.g., 0.5 Present. Default is 1.0 / Present).
- **Cancelled**: The instructor did not conduct the class. This occurrence is excluded from calculations.
- **Extra Class**: An unscheduled class conducted. This increments both the attended and total counts.

### 3.2 Key Formulas

#### Formula 1: Current Attendance Percentage ($P$)
Let $A_{p}$ be the count of Present classes, $A_{a}$ be the count of Absent classes, and $A_{l}$ be the count of Late classes.
Let $W_{l}$ be the configured weight of a Late attendance ($0.0 \le W_{l} \le 1.0$, default is $1.0$).

$$P = \left( \frac{A_{p} + (A_{l} \times W_{l})}{A_{p} + A_{a} + A_{l}} \right) \times 100$$

*Note: Cancelled classes do not enter this calculation. Extra classes increase the numerator and denominator normally if present/absent.*

#### Formula 2: Safe Bunk Calculator ($B_{safe}$)
Given a target attendance threshold $T$ (expressed as a percentage, e.g., $75$), $B_{safe}$ calculates how many **consecutive future classes** a student can miss (bunk) without their attendance percentage dropping below $T$.

Let $A_{effective\_present} = A_{p} + (A_{l} \times W_{l})$ and $A_{total} = A_{p} + A_{a} + A_{l}$.

$$B_{safe} = \left\lfloor \frac{100 \times A_{effective\_present} - T \times A_{total}}{T} \right\rfloor$$

- If $B_{safe} > 0$, the student can safely bunk $B_{safe}$ classes.
- If $B_{safe} = 0$, the student cannot bunk any class.
- If $B_{safe} < 0$, the student is already below the threshold, and this metric is invalid (displaying "0").

#### Formula 3: "Must Attend" Calculator ($A_{req}$)
If the student's current attendance percentage is below the target threshold $T$, $A_{req}$ calculates how many **consecutive future classes** they must attend to bring their percentage back up to $T$.

$$A_{req} = \left\lceil \frac{T \times A_{total} - 100 \times A_{effective\_present}}{100 - T} \right\rceil$$

- *Edge Case*: If $T = 100$ and $A_{effective\_present} < A_{total}$, it is mathematically impossible to reach 100% attendance again. The app will catch this and display "N/A" (or state that 100% is unreachable).

#### Formula 4: Attendance Forecast / Prediction ($P_{predicted}$)
To project what a student's final attendance will be at the end of the semester, we look at historical attendance and the remaining schedule.

Let:
- $R$ = Remaining scheduled classes for the subject in the semester (calculated as `weeks_remaining * classes_per_week - known_holidays`).
- $R_{recent}$ = Recent attendance rate (percentage of classes attended in the last 30 days. If the student has less than 10 classes logged, fallback to the overall lifetime attendance rate $P/100$).

$$A_{predicted\_present} = A_{effective\_present} + (R \times R_{recent})$$
$$A_{predicted\_total} = A_{total} + R$$

$$P_{predicted} = \left( \frac{A_{predicted\_present}}{A_{predicted\_total}} \right) \times 100$$

---

## 4. Scope and Exclusions

### In Scope
- 100% offline-first logging of subject attendance.
- Customizable subject thresholds, weightings for late attendance, and timetables.
- Visual status dashboards (charts, trends, cards).
- Algorithmic predictions (forecasts, safe bunks).
- Complete database backup and restore engine (.attendiq).
- Local AI Advisor analyzing student schedule and statistics.

### Out of Scope
- User accounts, registration, login, or cloud sync.
- Automated integration with official university attendance systems. All inputs are logged by the student.
- Complex professor dashboard (AttendIQ is exclusively client-facing for students).
