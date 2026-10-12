import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../date_utils.dart' as du;
import '../localization.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'curriculum_screen.dart';
import 'manage_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = du.todayDateOnly();
    final appData = context.watch<AppData>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.bgTop, AppColors.bgBottom],
            stops: const [0.0, 0.35],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(today: today),
                _ExamAlertBanner(today: today),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SparkleTitle(text: appData.tr('home_daily_title')),
                ),
                const SizedBox(height: 16),
                _DayCardsRow(today: today),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SparkleTitle(text: appData.tr('home_activities_title')),
                ),
                const SizedBox(height: 16),
                _ActivitiesList(today: today),
                const SizedBox(height: 20),
                const _TermsFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final DateTime today;
  const _Header({required this.today});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return SizedBox(
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dekoratif bulut / yıldız arka planı
          Positioned.fill(
            child: CustomPaint(painter: _CloudsPainter()),
          ),
          Positioned(
            top: 12,
            right: 16,
            child: Row(
              children: [
                _RoundIconButton(
                  icon: Icons.grid_view_rounded, // ManageScreen için uygun ikon
                  tooltip: appData.tr('icon1_tooltip'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManageScreen()),
                  ),
                ),
                const SizedBox(width: 10),
                _RoundIconButton(
                  icon: Icons.settings_rounded, // SettingsScreen için uygun ikon
                  tooltip: appData.tr('settings_title'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () => _showAvatarPicker(context, appData),
              child: Container(
                width: 116,
                height: 116,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icon${appData.avatarIndex}.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar ikonuna dokununca açılan, temaya uygun renklerle çizilmiş
/// seçim penceresi. assets/icon1.png ... icon15.png arasından seçim
/// yapılır; seçim kalıcı olarak saklanır ve tema değişse bile korunur.
void _showAvatarPicker(BuildContext context, AppData appData) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.bgBottom,
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
            Text(appData.tr('choose_avatar'), style: headingFont(fontSize: 20)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: AppData.avatarCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final index = i + 1;
                final selected = appData.avatarIndex == index;
                return GestureDetector(
                  onTap: () {
                    appData.setAvatarIndex(index);
                    Navigator.of(sheetContext).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.midPurple : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(2.5),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon$index.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 1,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.deepPurple,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloudsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cloudPaint = Paint()..color = AppColors.headerCloud.withValues(alpha: 0.6);
    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.35, size.width * 0.3, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.7, size.width * 0.6, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.3, size.width, size.height * 0.5)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, cloudPaint);

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    _drawStar(canvas, starPaint, Offset(size.width * 0.22, size.height * 0.18), 8);
    _drawStar(canvas, starPaint, Offset(size.width * 0.88, size.height * 0.12), 5);
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.lineTo(center.dx + size * 0.25, center.dy - size * 0.25);
    path.lineTo(center.dx + size, center.dy);
    path.lineTo(center.dx + size * 0.25, center.dy + size * 0.25);
    path.lineTo(center.dx, center.dy + size);
    path.lineTo(center.dx - size * 0.25, center.dy + size * 0.25);
    path.lineTo(center.dx - size, center.dy);
    path.lineTo(center.dx - size * 0.25, center.dy - size * 0.25);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExamAlertBanner extends StatelessWidget {
  final DateTime today;
  const _ExamAlertBanner({required this.today});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final tomorrow = today.add(const Duration(days: 1));

    final todayExams = appData.exams.where((e) => du.isSameDay(e.date, today)).toList();
    final tomorrowExams = appData.exams.where((e) => du.isSameDay(e.date, tomorrow)).toList();

    if (todayExams.isEmpty && tomorrowExams.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFCE8E8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9A0A0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final e in todayExams)
              _ExamLine(text: '${appData.tr('exam_today_alert')}: ${e.course} 📝', icon: Icons.warning_amber_rounded),
            for (final e in tomorrowExams)
              _ExamLine(text: '${appData.tr('exam_tomorrow_alert')}: ${e.course} 📝', icon: Icons.notifications_active_outlined),
          ],
        ),
      ),
    );
  }
}

class _ExamLine extends StatelessWidget {
  final String text;
  final IconData icon;
  const _ExamLine({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFB03A3A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFB03A3A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCardsRow extends StatelessWidget {
  final DateTime today;
  const _DayCardsRow({required this.today});

  @override
  Widget build(BuildContext context) {
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _DayCard(date: yesterday, today: today, background: AppColors.cardYesterday),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DayCard(date: today, today: today, background: AppColors.cardToday),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _DayCard(date: tomorrow, today: today, background: AppColors.cardTomorrow),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime date;
  final DateTime today;
  final Color background;

  const _DayCard({
    required this.date,
    required this.today,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final isToday = du.isSameDay(date, today);
    final isYesterday = du.isSameDay(date, today.subtract(const Duration(days: 1)));
    final isTomorrow = du.isSameDay(date, today.add(const Duration(days: 1)));

    late final String label;
    late final IconData decorationIcon;
    if (isToday) {
      label = appData.tr('day_today');
      decorationIcon = Icons.auto_awesome;
    } else if (isYesterday) {
      label = appData.tr('day_yesterday');
      decorationIcon = Icons.pets;
    } else if (isTomorrow) {
      label = appData.tr('day_tomorrow');
      decorationIcon = Icons.cloud;
    } else {
      label = DateFormat('EEEE', appData.language.localeTag).format(date);
      decorationIcon = Icons.calendar_today;
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CurriculumScreen(date: date)),
      ),
      child: Container(
        height: 190,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.deepPurple.withValues(alpha: isToday ? 1 : 0.65),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      du.dayNumber(date),
                      style: headingFont(
                        fontSize: 34,
                        color: isToday ? AppColors.deepPurple : AppColors.deepPurple.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      du.monthShort(date, appData.language.localeTag),
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.midPurple.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                if (isToday) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      appData.tr('day_today'),
                      style: TextStyle(
                        color: AppColors.midPurple,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Icon(
                decorationIcon,
                size: 22,
                color: AppColors.softPurple.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivitiesList extends StatelessWidget {
  final DateTime today;
  const _ActivitiesList({required this.today});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(4, (i) {
          final date = today.add(Duration(days: i));
          final activity = appData.activityForDate(date);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ActivityRow(date: date, today: today, activity: activity),
          );
        }),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final DateTime date;
  final DateTime today;
  final Activity? activity;
  const _ActivityRow({required this.date, required this.today, this.activity});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    String? badgeLabel;
    if (du.isSameDay(date, today)) {
      badgeLabel = appData.tr('activity_upcoming');
    } else if (du.isSameDay(date, today.add(const Duration(days: 1)))) {
      badgeLabel = appData.tr('activity_tomorrow');
    }

    return Material(
      color: AppColors.white.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ManageScreen(initialDate: date)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.iconBoxGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_month, color: AppColors.midPurple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '${DateFormat('MMMM', appData.language.localeTag).format(date)} ${date.day}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.deepPurple,
                ),
              ),
              if (badgeLabel != null) ...[
                const SizedBox(width: 8),
                StatusBadge(label: badgeLabel),
              ],
              const Spacer(),
              Expanded(
                flex: 2,
                child: Text(
                  activity != null
                      ? '${activity!.title} • ${activity!.time}'
                      : '---- ${appData.tr('activity_none')} ----',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: activity == null ? FontStyle.italic : FontStyle.normal,
                    color: activity == null
                        ? AppColors.midPurple.withValues(alpha: 0.6)
                        : AppColors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.iconBoxGrey),
                ),
                child: Icon(Icons.chevron_right, size: 18, color: AppColors.midPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsFooter extends StatelessWidget {
  const _TermsFooter();

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return Center(
      child: GestureDetector(
        onTap: () => _showTermsDialog(context, appData),
        child: Text(
          appData.tr('terms_conditions_link'),
          style: TextStyle(
            fontSize: 11,
            fontStyle: FontStyle.italic,
            decoration: TextDecoration.underline,
            color: AppColors.deepPurple.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}

void _showTermsDialog(BuildContext context, AppData appData) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.bgBottom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appData.tr('terms_conditions_title'), style: headingFont(fontSize: 18)),
              const SizedBox(height: 16),
              Text(
                appData.tr('terms_conditions_body'),
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.deepPurple.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(appData.tr('terms_ok')),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}