import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:august/const/colors/course_color.dart';
import 'package:flutter/cupertino.dart';

import '../get_api/timetable/schedule.dart';

class TimetableInfo {
  List<ScheduleList> courses;
  Duration startTime;
  Duration endTime;

  TimetableInfo({
    required this.courses,
    required this.startTime,
    required this.endTime,
  });
}

class CoursesProvider with ChangeNotifier {
/* -------------------------only for editing page--------------------------- */
  List<ScheduleList> _courses = [];
  List<ScheduleList> _addedCourseList = [];
  List<int> _removedCourseList = [];

  List<ScheduleList> get courses => _courses;
  List<ScheduleList> get addedCourseList => _addedCourseList;
  List<int> get removedCourseList => _removedCourseList;

  void addCourseToCurrentTimetableforEditPage(ScheduleList course) {
    _courses.add(course);
    notifyListeners();
  }

  void setCoursesforEditingPage(List<ScheduleList> newCourses) {
    _courses = newCourses;
    notifyListeners();
  }

  void removeCourseFromTimetableforEditingPage(int courseId) {
    _courses.removeWhere((course) => course.id == courseId);
    notifyListeners();
  }

  void additionalCourseforEditPage(ScheduleList course) {
    _addedCourseList.add(course);
    notifyListeners();
  }

  void removedCourseforEditPage(int courseId) {
    _removedCourseList.add(courseId);
    notifyListeners();
  }

  void resetAddedandRemovedCourseList() {
    _removedCourseList.clear();
    _addedCourseList.clear();
    notifyListeners();
  }

  /* --- get timetable length --- */
  int _timetableLength = 0;

  int get timetableLength => _timetableLength;

  set timetableLength(int length) {
    _timetableLength = length;
    notifyListeners();
  }

  /* --- get first timetable courses count */
  int _numCourses = 0;

  int get numCourses => _numCourses;

  set numCourses(int num) {
    _numCourses = num;
    notifyListeners();
  }

/* ---------------------below is for any other thing------------------------ */

  List<List<ScheduleList>> _selectedCoursesData = [];
  List<List<ScheduleList>> _coursesData = [];
  int _currentPageIndex = 0;
  List<List<ScheduleList>> get selectedCoursesData => _selectedCoursesData;
  List<List<ScheduleList>> get coursesData => _coursesData;
  int _addedCoursesCount = 0;
  int get addedCoursesCount => _addedCoursesCount;
  var boxColor = CourseColor;
  int currentColorIndex = 0;

  int get currentPageIndex {
    // _selectedCoursesData가 비어 있지 않은 경우에만 currentPageIndex 반환
    if (_selectedCoursesData.isNotEmpty) {
      // 범위를 벗어나지 않도록 조정
      _currentPageIndex =
          min(_currentPageIndex, _selectedCoursesData.length - 1);
      return _currentPageIndex;
    } else {
      // 비어 있으면 안전한 기본값 반환
      return 0;
    }
  }

  set currentPageIndex(int index) {
    // 범위를 벗어나지 않는 범위에서만 설정
    if (index >= 0 && index < _selectedCoursesData.length) {
      _currentPageIndex = index;
      notifyListeners();
    } else {
      print('Error: Invalid currentPageIndex');
    }
  }

  set selectedCoursesData(List<List<ScheduleList>> data) {
    _selectedCoursesData = data;
    notifyListeners();
  }

  void resetAddedCoursesCount() {
    _addedCoursesCount = 0;
    notifyListeners(); // Notify any listeners about this change.
  }

  void clearSelectedCourses() {
    selectedCoursesData.clear();
    notifyListeners();
  }

  void addCourse(List<ScheduleList> course) {
    _selectedCoursesData.add(course);
    _addedCoursesCount++;
    notifyListeners();
  }

  void deSelectCourse(List<ScheduleList> course) {
    _selectedCoursesData.remove(course);
    _addedCoursesCount--;
    notifyListeners();
  }

  void setzero(int num) {
    _addedCoursesCount = 0;
  }

  void setCourses(List<List<ScheduleList>> courses) {
    _coursesData = courses;
    notifyListeners();
  }

  void setCurrentPageIndex(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }

  void createNewTimetable() {
    _selectedCoursesData.add([]);
    _currentPageIndex = _selectedCoursesData.length - 1;
    notifyListeners();
  }

  void resetSelectedCoursesData() {
    _selectedCoursesData = [];
    notifyListeners();
  }

  /* --- manual page --- */
  void addCourseToTimetable(ScheduleList course, int timetableIndex) {
    if (timetableIndex >= 0 && timetableIndex < _selectedCoursesData.length) {
      _selectedCoursesData[timetableIndex].add(course);
      print('Current Timetable:');
      for (var c in selectedCoursesData[timetableIndex]) {
        print('${c.courseCode}, ${c.name}');
      }
    } else {
      print('Error: index out of range');
    }

    notifyListeners();
  }

  void removeCourse(int timetableIndex, int? courseId) {
    if (courseId == null) {
      print('Error: course id is null');
      return; // Early return if courseId is null
    }

    if (timetableIndex < 0 || timetableIndex >= _selectedCoursesData.length) {
      print('Trying to remove course at index: $timetableIndex');
      print('Length of _selectedCoursesData: ${_selectedCoursesData.length}');

      print('Error: index out of range');
      return; // Early return if index is out of range
    }

    // Store the initial length of the list
    var initialLength = _selectedCoursesData[timetableIndex].length;

    // Remove the course
    _selectedCoursesData[timetableIndex]
        .removeWhere((course) => course.id == courseId);

    // Check if the length has changed
    var removed = initialLength != _selectedCoursesData[timetableIndex].length;

    if (!removed) {
      print('Error: No course found with id $courseId');
    }

    notifyListeners();
  }
}
