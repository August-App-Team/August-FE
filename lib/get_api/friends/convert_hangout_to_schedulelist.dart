import 'dart:convert';
import 'package:august/get_api/timetable/schedule.dart'; // Ensure correct import paths

// Helper function to load meetings JSON and create a ScheduleList
ScheduleList createScheduleListFromJson(String jsonString) {
  if (jsonString.isEmpty) {
    return ScheduleList();
  }

  try {
    final jsonMap = json.decode(jsonString);
    if (jsonMap is Map<String, dynamic> && jsonMap.containsKey('meetings')) {
      final meetingsData = jsonMap['meetings'] as List<dynamic>;
      List<ScheduleMeeting> meetings = meetingsData
          .map((item) => ScheduleMeeting.fromJson(item as Map<String, dynamic>))
          .toList();

      return ScheduleList(
        id: 301,
        name: " ",
        courseCode: " ",
        sectionCode: " ",
        instructors: [" "],
        credits: 0,
        seats: 0,
        openSeats: 0,
        waitlist: 0,
        holdfile: 0,
        meetings: meetings,
      );
    }
  } catch (e) {
    // Log the error or handle it appropriately
    print('Error parsing JSON: $e');
  }

  // Return an empty ScheduleList if JSON is empty, invalid, or does not contain 'meetings'
  return ScheduleList();
}
