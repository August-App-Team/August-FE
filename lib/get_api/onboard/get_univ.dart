import 'dart:convert';
import 'package:http/http.dart' as http;

class Institution {
  final int id; // ID 속성 추가
  final String fullName;
  final String nickname;
  final String logo;
  Institution({
    required this.id, // ID를 필수 인자로 추가
    required this.fullName,
    required this.nickname,
    required this.logo,
  });

  // Factory constructor for creating an instance from a map
  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'], // JSON에서 id를 읽어옴
      fullName: json['full_name'],
      nickname: json['nickname'],
      logo: json['logo'],
    );
  }
}

Future<List<Institution>> fetchInstitutions() async {
  final response =
      await http.get(Uri.parse('https://augustapp.one/institutions/'));

  if (response.statusCode == 200) {
    // Decode the JSON response which is expected to be a list of objects
    final List<dynamic> jsonList = jsonDecode(response.body);

    // Map through the list and create an Institution object from each map
    return jsonList
        .map<Institution>((item) => Institution.fromJson(item))
        .toList();
  } else {
    throw Exception('Failed to load institutions');
  }
}
