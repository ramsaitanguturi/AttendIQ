import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../controllers/weekly_schedule_view_controller.dart';
import 'class_schedule_card.dart';

class DayTimelineView extends StatefulWidget {
  final DayScheduleData dayData;
  final Function(ScheduleClassSlot)? onSlotTap;

  const DayTimelineView({
    super.key,
    required this.dayData,
    this.onSlotTap,
  });

  @override
  State<DayTimelineView> createState() => _DayTimelineViewState();
}

class _DayTimelineViewState extends State<DayTimelineView> {
  static const double _hourRowHeight = 72.0;
  static const double _timeColumnWidth = 54.0;
  static const int _startHour = 8;
  static const int _endHour = 22; // Timeline runs 08:00 - 22:00

  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _isToday(DateTime date) {
    return date.year == _now.year && date.month == _now.month && date.day == _now.day;
  }

  int _timeToMinutes(String timeStr) {
    try {
      final parts = timeStr.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      return hours * 60 + minutes;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayData = widget.dayData;

    // 1. Holiday Banner View
    if (dayData.isHoliday) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.beach_access_rounded,
                  size: 48,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                dayData.holidayTitle ?? 'College Holiday',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                dayData.holidayDescription ?? 'No classes scheduled for today.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final isTodayDate = _isToday(dayData.date);
    final totalHours = _endHour - _startHour;
    final totalGridHeight = totalHours * _hourRowHeight;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 12.0, bottom: 40.0),
      child: Stack(
        children: [
          // Background Hour Grid Lines and Labels
          Column(
            children: List.generate(totalHours + 1, (index) {
              final hour = _startHour + index;
              final timeStr = '${hour.toString().padLeft(2, '0')}:00';

              return SizedBox(
                height: index == totalHours ? 20.0 : _hourRowHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: _timeColumnWidth,
                      child: Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 6.0),
                        height: 1.0,
                        color: isDark
                            ? AppColors.darkBorder.withOpacity(0.5)
                            : AppColors.lightBorder.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // Cards Overlay positioned on Timeline
          if (dayData.items.isNotEmpty)
            Positioned(
              left: _timeColumnWidth + 8.0,
              right: 8.0,
              top: 0,
              height: totalGridHeight,
              child: Stack(
                children: dayData.items.map((slot) {
                  final startMin = _timeToMinutes(slot.startTime);
                  final endMin = _timeToMinutes(slot.endTime);
                  final timelineStartMin = _startHour * 60;

                  final topOffset = ((startMin - timelineStartMin) / 60.0) * _hourRowHeight;
                  final durationMinutes = (endMin - startMin).clamp(30, 360);
                  final cardHeight = (durationMinutes / 60.0) * _hourRowHeight;

                  return Positioned(
                    top: topOffset.clamp(0.0, totalGridHeight - 40.0),
                    left: 0,
                    right: 0,
                    height: cardHeight,
                    child: ClassScheduleCard(
                      slot: slot,
                      onTap: () => widget.onSlotTap?.call(slot),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Current Time Indicator Line (If today)
          if (isTodayDate) ...[
            Builder(builder: (context) {
              final currentMinutes = _now.hour * 60 + _now.minute;
              final startMinutes = _startHour * 60;
              final endMinutes = _endHour * 60;

              if (currentMinutes >= startMinutes && currentMinutes <= endMinutes) {
                final topPos = ((currentMinutes - startMinutes) / 60.0) * _hourRowHeight;

                return Positioned(
                  top: topPos + 6.0,
                  left: _timeColumnWidth - 6.0,
                  right: 0,
                  child: Row(
                    children: [
                      Container(
                        width: 12.0,
                        height: 12.0,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 2.0,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],

          // Empty state if no items scheduled
          if (dayData.items.isEmpty)
            Positioned(
              left: _timeColumnWidth,
              right: 0,
              top: _hourRowHeight * 2,
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 40,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No classes scheduled for this day',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
