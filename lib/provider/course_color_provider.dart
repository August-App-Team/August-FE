import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseColorProvider extends ChangeNotifier {
  List<Color> _colors = [
    Color.fromARGB(255, 171, 255, 235),
    Color.fromARGB(255, 160, 242, 255),
    Color.fromARGB(255, 190, 210, 252),
    Color.fromARGB(255, 217, 206, 255),
    Color.fromARGB(255, 253, 207, 179),
    Color.fromARGB(255, 253, 206, 214),
    Color.fromARGB(255, 255, 238, 201),
    Color.fromARGB(255, 161, 235, 198),
    Color.fromARGB(255, 185, 234, 247),
    Color.fromARGB(255, 203, 214, 254),
  ];

  List<double> _stops = [];
  Map<int, Color> _courseColorMap = {};
  Map<int, Color> _friendColorMap = {};

  int _colorIndex = 0;

  List<Color> get colors => _colors;
  List<double> get stops => _stops;

  CourseColorProvider() {
    loadColors(); // Load colors from shared preferences or use default if none saved
    _updateStops(); // Initialize stops
  }

  void _updateStops() {
    int length = _colors.length;
    if (length == 1) {
      _stops = [0.0];
    } else {
      double step = 1.0 / (length - 1);
      _stops = List<double>.generate(length, (index) => index * step);
    }
  }

  void setColorAtIndex(int index, Color newColor) {
    if (index >= 0 && index < _colors.length) {
      _colors[index] = newColor;
      saveColors(); // Save after modification
      _updateStops();
      notifyListeners();
    }
  }

  Color getColorByIndex(int index) {
    return _colors[index %
        _colors.length]; // Cycle through colors if index exceeds the list
  }

  Color getColorForCourse(int courseId) {
    if (!_courseColorMap.containsKey(courseId)) {
      _courseColorMap[courseId] = _colors[_colorIndex];
      _colorIndex = (_colorIndex + 1) % _colors.length;
    }
    return _courseColorMap[courseId]!;
  }

  // Get a color for a specific friend ID
  Color getColorForFriend(int friendId) {
    if (!_friendColorMap.containsKey(friendId)) {
      _friendColorMap[friendId] = _colors[_colorIndex];
      _colorIndex = (_colorIndex + 1) % _colors.length;
    }
    return _friendColorMap[friendId]!;
  }

  Future<void> saveColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> colorStrings =
        _colors.map((color) => color.value.toString()).toList();
    await prefs.setStringList('savedColors', colorStrings);
  }

  Future<void> loadColors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> colorStrings = prefs.getStringList('savedColors') ?? [];
    _colors = colorStrings.map((string) => Color(int.parse(string))).toList();

    // Set default colors if none were saved
    if (_colors.isEmpty) {
      _colors = [
        Color.fromARGB(255, 171, 255, 235),
        Color.fromARGB(255, 160, 242, 255),
        Color.fromARGB(255, 190, 210, 252),
        Color.fromARGB(255, 217, 206, 255),
        Color.fromARGB(255, 253, 207, 179),
        Color.fromARGB(255, 253, 206, 214),
        Color.fromARGB(255, 255, 238, 201),
        Color.fromARGB(255, 161, 235, 198),
        Color.fromARGB(255, 185, 234, 247),
        Color.fromARGB(255, 203, 214, 254),
      ];
    }
    _updateStops();
    notifyListeners();
  }

  void resetColors() {
    _colors = [
      Color.fromARGB(255, 171, 255, 235),
      Color.fromARGB(255, 160, 242, 255),
      Color.fromARGB(255, 190, 210, 252),
      Color.fromARGB(255, 217, 206, 255),
      Color.fromARGB(255, 253, 207, 179),
      Color.fromARGB(255, 253, 206, 214),
      Color.fromARGB(255, 255, 238, 201),
      Color.fromARGB(255, 161, 235, 198),
      Color.fromARGB(255, 185, 234, 247),
      Color.fromARGB(255, 203, 214, 254),
    ];
    saveColors();
    _updateStops();
    notifyListeners();
  }
}
