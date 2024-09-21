import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> sendTimetableToServer(
    int semester, String timetableName, List<int> sectionIds) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');

  var url = Uri.parse('https://augustapp.one/timetables/$semester/');
  var response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer $accessToken', // Include the access token in the headers
    },
    body: jsonEncode({
      'name': timetableName,
      'section_ids': sectionIds,
    }),
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    print('Timetable sent successfully');
  } else {
    // Handle errors or unsuccessful responses appropriately
    print('Failed to send timetable with status code: ${response.statusCode}');
  }
}
