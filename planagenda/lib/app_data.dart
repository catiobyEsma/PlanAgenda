import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'localization.dart';
import 'models.dart';
import 'notifications.dart';
import 'theme.dart';
import 'translations.dart' as i18n;

class AppData extends ChangeNotifier {
  final List<ScheduleEntry> _schedules = [];
  final List<Activity> _activities = [];
  final List<Exam> _exams = [];

  List<ScheduleEntry> get schedules => List.unmodifiable(_schedules);
  List<Activity> get activities => List.unmodifiable(_activities);
  List<Exam> get exams => List.unmodifiable(_exams);

  AppLanguage _language = AppLanguage.tr;
  AppLanguage get language => _language;

  AppThemeOption _themeOption = AppThemeOption.default_;
  AppThemeOption get themeOption => _themeOption;

  int _avatarIndex = 1;
  int get avatarIndex => _avatarIndex;
  static const int avatarCount = 15;

  String tr(String key) => i18n.t(_language, key);

  static const _scheduleKey = 'PlanAgenda_schedules_v1';
  static const _activityKey = 'PlanAgenda_activities_v1';
  static const _examKey = 'PlanAgenda_exams_v1';
  static const _languageKey = 'PlanAgenda_language_v1';
  static const _themeKey = 'PlanAgenda_theme_v1';
  static const _avatarKey = 'PlanAgenda_avatar_v1';

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_scheduleKey);
    final a = prefs.getString(_activityKey);
    final ex = prefs.getString(_examKey);
    final langCode = prefs.getString(_languageKey);
    final themeName = prefs.getString(_themeKey);
    final avatarIndex = prefs.getInt(_avatarKey);

    _schedules.clear();
    _activities.clear();
    _exams.clear();

    if (s != null && s.isNotEmpty) {
      final list = jsonDecode(s) as List;
      _schedules.addAll(
        list.map((e) => ScheduleEntry.fromJson(e as Map<String, dynamic>)),
      );
    }
    if (a != null && a.isNotEmpty) {
      final list = jsonDecode(a) as List;
      _activities.addAll(
        list.map((e) => Activity.fromJson(e as Map<String, dynamic>)),
      );
    }
    if (ex != null && ex.isNotEmpty) {
      final list = jsonDecode(ex) as List;
      _exams.addAll(
        list.map((e) => Exam.fromJson(e as Map<String, dynamic>)),
      );
    }
    _language = languageFromCode(langCode);
    _themeOption = AppThemeOption.values.firstWhere(
      (o) => o.name == themeName,
      orElse: () => AppThemeOption.default_,
    );
    AppColors.apply(_themeOption);
    if (avatarIndex != null && avatarIndex >= 1 && avatarIndex <= avatarCount) {
      _avatarIndex = avatarIndex;
    }

    _sortSchedules();
    _activities.sort((x, y) => x.date.compareTo(y.date));
    _exams.sort((x, y) => x.date.compareTo(y.date));
    _loaded = true;
    notifyListeners();

    await NotificationService.instance.init();
    await NotificationService.instance.rescheduleAll(this);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _scheduleKey,
      jsonEncode(_schedules.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _activityKey,
      jsonEncode(_activities.map((e) => e.toJson()).toList()),
    );
    await prefs.setString(
      _examKey,
      jsonEncode(_exams.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
  }

  Future<void> setThemeOption(AppThemeOption option) async {
    _themeOption = option;
    AppColors.apply(option);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, option.name);
  }

  Future<void> setAvatarIndex(int index) async {
    if (index < 1 || index > avatarCount) return;
    _avatarIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_avatarKey, index);
  }

  Future<void> addSchedule(ScheduleEntry entry) async {
    _schedules.add(entry);
    _sortSchedules();
    notifyListeners();
    await _persist();
    await NotificationService.instance.rescheduleAll(this);
  }

  Future<void> deleteSchedule(String id) async {
    _schedules.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
    await NotificationService.instance.rescheduleAll(this);
  }

  Future<void> updateScheduleTime(
    String id, {
    required String hour,
    required int startMinutes,
  }) async {
    final index = _schedules.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final old = _schedules[index];
    _schedules[index] = ScheduleEntry(
      id: old.id,
      date: old.date,
      hour: hour,
      startMinutes: startMinutes,
      lecture: old.lecture,
      room: old.room,
      type: old.type,
    );
    _sortSchedules();
    notifyListeners();
    await _persist();
    await NotificationService.instance.rescheduleAll(this);
  }

  Future<void> addActivity(Activity activity) async {
    _activities.removeWhere((e) => _isSameDay(e.date, activity.date));
    _activities.add(activity);
    _activities.sort((x, y) => x.date.compareTo(y.date));
    notifyListeners();
    await _persist();
    await NotificationService.instance.rescheduleAll(this);
  }

  Future<void> deleteActivity(String id) async {
    _activities.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
    await NotificationService.instance.rescheduleAll(this);
  }

  Future<void> addExam(Exam exam) async {
    _exams.add(exam);
    _exams.sort((x, y) => x.date.compareTo(y.date));
    notifyListeners();
    await _persist();
    await NotificationService.instance.rescheduleAll(this);
  }

  Future<void> deleteExam(String id) async {
    _exams.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
    await NotificationService.instance.rescheduleAll(this);
  }

  void _sortSchedules() {
    _schedules.sort((a, b) {
      final d = a.date.compareTo(b.date);
      if (d != 0) return d;
      return a.startMinutes.compareTo(b.startMinutes);
    });
  }

  List<ScheduleEntry> schedulesForDate(DateTime date) {
    return _schedules.where((e) => _isSameDay(e.date, date)).toList();
  }

  List<ScheduleEntry> schedulesForDateAndType(DateTime date, EntryType type) {
    return schedulesForDate(date).where((e) => e.type == type).toList();
  }

  List<ScheduleEntry> schedulesInRange(DateTime start, DateTime end) {
    final s = _isSameDay(start, end) ? start : (start.isBefore(end) ? start : end);
    final e = _isSameDay(start, end) ? end : (start.isBefore(end) ? end : start);
    return _schedules
        .where((entry) => !entry.date.isBefore(s) && !entry.date.isAfter(e))
        .toList()
      ..sort((a, b) {
        final d = a.date.compareTo(b.date);
        if (d != 0) return d;
        return a.startMinutes.compareTo(b.startMinutes);
      });
  }

  Activity? activityForDate(DateTime date) {
    for (final act in _activities) {
      if (_isSameDay(act.date, date)) return act;
    }
    return null;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}