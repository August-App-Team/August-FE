import 'package:august/get_api/timetable/schedule.dart';
import 'package:flutter/material.dart';

final List<Color> CourseColor = [
  Color.fromARGB(255, 171, 255, 235),
  Color.fromARGB(255, 160, 242, 255),
  Color.fromARGB(255, 190, 210, 252),
  Color.fromARGB(255, 217, 206, 255),
  Color.fromARGB(255, 253, 207, 179),
  Color.fromARGB(255, 253, 206, 214),
  Color.fromARGB(255, 255, 238, 201),
  Color.fromARGB(255, 161, 235, 198),
  Color.fromARGB(255, 185, 234, 247),
  Color.fromARGB(255, 203, 214, 254),
];

final List<Color> FriendColor = [
  Color.fromARGB(255, 203, 214, 254),
];

/* --- course dummy data --- */

final List<ScheduleList> dummyData = [
  ScheduleList(
      id: 1,
      name: "1 Course",
      courseCode: "Course 1",
      sectionCode: "1",
      instructors: [""],
      meetings: [
        ScheduleMeeting(
            building: "",
            room: "",
            days: "M",
            startTime: "09:00",
            endTime: "10:00")
      ],
      credits: 0,
      seats: 0,
      openSeats: 0,
      waitlist: 0,
      holdfile: 0),
  ScheduleList(
      id: 2,
      name: "2 Course",
      courseCode: "Course 2",
      sectionCode: "2",
      instructors: [""],
      meetings: [
        ScheduleMeeting(
            building: "",
            room: "",
            days: "Tu",
            startTime: "10:00",
            endTime: "11:00")
      ],
      credits: 0,
      seats: 0,
      openSeats: 0,
      waitlist: 0,
      holdfile: 0),
  ScheduleList(
      id: 3,
      name: "3 Course",
      courseCode: "Course 3",
      sectionCode: "3",
      instructors: [""],
      meetings: [
        ScheduleMeeting(
            building: "",
            room: "",
            days: "W",
            startTime: "9:00",
            endTime: "10:00")
      ],
      credits: 0,
      seats: 0,
      openSeats: 0,
      waitlist: 0,
      holdfile: 0),
  ScheduleList(
      id: 4,
      name: "4 Course",
      courseCode: "Course 4",
      sectionCode: "4",
      instructors: [""],
      meetings: [
        ScheduleMeeting(
            building: "",
            room: "",
            days: "Th",
            startTime: "10:00",
            endTime: "11:00")
      ],
      credits: 0,
      seats: 0,
      openSeats: 0,
      waitlist: 0,
      holdfile: 0),
  ScheduleList(
      id: 5,
      name: "5 Course",
      courseCode: "Course 5",
      sectionCode: "5",
      instructors: [""],
      meetings: [
        ScheduleMeeting(
            building: "",
            room: "",
            days: "F",
            startTime: "9:00",
            endTime: "10:00")
      ],
      credits: 0,
      seats: 0,
      openSeats: 0,
      waitlist: 0,
      holdfile: 0),
  ScheduleList(
      id: 6,
      name: "6 Course",
      courseCode: "Course 6",
      sectionCode: "6",
      instructors: [""],
      meetings: [
        ScheduleMeeting(
            building: "",
            room: "",
            days: "M",
            startTime: "11:00",
            endTime: "12:00")
      ],
      credits: 0,
      seats: 0,
      openSeats: 0,
      waitlist: 0,
      holdfile: 0),
  ScheduleList(
      id: 7,
      name: "7 Course",
      courseCode: "Course 7",
      sectionCode: "7",
      instructors: [""],
      meetings: [
        ScheduleMeeting(
            building: "",
            room: "",
            days: "Tu",
            startTime: "12:00",
            endTime: "13:00")
      ],
      credits: 0,
      seats: 0,
      openSeats: 0,
      waitlist: 0,
      holdfile: 0),
  ScheduleList(
      id: 8,
      name: "8 Course",
      courseCode: "Course 8",
      sectionCode: "8",
      instructors: [""],
      meetings: [
        ScheduleMeeting(
            building: "",
            room: "",
            days: "W",
            startTime: "11:00",
            endTime: "12:00")
      ],
      credits: 0,
      seats: 0,
      openSeats: 0,
      waitlist: 0,
      holdfile: 0),
  ScheduleList(
      id: 9,
      name: "9 Course",
      courseCode: "Course 9",
      sectionCode: "9",
      instructors: [""],
      meetings: [
        ScheduleMeeting(
            building: "",
            room: "",
            days: "Th",
            startTime: "12:00",
            endTime: "13:00")
      ],
      credits: 0,
      seats: 0,
      openSeats: 0,
      waitlist: 0,
      holdfile: 0),
  ScheduleList(
      id: 10,
      name: "10 Course",
      courseCode: "Course 10",
      sectionCode: "10",
      instructors: [""],
      meetings: [
        ScheduleMeeting(
            building: "",
            room: "",
            days: "F",
            startTime: "11:00",
            endTime: "12:00")
      ],
      credits: 0,
      seats: 0,
      openSeats: 0,
      waitlist: 0,
      holdfile: 0),
];
