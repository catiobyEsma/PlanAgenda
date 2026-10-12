import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../date_utils.dart' as du;
import '../localization.dart';
import '../models.dart';
import '../theme.dart';
import '../translations.dart';

class ManageScreen extends StatefulWidget {
  final DateTime? initialDate;
  const ManageScreen({super.key, this.initialDate});

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      appBar: AppBar(
        backgroundColor: AppColors.bgBottom,
        elevation: 0,
        foregroundColor: AppColors.deepPurple,
        title: Text(appData.tr('manage_title'), style: headingFont(fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.deepPurple,
          unselectedLabelColor: AppColors.midPurple,
          indicatorColor: AppColors.midPurple,
          tabs: [
            Tab(text: appData.tr('tab_schedule')),
            Tab(text: appData.tr('tab_activities')),
          ],
        ),
      ),
      body: Column(
        children: [
          _NotificationHint(text: appData.tr('notif_permission_note')),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ScheduleTab(initialDate: widget.initialDate),
                _ActivityTab(initialDate: widget.initialDate),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationHint extends StatelessWidget {
  final String text;
  const _NotificationHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.midPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.notifications_active_outlined, size: 16, color: AppColors.midPurple),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 11.5, color: AppColors.midPurple, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

enum _RepeatMode { single, recurring }
const List<MapEntry<int, String>> _weekdayKeys = [
  MapEntry(1, 'weekday_mon'),
  MapEntry(2, 'weekday_tue'),
  MapEntry(3, 'weekday_wed'),
  MapEntry(4, 'weekday_thu'),
  MapEntry(5, 'weekday_fri'),
  MapEntry(6, 'weekday_sat'),
  MapEntry(7, 'weekday_sun'),
];

class _ScheduleTab extends StatefulWidget {
  final DateTime? initialDate;
  const _ScheduleTab({this.initialDate});

  @override
  State<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<_ScheduleTab> {
  _RepeatMode _repeatMode = _RepeatMode.single;

  late DateTime _selectedDate; // tek günlük mod için
  DateTimeRange? _selectedRange; // tekrarlı mod için
  final Set<int> _selectedWeekdays = {}; // tekrarlı mod için seçili günler

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final _lectureController = TextEditingController();
  final _roomController = TextEditingController();
  EntryType _type = EntryType.lesson;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? du.todayDateOnly();
  }

  @override
  void dispose() {
    _lectureController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = du.dateOnly(picked));
    }
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedRange ??
          DateTimeRange(
            start: du.todayDateOnly(),
            end: du.todayDateOnly().add(const Duration(days: 7)),
          ),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedRange = DateTimeRange(
            start: du.dateOnly(picked.start),
            end: du.dateOnly(picked.end),
          ));
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
      helpText: context.read<AppData>().tr('start_time_label'),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
       
        if (_endTime != null && _toMinutes(_endTime!) <= _toMinutes(picked)) {
          _endTime = null;
        }
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
      helpText: context.read<AppData>().tr('end_time_label'),
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  int _toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String? get _hourRangeText {
    if (_startTime == null) return null;
    final start = _formatTime(_startTime!);
    if (_endTime == null) return start;
    return '$start - ${_formatTime(_endTime!)}';
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_selectedWeekdays.contains(weekday)) {
        _selectedWeekdays.remove(weekday);
      } else {
        _selectedWeekdays.add(weekday);
      }
    });
  }

  void _submit() {
    final hourText = _hourRangeText;
    final appData = context.read<AppData>();
    if (hourText == null || _lectureController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appData.tr('please_fill_hour_lecture'))),
      );
      return;
    }

    if (_repeatMode == _RepeatMode.single) {
      final entry = ScheduleEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: _selectedDate,
        hour: hourText,
        startMinutes: _toMinutes(_startTime!),
        lecture: _lectureController.text.trim(),
        room: _roomController.text.trim(),
        type: _type,
      );
      appData.addSchedule(entry);
      _clearFieldsAndUnfocus();
      return;
    }

    // Tekrarlı mod
    final range = _selectedRange;
    if (range == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appData.tr('please_select_range'))),
      );
      return;
    }
    if (_selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appData.tr('please_select_weekday'))),
      );
      return;
    }

    var count = 0;
    var cursor = range.start;
    while (!cursor.isAfter(range.end)) {
      if (_selectedWeekdays.contains(cursor.weekday)) {
        appData.addSchedule(ScheduleEntry(
          id: '${DateTime.now().microsecondsSinceEpoch}_$count',
          date: cursor,
          hour: hourText,
          startMinutes: _toMinutes(_startTime!),
          lecture: _lectureController.text.trim(),
          room: _roomController.text.trim(),
          type: _type,
        ));
        count++;
      }
      cursor = cursor.add(const Duration(days: 1));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count ${appData.tr('added_for_days')}')),
    );
    _clearFieldsAndUnfocus();
  }

  void _clearFieldsAndUnfocus() {
    setState(() {
      _startTime = null;
      _endTime = null;
    });
    _lectureController.clear();
    _roomController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();

    final List<ScheduleEntry> entries;
    final String listTitle;
    if (_repeatMode == _RepeatMode.single) {
      entries = appData.schedulesForDate(_selectedDate);
      listTitle = '${DateFormat('d MMMM', appData.language.localeTag).format(_selectedDate)} ${appData.tr('schedule_for')}';
    } else if (_selectedRange != null) {
      entries = appData.schedulesInRange(_selectedRange!.start, _selectedRange!.end);
      listTitle =
          '${DateFormat('d MMM', appData.language.localeTag).format(_selectedRange!.start)} - ${DateFormat('d MMM', appData.language.localeTag).format(_selectedRange!.end)} ${appData.tr('lessons_between')}';
    } else {
      entries = const [];
      listTitle = appData.tr('label_lessons');
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(appData.tr('repeat_label'), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepPurple)),
          const SizedBox(height: 8),
          _RepeatModeSelector(
            mode: _repeatMode,
            singleLabel: appData.tr('repeat_single'),
            recurringLabel: appData.tr('repeat_recurring'),
            onChanged: (m) => setState(() => _repeatMode = m),
          ),
          const SizedBox(height: 20),
          if (_repeatMode == _RepeatMode.single) ...[
            Text(appData.tr('date_label'), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepPurple)),
            const SizedBox(height: 8),
            _DateChip(date: _selectedDate, onTap: _pickDate),
          ] else ...[
            Text(appData.tr('date_range_label'), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepPurple)),
            const SizedBox(height: 8),
            _DateRangeChip(range: _selectedRange, onTap: _pickRange),
            const SizedBox(height: 16),
            Text(appData.tr('days_label'), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepPurple)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _weekdayKeys
                  .map((e) => _WeekdayChip(
                        label: appData.tr(e.value),
                        selected: _selectedWeekdays.contains(e.key),
                        onTap: () => _toggleWeekday(e.key),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _TimeChip(
                  label: appData.tr('start_time_label'),
                  time: _startTime,
                  onTap: _pickStartTime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeChip(
                  label: appData.tr('end_time_label'),
                  time: _endTime,
                  onTap: _pickEndTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TextField(controller: _lectureController, label: appData.tr('lecture_name_label')),
          const SizedBox(height: 12),
          _TextField(controller: _roomController, label: appData.tr('room_label')),
          const SizedBox(height: 12),
          DropdownButtonFormField<EntryType>(
            initialValue: _type,
            decoration: _fieldDecoration(appData.tr('type_label')),
            items: EntryType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(entryTypeLabel(appData.language, t))))
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? EntryType.lesson),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.midPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _submit,
              child: Text(appData.tr('btn_add')),
            ),
          ),
          const SizedBox(height: 28),
          Text(listTitle, style: headingFont(fontSize: 18)),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(appData.tr('no_schedule_yet'), style: TextStyle(color: AppColors.midPurple))
          else
            ...entries.map((e) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: AppColors.rowLavender1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    title: Text(e.lecture, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${DateFormat('d MMM', appData.language.localeTag).format(e.date)} · ${e.hour} · ${e.room} · ${entryTypeLabel(appData.language, e.type)}',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: AppColors.midPurple),
                      onPressed: () => context.read<AppData>().deleteSchedule(e.id),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}


class _RepeatModeSelector extends StatelessWidget {
  final _RepeatMode mode;
  final String singleLabel;
  final String recurringLabel;
  final ValueChanged<_RepeatMode> onChanged;
  const _RepeatModeSelector({
    required this.mode,
    required this.singleLabel,
    required this.recurringLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.iconBoxGrey,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: singleLabel,
              selected: mode == _RepeatMode.single,
              onTap: () => onChanged(_RepeatMode.single),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: recurringLabel,
              selected: mode == _RepeatMode.recurring,
              onTap: () => onChanged(_RepeatMode.recurring),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.midPurple : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.midPurple,
          ),
        ),
      ),
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _WeekdayChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.midPurple : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.midPurple : AppColors.iconBoxGrey),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.deepPurple,
          ),
        ),
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onTap;
  const _TimeChip({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = time;
    final text = t == null
        ? label
        : '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.iconBoxGrey),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 18, color: AppColors.midPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: t == null ? AppColors.midPurple.withValues(alpha: 0.7) : AppColors.deepPurple,
                  fontWeight: t == null ? FontWeight.w400 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _DateRangeChip extends StatelessWidget {
  final DateTimeRange? range;
  final VoidCallback onTap;
  const _DateRangeChip({required this.range, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final r = range;
    final locale = appData.language.localeTag;
    final text = r == null
        ? appData.tr('select_date_range')
        : '${DateFormat('d MMMM yyyy', locale).format(r.start)}  →  ${DateFormat('d MMMM yyyy', locale).format(r.end)}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.iconBoxGrey),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, size: 18, color: AppColors.midPurple),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.deepPurple, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ActivityTab extends StatefulWidget {
  final DateTime? initialDate;
  const _ActivityTab({this.initialDate});

  @override
  State<_ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<_ActivityTab> {
  late DateTime _selectedDate;
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? du.todayDateOnly();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = du.dateOnly(picked));
    }
  }

  void _submit() {
    final appData = context.read<AppData>();
    if (_titleController.text.trim().isEmpty || _timeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appData.tr('please_fill_activity'))),
      );
      return;
    }
    final activity = Activity(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      date: _selectedDate,
      title: _titleController.text.trim(),
      time: _timeController.text.trim(),
    );
    appData.addActivity(activity);
    _titleController.clear();
    _timeController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final activity = appData.activityForDate(_selectedDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(appData.tr('date_label'), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepPurple)),
          const SizedBox(height: 8),
          _DateChip(date: _selectedDate, onTap: _pickDate),
          const SizedBox(height: 20),
          _TextField(controller: _titleController, label: appData.tr('activity_name_hint')),
          const SizedBox(height: 12),
          _TextField(controller: _timeController, label: appData.tr('activity_time_hint')),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.midPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _submit,
              child: Text(appData.tr('btn_save')),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '${DateFormat('d MMMM', appData.language.localeTag).format(_selectedDate)} ${appData.tr('activity_for_date')}',
            style: headingFont(fontSize: 18),
          ),
          const SizedBox(height: 12),
          if (activity == null)
            Text(appData.tr('no_activity_yet'), style: TextStyle(color: AppColors.midPurple))
          else
            Card(
              color: AppColors.chipPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${appData.tr('time_label')}: ${activity.time}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: AppColors.chipPinkText),
                  onPressed: () => context.read<AppData>().deleteActivity(activity.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class _DateChip extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DateChip({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.iconBoxGrey),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: AppColors.midPurple),
            const SizedBox(width: 10),
            Text(
              DateFormat('d MMMM yyyy, EEEE', appData.language.localeTag).format(date),
              style: TextStyle(color: AppColors.deepPurple, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  const _TextField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: _fieldDecoration(label),
    );
  }
}

InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: AppColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.iconBoxGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.iconBoxGrey),
    ),
  );
}