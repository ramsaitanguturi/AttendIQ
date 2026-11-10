# AttendIQ - Project Definition

## Project Name

AttendIQ

## Description

AttendIQ is a cross-platform mobile application for college students to manage their academic schedule, track attendance, calculate safe bunks, receive reminders, and securely synchronize their academic data across devices.

The goal is to remove manual attendance calculations and help students maintain required attendance percentages.

---

# Target Users

Primary users:

- College students
- Universities requiring attendance percentage
- Students managing multiple subjects and semesters

---

# Core Problem

Students often struggle with:

- Tracking attendance manually
- Knowing how many classes they can skip
- Predicting future attendance
- Managing timetable changes
- Remembering assignments and exams

AttendIQ solves these problems with automation.

---

# Main Features

## Authentication

Users can:

- Register
- Login
- Google Sign-In
- Forgot password
- Logout

User data should sync securely.

---

## Semester Management

Users can create multiple semesters.

Example:

Semester 3

Start Date:
01-08-2026

End Date:
30-11-2026


Old semesters can be archived.

---

## Subject Management

Each subject contains:

- Subject name
- Subject code
- Faculty
- Credits
- Attendance target percentage
- Color identifier
- Theory/Lab type


---

## Timetable

Supports recurring weekly schedules.

Each class contains:

- Subject
- Room
- Faculty
- Start time
- End time
- Recurring days
- Notes


---

## Event System

Every timetable entry creates events.

Event types:

- Regular class
- Extra class
- Lab
- Tutorial
- Seminar
- Exam
- Assignment
- Holiday
- Cancelled class


---

## Attendance

Attendance status:

- Present
- Absent
- Cancelled
- Holiday
- Extra Present
- Extra Absent


Attendance calculations must update automatically.

---

## Smart Attendance

Calculate:

- Current percentage
- Present classes
- Total classes
- Safe bunks
- Classes needed
- Predicted semester percentage


---

## Notifications

Support:

- Daily timetable reminder
- Upcoming class
- Exam reminder
- Assignment reminder
- Attendance warning


---

# Development Goal

Build a production-quality mobile application with:

- Clean architecture
- Offline-first design
- Secure cloud sync
- Smooth UI
- Maintainable code