import 'package:august/login/load_institution.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> fetchSections(
    String semester, String queryType, String query) async {
  // get school id
  int schoolId = await getSchoolId();
  final response = await http.get(Uri.parse(
      'https://augustapp.one/sections?semester=$semester&querytype=$queryType&query=$query&institution_id=$schoolId'));

  if (response.statusCode == 200) {
    // 서버가 성공적으로 응답하면, JSON 파싱
    return jsonDecode(response.body);
  } else {
    // 서버가 에러 응답이면 예외 발생시킴.
    throw Exception('Failed to load sections');
  }
}
