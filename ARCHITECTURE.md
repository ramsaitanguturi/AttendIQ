# AttendIQ Architecture


## Architecture Pattern

Use Clean Architecture.


Layers:


## Presentation Layer

Responsible for:

- Screens
- Widgets
- UI state
- User interaction


Example:

Dashboard Screen

Attendance Screen


## Domain Layer

Contains:

- Business logic
- Use cases
- Entities


Examples:

CalculateAttendance

PredictAttendance

GenerateEvents


## Data Layer

Responsible for:

- Firebase
- SQLite
- APIs
- Repositories


## Folder Structure


lib/

features/

authentication/

dashboard/

attendance/

subjects/

timetable/

calendar/

analytics/


core/

constants/

database/

theme/

utils/


shared/

widgets/


## State Management

Preferred:

Riverpod


## Data Flow


UI

↓

Provider

↓

Use Case

↓

Repository

↓

Firebase / Local Database



## Offline First

The application should work without internet.

Local database is the primary source.

Firebase synchronizes changes when internet is available.


## Synchronization Strategy


Local change

↓

Save SQLite

↓

Update UI

↓

Sync Firestore

↓

Resolve conflicts

