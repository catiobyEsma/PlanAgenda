import 'localization.dart';
import 'models.dart';
import 'translations.dart';
class StudySuggestion {
  final String course;
  final ExamDifficulty difficulty;
  final int daysUntilExam;
  final int suggestedMinutes;
  final String reason;
  final bool isComprehensiveReview;

  StudySuggestion({
    required this.course,
    required this.difficulty,
    required this.daysUntilExam,
    required this.suggestedMinutes,
    required this.reason,
    this.isComprehensiveReview = false,
  });
}

List<StudySuggestion> buildStudySuggestions({
  required DateTime date,
  required List<Exam> exams,
  required List<ScheduleEntry> daySchedule,
  required AppLanguage language,
}) {
  final upcoming = exams.where((e) => !e.date.isBefore(date)).toList();
  if (upcoming.isEmpty) return [];

  final lessonCount = daySchedule.where((e) => e.type == EntryType.lesson).length;
  final freeTimeEntries = daySchedule.where((e) => e.type == EntryType.freeTime).toList();
  final isBusyDay = lessonCount >= 4;

  final scored = upcoming.map((exam) {
    final daysUntil = exam.date.difference(date).inDays;
    final urgency = 1 / (daysUntil + 1); // sınav yaklaştıkça artar
    final score = exam.difficulty.weight * urgency;
    return MapEntry(exam, score);
  }).toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final top = scored.take(3).toList();

  return top.map((entry) {
    final exam = entry.key;
    final daysUntil = exam.date.difference(date).inDays;
    final isComprehensive = daysUntil <= 1;

    int minutes;
    if (daysUntil <= 1) {
      minutes = 120;
    } else if (daysUntil <= 3) {
      minutes = 90;
    } else if (daysUntil <= 7) {
      minutes = 60;
    } else {
      minutes = 30;
    }
    if (exam.difficulty == ExamDifficulty.hard) minutes += 30;
    if (exam.difficulty == ExamDifficulty.easy) minutes -= 15;
    if (isComprehensive) minutes = (minutes * 1.25).round(); // kapsamlı tekrar için ekstra süre
    if (isBusyDay) minutes = (minutes * 0.7).round();
    if (minutes < 20) minutes = 20;

    final reasonParts = <String>[];
    if (daysUntil == 0) {
      reasonParts.add(t(language, 'study_reason_exam_today'));
    } else if (daysUntil == 1) {
      reasonParts.add(t(language, 'study_reason_exam_tomorrow'));
    } else {
      reasonParts.add(t(language, 'study_reason_days_left').replaceAll('{days}', daysUntil.toString()));
    }
    reasonParts.add(t(language, 'study_reason_difficulty').replaceAll('{difficulty}', difficultyLabel(language, exam.difficulty)));
    if (isBusyDay) reasonParts.add(t(language, 'study_reason_busy_day'));
    if (freeTimeEntries.isNotEmpty) {
      final slots = freeTimeEntries.map((e) => e.hour).join(', ');
      reasonParts.add(t(language, 'study_reason_free_time').replaceAll('{slots}', slots));
    }

    return StudySuggestion(
      course: exam.course,
      difficulty: exam.difficulty,
      daysUntilExam: daysUntil,
      suggestedMinutes: minutes,
      reason: reasonParts.join(' · '),
      isComprehensiveReview: isComprehensive,
    );
  }).toList();
}