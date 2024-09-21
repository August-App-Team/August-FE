import 'dart:convert';
import 'package:august/get_api/onboard/get_univ.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendInfo {
  final int id;
  final String name;
  String? department;
  final String? profileImage;
  final String yearInSchool;
  final Institution? institution;

  FriendInfo({
    required this.id,
    required this.name,
    this.department,
    this.profileImage,
    required this.yearInSchool,
    this.institution,
  });

  factory FriendInfo.fromJson(Map<String, dynamic> json) {
    return FriendInfo(
      id: json['id'],
      name: json['name'],
      department: json['department'] != null ? json['department'] : null,
      profileImage: json['profile_image'],
      yearInSchool: json['year_in_school'],
      institution: json['institution'] != null
          ? Institution.fromJson(json['institution'])
          : null,
    );
  }
}

class FriendInfos {
  var url = Uri.parse('https://augustapp.one/friends/');

  Future<List<FriendInfo>> fetchFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Explicitly decode the response body as UTF-8
      String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      List<FriendInfo> friends =
          jsonList.map((json) => FriendInfo.fromJson(json)).toList();
      return friends;
    } else if (response.statusCode == 401) {
      throw Exception(
          'Unauthorized request: Please check your authentication token.');
    } else {
      throw Exception(
          'Failed to load friends on get friends.dart:  ${response.body}');
    }
  }
}

/* ----------------------- test data model ------------------------- */

class DataModel {
  static int _idCounter = 0; // static 변수로 클래스 레벨에서 id 카운터를 관리
  final String title;
  final String imageName;
  final String subtitle;
  final int id;

  DataModel(
    this.title,
    this.imageName,
    this.subtitle,
  ) : this.id = ++_idCounter; // 생성자에서 id를 자동으로 할당
}

List<DataModel> dataList = [
  // DataModel("Beta", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Alpha", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Gamma", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Beta", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Alpha", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Gamma", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Beta", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Alpha", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Gamma", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Beta", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Alpha", "assets/icons/memoji.png", "Freshman"),
  // DataModel("Gamma", "assets/icons/memoji.png", "Freshman"),
];


/* ----------------------- test data model ------------------------- */