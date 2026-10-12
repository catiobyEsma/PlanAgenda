import 'package:intl/intl.dart';


DateTime todayDateOnly() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String monthAbbrev(DateTime d, [String locale = 'en_US']) => DateFormat('MMMM', locale).format(d);

String monthShort(DateTime d, [String locale = 'en_US']) => DateFormat('MMM', locale).format(d);

String dayNumber(DateTime d) => d.day.toString();

int startMinutesFromHourRange(String hourRange) {
  try {
    final startPart = hourRange.split('-').first.trim();
    final parts = startPart.split(':');
    final h = int.parse(parts[0].trim());
    final m = int.parse(parts[1].trim());
    return h * 60 + m;
  } catch (_) {
    return 24 * 60;
  }
}

int durationMinutesFromHourRange(String hourRange) {
  final matches = RegExp(r'(\d{1,2}):(\d{2})').allMatches(hourRange).toList();
  if (matches.length < 2) return 0;

  int toMinutes(RegExpMatch m) => int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);

  final start = toMinutes(matches[0]);
  var end = toMinutes(matches[1]);
  if (end < start) end += 24 * 60; 
  return end - start;
}