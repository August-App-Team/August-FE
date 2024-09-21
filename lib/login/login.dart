import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:august/get_api/onboard/get_user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveTokensToSpecificPath(
    String accessToken, String idToken) async {
  try {
    // Specify the path directly
    String path = '/Users/Files/tokens.txt';

    // Create a file at the specified path
    final file = File(path);

    // Write the tokens to the file
    await file.writeAsString('AccessToken: $accessToken\nIdToken: $idToken');
  } catch (e) {
    print('Failed to write tokens to file: $e');
    // Handle the exception, maybe show a dialog or a toast to the user
  }
}

Future<void> saveTokens(String accessToken, String refreshToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('accessToken', accessToken);
  await prefs.setString('refreshToken', refreshToken);
}

Future<bool> checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  if (accessToken != null) {
    print('Using current access token to login');
    return true;
  } else {
    print('No access token found. Need login or token refresh.');
    return false;
  }
}

Future<bool> refreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  final refreshToken = prefs.getString('refreshToken');
  if (refreshToken == null) {
    print('No refresh token found');
    return false;
  }

  final response = await http.post(
    Uri.parse('https://augustapp.one/dj-rest-auth/token/refresh/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refresh': refreshToken}),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final newAccessToken = responseData['access'];
    final newRefreshToken = responseData['refresh'] ??
        refreshToken; // Fallback to old refreshToken if not provided

    await prefs.setString('accessToken', newAccessToken);
    await prefs.setString('refreshToken', newRefreshToken);
    print('Token refreshed successfully');
    return true;
  } else {
    print('Failed to refresh token, Status code: ${response.statusCode}');
    return false;
  }
}

Future<bool> checkAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  if (accessToken == null) {
    print('No access token found, attempting to refresh...');
    return await refreshToken();
  }

  // Perform a test API call that requires authentication
  final testResponse = await http.get(
    Uri.parse(
        'https://augustapp.one/dj-rest-auth/user/'), // Adjust the URL to your needs
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (testResponse.statusCode == 200) {
    print('Access token is valid.');
    return true;
  } else if (testResponse.statusCode == 401) {
    // If the token is expired or invalid, attempt to refresh it
    print('Access token expired or invalid, attempting to refresh...');
    return await refreshToken();
  } else {
    print(
        'Failed to validate access token, Status code: ${testResponse.statusCode}');
    return false;
  }
}

Future<bool> initApp(BuildContext context) async {
  final isLoggedIn = await checkLoginStatus();
  if (!isLoggedIn) {
    final isTokenRefreshed = await refreshToken();
    if (isTokenRefreshed) {
      // 사용자 정보를 가져오고 출력
      await fetchAndPrintUserInfo(context);

      return true; // 로그인 상태가 유효하다고 가정
    } else {
      // 토큰 갱신 실패
      print('Token refresh failed');
      return false;
    }
  } else {
    // 이미 로그인되어 있음
    await fetchAndPrintUserInfo(context);
    return true;
  }
}

