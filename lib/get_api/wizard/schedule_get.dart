class ScheduleList {
  int? id;
  String? name;
  List<String>? instructors;
  List<ScheduleMeeting>? meetings;
  String? courseCode;
  String? sectionCode;
  int? credits;

  ScheduleList({
    this.id, //모든 정보를 합친 데이터
    this.name,
    this.instructors,
    this.meetings, //classroom
    this.courseCode, //courseID
    this.sectionCode, //sectionID
    this.credits,
  });

  ScheduleList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];

    // // Check if 'instructors' is not null before converting
    // if (json['instructors'] != null) {
    //   instructors = List<String>.from(json['instructors']);
    // }

    // // Check if 'meetings' is not null before converting
    // if (json['meetings'] != null) {
    //   meetings = List<ScheduleMeeting>.from(
    //       json['meetings'].map((m) => ScheduleMeeting.fromJson(m)));
    // }
    meetings = List<ScheduleMeeting>.from(
        json['meetings'].map((m) => ScheduleMeeting.fromJson(m)));
    instructors = List<String>.from(json['instructors']);
    courseCode = json['course_code'];
    sectionCode = json['section_code'];
    credits = json['credits'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['instructors'] = instructors;
    data['meetings'] = meetings?.map((m) => m.toJson()).toList();
    data['course_code'] = courseCode;
    data['section_code'] = sectionCode;
    data['credits'] = credits;
    return data;
  }
}

class ScheduleMeeting {
  String? building;
  String? room;
  String? days;
  String? startTime;
  String? endTime;

  ScheduleMeeting(
      {this.building, this.room, this.days, this.startTime, this.endTime});

  ScheduleMeeting.fromJson(Map<String, dynamic> json) {
    building = json['building'];
    room = json['room'];
    days = json['days'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['building'] = building;
    data['room'] = room;
    data['days'] = days;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    return data;
  }
}
