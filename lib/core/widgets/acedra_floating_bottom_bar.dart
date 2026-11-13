import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/colors.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';

class AcedraNavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const AcedraNavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Persistent, floating, pill-shaped glass bottom navigation bar.
class AcedraFloatingBottomBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const AcedraFloatingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const List<AcedraNavigationItem> items = [
    AcedraNavigationItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Home',
    ),
    AcedraNavigationItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Timetable',
    ),
    AcedraNavigationItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Analytics',
    ),
    AcedraNavigationItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle_rounded,
      label: 'Account',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isGlassy = ref.watch(isGlassyThemeEnabledProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Outer container margin respecting gesture inset
    final margin = EdgeInsets.only(
      left: 18.0,
      right: 18.0,
      bottom: bottomPadding > 0 ? bottomPadding + 6.0 : 16.0,
    );

    // Styling depending on glassy / dark / light mode
    final Color barBgColor;
    final Border? barBorder;
    final List<BoxShadow> barShadows;

    if (isGlassy) {
      barBgColor = const Color(0xB810141D); // Smoked obsidian glass
      barBorder = Border.all(
        color: const Color(0x3DE2E8F0), // Translucent silver edge
        width: 1.2,
      );
      barShadows = [
        BoxShadow(
          color: Colors.black.withOpacity(0.55),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: AppColors.primary.withOpacity(0.12),
          blurRadius: 18,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (isDark) {
      barBgColor = const Color(0xF2161A24);
      barBorder = Border.all(
        color: const Color(0xFF2A2E3D),
        width: 1.0,
      );
      barShadows = [
        BoxShadow(
          color: Colors.black.withOpacity(0.45),
          blurRadius: 20,
          offset: const Offset(0, 6),
        ),
      ];
    } else {
      barBgColor = const Color(0xF7FFFFFF);
      barBorder = Border.all(
        color: const Color(0xFFE2E8F0),
        width: 1.0,
      );
      barShadows = [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
    }

    Widget content = Container(
      height: 66.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: barBgColor,
        borderRadius: BorderRadius.circular(33.0),
        border: barBorder,
        boxShadow: barShadows,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;
          return Expanded(
            child: _BottomBarItem(
              item: item,
              isSelected: isSelected,
              isDark: isDark,
              isGlassy: isGlassy,
              onTap: () => onTabSelected(index),
            ),
          );
        }),
      ),
    );

    if (isGlassy) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(33.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: content,
        ),
      );
    }

    return Padding(
      padding: margin,
      child: content,
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final AcedraNavigationItem item;
  final bool isSelected;
  final bool isDark;
  final bool isGlassy;
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.item,
    required this.isSelected,
    required this.isDark,
    required this.isGlassy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary.withOpacity(0.7)
        : AppColors.lightTextSecondary;

    return Semantics(
      label: item.label,
      selected: isSelected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: isSelected
                ? (isGlassy
                    ? const Color(0x2800E599) // Frosted emerald glow pill
                    : (isDark
                        ? AppColors.primary.withOpacity(0.14)
                        : AppColors.primary.withOpacity(0.12)))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24.0),
            border: isSelected
                ? Border.all(
                    color: isGlassy
                        ? const Color(0x5500E599)
                        : (isDark
                            ? AppColors.primary.withOpacity(0.3)
                            : AppColors.primary.withOpacity(0.2)),
                    width: 1.0,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 200),
                scale: isSelected ? 1.08 : 0.95,
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 22.0,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 3.0),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 11.5 : 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : inactiveColor,
                  letterSpacing: 0.2,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
