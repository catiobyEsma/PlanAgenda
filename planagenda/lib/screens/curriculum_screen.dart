import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../date_utils.dart' as du;
import '../models.dart';
import '../study_suggestions.dart';
import '../theme.dart';
import '../localization.dart';
import 'manage_screen.dart';
import 'midterm_screen.dart';
import 'freetime_screen.dart';

class CurriculumScreen extends StatelessWidget {
  final DateTime date;
  const CurriculumScreen({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final rowColors = [
      AppColors.rowLavender1,
      AppColors.rowLavender2,
      AppColors.rowLavender3,
      AppColors.rowLavender4,
      AppColors.rowLavender5,
      AppColors.rowLavender6,
      AppColors.rowLavender7,
    ];
    final lessons = appData
        .schedulesForDate(date)
        .where((e) => e.type == EntryType.lesson)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back, color: AppColors.deepPurple),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, size: 15, color: AppColors.softPurple),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                appData.tr('curriculum_title'),
                                style: headingFont(fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        CustomPaint(size: const Size(70, 7), painter: _TitleSquigglePainter()),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          du.dayNumber(date),
                          style: headingFont(fontSize: 26, color: AppColors.midPurple),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 3, left: 2),
                          child: Text(
                            du.monthAbbrev(date, appData.language.localeTag),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.midPurple.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _DiaryIcon(size: 56),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _ColumnHeader(icon: Icons.access_time, label: appData.tr('col_hour'))),
                  const SizedBox(width: 8),
                  Expanded(child: _ColumnHeader(icon: Icons.menu_book, label: appData.tr('col_lecture'))),
                  const SizedBox(width: 8),
                  Expanded(child: _ColumnHeader(icon: Icons.home_outlined, label: appData.tr('col_room'))),
                ],
              ),
              const SizedBox(height: 10),
              ...List.generate(7, (i) {
                final entry = i < lessons.length ? lessons[i] : null;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _ScheduleRow(
                    color: rowColors[i],
                    entry: entry,
                    onTap: entry == null ? null : () => _onRowTap(context, entry),
                  ),
                );
              }),
              const SizedBox(height: 20),
              _BottomCard(date: date),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.midPurple,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ManageScreen(initialDate: date)),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Tablodaki bir derse dokununca açılan menü: bu günden sil ya da
/// sadece bu güne ait saati değiştir (tekrarlı girişlerde diğer
/// günleri etkilemez).
void _onRowTap(BuildContext context, ScheduleEntry entry) {
  final appData = context.read<AppData>();
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.lecture, style: headingFont(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              '${entry.hour} · ${entry.room}',
              style: TextStyle(color: AppColors.midPurple),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.midPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  Navigator.of(sheetContext).pop();
                  await _editScheduleTime(context, entry);
                },
                icon: const Icon(Icons.access_time, size: 18),
                label: Text(appData.tr('action_change_time')),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  side: const BorderSide(color: Colors.redAccent),
                ),
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  context.read<AppData>().deleteSchedule(entry.id);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                label: Text(appData.tr('action_delete_day'), style: const TextStyle(color: Colors.redAccent)),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Sadece bu güne ait dersin saatini değiştirmek için iki saat seçici açar.
Future<void> _editScheduleTime(BuildContext context, ScheduleEntry entry) async {
  final appData = context.read<AppData>();
  final initialStart = TimeOfDay(
    hour: entry.startMinutes ~/ 60,
    minute: entry.startMinutes % 60,
  );

  final newStart = await showTimePicker(
    context: context,
    initialTime: initialStart,
    helpText: appData.tr('start_time_label'),
  );
  if (newStart == null || !context.mounted) return;

  final newEnd = await showTimePicker(
    context: context,
    initialTime: initialStart,
    helpText: appData.tr('end_time_label'),
  );
  if (newEnd == null || !context.mounted) return;

  String two(int n) => n.toString().padLeft(2, '0');
  final hourText =
      '${two(newStart.hour)}:${two(newStart.minute)} - ${two(newEnd.hour)}:${two(newEnd.minute)}';
  final startMinutes = newStart.hour * 60 + newStart.minute;

  context.read<AppData>().updateScheduleTime(
        entry.id,
        hour: hourText,
        startMinutes: startMinutes,
      );
}

