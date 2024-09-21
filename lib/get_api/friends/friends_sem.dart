import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendSemester {
  Future<List<int>> fetchFriendSemester(int id) async {
    var url = Uri.parse('https://augustapp.one/friends/$id/tables/semesters/');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return List<int>.from(
          jsonDecode(response.body).map((i) => int.parse(i.toString())));
    } else if (response.statusCode == 401) {
      throw Exception(
          'Unauthorized access: Please check your authentication token.');
    } else {
      // Handle other errors
      throw Exception(
          'Failed to load semesters with status code ${response.statusCode}');
    }
  }
}
