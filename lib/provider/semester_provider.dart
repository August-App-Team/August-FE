import 'package:august/get_api/onboard/get_semester.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SemesterProvider with ChangeNotifier {
  List<String> _semesterList = [];
  String _semester = '';

  List<String> get semestersList => _semesterList;
  String get semester => _semester;

  SemesterProvider() {
    loadSemesters();
  }

  set semestersList(List<String> value) {
    _semesterList = value;
    if (_semesterList.isNotEmpty) {
      if (_semesterList.last.endsWith('01') ||
          _semesterList.last.endsWith('08')) {
        _semester = _semesterList.last;
        print('last normal semster: $_semester');
      } else {
        _semester = _semesterList[_semesterList.length - 2];
      }
      _semester = _semesterList.last;
    }
    notifyListeners();
  }

  set semester(String value) {
    _semester = value;
    notifyListeners();
  }

  Future<void> loadSemesters() async {
    _semesterList = await fetchAllSemesters();
    if (_semesterList.isNotEmpty) {
      if (_semesterList.last.endsWith('01') ||
          _semesterList.last.endsWith('08')) {
        _semester = _semesterList.last;
      } else {
        _semester = _semesterList[_semesterList.length - 2];
      }
    }
    notifyListeners();
  }
}
