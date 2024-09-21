import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImageHandler {
  // 이미지를 다운로드하고 Base64 인코딩 문자열로 변환하여 SharedPreferences에 저장
  Future<void> downloadAndSaveImageAsBase64(String imageUrl, String key) async {
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {
      // 이미지 데이터를 Base64 인코딩
      String base64Image = base64Encode(response.bodyBytes);
      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, base64Image);
    } else {
      throw Exception('Failed to download image.');
    }
  }
}
