import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VerifyFriend {
  final int id;
  final String name;

  VerifyFriend({required this.id, required this.name});

  factory VerifyFriend.fromJson(Map<String, dynamic> json) {
    return VerifyFriend(
      id: json['id'],
      name: json['name'],
    );
  }
}

class VerifyFriendResponse {
  final bool success;
  final VerifyFriend? friend;

  VerifyFriendResponse({required this.success, this.friend});
}

class VerifyFriendService {
  Future<VerifyFriendResponse> acceptFriendRequest(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      print('Access token not found');
      return VerifyFriendResponse(success: false);
    }

    final url = Uri.parse('https://augustapp.one/friends/accept/?code=$code');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 201) {
      final jsonData = jsonDecode(response.body);
      return VerifyFriendResponse(
          success: true, friend: VerifyFriend.fromJson(jsonData['user']));
    } else {
      if (response.statusCode == 401) {
        print('Authentication credentials were not provided.');
      } else if (response.statusCode == 404) {
        print('Invalid or expired code provided.');
      } else {
        print(
            'Failed to process the request. Status Code: ${response.statusCode}');
      }
      return VerifyFriendResponse(success: false);
    }
  }
}
