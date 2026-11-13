# AttendIQ UI/UX Completion — Dark Smoked Glass & Silver Reflections

## 1. Aesthetic Vision & Design Standards

The AttendIQ visual design language follows a **Dark Smoked Glass** aesthetic accented exclusively with **Silver Reflections**, establishing an abstract, AI-inspired, sophisticated interface that elevates student productivity without visual distraction or battery drain.

### Core Principles
- **Smoked Glass Translucency**: High-contrast, dark obsidian backgrounds (`#0D0D11`) layered with 87% opacity smoked glass cards (`#16161C` / `#191922`).
- **Silver Reflections & Edges**: Subtle, translucent silver borders (`#E2E8F0` at 10%–20% alpha) replace bright primary outlines, giving cards a milled metallic feel.
- **Abstract & Refined**: Eliminates gratuitous neon glow, excessive animations, and heavy blurs that induce frame drops.
- **Uncompromised Accessibility**: Retains WCAG AAA/AA text contrast ratios (light silver `#F5F5F7` for headers, metallic silver `#A1A1AA` for secondary subtitles).

---

## 2. Palette Specification

| Token | Hex / Alpha | Role |
|---|---|---|
| `darkBackground` | `#0D0D11` | Primary screen canvas; deep obsidian |
| `darkSurface` | `#16161C` | Smoked glass container surface |
| `darkCard` | `#191922` | Component card background |
| `silverReflect` | `#E2E8F0` | Polished silver primary accent |
| `silverBorder` | `rgba(226, 232, 240, 0.20)` | Highlighted card border |
| `silverBorderSubtle` | `rgba(226, 232, 240, 0.10)` | Default card border |
| `silverBorderGlow` | `rgba(226, 232, 240, 0.30)` | Active / interactive state rim |
| `attendanceHigh` | `#14A35B` | Safe Attendance ($\ge 75\%$) |
| `attendanceMid` | `#F59E0B` | Warning Attendance (near $75\%$) |
| `attendanceLow` | `#EF4444` | Critical Attendance ($< 75\%$) |

---

## 3. UI Component Implementations

### Smoked Glass Container Decorator
```dart
AppColors.smokedGlassDecoration(
  isDark: true,
  borderRadius: 16.0,
  borderWidth: 1.0,
)
```
Generates dual-layer box shadows:
1. Deep diffuse drop shadow (`Colors.black.withOpacity(0.4)`, blur: 16px).
2. Ultra-fine top silver rim reflection (`Color(0xFFE2E8F0).withOpacity(0.04)`, blur: 1px, offset: [0, 1]).

### Component Enhancements
1. **Academic Calendar Bottom Sheet**: Updated from plain flat tiles to smoked-glass class cards with interactive buttons for Present, Late, Absent, Cancelled, and Undo.
2. **Dashboard Schedule Card**: Added Late attendance action button with amber reflection highlight.
3. **Pending Check-Ins Banner**: High-priority smoked-glass alert card on the home screen when unanswered past classes require attention.
4. **Settings Page**: Clean group cards with custom radio tiles, sliders, and dropdown selectors matching the dark smoked-glass theme.

