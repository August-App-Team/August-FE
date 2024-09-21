import 'dart:convert';
import 'dart:ui';
import 'package:august/components/firebase/firebase_analytics.dart';
import 'package:august/const/font/font.dart';
import 'package:august/const/icons/icons.dart';
import 'package:august/get_api/timetable/send_timetable.dart';
import 'package:august/pages/main/homepage.dart';
import 'package:august/pages/manual/manual_search_page.dart';
import 'package:august/provider/semester_provider.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../components/home/button.dart';
import '../../provider/courseprovider.dart';
import '../../components/timetable/timetable.dart';
import '../../get_api/timetable/class.dart';
import '../../get_api/timetable/schedule.dart';

class ManualPage extends StatefulWidget {
  final List<ScheduleList> coursesData; // Course is a hypothetical class here.
  final int index;
  const ManualPage({
    Key? key,
    this.coursesData = const [],
    this.index = 0,
  }) : super(key: key);

  @override
  State<ManualPage> createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  late String currentSemester;

  // Future<void> saveTimetableToLocalStorage(
  //     List<List<ScheduleList>> newTimetable, String semester) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();

  //   // Load existing timetables from local storage
  //   String? serializedExistingTimetables = prefs.getString('timetable');
  //   List<Map<String, dynamic>> existingTimetables = [];

  //   if (serializedExistingTimetables != null) {
  //     List<dynamic> deserializedExistingTimetables =
  //         jsonDecode(serializedExistingTimetables);
  //     existingTimetables = deserializedExistingTimetables
  //         .map((timetableData) {
  //           // Ensure that timetableData['coursesData'] is correctly structured
  //           if (timetableData is Map<String, dynamic> &&
  //               timetableData.containsKey('coursesData') &&
  //               timetableData['coursesData'] is List<dynamic>) {
  //             return {
  //               'semester': timetableData['semester'],
  //               'courses': (timetableData['coursesData'] as List<dynamic>)
  //                   .map((scheduleItem) =>
  //                       ScheduleList.fromJson(scheduleItem).toJson())
  //                   .toList(),
  //             };
  //           } else {
  //             print("Invalid format in existing timetable data");
  //             return null; // Handle invalid format
  //           }
  //         })
  //         .where((element) => element != null)
  //         .cast<Map<String, dynamic>>()
  //         .toList();
  //   }

  //   // Process the new timetable
  //   List<Map<String, dynamic>> newTimetablesData =
  //       newTimetable.map((coursesList) {
  //     return {
  //       'semester': semester,
  //       'courses': coursesList.map((course) => course.toJson()).toList(),
  //     };
  //   }).toList();

  //   // Combine and save all timetables
  //   existingTimetables.addAll(newTimetablesData);
  //   String serializedAllTimetables = jsonEncode(existingTimetables);
  //   await prefs.setString('timetable', serializedAllTimetables);
  //   print("Timetables saved successfully");
  // }

  Future<void> saveTimetableToLocalStorage(
      List<List<ScheduleList>> newTimetable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load existing timetables from local storage
    String? serializedExistingTimetables = prefs.getString('timetable');
    List<List<ScheduleList>> existingTimetables = [];

    if (serializedExistingTimetables != null) {
      List<dynamic> deserializedExistingTimetables =
          jsonDecode(serializedExistingTimetables);
      existingTimetables = deserializedExistingTimetables
          .map((timetableData) {
            return (timetableData as List)
                .map((courseData) => ScheduleList.fromJson(courseData))
                .toList();
          })
          .toList()
          .cast<List<ScheduleList>>();
    }

    // Filter out courses without an ID in the new timetable.
    newTimetable = newTimetable.map((courses) {
      return courses.where((course) => course.id != null).toList();
    }).toList();

    // Combine existing timetables with the new timetable
    existingTimetables.addAll(newTimetable);

    // Save all timetables to local storage
    String serializedAllTimetables = jsonEncode(existingTimetables);

    prefs.setString('timetable', serializedAllTimetables);
  }

  @override
  void initState() {
    super.initState();
    currentSemester =
        Provider.of<SemesterProvider>(context, listen: false).semester;

    Future.delayed(Duration.zero, () {
      Provider.of<CoursesProvider>(context, listen: false).createNewTimetable();
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<CoursesProvider>(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                provider.createNewTimetable();
                provider.resetSelectedCoursesData();
                provider.clearSelectedCourses();
                Navigator.pop(context);
              }
            },
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Center(
                  child: Icon(
                    AugustIcons.backButton,
                    size: 15,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15, bottom: 13),
                child: Button(
                  buttonColor: Colors.blueAccent,
                  textColor: Colors.white,
                  text: 'Create',
                  width: 70,
                  height: 35,
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await AnalyticsService().manuallyCreate();
                    List<List<ScheduleList>> copiedCoursesData =
                        List.from(provider.selectedCoursesData);

                    List<int> sectionIds = copiedCoursesData
                        .expand((courses) => courses)
                        .where((course) => course.id != null)
                        .map((course) => course.id!)
                        .toList();

                    int intCurrentSemester = int.parse(currentSemester);
                    sendTimetableToServer(
                            intCurrentSemester, "Manual", sectionIds)
                        .then((_) {
                      // First, handle provider-related operations
                      provider.createNewTimetable();
                      provider.resetSelectedCoursesData();
                      copiedCoursesData.clear();
                      provider.clearSelectedCourses();

                      // After all provider operations are complete, navigate to HomePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    });
                  },
                  borderColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ColorfulSafeArea(
        topColor: Colors.red,
        bottomColor: Colors.white.withOpacity(0),
        overflowRules: OverflowRules.all(true),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Manual',
                    style: AugustFont.head3(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                ),
                Flexible(
                  child: Consumer<CoursesProvider>(
                    builder: (context, provider, child) {
                      return SingleTimetable(
                        courses: provider.currentPageIndex <
                                provider.selectedCoursesData.length
                            ? provider
                                .selectedCoursesData[provider.currentPageIndex]
                            : [],
                        index: provider.currentPageIndex,
                        showEditButton: true,
                        forceFixedTimeRange: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        child: Stack(children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.18,
          ),
          Positioned(
            bottom: 50,
            right: 40,
            child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(AugustIcons.add, size: 40),
                color: Colors.white,
                onPressed: _navigateToPage,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _navigateToPage() async {
    HapticFeedback.lightImpact();
    var addedCoursesNotifier = ValueNotifier<List<CourseList>>([]);
    showCupertinoModalBottomSheet<Map<String, dynamic>>(
      topRadius: Radius.circular(30), // Set radius to 0 for full-width coverage
      context: context,
      backgroundColor: Colors.transparent,

      builder: (BuildContext context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pop(context); // Close the sheet when tapping outside
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification.metrics.pixels ==
                  notification.metrics.maxScrollExtent) {
                HapticFeedback.lightImpact();
              }
              return true;
            },
            child: DraggableScrollableSheet(
              expand: true, // Ensure the sheet is expanded fully
              initialChildSize: 1, // Start and stay full screen
              maxChildSize: 1,
              minChildSize: 1,

              builder: (BuildContext context,
                  ScrollController sheetScrollController) {
                return GestureDetector(
                    onTap: () {}, // Prevent tap events from closing the modal
                    child: ManualSearchPage(
                      addedCoursesNotifier: addedCoursesNotifier,
                      onCourseSelected: (CourseList course) {
                        var currentList = addedCoursesNotifier.value;
                        currentList.add(course);
                        addedCoursesNotifier.value = currentList;
                      },
                    ));
              },
            ),
          ),
        );
      },
    );
  }
}
