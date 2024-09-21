import 'dart:convert';

import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:august/components/ad/ad_list.dart';
import 'package:august/components/home/dialog.dart';
import 'package:august/components/tile/simple_course_tile.dart';
import 'package:august/const/font/font.dart';
import 'package:august/const/icons/icons.dart';
import 'package:august/get_api/onboard/get_semester.dart';
import 'package:august/get_api/search/simple_sections.dart';
import 'package:august/provider/semester_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../provider/courseprovider.dart';
import '../../components/home/loading.dart';
import '../../get_api/timetable/class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../get_api/timetable/schedule.dart';
import 'package:intl/intl.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:toasty_box/toasty_box.dart';

class ManualSearchPage extends StatefulWidget {
  final void Function(CourseList) onCourseSelected;
  final ValueNotifier<List<CourseList>> addedCoursesNotifier;
  final String? title;
  ManualSearchPage({
    Key? key,
    required this.onCourseSelected,
    required this.addedCoursesNotifier,
    this.title,
  }) : super(key: key);

  @override
  State<ManualSearchPage> createState() => _ManualSearchPageState();
}

class InstructorCourse {
  final CourseList course;
  final Section section;

  InstructorCourse(this.course, this.section);
}

class _ManualSearchPageState extends State<ManualSearchPage>
    with SingleTickerProviderStateMixin {
  List<CourseList> _foundCourses = [];
  late TextEditingController _keywordController;
  late Future<List<CourseList>>? _coursesFuture = null;
  late AnimationController _controller;
  late String currentSemester;
  List<String> _searchKeywords = [];

  void addToGroup(BuildContext context, Section section, CourseList course) {
    ScheduleList schedule = ScheduleList(
        id: section.id,
        name: course.name,
        courseCode: course.courseCode,
        sectionCode: section.code,
        instructors: section.instructors,
        meetings: section.meetings
            ?.map((meeting) => ScheduleMeeting(
                building: meeting.building,
                room: meeting.room,
                days: meeting.days,
                startTime: meeting.startTime,
                endTime: meeting.endTime))
            .toList(),
        credits: course.credits,
        seats: section.seats,
        openSeats: section.openSeats,
        waitlist: section.waitlist);

    var provider = Provider.of<CoursesProvider>(context, listen: false);

    // Get the index of the current timetable.
    int currentPageIndex = provider.currentPageIndex;

    List<ScheduleList> currentTimetable =
        provider.selectedCoursesData[currentPageIndex];

    if (!checkTimeConflict(schedule, currentTimetable)) {
      // Now we can safely add the course to the current page.
      provider.addCourseToTimetable(schedule, currentPageIndex);

      String jsonSchedule = jsonEncode(schedule.toJson());

      for (var schedule in currentTimetable) {
        print(jsonEncode(schedule.toJson()));
      }

      // Notify listeners about changes in selected courses data.
    } else {
      ToastService.showToast(
        context,
        backgroundColor: Theme.of(context).colorScheme.background,
        shadowColor: Theme.of(context).colorScheme.shadow,
        leading: Icon(
          AugustIcons.close,
          color: Colors.redAccent,
        ),
        message: 'This course conflicts with already added course.',
      );
    }
  }

  void removeFromGroup(CourseList course) {
    widget.addedCoursesNotifier.value.remove(course);
  }

  Future<List<CourseList>> _runSearch(String enteredKeyword) async {
    FetchCourse _courses = FetchCourse();

    String querytype = 'code';

    List<CourseList> apiData = await _courses.getCourseList(
        querytype: querytype, semester: currentSemester, query: enteredKeyword);
    // Sort each course's sections by section.code
    for (var course in apiData) {
      course.sections?.sort((a, b) => a.code!.compareTo(b.code!));
    }
    if (mounted) {
      setState(() {
        _foundCourses = apiData;
      });
    }
    await _storeSearchKeyword(enteredKeyword);
    return apiData;
  }

  @override
  void initState() {
    super.initState();
    currentSemester =
        Provider.of<SemesterProvider>(context, listen: false).semester;
    _loadSearchKeywords();
    // Initialize the keyword controller and add listener
    this._keywordController = TextEditingController();

    // Initialize animation controller
    this._controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  //검색어 로드
  Future<void> _loadSearchKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchKeywords = prefs.getStringList('searchKeywords') ?? [];
    });
  }

  //검색어 저장
  Future<void> _storeSearchKeyword(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    // Avoid storing duplicate and empty keywords.
    if (!_searchKeywords.contains(keyword) && keyword.isNotEmpty) {
      _searchKeywords.add(keyword);
      await prefs.setStringList('searchKeywords', _searchKeywords);
    }
  }

  Future<void> _deleteSearchKeyword(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    _searchKeywords.remove(keyword);
    await prefs.setStringList('searchKeywords', _searchKeywords);
    setState(() {}); // Update the UI to reflect the deletion.
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: Scaffold(
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          //   forceMaterialTransparency: true,
          leading: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 20),
                    child: Text(
                      'Search',
                      style: AugustFont.head3(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 23, bottom: 0),
                    child: Text(
                      formatSemester(currentSemester),
                      style: AugustFont.subText(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              Spacer(),
            ],
          ),
          leadingWidth: 500,
          toolbarHeight: 110,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle, // Ensures the container is circular
                ),
                child: IconButton(
                  icon: Icon(
                    AugustIcons.close,
                    color: Theme.of(context).colorScheme.outline,
                  ),

                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    }
                  },
                  padding:
                      EdgeInsets.all(5), // Remove padding to fit the icon well
                  constraints:
                      BoxConstraints(), // Remove constraints if necessary
                ),
              ),
            ),
          ],
        ),
        body: ColorfulSafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      top: 0.0, bottom: 10.0, left: 15.0, right: 15.0),
                  child: AnimatedTextField(
                      style: AugustFont.textField(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      controller: _keywordController,
                      animationType: Animationtype.typer,
                      cursorColor: Theme.of(context).colorScheme.outline,
                      hintTexts: const [
                        'CMSC131 ',
                        'Orchestra ',
                        'Biology ',
                        'CHEM132 ',
                        'BMGT310 ',
                        'MATH240 ',
                        'KORA201 ',
                      ],
                      animationDuration: Duration(milliseconds: 500),
                      hintTextStyle: AugustFont.textField(
                        color: Colors.grey,
                      ),
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).colorScheme.primary,
                        filled: true, // 배경색 채우기 활성화
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        border: OutlineInputBorder(
                          // 기본 테두리 설정
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none, // 둘레 색 없애기
                        ),
                        focusedBorder: OutlineInputBorder(
                          // 포커스 됐을 때의 테두리 설정
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none, // 둘레 색 없애기
                        ),
                        hintText: 'Search Course',
                        prefixIcon: Icon(
                          AugustIcons.search,
                          size: 25.0,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _keywordController.clear();
                            setState(() {
                              _coursesFuture =
                                  null; // Set to null when the search bar is cleared.
                              _foundCourses =
                                  []; // Clear the list of found courses.
                            });
                          },
                          icon: Icon(
                            AugustIcons.delete,
                            size: 20,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      onSubmitted: (String value) async {
                        String formattedValue =
                            value.replaceAll(' ', ''); // Remove all spaces
                        setState(() {
                          _coursesFuture = _runSearch(formattedValue);
                        });
                      })),
              Expanded(
                child: FutureBuilder<List<CourseList>>(
                  future: _coursesFuture,
                  builder: (context, snapshot) {
                    if (_coursesFuture == null) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 0, left: 20),
                                child: Consumer<SemesterProvider>(
                                  builder: (context, semesterProvider, child) {
                                    return Text(
                                      'Recent',
                                      style: AugustFont.head2(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          if (_searchKeywords.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'No recent searches',
                                style: AugustFont.subText2(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            )
                          else
                            Container(
                                margin: EdgeInsets.only(left: 10, top: 5),
                                child: Wrap(
                                  spacing: 8.0, // 가로 간격
                                  runSpacing: 4.0, // 세로 간격
                                  children: List.generate(
                                      _searchKeywords.length, (index) {
                                    return GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        // Update the TextEditingController to display the keyword
                                        _keywordController.text =
                                            _searchKeywords[index];
                                        // Trigger the search with the keyword
                                        setState(() {
                                          _coursesFuture = _runSearch(
                                              _searchKeywords[index].trim());
                                        });
                                      },
                                      child: Chip(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              color: Colors.transparent),
                                          borderRadius: BorderRadius.horizontal(
                                            left: const Radius.circular(30),
                                            right: const Radius.circular(30),
                                          ),
                                        ),
                                        label: Text(
                                          _searchKeywords[index],
                                          style: AugustFont.chip(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                        ),
                                        onDeleted: () {
                                          _deleteSearchKeyword(_searchKeywords[
                                              index]); // 삭제 아이콘 클릭 시 해당 검색어를 삭제합니다.
                                        },
                                        deleteIcon: Icon(
                                          AugustIcons.chipDelete,
                                          size: 20,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                        ),
                                      ),
                                    );
                                  }),
                                )),
                        ],
                      );

                      //    'Please enter a Course to search for courses',
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return SingleChildScrollView(
                        child: Center(
                          child: Column(
                            children: List<Widget>.generate(
                                7, (index) => GroupLoading2(context)),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Network error. Please try again later.',
                          style: AugustFont.head2(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (_foundCourses.isEmpty) {
                      // Add this condition.
                      return Center(
                        child: Text(
                          'No courses found.\nPlease try another keyword.',
                          style: AugustFont.head2(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      // Flatten the list of instructors.
                      List<InstructorCourse> instructorCourses = [];
                      for (var course in _foundCourses) {
                        if (course.sections != null) {
                          for (var section in course.sections!) {
                            if (section.instructors != null) {
                              for (var instructor in section.instructors!) {
                                instructorCourses
                                    .add(InstructorCourse(course, section));
                              }
                            }
                          }
                        }
                      }

                      return ListView.builder(
                        itemCount: _foundCourses.length,
                        itemBuilder: (context, courseIndex) {
                          var course = _foundCourses[courseIndex];
                          List<Widget> widgets = [];
                          int sectionsCount = course.sections?.length ?? 0;

                          // 각 코스의 섹션을 순회하면서 위젯 리스트에 추가
                          for (int i = 0; i < sectionsCount; i++) {
                            var section = course.sections![i];
                            List<String> formattedMeetingTimes = section
                                    .meetings
                                    ?.map((meeting) {
                                  DateTime startTime =
                                      DateFormat.Hm().parse(meeting.startTime!);
                                  DateTime endTime =
                                      DateFormat.Hm().parse(meeting.endTime!);
                                  String formattedStartTime =
                                      DateFormat('h:mm a').format(startTime);
                                  String formattedEndTime =
                                      DateFormat('h:mm a').format(endTime);
                                  return '${meeting.days} $formattedStartTime - $formattedEndTime';
                                }).toList() ??
                                [];
                            // If no meeting times are available, set to "Online"
                            String meetingTimes =
                                formattedMeetingTimes.isNotEmpty
                                    ? formattedMeetingTimes.join('\n')
                                    : "Online";

                            widgets.add(SimepleCourseTile(
                              classes: course,
                              sectionCode:
                                  section.code ?? '', // Pass the section code
                              instructorName: section.instructors?.first ??
                                  '', // Pass the first instructor's name
                              icon: AugustIcons.addCoursetoGroup,
                              backgroundColor: Colors.white,
                              index: courseIndex,
                              onPressed: (context) {
                                addToGroup(context, section, course);
                                Navigator.pop(context);
                              },
                              onTap: (context) {
                                // Define onTap action
                              },
                              meetingTimes: meetingTimes,
                              fullSeat: section.seats ?? 0,
                              openSeat: section.openSeats ?? 0,
                              waitlist: section.waitlist ?? 0,
                              holdfile: section.holdfile ?? 0,
                            ));

                            // 3개보다 많은 섹션이 있을 경우, 5번째 섹션마다 광고 삽입
                            if (sectionsCount > 3 && (i + 1) % 5 == 0) {
                              widgets.add(
                                googleAdMobContainer(
                                  isGroup: false,
                                  isMedium: true,
                                ),
                              );
                            }
                          }

                          // 3개 이하의 섹션이 있고, 섹션이 하나 이상 있는 경우, 리스트의 마지막에 광고 삽입
                          if (sectionsCount > 1 && sectionsCount <= 4) {
                            widgets.add(
                              googleAdMobContainer(
                                isGroup: false,
                                isMedium: true,
                              ),
                            );
                          }

                          return Column(children: widgets);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: MediaQuery.of(context).size.height * 0.08,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.0),
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                Theme.of(context).colorScheme.primaryContainer.withOpacity(1.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

bool checkTimeConflict(
    ScheduleList newCourse, List<ScheduleList> existingCourses) {
  // Helper function to parse days into a standard format
  List<String> parseDays(String days) {
    // List of standard day abbreviations
    final List<String> allDays = ['M', 'Tu', 'W', 'Th', 'F'];
    List<String> parsedDays = [];
    for (var day in allDays) {
      if (days.contains(day)) {
        parsedDays.add(day);
        days = days.replaceFirst(day,
            ''); // Remove the day once it's parsed to prevent misinterpretation
      }
    }
    return parsedDays;
  }

  // Helper function to check if times overlap
  bool timesOverlap(String start1, String end1, String start2, String end2) {
    DateTime startTime1 = DateTime.parse('1970-01-01 $start1:00');
    DateTime endTime1 = DateTime.parse('1970-01-01 $end1:00');
    DateTime startTime2 = DateTime.parse('1970-01-01 $start2:00');
    DateTime endTime2 = DateTime.parse('1970-01-01 $end2:00');
    return startTime1.isBefore(endTime2) && startTime2.isBefore(endTime1);
  }

  // Process each new course meeting and compare with existing courses
  for (var newMeeting in newCourse.meetings!) {
    var newDays = parseDays(newMeeting.days!);
    var newStart = newMeeting.startTime!;
    var newEnd = newMeeting.endTime!;

    for (var day in newDays) {
      for (var existingCourse in existingCourses) {
        for (var existingMeeting in existingCourse.meetings!) {
          var existingDays = parseDays(existingMeeting.days!);
          if (existingDays.contains(day)) {
            // Check if same day
            var existingStart = existingMeeting.startTime!;
            var existingEnd = existingMeeting.endTime!;
            if (timesOverlap(newStart, newEnd, existingStart, existingEnd)) {
              return true; // There's a conflict
            }
          }
        }
      }
    }
  }

  return false; // No conflicts found
}
