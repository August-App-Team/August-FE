import 'dart:convert';
import 'package:august/login/load_institution.dart';
import 'package:http/http.dart' as http;

Future<List<String>> fetchDepartments() async {
  // get school id
  int schoolId = await getSchoolId();
  final response = await http.get(
      Uri.parse('https://augustapp.one/departments/?institution_id=$schoolId'));
  if (response.statusCode == 200) {
    // JSON 문자열을 디코딩하여 List<dynamic>으로 변환
    final List<dynamic> jsonList = json.decode(response.body);

    // List<dynamic>을 List<String>으로 변환
    // 각 아이템의 id, full_name, nickname을 포함하는 문자열 생성
    List<String> departments = jsonList.map((item) {
      return "ID: ${item['id']}, ${item['full_name']} (${item['nickname']}) ";
    }).toList();

    return departments;
  } else {
    // HTTP 상태 코드가 200이 아닌 경우 예외 발생
    throw Exception('Failed to load departments');
  }
}
