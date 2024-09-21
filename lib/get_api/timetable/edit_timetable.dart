import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> removeCourse(String semester, int order, int sectionId) async {
  final prefs = await SharedPreferences.getInstance(); //류컬에서 받아옴
  final accessToken = prefs.getString('accessToken');
  if (accessToken == null) {
    print('Access token not found');
    return false;
  }

  var url = Uri.parse(
      'https://augustapp.one/timetables/$semester/$order/sections/$sectionId/');

  try {
    var response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 404) {
      print('Timetable not found with given semester and order.');
      return false;
    } else if (response.statusCode >= 200 && response.statusCode < 300) {
      print(
          'Success to delete course with status code: ${response.statusCode}');
      return true;
    } else {
      print('Failed to delete course with status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Exception occurred while deleting course: $e');
    return false;
  }
}

Future<bool> addCourses(
    String semester, int order, List<int?> addedCourseIds) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  if (accessToken == null) {
    print('Access token not found');
    return false;
  }

  var url =
      Uri.parse('https://augustapp.one/timetables/$semester/$order/sections/');
  bool allSuccessful = true;

  for (var courseId in addedCourseIds) {
    if (courseId == null) continue; // Skip any null values in the list

    // Prepare the body of the POST request for each courseId
    var body = courseId.toString();

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: body, // Include the single courseId in the request
      );

      if (response.statusCode != 200) {
        // Check if the response is exactly 200, assuming 200 is the only success code based on your API
        print(
            'Failed to add course with ID $courseId, status code: ${response.statusCode}');
        allSuccessful =
            false; // If any request fails, set allSuccessful to false
      } else {
        print('Successfully added course with ID $courseId');
      }
    } catch (e) {
      print('Exception occurred while adding course with ID $courseId: $e');
      allSuccessful = false;
    }
  }

  return allSuccessful; // Return true if all IDs were added successfully, false if any failed
}

Future<bool> reorderTimetable(String semester, List<int?> order) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    print('Access token not found');
    return false;
  }

  // Ensure the semester variable is directly inserted into the URL path.
  var url = Uri.parse('https://augustapp.one/timetables/$semester/reorder/');

  bool allSuccessful = true;

  try {
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(order), // Convert the order list to JSON string
    );
    print('This is from API: ${jsonEncode(order)}');

    if (response.statusCode != 200) {
      print('Failed to reorder timetable, status code: ${response.statusCode}');
      allSuccessful = false;
    } else {
      print('Successfully reordered timetable');
    }
  } catch (e) {
    print('Exception occurred while reordering timetable: $e');
    allSuccessful = false;
  }

  return allSuccessful;
}
