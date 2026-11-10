# AttendIQ Database Design


Database:

Cloud Firestore

Local:

SQLite / Isar


# Collections


## Users

Fields:

id

name

email

createdAt



## Semesters

Fields:

id

userId

name

startDate

endDate

isArchived



## Subjects

Fields:

id

semesterId

name

code

faculty

credits

attendanceTarget

color

type


type:

Theory

Lab



## Timetable


Fields:

id

subjectId

weekday

startTime

endTime

room

faculty

notes



## Events


Every timetable entry creates events.


Fields:

id

subjectId

date

startTime

endTime

eventType

status



eventType:

REGULAR_CLASS

EXTRA_CLASS

LAB

TUTORIAL

SEMINAR

EXAM

ASSIGNMENT

HOLIDAY



status:

PRESENT

ABSENT

CANCELLED

HOLIDAY



## Attendance


Fields:

subjectId

present

absent

cancelled

totalClasses

percentage



## Assignment


Fields:

id

subjectId

title

description

dueDate



## Exam


Fields:

id

subjectId

title

date

