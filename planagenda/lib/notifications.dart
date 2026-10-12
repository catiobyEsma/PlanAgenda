import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app_data.dart';
import 'models.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final offsetMs = DateTime.now().timeZoneOffset.inMilliseconds;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      tz.Location? match;
      for (final loc in tz.timeZoneDatabase.locations.values) {
        if (loc.timeZone(nowMs).offset.inMilliseconds == offsetMs) {
          match = loc;
          break;
        }
      }
      tz.setLocalLocation(match ?? tz.UTC);
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }


  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    final android = _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();
  }

  static const _androidDetails = AndroidNotificationDetails(
    'PlanAgenda_reminders',
    'Ders & Aktivite Hatırlatmaları',
    channelDescription: 'Derslerden, aktivitelerden ve sınavlardan önce hatırlatma bildirimleri',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _details = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  Future<void> rescheduleAll(AppData appData) async {
    if (!_initialized) await init();
    await _plugin.cancelAll();

    final now = DateTime.now();


    for (final entry in appData.schedules) {
      if (entry.type != EntryType.lesson) continue;
      final start = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
        entry.startMinutes ~/ 60,
        entry.startMinutes % 60,
      );
      final notifyAt = start.subtract(const Duration(minutes: 5));
      if (!notifyAt.isAfter(now)) continue;

      await _zonedSchedule(
        id: _idFor('lesson', entry.id),
        title: appData.tr('notif_lesson_title'),
        body:
            '${appData.tr('notif_lecture_label')}: ${entry.lecture}   ${appData.tr('notif_room_label')}: ${entry.room}   ${appData.tr('notif_time_label')}: ${entry.hour}   ${appData.tr('notif_good_luck_lesson')}',
        when: notifyAt,
      );
    }

    for (final activity in appData.activities) {
      final time = _parseTimeString(activity.time);
      if (time == null) continue;
      final start = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
        time.hour,
        time.minute,
      );
      final notifyAt = start.subtract(const Duration(minutes: 5));
      if (!notifyAt.isAfter(now)) continue;

      await _zonedSchedule(
        id: _idFor('activity', activity.id),
        title: appData.tr('notif_activity_title'),
        body:
            '${activity.title}   ${appData.tr('notif_time_label')}: ${activity.time}   ${appData.tr('notif_good_luck_activity')}',
        when: notifyAt,
      );
    }

    for (final exam in appData.exams) {
      final notifyAt = DateTime(exam.date.year, exam.date.month, exam.date.day, 7, 0);
      if (!notifyAt.isAfter(now)) continue;

      await _zonedSchedule(
        id: _idFor('exam', exam.id),
        title: appData.tr('notif_exam_title'),
        body: '${exam.course} ${appData.tr('notif_good_luck_exam')}',
        when: notifyAt,
      );
    }
  }

  Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(when, tz.local),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {

    }
  }

  int _idFor(String prefix, String entityId) => '$prefix:$entityId'.hashCode & 0x7fffffff;


  ({int hour, int minute})? _parseTimeString(String raw) {
    final match = RegExp(r'(\d{1,2})[:.](\d{2})').firstMatch(raw);
    if (match == null) return null;
    final h = int.tryParse(match.group(1)!);
    final m = int.tryParse(match.group(2)!);
    if (h == null || m == null || h > 23 || m > 59) return null;
    return (hour: h, minute: m);
  }
}