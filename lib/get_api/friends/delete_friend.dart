import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> deleteFriend(int friendsId) async {
  final prefs = await SharedPreferences.getInstance(); //류컬에서 받아옴
  final accessToken = prefs.getString('accessToken');
  if (accessToken == null) {
    print('Access token not found');
    return false;
  }

  var url = Uri.parse('https://augustapp.one/friends/$friendsId/');

  try {
    var response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 404) {
      print('Friend not found with given ID.');
      return false;
    } else if (response.statusCode >= 200 && response.statusCode < 300) {
      print(
          'Friend deleted successfully with status code: ${response.statusCode}');
      return true;
    } else {
      print('Failed to delete friend with status code: ${response.statusCode}');
      return false;
    }
  } catch (e) {
    print('Exception occurred while deleting friend: $e');
    return false;
  }
}
