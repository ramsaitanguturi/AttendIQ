# AI Advisor Architecture: AttendIQ

This document details the architectural design, API payload schemas, prompt guidelines, safety limits, and offline fallbacks for the **AttendIQ AI Advisor** feature powered by Gemini.

---

## 1. Overview & Data Context Flow

The AI Advisor acts as a virtual academic counselor. Rather than letting the student write arbitrary text prompts, we generate context packages programmatically and pass them to the LLM. This constraints the model to focus strictly on class prioritization, skip safety warnings, and schedule management advice.

```
┌─────────────────────────────────┐
│ User Local State:               │
│ - Timetable schedule            │
│ - Subject attendance logs       │
│ - Configured targets            │
│ - Upcoming exam dates (optional)│
└────────────────┬────────────────┘
                 │
                 ▼ (Data Packager)
┌─────────────────────────────────┐
│ JSON Payload Context            │
└────────────────┬────────────────┘
                 │
                 ▼ (Secure HTTPS Client / Remote Config)
┌─────────────────────────────────┐
│ Google Generative AI API        │
└────────────────┬────────────────┘
                 │
                 ▼ (Structured JSON Response)
┌─────────────────────────────────┐
│ UI Insight Cards / Suggestions  │
└─────────────────────────────────┘
```

---

## 2. Context Payload Schema (JSON)

The following structure represents the packaged JSON payload sent as the user's prompt context.

```json
{
  "studentProfile": {
    "targetAttendanceRate": 75.0,
    "currentDate": "2026-07-16T22:55:00Z",
    "weeksRemaining": 8
  },
  "subjects": [
    {
      "id": "sub_math_101",
      "name": "Mathematics IV",
      "credits": 4,
      "requiredThresholdOverride": null,
      "stats": {
        "present": 12,
        "absent": 4,
        "late": 1,
        "cancelled": 0,
        "currentPercentage": 73.5,
        "safeBunks": 0,
        "mustAttendConsecutive": 2
      },
      "weeklySlots": [
        { "day": "Monday", "time": "09:00-10:00" },
        { "day": "Wednesday", "time": "09:00-10:00" }
      ]
    },
    {
      "id": "sub_phy_102",
      "name": "Physics Lab",
      "credits": 2,
      "requiredThresholdOverride": 80.0,
      "stats": {
        "present": 8,
        "absent": 0,
        "late": 0,
        "cancelled": 1,
        "currentPercentage": 100.0,
        "safeBunks": 2,
        "mustAttendConsecutive": 0
      },
      "weeklySlots": [
        { "day": "Friday", "time": "14:00-16:00" }
      ]
    }
  ],
  "upcomingExams": [
    {
      "subjectId": "sub_math_101",
      "date": "2026-07-22"
    }
  ],
  "studentRequest": {
    "intent": "general_advisory",
    "userConstraint": "I want to take a break on Wednesday to prepare for an interview."
  }
}
```

---

## 3. System Prompt & Instructions

The LLM is configured with strict instructions to generate responses adhering to the following rules:

### System Instructions
```
You are the AttendIQ Advisor, a professional academic counselor helping college students balance their attendance.
Your response MUST be formatted strictly as a single JSON object matching the requested schema. Do not output markdown wrappers.
Keep your suggestions concise, actionable, and mathematically correct based on the provided statistics.

Rules:
1. Identify any critical subject that is currently below or within 2% of the threshold.
2. If the user lists a specific request/constraint, evaluate its impact on their attendance and suggest an alternative if it violates a threshold.
3. Suggest optimal "trade-offs" where a student can afford to skip a class with high attendance to catch up on a subject with low attendance.
4. Keep cards/insights limited to a maximum of 3 items.
```

---

## 4. Response Schema

The expected response from the Gemini API must parse into this JSON structure:

```json
{
  "criticalWarnings": [
    {
      "subjectId": "sub_math_101",
      "title": "Math attendance is critical",
      "description": "Your current attendance (73.5%) is below the 75% target. You must attend the upcoming class on Wednesday. Bunking it will drop you to 70.5%."
    }
  ],
  "recommendations": [
    {
      "type": "tradeoff",
      "title": "Use Physics slot on Friday",
      "description": "You have a 100% attendance in Physics with 2 safe bunks. You can safely skip Physics on Friday if you need extra time to prepare for your Math exam."
    }
  ],
  "userIntentResolution": {
    "feasible": false,
    "verdict": "Bunking Wednesday math class is not recommended because it is a critical subject. Instead, we recommend attending math and bunking another class if needed."
  }
}
```

---

## 5. Offline Fallback Advisor

To maintain functionality in zero-connectivity areas (e.g. university basement classrooms), the app contains a local rule-based fallback service `LocalAdvisorService`:

- **Rule 1 (Below Threshold Warning)**:
  - Loop through all subjects. If `currentPercentage < targetThreshold`, add a critical warning: `"Must attend [SubjectName] to reach [Target]%. You need [MustAttend] consecutive classes."`
- **Rule 2 (Near Threshold Warning)**:
  - If `currentPercentage >= targetThreshold` but `currentPercentage - targetThreshold <= 2.5%`, add a warnings: `"Alert: [SubjectName] is close to falling below target. You can only skip 0 classes."`
- **Rule 3 (Safe Skips Summary)**:
  - If `safeBunks > 0`, list the subject in a summary card: `"You have [SafeBunks] safe skips remaining in [SubjectName]."`
- The `LocalAdvisorService` runs immediately when `connectivity_plus` reports no internet, updating the UI panel without requesting Gemini endpoints.

---

## 6. AI Development Rules for Coding Assistants

When executing tasks or generating code for the AttendIQ codebase, all AI coding assistants must strictly adhere to the following architectural and scope boundaries:

*   **Business Logic Conformance**: All calculations, attendance records mutations, and status evaluations must strictly follow [DOMAIN_RULES.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/DOMAIN_RULES.md). Never introduce ad-hoc weights or status changes outside the defined specifications.
*   **Database & Synchronization Operations**: All caching, sync queues handling, conflict resolutions, and background updates must strictly adhere to [SYNC_ENGINE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/SYNC_ENGINE.md). Do not rely on native Firestore client caching as a replacement for the manual outbox queue pattern.
*   **Code Placement & Clean Architecture**: File locations, classes definitions, and layer interactions must strictly follow [FOLDER_STRUCTURE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/FOLDER_STRUCTURE.md). The domain layer must remain pure, with all database DTO serialization encapsulated in the data layer.
*   **Scope Compliance**: Development must strictly respect the scope limits defined in [MVP_SCOPE.md](file:///c:/Users/ramsa/Desktop/AttendIQ/docs/MVP_SCOPE.md). Do not write code or import libraries for Phase 4 (AI Advisor, OCR, GPA tracker, Wear OS, etc.) until the MVP completion criteria have been officially satisfied.

