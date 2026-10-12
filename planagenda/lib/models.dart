
enum EntryType { lesson, freeTime, extracurricular, study }

extension EntryTypeLabel on EntryType {
  String get label {
    switch (this) {
      case EntryType.lesson:
        return 'lesson';
      case EntryType.freeTime:
        return 'free_time';
      case EntryType.extracurricular:
        return 'extra';
      case EntryType.study:
        return 'study';
    }
  }
}


class ScheduleEntry {
  final String id;
  final DateTime date;


  final String hour;

  final int startMinutes;

  final String lecture;
  final String room;
  final EntryType type;

  ScheduleEntry({
    required this.id,
    required this.date,
    required this.hour,
    required this.startMinutes,
    required this.lecture,
    required this.room,
    this.type = EntryType.lesson,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'hour': hour,
        'startMinutes': startMinutes,
        'lecture': lecture,
        'room': room,
        'type': type.name,
      };

  factory ScheduleEntry.fromJson(Map<String, dynamic> j) => ScheduleEntry(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        hour: j['hour'] as String,
        startMinutes: j['startMinutes'] is int
            ? j['startMinutes'] as int
            : _parseStartMinutes(j['hour'] as String),
        lecture: j['lecture'] as String,
        room: j['room'] as String,
        type: EntryType.values.firstWhere(
          (e) => e.name == j['type'],
          orElse: () => EntryType.lesson,
        ),
      );

  static int _parseStartMinutes(String hour) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(hour);
    if (match == null) return 0;
    final h = int.tryParse(match.group(1)!) ?? 0;
    final m = int.tryParse(match.group(2)!) ?? 0;
    return h * 60 + m;
  }
}

class Activity {
  final String id;
  final DateTime date;
  final String title;
  final String time;

  Activity({
    required this.id,
    required this.date,
    required this.title,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'time': time,
      };

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        title: j['title'] as String,
        time: j['time'] as String,
      );
}

enum ExamDifficulty { easy, medium, hard }

extension ExamDifficultyLabel on ExamDifficulty {
  String get label {
    switch (this) {
      case ExamDifficulty.easy:
        return 'difficulty_easy';
      case ExamDifficulty.medium:
        return 'difficulty_medium';
      case ExamDifficulty.hard:
        return 'difficulty_hard';
    }
  }

  int get weight {
    switch (this) {
      case ExamDifficulty.easy:
        return 1;
      case ExamDifficulty.medium:
        return 2;
      case ExamDifficulty.hard:
        return 3;
    }
  }
}


class Exam {
  final String id;
  final String course;
  final DateTime date;
  final ExamDifficulty difficulty;

  Exam({
    required this.id,
    required this.course,
    required this.date,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'course': course,
        'date': date.toIso8601String(),
        'difficulty': difficulty.name,
      };

  factory Exam.fromJson(Map<String, dynamic> j) => Exam(
        id: j['id'] as String,
        course: j['course'] as String,
        date: DateTime.parse(j['date'] as String),
        difficulty: ExamDifficulty.values.firstWhere(
          (e) => e.name == j['difficulty'],
          orElse: () => ExamDifficulty.medium,
        ),
      );
}