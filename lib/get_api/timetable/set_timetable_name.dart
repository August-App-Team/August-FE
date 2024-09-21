// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> updateTimetableName(
    String semester, int order, String newName) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  if (accessToken == null) {
    print('Access token not found');
    return; // Stops execution if no access token
  }

  const String baseUrl = 'https://augustapp.one/timetables';
  String url = '$baseUrl/$semester/$order/';

  try {
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'name': newName}),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('Timetable name updated successfully.');
    } else {
      // Enhanced error handling to include more information
      print(
          'Failed to update timetable name: Status code ${response.statusCode} - ${response.reasonPhrase}');
      print(response
          .body); // Prints the response body to get more details about the failure
    }
  } catch (e) {
    print('Error updating timetable name: $e');
  }
}