Future<bool> fetchAndPrintUserInfo(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  if (accessToken == null) {
    print("Access token not found, user needs to login.");
    return false;
  }

  final response = await http.get(
    Uri.parse('https://augustapp.one/dj-rest-auth/user/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    print("User info fetched successfully.");
    fetchUserDetails();
    // 여기서 사용자 정보를 처리하거나 표시할 수 있습니다.
    return true;
  } else {
    print("Failed to fetch user info.");

    return false;
  }
}

//사람 확인하기
Future<bool> verifyUser() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  if (accessToken == null) {
    print('Access token not found');
    return false;
  }

  final response = await http.get(
    Uri.parse('https://augustapp.one/dj-rest-auth/user/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    print('User verified: $responseData');
    return true;
  } else {
    print('Failed to verify user');
    return false;
  }
}

//기본 정보 가져오기
Future<UserDetails?> fetchUserDetails() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final userPk = prefs.getInt('userPk');

  if (accessToken == null || userPk == null) {
    print('Access token or user PK not found');
    return null;
  }

  final response = await http.get(
    Uri.parse('https://augustapp.one/users/$userPk/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final responseBody = utf8.decode(response.bodyBytes);
    final responseData = jsonDecode(responseBody);
    print('User details fetched: $responseData');
    return UserDetails.fromJson(responseData);
  } else {
    print('Failed to fetch user details');
    return null;
  }
}

Future<String?> fetchUserEmail() async {
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    print('Access token not found. User needs to login.');
    return null;
  }

  final response = await http.get(
    Uri.parse('https://augustapp.one/dj-rest-auth/user/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final String userEmail = responseData['email'];
    print('User Email fetched successfully: $userEmail');

    // 이메일을 로컬에 저장
    await prefs.setString('userEmail', userEmail);

    return userEmail;
  } else {
    print('Failed to fetch user Email. Status code: ${response.statusCode}');
    return null;
  }
}

Future<void> logoutUser() async {
  final prefs = await SharedPreferences.getInstance();

  await prefs.clear();

  print('check hasSeenOnboard ${prefs.getBool('hasSeenOnboard')}');
  print('check isFirst ${prefs.getBool('isFirst')}');

  print('User logged out. All user data deleted.');

  // 로그아웃 후 처리, 예를 들어 로그인 화면으로 이동
  // Navigator.of(context).pushReplacementNamed('/login');
}

Future<void> deleteUser() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('accessToken');
  final userPk = prefs.getInt('userPk');

  if (accessToken == null || userPk == null) {
    print('Access token or user PK not found');
    return null;
  }

  final response = await http.post(
    Uri.parse('https://augustapp.one/users/me/delete/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 204) {
    print('User deleted successfully');
    return null;
  } else {
    print('Failed to delete user');
    return null;
  }
}

/* ----------------------- 여기서 부터는 사용자 정보 업데이트 --------------------------*/

Future<String?> refreshTokenForElement() async {
  final prefs = await SharedPreferences.getInstance();
  final refreshToken = prefs.getString('refreshToken');
  if (refreshToken == null) {
    print('No refresh token found');
    return null;
  }

  final response = await http.post(
    Uri.parse('https://augustapp.one/dj-rest-auth/token/refresh/'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'refresh': refreshToken}),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final newAccessToken = responseData['access'];
    await prefs.setString('accessToken', newAccessToken);
    print('Token refreshed successfully');
    return newAccessToken;
  } else {
    print('Failed to refresh token');
    return null;
  }
}

//pk만 가져오기
Future<int?> fetchUserPk() async {
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    print('Access token not found. User needs to login.');
    return null;
  }

  final response = await http.get(
    Uri.parse('https://augustapp.one/dj-rest-auth/user/'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    final int userPk = responseData['id'];
    print('User PK fetched successfully: $userPk');
    return userPk;
  } else {
    print('Failed to fetch user details. Status code: ${response.statusCode}');
    return null;
  }
}

//사용자 정보 PATCH (각각 변경)
Future<void> updateName(int userPk, String name) async {
  final String url = 'https://augustapp.one/users/$userPk/';
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    print('Access token not found. User needs to login.');
    return;
  }

  final response = await http.patch(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      'name': name,
    }),
  );

  if (response.statusCode == 200) {
    print('User details updated successfully.');
  } else {
    print('Failed to update user details. Status code: ${response.statusCode}');
  }
}

Future<void> updatePhoto(int userPk, File imageFile) async {
  final String url = 'https://augustapp.one/users/$userPk/';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    print('Access token not found. Attempting to refresh token...');
    accessToken = await refreshTokenForElement();
    if (accessToken == null) {
      print('Failed to refresh token. User needs to login again.');
      return;
    }
  }

  var request = http.MultipartRequest('PATCH', Uri.parse(url))
    ..headers['Authorization'] = 'Bearer $accessToken'
    ..files.add(await http.MultipartFile.fromPath(
      'profile_image',
      imageFile.path,
    ));

  try {
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      print('Profile photo updated successfully.');
    } else if (response.statusCode == 401) {
      // 토큰 만료 감지
      print('Access token expired. Attempting to refresh token...');
      accessToken = await refreshTokenForElement();
      if (accessToken != null) {
        // 토큰 갱신 성공 후, 사진 업데이트 재시도
        await updatePhoto(userPk, imageFile); // 재귀 호출
      } else {
        print('Failed to refresh token. User needs to login again.');
      }
    } else {
      print(
          'Failed to update profile photo. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  } catch (e) {
    print('Exception caught: $e');
  }
}

