import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<String?> getTimetableFromServer(int semester) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');

  var url = Uri.parse('https://augustapp.one/timetables/$semester/');

  var response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    // Convert the response body bytes to a string using UTF-8 encoding
    String responseBody = utf8.decode(response.bodyBytes);

    // Save the decoded timetable to local storage
    await saveTimetableToLocalStorage(responseBody);

    // Return the decoded response body
    return responseBody;
  } else {
    // If the request fails, print the error and return null
    print('Failed to fetch timetable with status code: ${response.statusCode}');
    return null;
  }
}

Future<void> saveTimetableToLocalStorage(String timetableJson) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('timetableData', timetableJson);
}