class _ColumnHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ColumnHeader({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.iconBoxGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.midPurple),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.deepPurple,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final Color color;
  final ScheduleEntry? entry;
  final VoidCallback? onTap;
  const _ScheduleRow({required this.color, this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry?.hour ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  entry?.lecture ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  entry?.room ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.deepPurple,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomCard extends StatelessWidget {
  final DateTime date;
  const _BottomCard({required this.date});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  appData.tr('bottom_card_title'),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.deepPurple,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PillButton(
                  icon: Icons.access_time,
                  label: appData.tr('btn_free_time'),
                  background: AppColors.rowLavender2,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => FreeTimeScreen(date: date)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PillButton(
                  icon: Icons.sports_basketball,
                  label: appData.tr('btn_extra'),
                  background: AppColors.chipPink,
                  textColor: AppColors.chipPinkText,
                  onTap: () => _showEntries(context, EntryType.extracurricular, appData.tr('btn_extra')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _PillButton(
            icon: Icons.menu_book_outlined,
            label: appData.tr('btn_study'),
            background: AppColors.rowLavender4,
            fullWidth: true,
            onTap: () => _onStudyTap(context),
          ),
        ],
      ),
    );
  }

  void _showEntries(BuildContext context, EntryType type, String title) {
    final appData = context.read<AppData>();
    final entries = appData.schedulesForDateAndType(date, type);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: headingFont(fontSize: 20)),
              const SizedBox(height: 12),
              if (entries.isEmpty)
                Text(appData.tr('no_records_for_date'), style: TextStyle(color: AppColors.midPurple))
              else
                ...entries.map((e) => ListTile(
                      title: Text(e.lecture),
                      subtitle: Text('${e.hour} · ${e.room}'),
                    )),
            ],
          ),
        );
      },
    );
  }

  /// "Study" butonuna basılınca çalışır. Henüz kayıtlı sınav yoksa direkt
  /// Midterm ekranına yönlendirir; kayıtlı sınav varsa kullanıcıya
  /// "View Suggestions" / "Enter Info" seçeneklerini sunar.
  void _onStudyTap(BuildContext context) {
    final appData = context.read<AppData>();

    if (appData.exams.isEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MidtermScreen(initialDate: date)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appData.tr('btn_study'), style: headingFont(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                appData.tr('study_sheet_desc'),
                style: TextStyle(color: AppColors.midPurple, fontSize: 13),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.midPurple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    _showSuggestions(context);
                  },
                  child: Text(appData.tr('study_view_suggestions')),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: BorderSide(color: AppColors.midPurple),
                  ),
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MidtermScreen(initialDate: date)),
                    );
                  },
                  child: Text(appData.tr('study_enter_info'), style: TextStyle(color: AppColors.midPurple)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuggestions(BuildContext context) {
    final appData = context.read<AppData>();
    final daySchedule = appData.schedulesForDate(date);
    final suggestions = buildStudySuggestions(
      date: date,
      exams: appData.exams,
      daySchedule: daySchedule,
      language: appData.language,
    );
    final hourUnit = appData.tr('unit_hour_short');
    final minuteUnit = appData.tr('unit_minute_short');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appData.tr('study_suggestions_title'), style: headingFont(fontSize: 20)),
              const SizedBox(height: 12),
              if (suggestions.isEmpty)
                Text(
                  appData.tr('no_upcoming_exam'),
                  style: TextStyle(color: AppColors.midPurple),
                )
              else
                ...suggestions.map((s) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: s.isComprehensiveReview ? const Color(0xFFFCE8E8) : AppColors.rowLavender1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: ListTile(
                        title: Row(
                          children: [
                            Flexible(
                              child: Text(
                                s.course,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (s.isComprehensiveReview) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9A0A0),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  appData.tr('comprehensive_review_badge'),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(s.reason, style: const TextStyle(fontSize: 12)),
                        trailing: Text(
                          s.suggestedMinutes >= 60
                              ? '${(s.suggestedMinutes / 60).toStringAsFixed(s.suggestedMinutes % 60 == 0 ? 0 : 1)} $hourUnit'
                              : '${s.suggestedMinutes} $minuteUnit',
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.midPurple),
                        ),
                      ),
                    )),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MidtermScreen(initialDate: date)),
                    );
                  },
                  child: Text(appData.tr('edit_exam_info')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color? textColor;
  final bool fullWidth;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.background,
    required this.onTap,
    this.textColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? AppColors.deepPurple;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: effectiveTextColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "My Curriculum" başlığının altındaki dekoratif dalga çizgisi.
class _TitleSquigglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.softPurple
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 1.2, size.width, size.height * 0.4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "My Curriculum" ekranının sağ üstündeki günlük/defter rozeti.
/// Dışarıdan bir görsele bağımlı olmadığı için her zaman düzgün görünür;
/// istersen assets/book.png'yi kendi görselinle değiştirip bu widget'ı
/// tekrar Image.asset('assets/book.png') ile değiştirebilirsin.
class _DiaryIcon extends StatelessWidget {
  final double size;
  const _DiaryIcon({this.size = 74});

  @override
  Widget build(BuildContext context) {
    final pawSize = size * 0.38;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.softPurple, AppColors.midPurple],
              ),
              borderRadius: BorderRadius.circular(size * 0.24),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(Icons.menu_book_rounded, color: Colors.white, size: size * 0.4),
          ),
          Positioned(
            left: -pawSize * 0.2,
            bottom: -pawSize * 0.2,
            child: Container(
              width: pawSize,
              height: pawSize,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Icon(Icons.pets, size: pawSize * 0.55, color: AppColors.midPurple),
            ),
          ),
        ],
      ),
    );
  }
}