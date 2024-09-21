import 'dart:io';
import 'dart:ui';

import 'package:august/login/load_institution.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// 지원하는 모든 학기 목록을 가져오는 함수
// 지원하는 모든 학기 목록을 가져오는 함수

Future<List<String>> fetchAllSemesters() async {
  // get school id
  int schoolId = await getSchoolId();

  final response = await http.get(
      Uri.parse('https://augustapp.one/semesters/?institution_id=$schoolId'));

  if (response.statusCode == 200) {
    // Convert the list of int to a list of String
    return List<String>.from(
        jsonDecode(response.body).map((i) => i.toString()));
  } else {
    throw Exception('Failed to load semesters');
  }
}

String formatSemester(String semester) {
  // Check if the input is empty
  if (semester.isEmpty) {
    return " ";
  }

  // Process the semester string
  String year = semester.substring(0, 4);
  String season = getSeasonFromSemester(semester);
  return "$season $year";
}

String getSeasonFromSemester(String semester) {
  if (semester.endsWith("01")) {
    return "Spring";
  } else if (semester.endsWith("05")) {
    return "Summer";
  } else if (semester.endsWith("08")) {
    return "Fall";
  } else if (semester.endsWith("12")) {
    return "Winter";
  } else {
    return "Invalid";
  }
}

String extractSeason(String semester) {
  return semester.split(" ")[0].toLowerCase();
}

Color determineColor(String semester) {
  String season = extractSeason(semester);
  switch (season) {
    case "spring":
      return Color(0xFFffe6ea);
    case "summer":
      return Color(0xFFfff7e6);
    case "fall":
      return Color(0xFFffefe5);
    default:
      return Color(0xFFbac9f7);
  }
}
