import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../controllers/weekly_schedule_view_controller.dart';

class ClassScheduleCard extends StatelessWidget {
  final ScheduleClassSlot slot;
  final VoidCallback? onTap;

  const ClassScheduleCard({
    super.key,
    required this.slot,
    this.onTap,
  });

  Color _parseColor(String hex) {
    try {
      var h = hex.replaceAll('#', '');
      if (h.length == 6) {
        h = 'FF$h';
      }
      return Color(int.parse(h, radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  Color _adaptiveTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade300
        : Colors.grey.shade800;
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _parseColor(slot.colorHex);
    final isExam = slot.type == ScheduleSlotType.exam;
    final textColor = _adaptiveTextColor(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.0),
        side: BorderSide(
          color: isExam ? Colors.redAccent.withOpacity(0.5) : cardColor.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      color: cardColor.withOpacity(0.12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            border: Border(
              left: BorderSide(
                color: isExam ? Colors.red : cardColor,
                width: 5.0,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title & Badges Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slot.title,
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: cardColor.computeLuminance() > 0.6 ? Colors.black87 : cardColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (slot.code.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            slot.code,
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.w600,
                              color: cardColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Exam / Status Pills
                  if (isExam)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'EXAM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else if (slot.status != 'UNMARKED')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: slot.status == 'PRESENT'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: slot.status == 'PRESENT' ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Text(
                        slot.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: slot.status == 'PRESENT' ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8.0),

              // Time, Room & Faculty Row
              Wrap(
                spacing: 12.0,
                runSpacing: 4.0,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded, size: 13.0, color: cardColor),
                      const SizedBox(width: 4.0),
                      Text(
                        '${slot.startTime} - ${slot.endTime}',
                        style: TextStyle(
                          fontSize: 12.0,
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
                        Icon(Icons.meeting_room_outlined, size: 13.0, color: cardColor),
                        const SizedBox(width: 4.0),
                        Text(
                          slot.room!,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  if (slot.faculty != null && slot.faculty!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline, size: 13.0, color: cardColor),
                        const SizedBox(width: 4.0),
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
  }
}
