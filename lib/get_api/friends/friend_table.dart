import 'dart:convert';
import 'package:august/get_api/timetable/schedule.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendTimeTable {
  Future<List<ScheduleList>> fetchFriendTimetable(int id, int semester) async {
    var url = Uri.parse('https://augustapp.one/friends/$id/tables/$semester/');
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final response =
        await http.get(url, headers: {'Authorization': 'Bearer $accessToken'});

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var sections = jsonResponse['sections'] as List;
      return sections
          .map((i) => ScheduleList.fromJson(i as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 404) {
      throw Exception('No timetable exists for given user and semester.');
    } else if (response.statusCode == 401) {
      throw Exception('Authentication credentials were not provided.');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied for non-friend user ID.');
    } else {
      throw Exception(
          'Failed to fetch timetable with status code ${response.statusCode}');
    }
  }
}
