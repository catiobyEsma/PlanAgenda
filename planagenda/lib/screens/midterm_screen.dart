import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_data.dart';
import '../date_utils.dart' as du;
import '../localization.dart';
import '../models.dart';
import '../theme.dart';
import '../translations.dart';

class MidtermScreen extends StatefulWidget {
  final DateTime? initialDate;
  const MidtermScreen({super.key, this.initialDate});

  @override
  State<MidtermScreen> createState() => _MidtermScreenState();
}

class _MidtermScreenState extends State<MidtermScreen> {
  final _courseController = TextEditingController();
  late DateTime _examDate;
  ExamDifficulty _difficulty = ExamDifficulty.medium;

  @override
  void initState() {
    super.initState();
    _examDate = widget.initialDate ?? du.todayDateOnly();
  }

  @override
  void dispose() {
    _courseController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _examDate = du.dateOnly(picked));
    }
  }

  void _submit() {
    final appData = context.read<AppData>();
    if (_courseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appData.tr('please_fill_exam_name'))),
      );
      return;
    }
    final exam = Exam(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      course: _courseController.text.trim(),
      date: _examDate,
      difficulty: _difficulty,
    );
    appData.addExam(exam);
    _courseController.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(appData.tr('exam_added'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = context.watch<AppData>();
    final locale = appData.language.localeTag;
    final exams = [...appData.exams]..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      appBar: AppBar(
        backgroundColor: AppColors.bgBottom,
        elevation: 0,
        foregroundColor: AppColors.deepPurple,
        title: Text(appData.tr('midterm_title'), style: headingFont(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appData.tr('exam_course_label'), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepPurple)),
            const SizedBox(height: 8),
            TextField(
              controller: _courseController,
              decoration: _fieldDecoration(appData.tr('exam_course_hint')),
            ),
            const SizedBox(height: 16),
            Text(appData.tr('exam_date_label'), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepPurple)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
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
                    Icon(Icons.event, size: 18, color: AppColors.midPurple),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('d MMMM yyyy, EEEE', locale).format(_examDate),
                      style: TextStyle(color: AppColors.deepPurple, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(appData.tr('difficulty_label'), style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepPurple)),
            const SizedBox(height: 8),
            Row(
              children: ExamDifficulty.values.map((d) {
                final selected = _difficulty == d;
                final color = _difficultyColor(d);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: d != ExamDifficulty.values.last ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _difficulty = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? color : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: selected ? color : AppColors.iconBoxGrey),
                        ),
                        child: Text(
                          difficultyLabel(appData.language, d),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected ? AppColors.white : AppColors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
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
            Text(appData.tr('saved_exams_title'), style: headingFont(fontSize: 18)),
            const SizedBox(height: 12),
            if (exams.isEmpty)
              Text(appData.tr('no_exams_yet'), style: TextStyle(color: AppColors.midPurple))
            else
              ...exams.map((e) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: AppColors.rowLavender1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      title: Text(e.course, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        '${DateFormat('d MMMM yyyy', locale).format(e.date)} · ${difficultyLabel(appData.language, e.difficulty)}',
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: AppColors.midPurple),
                        onPressed: () => context.read<AppData>().deleteExam(e.id),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

Color _difficultyColor(ExamDifficulty d) {
  switch (d) {
    case ExamDifficulty.easy:
      return const Color(0xFF6FBE8F);
    case ExamDifficulty.medium:
      return const Color(0xFFE0A64C);
    case ExamDifficulty.hard:
      return const Color(0xFFD4677A);
  }
}

InputDecoration _fieldDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
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
