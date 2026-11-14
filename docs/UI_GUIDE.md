# ACEDRA – Monochromatic Design System Guide (v2.0)

This document details the official design system, semantic color tokens, typography, navigation architecture, and component standards for the **ACEDRA** academic attendance and scheduling platform.

---

## 1. Official ACEDRA Monochromatic Palette

The visual design system of ACEDRA is strictly built upon an authoritative 9-color monochromatic palette (Bootstrap Gray 100–900 tier). No extraneous color hues (blue, green, red, amber, purple, teal) are permitted in the application UI. Transparency, opacity, and blur variations of these nine colors are utilized for smoked glass effects, overlays, shadows, and specular reflections.

| Token | Hex | Role / Semantic Assignment |
| :--- | :--- | :--- |
| `gray100` | `#f8f9fa` | Primary text, selected navigation indicator, active crest, primary action labels |
| `gray200` | `#e9ecef` | Light silver highlight, specular reflections, high-prominence badges |
| `gray300` | `#dee2e6` | Primary icons, silver reflect, safe attendance / high-tier status |
| `gray400` | `#ced4da` | Secondary text, active borders, card outlines |
| `gray500` | `#adb5bd` | Mid-tone silver, warning/late attendance status, tertiary labels |
| `gray600` | `#6c757d` | Disabled text, absent/critical attendance status, subtle dividers |
| `gray700` | `#495057` | Elevated card surfaces, container borders, cancelled class markers |
| `gray800` | `#343a40` | Standard card surfaces, secondary background, chip containers |
| `gray900` | `#212529` | Main application background, selected navigation icon, pitch base |

---

## 2. Semantic Color Architecture

Rather than hardcoding raw hex values in individual widgets, all components consume centralized semantic tokens from `AppColors` and `GlassTokens`:

### 2.1 Surfaces & Layout
- **Main Background**: `#212529` (`AppColors.darkBackground`)
- **Secondary Background**: `#343a40` (`AppColors.darkSurface`)
- **Standard Cards**: `#343a40` (`AppColors.darkCard`)
- **Elevated Cards**: `#495057` (`AppColors.darkElevated`)
- **Borders & Dividers**: `#495057` (`AppColors.darkBorder`) with subtle variants in `AppColors.silverBorder`

### 2.2 Typography
- **Primary Headings & Key Metrics**: `#f8f9fa` (`AppColors.textPrimaryDark`)
- **Secondary Subheadings & Details**: `#ced4da` (`AppColors.textSecondaryDark`)
- **Disabled, Timestamps & Placeholders**: `#6c757d` (`AppColors.textDisabledDark`)

### 2.3 Status Indicators (Contrast & Pattern Driven)
To ensure accessibility without relying on colorful lights:
- **Safe / Above Target / Present**: `#dee2e6` (`AppColors.attendanceHigh`), labeled with clear check icons.
- **Warning / Near Target / Late**: `#adb5bd` (`AppColors.attendanceMid`), paired with clock/alert icons.
- **Critical / Below Target / Absent**: `#6c757d` (`AppColors.attendanceLow`), paired with distinct cross/warning badges.
- **Cancelled Class**: `#495057` (`AppColors.statusCancelled`), rendered with strike-through styling.

---

## 3. Dual Appearance Modes

### 3.1 Default Monochromatic Solid Appearance (Glass Disabled)
- Solid dark surfaces (`#212529` and `#343a40`).
- Crisp, high-contrast borders (`#495057`).
- Zero background noise; maximum battery conservation on OLED panels.

### 3.2 Monochromatic Glass Appearance (Glassy Interface Enabled)
- Smoked-glass translucent surfaces (`rgba(33, 37, 41, 0.72)`).
- Specular rim highlights (`rgba(222, 226, 230, 0.20)`).
- Subtle monochromatic canvas ambient glows.
- Hardware-accelerated backdrop blur (`sigmaX: 18, sigmaY: 18`).
- Strict readability preservation with high-contrast text overlays (`#f8f9fa`).

---

## 4. Floating Glass Navigation Bar

The navigation architecture uses a floating pill bar rendered in front of the active shell:
- **Pill Container**: Smoked glass container with neutral silver-white specular reflections (`AppColors.glassFloatingPillBg`, `AppColors.glassFloatingPillBorder`).
- **Selection Bubble**: Solid luminous monochromatic bubble (`#f8f9fa`).
- **Selected Icon & Label**: High-contrast pitch tone (`#212529`).
- **Unselected Icons & Labels**: Muted silver (`#ced4da` and `#adb5bd`).
- **Animation**: 380ms ease-out spring physics curve.
- **Destinations**: 4 primary tabs:
  1. `Home` (Dashboard overview, today's schedule, quick actions)
  2. `Timetable` (Weekly schedule, day timeline, academic calendar)
  3. `Analytics` (Attendance charts, safe bunk calculations, subject comparisons)
  4. `Account` (Profile, semester management, settings, backup, AI advisor)

---

## 5. Non-Color Accessibility & Information Design

In strict compliance with WCAG 2.2:
- No critical information is conveyed via color hue alone.
- Attendance metrics provide explicit numerical percentages (`75.0%`), state tags (`Safe`, `Warning`, `Critical`), and status counters (`Must Attend 2 Classes`, `Safe to Bunk 1 Class`).
- Charts use varied monochrome stroke weights, dotted/dashed gridlines, and labeled milestones rather than multi-color legends.
- Touch targets strictly maintain minimum 48×48dp hitboxes with safe bottom insets for device navigation bars.
