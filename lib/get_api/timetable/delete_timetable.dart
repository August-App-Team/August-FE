import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> deleteTimetable(String semester, int order) async {
  final prefs = await SharedPreferences.getInstance(); //류컬에서 받아옴
  final accessToken = prefs.getString('accessToken');
  if (accessToken == null) {
    print('Access token not found');
    return false;
  }

  var url = Uri.parse('https://augustapp.one/timetables/$semester/$order/');

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
          'Success to delete timetable with status code: ${response.statusCode}');
      return true;
    } else {
      print(
          'Failed to delete timetable with status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Exception occurred while deleting timetable: $e');
    return false;
  }
}
