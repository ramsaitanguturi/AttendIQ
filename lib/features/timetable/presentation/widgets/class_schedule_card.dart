import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/glass/glass_theme_tokens.dart';
import '../controllers/weekly_schedule_view_controller.dart';

class ClassScheduleCard extends StatelessWidget {
  final ScheduleClassSlot slot;
  final VoidCallback? onTap;
  final bool isGlassy;

  const ClassScheduleCard({
    super.key,
    required this.slot,
    this.onTap,
    this.isGlassy = false,
  });

  Color _parseColor(String hex) {
    return AppColors.parseMonochromeHex(hex, AppColors.gray300);
  }

  Color _adaptiveTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = _parseColor(slot.colorHex);
    final isExam = slot.type == ScheduleSlotType.exam;
    final isEvent = slot.type == ScheduleSlotType.event;
    final textColor = _adaptiveTextColor(context);

    final borderColor = isExam
        ? AppColors.gray600
        : (isEvent
            ? AppColors.gray500
            : (isGlassy
                ? (isDark
                    ? GlassTokens.silverBorder
                    : GlassTokens.lightGlassBorder)
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder)));

    final cardBgColor = isGlassy
        ? (isDark
            ? GlassTokens.smokedGlassSurface
            : GlassTokens.lightGlassSurface)
        : (isDark ? AppColors.darkSurface : AppColors.lightSurface);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 85.0;

        return Card(
          elevation: isGlassy ? 4 : 0,
          margin: EdgeInsets.symmetric(
            vertical: isCompact ? 2.0 : 4.0,
            horizontal: 2.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isCompact ? 10.0 : 14.0),
            side: BorderSide(
              color: borderColor,
              width: 1.1,
            ),
          ),
          color: cardBgColor,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(isCompact ? 10.0 : 14.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: isCompact ? 4.0 : 10.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isCompact ? 10.0 : 14.0),
                border: Border(
                  left: BorderSide(
                    color: isExam
                        ? AppColors.gray600
                        : (isEvent ? AppColors.gray500 : cardColor),
                    width: 4.0,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title & Badges Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                slot.title,
                                style: TextStyle(
                                  fontSize: isCompact ? 13.0 : 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (slot.code.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                slot.code,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Exam / Event / Status Pills
                      if (isExam)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.gray700 : AppColors.gray200,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray700),
                          ),
                          child: Text(
                            'EXAM',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.gray100
                                  : AppColors.gray900,
                            ),
                          ),
                        )
                      else if (isEvent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color:
                                isDark ? AppColors.gray700 : AppColors.gray200,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray700),
                          ),
                          child: Text(
                            slot.code.isNotEmpty ? slot.code : 'EVENT',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.gray100
                                  : AppColors.gray900,
                            ),
                          ),
                        )
                      else if (slot.status != 'UNMARKED')
                        Builder(
                          builder: (context) {
                            final st = slot.status.toUpperCase();
                            Color pillColor;
                            Color pillBg;
                            Color pillBorder;

                            if (st == 'PRESENT' || st == 'EXTRA_PRESENT') {
                              pillColor = AppColors.attendanceHigh;
                              pillBg = isDark
                                  ? AppColors.gray700.withOpacity(0.5)
                                  : AppColors.gray900;
                              pillBorder = isDark
                                  ? AppColors.gray300
                                  : AppColors.gray700;
                            } else if (st == 'CANCELLED' ||
                                st == 'CANCELLED_CLASS') {
                              pillColor = AppColors.statusCancelled;
                              pillBg = isDark
                                  ? AppColors.gray800
                                  : AppColors.gray900;
                              pillBorder = isDark
                                  ? AppColors.gray500
                                  : AppColors.gray700;
                            } else if (st == 'LATE') {
                              pillColor = AppColors.attendanceMid;
                              pillBg = isDark
                                  ? AppColors.gray700.withOpacity(0.5)
                                  : AppColors.gray900;
                              pillBorder = isDark
                                  ? AppColors.gray400
                                  : AppColors.gray600;
                            } else {
                              // ABSENT / EXTRA_ABSENT
                              pillColor = AppColors.attendanceLow;
                              pillBg = isDark
                                  ? AppColors.gray800
                                  : AppColors.gray900;
                              pillBorder = isDark
                                  ? AppColors.gray500
                                  : AppColors.gray700;
                            }

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: pillBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: pillBorder),
                              ),
                              child: Text(
                                slot.status,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: pillColor,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  SizedBox(height: isCompact ? 3.0 : 6.0),

                  // Time, Room & Faculty Row
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 2.0,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: isCompact ? 11.0 : 13.0, color: cardColor),
                          const SizedBox(width: 3.0),
                          Text(
                            '${slot.startTime} - ${slot.endTime}',
                            style: TextStyle(
                              fontSize: isCompact ? 11.0 : 12.0,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                      if (slot.room != null && slot.room!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.meeting_room_outlined,
                                size: isCompact ? 11.0 : 13.0,
                                color: cardColor),
                            const SizedBox(width: 3.0),
                            Text(
                              slot.room!,
                              style: TextStyle(
                                fontSize: isCompact ? 10.5 : 12.0,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      if (!isCompact &&
                          slot.faculty != null &&
                          slot.faculty!.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline,
                                size: 13.0, color: cardColor),
                            const SizedBox(width: 3.0),
                            Text(
                              slot.faculty!,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
