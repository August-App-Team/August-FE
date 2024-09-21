// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:august/const/device/device_util.dart';
import 'package:august/const/font/font.dart';
import 'package:august/provider/course_color_provider.dart';
import 'package:august/get_api/timetable/schedule.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../const/colors/course_color.dart';

import '../home/button.dart';
import '../../provider/courseprovider.dart';

class TimeTables extends StatelessWidget {
  final List<List<ScheduleList>> coursesData;
  final PageController? pageController;
  final bool isSelectpage;
  String? name;
  int? credits;
  int? order;

  TimeTables({
    Key? key,
    required this.coursesData,
    this.pageController,
    this.isSelectpage = false,
    this.name,
    this.credits,
    this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController ?? PageController(),
      itemCount: coursesData.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: pageController ?? PageController(),
          builder: (BuildContext context, _) {
            double value = 1;
            // if (pageController!.position.haveDimensions) {
            //   value = pageController!.page! - index;
            //   value = (1 - (value.abs() * 0.1)).clamp(0.96, 1.0);
            // }
            return SizedBox.expand(
              child: Transform.scale(
                scale: value,
                child: SingleChildScrollView(
                  child: SingleTimetable(
                    courses: coursesData[index],
                    index: index,
                    isSelectpage: isSelectpage,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class SingleTimetable extends StatefulWidget {
  final List<ScheduleList> courses;
  final int index;
  final bool isSelected;
  final bool showEditButton;
  final bool forceFixedTimeRange;
  final bool isSelectpage;
  final bool isFriend;
  final bool isCustomizeColor;
  const SingleTimetable(
      {Key? key,
      required this.courses,
      required this.index,
      this.isSelected = false,
      this.showEditButton = false,
      this.forceFixedTimeRange = false,
      this.isSelectpage = false,
      this.isFriend = false,
      this.isCustomizeColor = false})
      : super(key: key);
  @override
  _SingleTimetableState createState() => _SingleTimetableState();
}

class _SingleTimetableState extends State<SingleTimetable> {
  final List<String> week = ['M', 'Tu', 'W', 'Th', 'F'];
  final double FirstColumnHeight = 20;
  final double tabletFirstColumnHeight = 20;
  final double boxSize = 60;
  final double tabletBoxSize = 120;
  late int ColumnLength;
  List<ScheduleList>? courses;
  late List<int> displayedHours;
  late Duration earliestStartTime;
  late Duration latestEndTime;
  Map<int, Color> _courseColorMap = {};
  int _colorIndex = 0;

  // Color getCourseColor(int courseId) {
  //   if (!_courseColorMap.containsKey(courseId)) {
  //     _courseColorMap[courseId] = CourseColor[_colorIndex];
  //     _colorIndex = (_colorIndex + 1) % CourseColor.length;
  //   }

  //   return _courseColorMap[courseId]!;
  // }

  Color getColorForFriends(int courseId) {
    if (!_courseColorMap.containsKey(courseId)) {
      _courseColorMap[courseId] = FriendColor[_colorIndex];
      _colorIndex = (_colorIndex + 1) % FriendColor.length;
    }

    return _courseColorMap[courseId]!;
  }

  String _formatTime(Duration duration) {
    int hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final ampm = hours >= 12 ? 'PM' : 'AM';

    hours = hours % 12;
    hours = hours != 0 ? hours : 12; // Convert hour '0' to '12'

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')} $ampm';
  }

  Duration _parseTime(String time) {
    final cleanTime = time.replaceAll(RegExp(r'[a-zA-Z]'), '');

    final timeParts = cleanTime.split(':');
    final hours = int.parse(timeParts[0]);

    // 분에 대한 처리 추가
    final minutes = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;

    return Duration(hours: hours, minutes: minutes);
  }

  @override
  void initState() {
    super.initState();

    if (widget.courses.isEmpty || widget.forceFixedTimeRange) {
      earliestStartTime = Duration(hours: 7);
      latestEndTime = Duration(hours: 22);
    } else {
      latestEndTime = Duration(minutes: 0);
      earliestStartTime = Duration(hours: 24);

      for (var course in widget.courses) {
        for (var meeting in course.meetings!) {
          var startTime = _parseTime(meeting.startTime ?? '');
          if (startTime < earliestStartTime) {
            earliestStartTime = startTime;
          }
          var endTime = _parseTime(meeting.endTime ?? '');
          if (endTime > latestEndTime) {
            latestEndTime = endTime;
          }
        }
      }

      // 'earliestStartTime'을 시간 기준으로 조정
      earliestStartTime = Duration(hours: earliestStartTime.inHours);
    }
    ColumnLength =
        ((latestEndTime.inMinutes - earliestStartTime.inMinutes) / 30 + 1)
            .round();
  }

  String formatInstructorName(String name, int maxLength) {
    if (name.length > maxLength) {
      return name.substring(0, maxLength) + '';
    } else {
      return name;
    }
  }

  String convertDays(day) {
    if (day == 'M') {
      day = 'Monday';
    } else if (day == 'Tu') {
      day = 'Tuesday';
    } else if (day == 'W') {
      day = 'Wednesday';
    } else if (day == 'Th') {
      day = 'Thursday';
    } else if (day == 'F') {
      day = 'Friday';
    }
    return day;
  }

  String formatMinutes(int minutes) {
    int hours = minutes ~/ 60; // Get the full hours
    int remainingMinutes = minutes % 60; // Get the remaining minutes

    if (hours > 0 && remainingMinutes > 0) {
      // If there are hours and remaining minutes
      return '${hours} hour${hours > 1 ? 's' : ''}\n${remainingMinutes} min';
    } else if (hours > 0) {
      // If there are only hours
      return '${hours} hour${hours > 1 ? 's' : ''}';
    } else {
      // If there are only minutes
      return '$remainingMinutes min';
    }
  }

  Widget buildCourseBox(
      ScheduleList schedule, ScheduleMeeting meeting, int courseIndex,
      {int? dayIndex}) {
    var startTime = _parseTime(meeting.startTime ?? '');
    var endTime = _parseTime(meeting.endTime ?? '');
    var day = convertDays(meeting.days);

    // Overflow 방지를 위해 최대값과 최소값 설정
    if (startTime < earliestStartTime) {
      startTime = earliestStartTime;
    }
    if (endTime > latestEndTime) {
      endTime = latestEndTime;
    }

    var startOffsetMinutes = startTime.inMinutes - earliestStartTime.inMinutes;
    var durationMinutes = endTime.inMinutes - startTime.inMinutes;

    var top = DeviceUtils.isTablet(context)
        ? (tabletFirstColumnHeight +
            (startOffsetMinutes / 60.0 * tabletBoxSize))
        : (FirstColumnHeight + (startOffsetMinutes / 60.0 * boxSize));

    var height = DeviceUtils.isTablet(context)
        ? (durationMinutes / 60.0 * tabletBoxSize)
        : (durationMinutes / 60.0 * boxSize);
    // var boxColor = widget.isFriend
    //     ? Provider.of<CourseColorProvider>(context)
    //         .getColorForFriend(schedule.id!)
    //     : Provider.of<CourseColorProvider>(context)
    //         .getColorForCourse(schedule.id!);

// 시간표 안에 있는 정보
    List<Widget> children = [];
    var boxColor =
        Provider.of<CourseColorProvider>(context).getColorByIndex(courseIndex);

    Size screenSize = MediaQuery.of(context).size;
    double minHeightForLargeDevice = 812.0;
    bool isLargeDevice = screenSize.height > minHeightForLargeDevice;

//isSelectpage
    if (widget.isCustomizeColor) {
      children.add(
        Container(
          width: double.infinity, // Take full width to center the text
          padding: EdgeInsets.only(top: 10), // Minimal padding from the top
          child: Text(
            schedule.sectionCode!,
            textAlign: TextAlign.center, // Center text horizontally
            style: AugustFont.head6(color: Colors.black),
          ),
        ),
      );
    }
    if (widget.isFriend == true && !widget.isCustomizeColor) {
      if (height > 15) {
        children.add(
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                  text: formatMinutes(durationMinutes),
                  style: AugustFont.captionSmallBold3(color: Colors.black),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: <TextSpan>[
                TextSpan(
                  text: formatMinutes(durationMinutes),
                  style: AugustFont.captionSmallBold2(color: Colors.black),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      if (height < 60 && !widget.isCustomizeColor) {
        children.addAll([
          Text(
            schedule.sectionCode!,
            style: AugustFont.captionSmallNormal0(color: Colors.black),
          ),
          if (isLargeDevice && Platform.isIOS)
            Text(
              '${schedule.instructors!.first}',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AugustFont.captionSmallNormal2(color: Colors.black),
            ),
          // Add other widgets specific to height > 20 condition
        ]);
      } else if (height > 50 && !widget.isCustomizeColor) {
        children.addAll([
          Text(
            schedule.sectionCode!,
            style: AugustFont.captionSmallNormal0(color: Colors.black),
          ),
          Text(
            '${schedule.instructors!.first}',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AugustFont.captionSmallNormal2(color: Colors.black),
          ),
          // Add other widgets specific to height > 20 condition
        ]);
      }

      if (height > 50 && dayIndex != null && !widget.isCustomizeColor) {
        children.add(
          Text(
            '${schedule.meetings!.firstWhere((meeting) => meeting.days?.contains(week[dayIndex]) ?? false).building} ${schedule.meetings!.firstWhere((meeting) => meeting.days?.contains(week[dayIndex]) ?? false).room}',
            style: AugustFont.captionSmallNormal1(color: Colors.black),
          ),
        );
      } else if (dayIndex != null) {
        if (widget.isSelectpage) {
          children.addAll([
            // Add other widgets specific to height > 20 condition
          ]);
        } else {
          children.add(
            Text(
              '${schedule.meetings!.firstWhere((meeting) => meeting.days?.contains(week[dayIndex]) ?? false).building} ${schedule.meetings!.firstWhere((meeting) => meeting.days?.contains(week[dayIndex]) ?? false).room}',
              style: AugustFont.captionSmallNormal1(color: Colors.black),
            ),
          );
        }
      }
    }

    // Wrap your Scaffold with a GestureDetector to detect swipe down

    return widget.isCustomizeColor
        ? Positioned(
            top: top,
            left: 0.0,
            right: 0.0,
            height: height,
            child: Container(
              decoration: BoxDecoration(
                color: boxColor,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children),
            ),
          )
        : Positioned(
            top: top,
            left: 0.0,
            right: 0.0,
            height: height,
            child: Padding(
              padding: const EdgeInsets.only(left: 1),
              child: OpenContainer(
                openColor: boxColor,
                closedColor: boxColor,
                transitionDuration: Duration(milliseconds: 400),
                transitionType:
                    ContainerTransitionType.fadeThrough, // 애니메이션 타입 설정
                closedBuilder: (BuildContext _, VoidCallback openContainer) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact(); // 터치 피드백 추가
                      openContainer();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: boxColor,
                      ),
                      child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: children)),
                    ),
                  );
                },
                closedShape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.all(
                    widget.isFriend ? Radius.circular(0) : Radius.circular(2),
                  ), // 직각 모서리
                ),

                openBuilder: (
                  BuildContext _,
                  VoidCallback __,
                ) {
                  return GestureDetector(
                    onVerticalDragEnd: (details) {
                      // Check if swipe direction is down
                      if (details.primaryVelocity! > 0) {
                        Navigator.of(context).pop(); // Close the OpenContainer
                      }
                    },
                    child: Scaffold(
                      extendBody: true,
                      backgroundColor: boxColor,
                      body: ColorfulSafeArea(
                        color: boxColor,
                        bottomColor: Colors.white.withOpacity(0),
                        overflowRules: OverflowRules.only(bottom: true),
                        child: (widget.isFriend == false)
                            ? SingleChildScrollView(
                                child: Container(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width, // 화면 너비에 맞춤
                                  color: boxColor,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 20, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            'Course',
                                            style: AugustFont.subText5(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 5, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            '${schedule.sectionCode}',
                                            style: AugustFont.head1(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 20, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            'Name',
                                            style: AugustFont.subText5(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 5, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            '${schedule.name}',
                                            style: AugustFont.head1(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 20, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            'Instructor',
                                            style: AugustFont.subText5(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 5, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            '${schedule.instructors?.join(', ')}',
                                            style: AugustFont.head1(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 20, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            'Time',
                                            style: AugustFont.subText5(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 5, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            '${_formatTime(_parseTime(meeting.startTime ?? ''))} ~ ${_formatTime(_parseTime(meeting.endTime ?? ''))}',
                                            style: AugustFont.head1(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 20, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            'Location',
                                            style: AugustFont.subText5(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 5, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            '${meeting.building} ${meeting.room}',
                                            style: AugustFont.head1(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 20, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            'Credit',
                                            style: AugustFont.subText5(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 5, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            '${schedule.credits} credits',
                                            style: AugustFont.head1(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 20,
                                                    top: 20,
                                                    right: 10),
                                                child: Align(
                                                  alignment: Alignment
                                                      .centerLeft, // 왼쪽 정렬
                                                  child: Text(
                                                    'Seats',
                                                    style: AugustFont.subText5(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 20,
                                                    top: 5,
                                                    right: 10),
                                                child: Align(
                                                  alignment: Alignment
                                                      .centerLeft, // 왼쪽 정렬
                                                  child: Text(
                                                    '${schedule.seats}',
                                                    style: AugustFont.head1(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 20,
                                                    right: 10),
                                                child: Align(
                                                  alignment: Alignment
                                                      .centerLeft, // 왼쪽 정렬
                                                  child: Text(
                                                    'Open Seats',
                                                    style: AugustFont.subText5(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 5,
                                                    right: 10),
                                                child: Align(
                                                  alignment: Alignment
                                                      .centerLeft, // 왼쪽 정렬
                                                  child: Text(
                                                    '${schedule.openSeats}',
                                                    style: AugustFont.head1(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 20,
                                                    right: 10),
                                                child: Align(
                                                  alignment: Alignment
                                                      .centerLeft, // 왼쪽 정렬
                                                  child: Text(
                                                    'Waitlist',
                                                    style: AugustFont.subText5(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 5,
                                                    right: 10),
                                                child: Align(
                                                  alignment: Alignment
                                                      .centerLeft, // 왼쪽 정렬
                                                  child: Text(
                                                    '${schedule.waitlist}',
                                                    style: AugustFont.head1(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Spacer(),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 20,
                                                    right: 20),
                                                child: Align(
                                                  alignment: Alignment
                                                      .centerLeft, // 왼쪽 정렬
                                                  child: Text(
                                                    'Holdfile',
                                                    style: AugustFont.subText5(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10,
                                                    top: 5,
                                                    right: 20),
                                                child: Align(
                                                  alignment: Alignment
                                                      .centerLeft, // 왼쪽 정렬
                                                  child: Text(
                                                    (schedule.holdfile == null)
                                                        ? '0'
                                                        : '${schedule.holdfile}',
                                                    style: AugustFont.head1(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 50)
                                        ],
                                      ),
                                      SizedBox(height: 120)
                                    ],
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: Container(
                                  width: MediaQuery.of(context)
                                      .size
                                      .width, // Adjusts the container's width to the full width of the screen
                                  color:
                                      boxColor, // Background color of the container
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .start, // Centers the children vertically
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start, // Centers the children horizontally
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 20, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            'Date',
                                            style: AugustFont.head7(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 5, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            '$day',
                                            style: AugustFont.friendTime(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 20, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            'Total Time',
                                            style: AugustFont.head7(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 5, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            formatMinutes(durationMinutes),
                                            style: AugustFont.friendTime(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 20, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            'Time',
                                            style: AugustFont.head7(
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 20, top: 5, right: 20),
                                        child: Align(
                                          alignment:
                                              Alignment.centerLeft, // 왼쪽 정렬
                                          child: Text(
                                            '${_formatTime(_parseTime(meeting.startTime ?? ''))} ~\n${_formatTime(_parseTime(meeting.endTime ?? ''))}',
                                            style: AugustFont.friendTime(
                                                color: Colors.black),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      // Text(
                                      //   '${_formatTime(_parseTime(meeting.startTime ?? ''))}', // Displays formatted start time
                                      //   style: TextStyle(
                                      //     fontSize: 40,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.black,
                                      //   ),
                                      //   textAlign: TextAlign.center,
                                      // ),
                                      // Text(
                                      //   '~', // Separator
                                      //   style: TextStyle(
                                      //     fontSize: 40,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.black,
                                      //   ),
                                      //   textAlign: TextAlign.center,
                                      // ),
                                      // Text(
                                      //   '${_formatTime(_parseTime(meeting.endTime ?? ''))}', // Displays formatted end time
                                      //   style: TextStyle(
                                      //     fontSize: 40,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.black,
                                      //   ),
                                      //   textAlign: TextAlign.center,
                                      //),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                      bottomNavigationBar: Container(
                        color: Colors.white.withOpacity(0),
                        child: widget.showEditButton
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0, top: 0, bottom: 30),
                                    child: Button(
                                      buttonColor: Colors.red,
                                      height: 60,
                                      text: 'Remove',
                                      width: 100,
                                      textColor: Colors.white,
                                      onTap: () {
                                        if (schedule.id != null) {
                                          Provider.of<CoursesProvider>(context,
                                                  listen: false)
                                              .removeCourse(
                                                  widget.index, schedule.id!);

                                          Provider.of<CoursesProvider>(context,
                                                  listen: false)
                                              .removeCourseFromTimetableforEditingPage(
                                                  schedule.id!);
                                          Provider.of<CoursesProvider>(context,
                                                  listen: false)
                                              .removedCourseforEditPage(
                                                  schedule.id!);

                                          Navigator.of(context).pop();
                                        } else {
                                          print('Error : course id is null');
                                        }
                                      },
                                      borderColor: Colors.red,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 30,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 0, top: 0, bottom: 30),
                                    child: Button(
                                      buttonColor: Colors.black,
                                      height: 60,
                                      text: 'Close',
                                      width: 100,
                                      textColor: Colors.white,
                                      onTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      borderColor: Theme.of(context)
                                          .colorScheme
                                          .background,
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    left: 120, top: 0, bottom: 30, right: 120),
                                child: Button(
                                  buttonColor: Colors.black,
                                  height: 60,
                                  text: 'Close',
                                  width: 100,
                                  textColor: Colors.white,
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  borderColor:
                                      Theme.of(context).colorScheme.background,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    List<ScheduleList> courses = [];
    if (widget.index >= 0 &&
        widget.index <
            Provider.of<CoursesProvider>(context).selectedCoursesData.length) {
      courses = Provider.of<CoursesProvider>(context)
          .selectedCoursesData[widget.index];
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Container(
          height: DeviceUtils.isTablet(context)
              ? ColumnLength / 2 * tabletBoxSize + ColumnLength
              : ColumnLength / 2 * boxSize + ColumnLength,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            border: Border.all(
              color: Colors.transparent,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                blurRadius: 10,
                offset: Offset(6, 4),
              ),
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                blurRadius: 10,
                offset: Offset(-2, 0),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    buildTimeColumn(),
                    for (var index = 0; index < week.length; index++)
                      ...buildDayColumn(index),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Expanded buildTimeColumn() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: DeviceUtils.isTablet(context)
                ? tabletFirstColumnHeight
                : FirstColumnHeight,
          ),
          ...List.generate(ColumnLength, (index) {
            int displayedHour = (index / 2).floor() + earliestStartTime.inHours;
            if (displayedHour >= 12) {
              displayedHour = displayedHour - 12;
            }
            if (displayedHour == 0) {
              displayedHour = 12;
            }

            if (index % 2 == 0) {
              return const Divider(color: Colors.grey, height: 0);
            }
            return SizedBox(
              height: DeviceUtils.isTablet(context) ? tabletBoxSize : boxSize,
              child: Text(
                '$displayedHour',
                style: AugustFont.timeAndDayText(
                    color: Theme.of(context).colorScheme.outline),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> buildDayColumn(int dayIndex) {
    List<Widget> dayColumnWidgets = [
      const VerticalDivider(color: Colors.grey, width: 0),
      Expanded(
        flex: 4,
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: FirstColumnHeight,
                  child: Center(
                    child: Text(
                      week[
                          dayIndex], // Removed unnecessary string interpolation
                      style: AugustFont.timeAndDayText(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                ),
                ...List.generate(ColumnLength, (i) {
                  // Avoid variable shadowing
                  if (i % 2 == 0) {
                    return const Divider(color: Colors.grey, height: 0);
                  }
                  return SizedBox(
                    height:
                        DeviceUtils.isTablet(context) ? tabletBoxSize : boxSize,
                    child: Container(),
                  );
                }),
              ],
            ),
            ...widget.courses.asMap().entries.expand((entry) {
              int courseIndex = entry.key;
              ScheduleList schedule = entry.value;
              return schedule.meetings
                      ?.where((meeting) =>
                          meeting.days?.contains(week[dayIndex]) ?? false)
                      .map((meeting) => buildCourseBox(
                          schedule, meeting, courseIndex,
                          dayIndex: dayIndex)) ??
                  Iterable.empty();
            }),
          ],
        ),
      ),
    ];
    return dayColumnWidgets;
  }
}
