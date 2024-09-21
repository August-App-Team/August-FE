import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<int> getCount(String jsonData) async {
  print('Sending data: $jsonData'); // Add this line
  Uri uri = Uri.parse('https://augustapp.one/wizard/schedules/count/');

  final request = http.Request('GET', uri)
    ..headers[HttpHeaders.contentTypeHeader] = 'application/json'
    ..body = jsonData;

  final stopwatch = Stopwatch()..start(); // Start measuring time

  try {
    final response = await http.Client()
        .send(request)
        .then(http.Response.fromStream)
        .timeout(Duration(seconds: 15)); // Set a 15 second timeout

    stopwatch.stop(); // Stop measuring time

    // Print the time taken in seconds
    print('Request completed in ${stopwatch.elapsedMilliseconds / 1000} s');

    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      print(response.body);
      return int.parse(
          response.body); // Return the number directly without conversion
    } else {
      throw Exception(
          'Failed to get data with status code ${response.statusCode} and body ${response.body} and time ${stopwatch.elapsedMilliseconds / 1000} s');
    }
  } on TimeoutException {
    stopwatch.stop(); // Stop measuring time if there was a timeout
    // Instead of throwing an exception, return 0
    print('Request timed out after 15 seconds. Returning 0 as the count.');
    return 0;
  }
}
