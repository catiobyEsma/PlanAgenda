import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../date_utils.dart' as du;
import '../localization.dart';
import '../models.dart';
import '../study_suggestions.dart';
import '../theme.dart';

class FreeTimeScreen extends StatelessWidget {
  final DateTime date;
  const FreeTimeScreen({super.key, required this.date});

  static const int _totalDayMinutes = 24 * 60;

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final daySchedule = appData.schedulesForDate(date);
    final hourUnit = appData.tr('unit_hour_short');
    final minuteUnit = appData.tr('unit_minute_short');

    final lessonMinutes = daySchedule
        .where((e) => e.type == EntryType.lesson)
        .fold<int>(0, (sum, e) => sum + du.durationMinutesFromHourRange(e.hour));

    final extraMinutes = daySchedule
        .where((e) => e.type == EntryType.extracurricular)
        .fold<int>(0, (sum, e) => sum + du.durationMinutesFromHourRange(e.hour));

    final suggestions = buildStudySuggestions(
      date: date,
      exams: appData.exams,
      daySchedule: daySchedule,
      language: appData.language,
    );
    final studyMinutes = suggestions.fold<int>(0, (sum, s) => sum + s.suggestedMinutes);

    final usedMinutes = lessonMinutes + extraMinutes + studyMinutes;
    final remainingMinutes = (_totalDayMinutes - usedMinutes).clamp(0, _totalDayMinutes);
    final overflow = usedMinutes > _totalDayMinutes;

    String formatHours(int minutes) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (h == 0 && m == 0) return '0 $hourUnit';
      if (m == 0) return '$h $hourUnit';
      return '$h $hourUnit $m $minuteUnit';
    }

    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      appBar: AppBar(
        backgroundColor: AppColors.bgBottom,
        elevation: 0,
        foregroundColor: AppColors.deepPurple,
        title: Text(appData.tr('btn_free_time'), style: headingFont(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${du.dayNumber(date)} ${du.monthAbbrev(date, appData.language.localeTag)}',
              style: headingFont(fontSize: 22),
            ),
            const SizedBox(height: 6),
            Text(
              appData.tr('freetime_desc'),
              style: TextStyle(color: AppColors.midPurple, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryRow(
                    icon: Icons.menu_book,
                    label: appData.tr('label_lessons'),
                    minutes: lessonMinutes,
                    color: AppColors.midPurple,
                    formatHours: formatHours,
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    icon: Icons.access_time_filled,
                    label: appData.tr('label_study_suggestion'),
                    minutes: studyMinutes,
                    color: AppColors.midPurple,
                    emptyNote: suggestions.isEmpty ? appData.tr('no_upcoming_suggestion') : null,
                    formatHours: formatHours,
                  ),
                  const Divider(height: 24),
                  _SummaryRow(
                    icon: Icons.sports_basketball,
                    label: appData.tr('label_extra_activities'),
                    minutes: extraMinutes,
                    color: AppColors.chipPinkText,
                    formatHours: formatHours,
                  ),
                  const Divider(height: 28, thickness: 1),
                  _SummaryRow(
                    icon: Icons.calculate_outlined,
                    label: appData.tr('label_total_busy'),
                    minutes: usedMinutes,
                    color: AppColors.deepPurple,
                    bold: true,
                    formatHours: formatHours,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardToday,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appData.tr('freetime_formula'),
                    style: TextStyle(color: AppColors.midPurple, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${appData.tr('label_remaining_free')}: ${formatHours(remainingMinutes)}',
                    style: headingFont(fontSize: 22),
                  ),
                  if (overflow) ...[
                    const SizedBox(height: 8),
                    Text(
                      appData.tr('overflow_note'),
                      style: TextStyle(color: AppColors.chipPinkText, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int minutes;
  final Color color;
  final bool bold;
  final String? emptyNote;
  final String Function(int) formatHours;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.minutes,
    required this.color,
    required this.formatHours,
    this.bold = false,
    this.emptyNote,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
                  color: AppColors.deepPurple,
                ),
              ),
              if (emptyNote != null && minutes == 0)
                Text(emptyNote!, style: TextStyle(fontSize: 11, color: AppColors.midPurple)),
            ],
          ),
        ),
        Text(
          formatHours(minutes),
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            fontSize: bold ? 16 : 14,
            color: AppColors.deepPurple,
          ),
        ),
      ],
    );
  }
}
