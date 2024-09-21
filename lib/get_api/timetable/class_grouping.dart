import 'package:flutter/material.dart';

import 'class.dart';

class ClassGrouping extends ChangeNotifier {
  //classes list
  final List<CourseList> _class = [];

  //여기에 수업에 들어가는 그룹

  //get class list
  List<CourseList> get classList => _class; // 수업 리스트 가져오기
  //user class

  final List<CourseList> _group = [];

  //get user group
  List<CourseList> get classGrouping => _group; //그룹에 들어있는 수업 가져오기

  // add class to the group
  void addClass(CourseList classes) {
    _group.add(classes);
    notifyListeners();
  }

  // remove class to the group
  void removeClass(CourseList classes) {
    _group.remove(classes);
    notifyListeners();
  }
}
