# Domain Rules: AttendIQ

This document defines the core, technology-agnostic business rules and mathematical constraints governing the AttendIQ application. These rules represent the logical model of the product and are independent of any database (Isar/Firestore), framework (Flutter), or backend provider (Firebase).

---

## 1. Attendance Rules

AttendIQ translates real-world class occurrences into discrete log records. Every log record belongs to a specific subject and has a designated attendance status.

### 1.1 Status Definitions & Numerical Weights

| Status | Code representation | Description | Numerical Weight ($W$) | Counts Towards Attended? | Counts Towards Total? |
|---|---|---|:---:|:---:|:---:|
| **Present** | `present` | The student attended the scheduled class. | $1.0$ | Yes | Yes |
| **Absent** | `absent` | The student missed the scheduled class. | $0.0$ | No | Yes |
| **Late** | `late` | The student arrived after the class started. | $W_l$ (Configurable) | Yes (Fractional) | Yes |
| **Cancelled** | `cancelled` | The instructor cancelled the class. | N/A | No | No |
| **Extra Present** | `extraClass` | An unscheduled class conducted and attended. | $1.0$ | Yes | Yes |
| **Extra Absent** | `extraClassAbsent` | An unscheduled class conducted but missed. | $0.0$ | No | Yes |
| **Unlogged** | `unlogged` | A pre-generated slot that has not yet been marked. | N/A | No | No |

### 1.2 Mathematical Foundations

To maintain absolute arithmetic consistency, the attendance calculations must satisfy the following definitions:

*   **Attended Classes Count ($A_{attended}$)**:
    $$A_{attended} = A_p + A_{ep} + (A_l \times W_l)$$
    Where:
    - $A_p$ is the count of `present` classes.
    - $A_{ep}$ is the count of `extraClass` (Extra Present) classes.
    - $A_l$ is the count of `late` classes.
    - $W_l$ is the late weight configuration ($0.0 \le W_l \le 1.0$, default is $1.0$).

*   **Total Classes Count ($A_{total}$)**:
    $$A_{total} = A_p + A_a + A_l + A_{ep} + A_{ea}$$
    Where:
    - $A_a$ is the count of `absent` classes.
    - $A_{ea}$ is the count of `extraClassAbsent` (Extra Absent) classes.

*   **Excluded Occurrences**:
    Classes marked as `cancelled`, `unlogged`, or designated as dynamic institutional `holidays` are excluded from both $A_{attended}$ and $A_{total}$ calculations.

*   **Current Attendance Percentage ($P$)**:
    $$P = \begin{cases} 
      100.0 & \text{if } A_{total} = 0 \\
      \left( \frac{A_{attended}}{A_{total}} \right) \times 100 & \text{if } A_{total} > 0 
   \end{cases}$$

---

## 2. Semester Rules

The semester acts as the temporal container for all subjects, schedules, and attendance logs.

*   **Semester Lifecycle**:
    A semester transitions through three states:
    1.  **Draft / Setup**: The metadata is defined, but the onboarding wizard has not finished. No attendance can be logged.
    2.  **Active**: The default semester loaded on dashboard entry. Timetable events are active, and attendance quick-logging is enabled. **Only one semester can be Active at any given time.**
    3.  **Archived**: Once the semester end date passes, or a new semester is activated, the old semester is marked as archived. Archived semesters are read-only; historical logs are locked against unintended changes.
*   **Start & End Date Constraints**:
    - A semester must possess a valid, non-null start date and end date.
    - The start date must precede the end date (`startDate < endDate`).
    - Semesters **cannot overlap in dates**. The system must reject the creation of a semester whose date boundaries cross an existing semester.
*   **Active Semester Boundaries**:
    Timetable event generation and notifications are strictly confined within the active semester's `[startDate, endDate]` interval.

---

## 3. Subject Rules

Subjects (courses) represent the academic modules monitored by the student.

*   **Subject Ownership**:
    Every subject is bound to exactly one semester. It cannot exist independently or span across multiple semesters.
*   **Target Customization**:
    By default, subjects inherit the target attendance percentage threshold of their parent semester. However, a student can configure a **subject-specific threshold override** (e.g., 85% instead of the semester's 75%) to account for stricter course regulations.
*   **Subject Deletion Rules**:
    - To prevent breaking historical stats, deleting a subject uses a **soft-delete** mechanism.
    - The subject is flagged as deleted (`isDeleted = true`) and hidden from active selectors and menus.
    - All previously recorded attendance logs for the subject are preserved in the database. This guarantees that overall semester averages, historical charts, and past digests remain mathematically accurate.

---

## 4. Event Rules

Events (attendance records) represent the concrete instances of classes on specific calendar dates.

*   **Timetable Template vs. Concrete Events**:
    - The weekly **Timetable** is a template defining recurring weekly class slots (e.g., "Math, Mondays at 9:00 AM").
    - **Events** are physical records generated in the database representing specific dates (e.g., "Math class on Monday, October 12, 2026").
*   **Event Creation**:
    Concrete events are generated automatically in a rolling window. Newly generated events default to the `unlogged` status.
*   **Event Modifications**:
    - A user can mutate the status of a generated event from `unlogged` to any active status (`present`, `absent`, `late`, `cancelled`).
    - Once logged, an event status can be changed retrospectively via the subject detail calendar.
    - **Extra Class Exceptions**: A user can manually inject a concrete event that has no corresponding weekly timetable template slot (e.g., a makeup class scheduled on a Saturday). This manually created record follows the rules of `extraClass` (Extra Present) or `extraClassAbsent` (Extra Absent).

---

## 5. Prediction Rules

Calculators run dynamically to provide safety margins and targets.

### 5.1 Safe Bunk Calculator ($B_{safe}$)

Calculates the maximum number of consecutive upcoming classes a student can skip (bunk) without their attendance dropping below the target threshold $T$ (expressed as a percentage, e.g. 75).

$$B_{safe} = \max\left(0, \left\lfloor \frac{100 \times A_{attended} - T \times A_{total}}{T} \right\rfloor\right)$$

*   If the calculated $B_{safe}$ is negative (meaning the current percentage is already below the target $T$), the rule evaluates to $0$.
*   If $A_{total} = 0$, $B_{safe} = 0$.

### 5.2 Must-Attend Calculator ($A_{req}$)

If the current percentage $P$ is below the target threshold $T$, calculates the minimum number of consecutive upcoming classes the student must attend to restore their attendance to $T$.

$$A_{req} = \begin{cases}
   0 & \text{if } P \ge T \\
   \text{N/A} & \text{if } T = 100 \text{ and } A_{attended} < A_{total} \\
   \left\lceil \frac{T \times A_{total} - 100 \times A_{attended}}{100 - T} \right\rceil & \text{if } P < T \text{ and } T < 100
\end{cases}$$

### 5.3 Attendance Warning Rules

To keep the student informed, warning heuristic checks are executed upon any logging write:
- **Low Margin Warning**: Triggered if $P \ge T$ but the margin is narrow: $P - T \le 2.5\%$. The UI must badge the subject as "Warning" and the notification service should recommend skipping no further classes.
- **Critical Status**: Triggered if $P < T$. The UI badges the subject as "Critical" or "Below Target" and displays the required consecutive attendance count $A_{req}$ prominently.
