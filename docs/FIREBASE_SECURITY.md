# Security & Firebase Rules: AttendIQ

This document details the security policies, authentication restrictions, data isolation mechanics, and backup procedures implemented for AttendIQ's Cloud Firebase backend.

---

## 1. Authentication Security Flow

All operations on Cloud Firestore require an authenticated user.
- **Provider Authentication**: Accounts are authenticated using Firebase Authentication via OAuth (Google Sign-In) or email/password verified tokens.
- **Data Partitioning Key**: Every record in Firestore contains a mandatory `userId` string field which matches the authenticated user's Firebase UID (`request.auth.uid`). No document can be queried or modified without matching this key.

---

## 2. Cloud Firestore Security Rules (`firestore.rules`)

We enforce strict validation rules. Clients can never execute multi-document operations or cross-user writes.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    function belongsToUser() {
      return isOwner(resource.data.userId);
    }

    function incomingBelongsToUser() {
      return isOwner(request.resource.data.userId);
    }

    // 1. Users Collection
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }

    // 2. Semesters Collection
    match /semesters/{semesterId} {
      allow read: if belongsToUser();
      allow create: if isAuthenticated() && incomingBelongsToUser();
      allow update: if belongsToUser() && incomingBelongsToUser();
      allow delete: if belongsToUser();
    }

    // 3. Subjects Collection
    match /subjects/{subjectId} {
      allow read: if belongsToUser();
      allow create: if isAuthenticated() && incomingBelongsToUser();
      allow update: if belongsToUser() && incomingBelongsToUser();
      allow delete: if belongsToUser();
    }

    // 4. Attendance Records Collection
    match /attendance_records/{recordId} {
      allow read: if belongsToUser();
      allow create: if isAuthenticated() && incomingBelongsToUser();
      allow update: if belongsToUser() && incomingBelongsToUser();
      allow delete: if belongsToUser();
    }

    // 5. Schedules Collection
    match /schedules/{scheduleId} {
      allow read: if belongsToUser();
      allow create: if isAuthenticated() && incomingBelongsToUser();
      allow update: if belongsToUser() && incomingBelongsToUser();
      allow delete: if belongsToUser();
    }
  }
}
```

---

## 3. Data Isolation Mechanics

*   **No Admin Backdoors on Clients**: The mobile application initializes Firebase SDKs with restricted client permissions. Client credentials cannot bypass rules.
*   **Logical Partitioning**: The Firestore database is flat and structured to prevent nested document escalations. Queries from the Flutter app must specify the `userId` filter:
    `firestore.collection('subjects').where('userId', '==', currentUserId)`
    If the query does not include the filter, the rule engine rejects the read request immediately before fetching data.
*   **Write Schema Validation**: Security rules verify that users cannot modify `userId` fields to hijack other users' documents. On update, `request.resource.data.userId == resource.data.userId` guarantees ownership cannot change.

---

## 4. Rate Limiting & Safety

To prevent DDoS vectors and billing spikes from abnormal synchronizations (e.g. infinite sync loops):
- **Firestore Rates**: Limit requests on a single collection using index limits.
- **API Key Hardening**: Firebase API keys are restricted in the Google Cloud Console to only allow calls to Authentication, Firestore, and Cloud Messaging APIs from the AttendIQ app bundles (`com.ramsai.attendiq`).
- **Gemini Rate Limiting**: The Google AI Generative SDK API calls are proxied or restricted through Firebase App Check to authenticate that requests are initiated from a verified AttendIQ application.

---

## 5. Backup & Recovery Strategy

To ensure zero data loss, we implement automated cloud database backups.

*   **Google Cloud Scheduled Backups**: A Google Cloud Scheduler cron job runs daily, invoking a Cloud Function that exports Firestore data to a Google Cloud Storage (GCS) bucket:
    `cron: 0 2 * * *` (Runs daily at 2:00 AM UTC).
*   **Bucket Lifecycle Policies**: The target GCS bucket (`gs://attendiq-backups`) is configured with Object Lifecycle Management to retain backups for **30 days**, automatically deleting older exports to control storage costs.
*   **Recovery Validation**: Backups are isolated by environment. Staging recovery tests are scheduled quarterly to restore data to a separate test database instance, validating backup integrity.
