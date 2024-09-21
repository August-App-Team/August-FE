import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FriendsRequestCode {
  final String code;
  final String expires;
  final String url;

  FriendsRequestCode(
      {required this.code, required this.expires, required this.url});

  factory FriendsRequestCode.fromJson(Map<String, dynamic> json) {
    return FriendsRequestCode(
      code: json['code'],
      expires: json['expires_at'],
      url: json['url'] ?? 'URL not available',
    );
  }
}

class FriendRequestService {
  Future<FriendsRequestCode> createFriendRequestCode() async {
    final url = Uri.parse('https://augustapp.one/friends/new-request-code/');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return FriendsRequestCode.fromJson(data);
    } else if (response.statusCode == 401) {
      print('Authentication failed. Please check your credentials.');
      throw Exception();
    } else {
      print('Failed to create friend request code.');
      throw Exception();
    }
  }

  Future<void> revokeFriendRequestCode() async {
    final url = Uri.parse('https://augustapp.one/friends/revoke-code/');

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('Successfully deleted the friend request code.');
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      print('Authentication failed. Please check your credentials.');
      throw Exception();
    } else {
      print('Failed to delete friend request code.');
      throw Exception();
    }
  }
}