/* --- 유저 이미지 default --- */
Future<String?> getUserDefaultPhoto() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String url = 'https://augustapp.one/users/me/profile-image/reset/';
  String? accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    print('Access token not found. Attempting to refresh token...');
    accessToken = await refreshTokenForElement();
    if (accessToken == null) {
      print('Failed to refresh token. User needs to login again.');
      return null;
    }
  }

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      var responseData = jsonDecode(response.body);
      print(responseData['profile_image']);
      return responseData['profile_image'];
    } else {
      print(
          'Failed to reset profile image. Status code: ${response.statusCode}, Body: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Exception caught when trying to reset profile image: $e');
    return null;
  }
}

Future<void> updateInstitution(int userPk, int institution) async {
  final String url = 'https://augustapp.one/users/$userPk/';
  final prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    print('Access token not found. Attempting to refresh token...');
    accessToken = await refreshTokenForElement();
    if (accessToken == null) {
      print('Failed to refresh token. User needs to login again.');
      return;
    }
  }
  print('this is institution: $institution');

  final response = await http.patch(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({'institution_id': institution}),
  );

  if (response.statusCode == 200) {
    print('User details updated successfully.');
  } else if (response.statusCode == 401) {
    // 토큰 만료 감지
    print('Access token expired. Attempting to refresh token...');
    accessToken = await refreshTokenForElement();
    if (accessToken != null) {
      // 토큰 갱신 성공 후, 기관 정보 업데이트 재시도
      await updateInstitution(userPk, institution); // 재귀 호출
    } else {
      print('Failed to refresh token. User needs to login again.');
    }
  } else {
    print('Failed to update user details. Status code: ${response.body}');
  }
}

Future<void> updateGrade(int userPk, String yearInSchool) async {
  final String url = 'https://augustapp.one/users/$userPk/';
  final prefs = await SharedPreferences.getInstance();
  final String? accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    print('Access token not found. User needs to login.');
    return;
  }

  final response = await http.patch(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body: jsonEncode({
      'year_in_school': yearInSchool,
    }),
  );

  if (response.statusCode == 200) {
    print('User details updated successfully.');
  } else {
    print('Failed to update user details. Status code: ${response.statusCode}');
  }
}

Future<void> updateDepartment(int userPk, int? department) async {
  final String url = 'https://augustapp.one/users/$userPk/';
  final prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');

  if (accessToken == null) {
    print('Access token not found. Attempting to refresh token...');
    accessToken = await refreshTokenForElement();
    if (accessToken == null) {
      print('Failed to refresh token. User needs to login again.');
      return;
    }
  }
  print('this is department: $department');

  final response = await http.patch(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    },
    body:
        jsonEncode({'department_id': (department != null) ? department : null}),
  );

  if (response.statusCode == 200) {
    print('User details updated successfully.');
  } else if (response.statusCode == 401) {
    // 토큰 만료 감지
    print('Access token expired. Attempting to refresh token...');
    accessToken = await refreshTokenForElement();
    if (accessToken != null) {
      // 토큰 갱신 성공 후, 기관 정보 업데이트 재시도
      await updateDepartment(userPk, department); // 재귀 호출
    } else {
      print('Failed to refresh token. User needs to login again.');
    }
  } else {
    print('Failed to update user details. Status code: ${response.statusCode}');
  }
}

///////// 토른 리프레시 자동화 /////////
class TimerService {
  Timer? _timer;

  void startTimer(Function callback,
      {Duration interval = const Duration(minutes: 1)}) {
    stopTimer(); // 이미 실행 중인 타이머가 있다면 중지
    _timer = Timer.periodic(interval, (Timer t) => callback());
  }

  void stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }
}

// 앱 시작 시 호출, 상시 호출하여 토큰 리프레쉬

void startTokenRefreshTimer() {
  TimerService timerService = TimerService();
  timerService.startTimer(() async {
    bool refreshTokenNeeded = await checkIfRefreshTokenNeeded();
    if (refreshTokenNeeded) {
      bool refreshedSuccessfully = await refreshToken();
      if (!refreshedSuccessfully) {
        // 토큰 갱신 실패 처리, 예를 들어 로그아웃
        logoutUser();

        print('Token refresh failed.');
      } else {
        print('Token refresh successful.');
      }
    }
  }, interval: Duration(minutes: 5));
}

Future<bool> checkIfRefreshTokenNeeded() async {
  final prefs = await SharedPreferences.getInstance();
  String? expirationString = prefs.getString('accessTokenExpiration');
  if (expirationString == null) return true;

  DateTime expirationDate = DateTime.parse(expirationString);

  return DateTime.now().isAfter(expirationDate.subtract(Duration(minutes: 5)));
}
