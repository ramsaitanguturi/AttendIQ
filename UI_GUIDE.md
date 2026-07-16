# UI/UX Style Guide: AttendIQ

This document details the user interface guidelines, navigation hierarchy, design tokens, color palette, screen breakdowns, and micro-interactions for the AttendIQ mobile application.

---

## 1. Visual Identity & Design System

AttendIQ adopts a modern, high-contrast, dark-mode-first aesthetic with glassmorphic accents, clean cards, and bright semantic status colors.

### 1.1 Color Palette (HSL-Based)

We define a curated set of HSL color tokens to ensure consistency.

```css
/* Core Palette */
--background:    hsl(240, 10%, 8%);    /* Dark charcoal/black (#111113) */
--surface:       hsl(240, 8%, 14%);   /* Slightly lighter card surface (#1B1B1F) */
--surface-glass: hsla(240, 8%, 14%, 0.7); /* Translucent surface for glassmorphism */
--primary:       hsl(160, 100%, 45%);  /* Emerald Green for presence, buttons (#00E599) */
--primary-glow:  hsla(160, 100%, 45%, 0.15);
--secondary:     hsl(195, 100%, 50%);  /* Cyan for predictions and info (#00BFFF) */
--border:        hsl(240, 6%, 22%);    /* Subtle border outline (#373740) */

/* Semantic Status Colors */
--attendance-high: hsl(150, 80%, 40%);  /* Safe state (above threshold) */
--attendance-mid:  hsl(38, 90%, 50%);   /* Warning state (near threshold) */
--attendance-low:  hsl(0, 85%, 55%);    /* Danger state (below threshold) */

/* Typography Colors */
--text-primary:    hsl(0, 0%, 95%);     /* Main text (#F2F2F2) */
--text-secondary:  hsl(240, 4%, 65%);   /* Muted subtext (#A0A0A5) */
```

### 1.2 Typography
- **Primary Font**: **Outfit** (via `google_fonts` package) - clean, modern, slightly rounded geometric sans-serif.
- **Fallback Font**: **Inter** - for dense text tables and schedules.
- **Scale**:
  - `Display Large`: 32pt (Bold, Outfit) - Main metrics / attendance percentages.
  - `Title Medium`: 20pt (Semi-Bold, Outfit) - Section headers / subject titles.
  - `Body Medium`: 14pt (Regular, Inter) - Text logs, remarks, schedule details.
  - `Label Small`: 11pt (Medium, Inter) - Dates, badges, status labels.

### 1.3 Card Styles & Glassmorphism
All cards use a subtle border (`1px` width, `--border` color), rounded corners (`16px` radius), and a low-opacity background with backdrop blur when placed over gradients.
- Flutter implementation: `BackdropFilter` with `ImageFilter.blur(sigmaX: 10, sigmaY: 10)`.

---

## 2. Navigation Model

AttendIQ uses a persistent **Bottom Navigation Bar** as its main navigational hub, active after authentication.

```
                  [ App Shell / Bottom Navigation ]
                                  │
      ┌──────────────┬────────────┼─────────────┬──────────────┐
      ▼              ▼            ▼             ▼              ▼
[ Dashboard ]  [ Timetable ] [ Analytics ] [ AI Advisor ] [ Settings ]
```

1. **Dashboard**: Shows overall attendance rate, a chronological list of classes for "Today", and a grid of subjects.
2. **Timetable**: View and edit the weekly class schedules.
3. **Analytics**: Subject-by-subject trends, prediction widgets, and charts.
4. **AI Advisor**: Structured generative advice cards, priority checklist, and direct conversation interface.
5. **Settings**: Configurations (late weight, targets, account management, offline status indicator).

---

## 3. Key Screen Breakdowns & Mockups

### 3.1 Splash & Authentication Flow
- **Splash Screen**: Checks if user is authenticated. Displays the AttendIQ logo with a smooth fading glow.
- **Login Screen**: Minimalist glassmorphic panel containing email/password fields, a primary emerald sign-in button, and a prominent Google Sign-In option.
- **Onboarding Wizard**: Step-by-step setup asking:
  1. "Name your active semester" (e.g., "Fall 2026").
  2. "Set semester duration" (Date pickers for Start and End dates).
  3. "Specify target rate" (Slider from 50% to 100%, defaults to 75%).

### 3.2 Main Dashboard
- **Header**: Overall attendance rate displayed inside a large, thin circular progress indicator. If attendance is $78\%$, the ring is emerald. If $74\%$ (below $75\%$ target), the ring is orange/red.
- **Today's Classes**: Horizontal carousel of classes for the current day.
  - **Swipe Action**: Swipe up/down (or drag handles) to log status.
  - Swipe **Right** to mark **Present**.
  - Swipe **Left** to mark **Absent**.
  - Tap for details (Cancelled, Late, Extra).
- **Subjects Grid**: Compact cards showing subject names, current percentage, and a dynamic pill badge:
  - `2 Safe Skips` (Green)
  - `Must Attend 3` (Orange)
  - `Critical` (Red)

### 3.3 Subject Detail Screen
- **Hero Header**: Subject title, instructor, and current percentage.
- **Metric Cards**: Two side-by-side cards:
  - Left Card: Safe Bunk number (large digit).
  - Right Card: Must Attend number (large digit).
- **Log Calendar**: Interactive monthly calendar showing colored dots (Green = Present, Red = Absent, Yellow = Late, Grey = Cancelled).
- **Logs List**: Scrollable list of recorded logs. Swipe-to-delete or tap to edit remarks.

### 3.4 AI Advisor Dashboard
- **Recommendation Cards**: Swipeable deck of AI insights (e.g., "Critical: You must attend Math tomorrow at 9:00 AM, otherwise attendance will fall to 74.2%").
- **Goal Setter**: Interactive checklist where users can add custom alerts (e.g., "Need to bunk Friday for Hackathon"). The AI will recalculate and recommend which classes to miss.

---

## 4. Micro-interactions & Polish

- **Spring-loaded Lists**: All scrolling lists use spring physics (`BouncingScrollPhysics`) on both iOS and Android to feel organic.
- **Percentage Ring Transitions**: When opening the dashboard, the circular attendance progress ring animates its sweep angle from 0 to target over 800ms using a standard ease-out curve.
- **Swipe-to-Mark Haptics**: Swiping a class to mark Present/Absent triggers a light physical vibration on the phone (`HapticFeedback.lightImpact()`) to confirm the action.
- **Sync Status Pill**: A tiny, pulsing dot in the top right corner of the dashboard represents database status:
  - Green (Pulsing): Fully synced.
  - Yellow: Local changes pending sync.
  - Grey: Offline mode active.
