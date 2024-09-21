import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<List<dynamic>> sendJsonData(String jsonData) async {
  print('Sending data: $jsonData'); // Add this line
  Uri uri = Uri.parse('https://augustapp.one/wizard/schedules/');

  final request = http.Request('GET', uri)
    ..headers[HttpHeaders.contentTypeHeader] = 'application/json'
    ..body = jsonData;

  final response =
      await http.Client().send(request).then(http.Response.fromStream);

  if (response.statusCode == HttpStatus.ok ||
      response.statusCode == HttpStatus.created) {
    print(response.body);
    return jsonDecode(response.body);
  } else {
    throw Exception(
        'Failed to get data with status code ${response.statusCode} and body ${response.body}');
  }
}
