import 'package:august/get_api/timetable/class.dart';
import 'package:august/login/load_institution.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchCourse {
  var data = [];
  List<CourseList> results = [];
  String fetchurl = "https://augustapp.one/sections/simple-sections/";

  Future<List<CourseList>> getCourseList({
    required String semester,
    required String querytype,
    required String query,
  }) async {
    Map<String, String> queryParams = {}; // Add this line to define queryParams

    int schoolId = await getSchoolId();

    var url = Uri.parse(
        "$fetchurl?semester=$semester&querytype=$querytype&query=$query&institution_id=$schoolId");
    print('Request url: $url');

    var response = await http.get(url);
    try {
      if (response.statusCode == 200) {
        data = json.decode(response.body);
        results = data.map((e) => CourseList.fromJson(e)).toList();
      } else {
        print('API error with status code: ${response.statusCode}');
      }
    } on Exception catch (e) {
      print('Error: $e');
    }
    return results;
  }
}
