import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:filcnaplo/api/providers/database_provider.dart';
import 'package:filcnaplo_kreta_api/models/lesson.dart';
import 'package:filcnaplo_kreta_api/providers/timetable_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoomsProvider extends ChangeNotifier {
  Map<String, String> _dayHashRoomMap = new Map();
  Map<DateTime, String> _dateDayHashMap = new Map();
  late BuildContext _context;

  RoomsProvider({
    required BuildContext context,
  }) {
    _context = context;
  }

  Future<void> fetch() async {
    var rooms = await Provider.of<DatabaseProvider>(_context, listen: false).query.getRooms();
    rooms.forEach((Map roomMap) {
      _dayHashRoomMap[_getKey(roomMap['dayhash'], roomMap['lesson_start'])] = roomMap['room'];
    });
  }

  bool hasOverride(Lesson l) {
    String? r = getRoomOverrideForLesson(l);
    return r != null && r.isNotEmpty;
  }

  String getRoomForLesson(Lesson l) {
    return getRoomOverrideForLesson(l) ?? l.room.replaceAll("_", " ");
  }

  String? getRoomOverrideForLesson(Lesson l) {
    return _dayHashRoomMap[_getKeyForLesson(l)];
  }

  Future<void> overrideRoom(String room, Lesson l) async {
    if (room == l.room) room = '';

    await Provider.of<DatabaseProvider>(_context, listen: false).store.overrideRoom(getDayHashForLesson(l), _getLessonStart(l), room);

    String key = _getKeyForLesson(l);
    if (room.isNotEmpty)
      _dayHashRoomMap[key] = room;
    else
      _dayHashRoomMap.remove(key);
    notifyListeners();
  }

  String getDayHashForLesson(Lesson lesson) {
    if (_dateDayHashMap.containsKey(lesson.date)) {
      return _dateDayHashMap[lesson.date]!;
    }

    List<Lesson> lessons =
        Provider.of<TimetableProvider>(_context, listen: false).lessons.where((l) => _sameDate(l.date, lesson.date) && l.lessonIndex != "+").toList();

    List<int> bytes = utf8.encode(lessons.map((e) => e.lessonIndex + e.subject.name).join());

    String hash = sha1.convert(bytes).toString();
    _dateDayHashMap[lesson.date] = hash;
    return hash;
  }

  List<String> get rooms {
    return _dayHashRoomMap.values.toSet().toList()..sort();
  }

  _getKey(String dayHash, String index) {
    return "$dayHash-$index";
  }

  _getKeyForLesson(Lesson l) {
    return _getKey(getDayHashForLesson(l), _getLessonStart(l).toString());
  }

  int _getLessonStart(Lesson l) {
    return ((l.start.millisecondsSinceEpoch - l.date.millisecondsSinceEpoch) / 1000).round();
  }

  bool _sameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  List<List<Lesson>> getEditableLessons() {
    List<Lesson> lessons = Provider.of<TimetableProvider>(_context, listen: false).lessons;

    Map<String, int> roomOccurances = Map();

    lessons.forEach((l) {
      if (!roomOccurances.containsKey(l.room)) {
        roomOccurances[l.room] = 1;
      } else {
        roomOccurances[l.room] = roomOccurances[l.room]! + 1;
      }
    });

    // If more than 5 unique rooms are present originally,
    // (need to test in the wild)
    // there is a good chance that
    // all the rooms are correct by default so no need to edit
    if (roomOccurances.keys.length > 5) return [];

    int highestOccurance = roomOccurances.values.length > 0 ? roomOccurances.values.reduce(min) : 0;

    List<List<Lesson>> ret = [];

    lessons
        .where((l) =>
            !hasOverride(l) &&
            // Sometimes a few classrooms are correct, we don't want to edit those
            roomOccurances[l.room] == highestOccurance &&
            l.subject.id != '')
        .forEach((l) {
      // Handle double lessons
      if (ret.isNotEmpty) {
        Lesson prev = ret.last.last;
        if (prev.subject == l.subject && _sameDate(prev.date, l.date) && int.tryParse(prev.lessonIndex)! + 1 == int.tryParse(l.lessonIndex))
          ret.last.add(l);
        else
          ret.add([l]);
      } else {
        ret.add([l]);
      }
    });

    return ret;
  }
}
