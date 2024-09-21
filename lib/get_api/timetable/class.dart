import 'dart:convert';

class CourseList {
  String? name;
  String? courseCode;
  int? credits;
  List<Section>? sections; // 변경된 부분: instructors 대신 sections 사용

  CourseList({
    this.name,
    this.courseCode,
    this.credits,
    this.sections,
  });

  CourseList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    courseCode = json['course_code'];
    credits = json['credits'];

    if (json['sections'] != null) {
      // 변경된 부분
      sections = [];
      json['sections'].forEach((v) {
        sections!.add(new Section.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['course_code'] = this.courseCode;
    data['credits'] = this.credits;

    if (this.sections != null) {
      data['sections'] = this.sections!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class Section {
  int? id;
  String? code;
  List<String>? instructors;
  List<Meeting>? meetings;
  int? seats;
  int? openSeats;
  int? waitlist;
  dynamic holdfile;

  Section(
      {this.id,
      this.code,
      this.instructors,
      this.meetings,
      this.seats,
      this.openSeats,
      this.waitlist,
      this.holdfile});

  Section.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['section_code'];
    instructors = json['instructors'].cast<String>();
    if (json['meetings'] != null) {
      meetings = <Meeting>[];
      json['meetings'].forEach((v) {
        meetings!.add(new Meeting.fromJson(v));
      });
    }
    seats = json['seats'];
    openSeats = json['open_seats'];
    waitlist = json['waitlist'];
    holdfile = json['holdfile'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['section_code'] = this.code;
    data['instructors'] = this.instructors;
    if (this.meetings != null) {
      data['meetings'] = this.meetings!.map((v) => v.toJson()).toList();
    }
    data['seats'] = this.seats;
    data['open_seats'] = this.openSeats;
    data['waitlist'] = this.waitlist;
    data['holdfile'] = this.holdfile;

    return data;
  }
}

class Meeting {
  String? building;
  String? room;
  String? days;
  String? startTime;
  String? endTime;

  Meeting({this.building, this.room, this.days, this.startTime, this.endTime});

  Meeting.fromJson(Map<String, dynamic> json) {
    building = json['building'];
    room = json['room'];
    days = json['days'];
    startTime = json['start_time'];
    endTime = json['end_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['building'] = this.building;
    data['room'] = this.room;
    data['days'] = this.days;
    data['start_time'] = this.startTime;
    data['end_time'] = this.endTime;

    return data;
  }
}

///
///
///

class GroupList {
  String? name;
  String? courseCode;
  int? credits;
  String? notes;
  List<GroupInstructor>? instructors;

  GroupList(
      {this.name, this.courseCode, this.credits, this.instructors, this.notes});

  GroupList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    courseCode = json['course_code'];
    credits = json['credits'];
    notes = json['notes'];
    if (json['sections_by_instructor'] != null) {
      instructors = [];
      json['sections_by_instructor'].forEach((v) {
        instructors!.add(new GroupInstructor.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['name'] = this.name;
    data['course_code'] = this.courseCode;
    data['credits'] = this.credits;

    if (this.instructors != null) {
      data['sections_by_instructor'] =
          this.instructors!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class GroupInstructor {
  String? name;
  List<GroupSection>? sections;

  GroupInstructor({this.name, this.sections});

  GroupInstructor.fromJson(Map<String, dynamic> json) {
    name = json["name"];
    if (json["sections"] != null) {
      sections = [];
      json["sections"].forEach((v) {
        sections!.add(new GroupSection.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["name"] = this.name;

    if (this.sections != null) {
      data["sections"] = this.sections!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class GroupSection {
  int? id;
  String? fullCode;
  int? seats;
  int? openSeats;
  int? waitlist;
  dynamic holdfile;
  bool meetingsExist = true; // Now non-nullable

  GroupSection({
    this.id,
    this.fullCode,
    this.seats,
    this.openSeats,
    this.waitlist,
    this.holdfile,
    required this.meetingsExist, // Required keyword ensures it must be provided
  });

  GroupSection.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    fullCode = json["section_code"];
    seats = json['seats'];
    openSeats = json['open_seats'];
    waitlist = json['waitlist'];
    holdfile = json['holdfile'];
    meetingsExist = json['meetings_exist'] ??
        false; // Provide a default value to handle potential nulls in JSON data
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data["id"] = this.id;
    data['section_code'] = this.fullCode;
    data['seats'] = this.seats;
    data['open_seats'] = this.openSeats;
    data['waitlist'] = this.waitlist;
    data['holdfile'] = this.holdfile;
    data['meetings_exist'] = this.meetingsExist;

    return data;
  }
}
