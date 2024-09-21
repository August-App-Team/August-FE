import 'package:august/get_api/friends/convert_hangout_to_schedulelist.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:august/get_api/timetable/schedule.dart'; // Ensure correct import paths

class HangoutRequest {
  Future<ScheduleList> fetchHangout(int friendUserId, int semester) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');

    if (accessToken == null) {
      print('Access token not found');
      return ScheduleList(); // Returns an empty ScheduleList
    }

    final url = Uri.parse(
        'https://augustapp.one/friends/$friendUserId/tables/$semester/hangout/');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return createScheduleListFromJson(response.body);
    } else {
      // Correctly return an empty ScheduleList when response is not 200
      return ScheduleList();
    }
  }
}
