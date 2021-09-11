import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:filcnaplo/api/providers/database_provider.dart';
import 'package:filcnaplo_kreta_api/controllers/timetable_controller.dart';
import 'package:filcnaplo_kreta_api/models/lesson.dart';
import 'package:filcnaplo_kreta_api/models/week.dart';
import 'package:filcnaplo_kreta_api/providers/timetable_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OverridesProvider extends ChangeNotifier {
  final Map<String, Map<String, String>> _recurringOverridesByKind = Map();
  final Map<String, Map<String, String>> _overridesByKind = Map();
  final Set<int> _fetchedWeeks = Set();
  final Map<DateTime, String> _dateDayHashMap = Map();
  late BuildContext _context;

  OverridesProvider({
    required BuildContext context,
  }) {
    _context = context;
  }

  Future<void> fetchRecurring() async {
    var overrides = await Provider.of<DatabaseProvider>(_context, listen: false).query.getRecurringLessonOverrides();
    overrides.forEach((Map map) {
      _set(_recurringOverridesByKind, map['kind'], _getKey(map['dayhash_or_weekid'], map['lesson_start_or_id']), map['value']);
    });
  }

  Future<void> fetchForWeek(int weekId) async {
    if (_fetchedWeeks.contains(weekId)) return;
    _fetchedWeeks.add(weekId);
    var overrides = await Provider.of<DatabaseProvider>(_context, listen: false).query.getLessonOverridesForWeek(weekId);
    overrides.forEach((Map map) {
      _set(_overridesByKind, map['kind'], map['lesson_start_or_id'], map['value']);
    });
  }

  bool hasOverrideOfKind(Lesson l, String kind) {
    String? v = getOverrideOfKind(l, kind);
    return v != null && v.isNotEmpty;
  }

  String? getOverrideOfKind(Lesson l, String kind) {
    return _overridesByKind[kind]?[l.id] ?? _recurringOverridesByKind[kind]?[_getKeyForLesson(l)];
  }

  List<String> getRecurringOverridesOfKind(String kind) {
    return _recurringOverridesByKind[kind]?.values.toSet().toList() ?? [];
  }

  Future<void> override(Lesson l, String kind, String value, {bool recurring = false}) async {
    var store = await Provider.of<DatabaseProvider>(_context, listen: false).store;
    if (recurring) {
      store.setRecurringLessonOverride(_getDayHashForLesson(l), _getLessonStart(l), kind, value);
      _set(_recurringOverridesByKind, kind, _getKeyForLesson(l), value);
    } else {
      store.setLessonOverride(_getWeekIdForLesson(l).toString(), l.id, kind, value);
      _set(_overridesByKind, kind, l.id, value);
    }
    notifyListeners();
  }

  String _getDayHashForLesson(Lesson lesson) {
    if (_dateDayHashMap.containsKey(lesson.date)) {
      return _dateDayHashMap[lesson.date]!;
    }

    List<Lesson> lessons = Provider.of<TimetableProvider>(_context, listen: false)
        .lessons
        .where((l) => _sameDate(l.date, lesson.date) && l.lessonIndex != "+" && l.subject.id != '')
        .toList();

    List<int> bytes = utf8.encode(lessons.map((e) => e.lessonIndex + e.subject.name).join());

    String hash = sha1.convert(bytes).toString();
    _dateDayHashMap[lesson.date] = hash;
    return hash;
  }

  int _getWeekIdForLesson(Lesson l) {
    return TimetableController.getWeekId(Week(
      start: l.date.subtract(Duration(days: l.date.weekday - 1)),
      end: DateTime.now(),
    ));
  }

  _set(Map<String, Map<String, String>> what, String key1, String key2, String value) {
    if (!what.containsKey(key1)) what[key1] = Map();
    if (value.isNotEmpty)
      what[key1]![key2] = value;
    else
      what[key1]!.remove(key2);
  }

  _getKey(String dayHash, String index) {
    return "$dayHash-$index";
  }

  _getKeyForLesson(Lesson l) {
    return _getKey(_getDayHashForLesson(l), _getLessonStart(l).toString());
  }

  int _getLessonStart(Lesson l) {
    return ((l.start.millisecondsSinceEpoch - l.date.millisecondsSinceEpoch) / 1000).round();
  }

  bool _sameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
