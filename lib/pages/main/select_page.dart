import 'dart:convert';

import 'package:august/components/firebase/firebase_analytics.dart';
import 'package:august/components/home/button.dart';
import 'package:august/components/home/dialog.dart';
import 'package:august/components/indicator/scrolling_dots_effect.dart';
import 'package:august/components/indicator/smooth_page_indicator.dart';
import 'package:august/components/timetable/timetable.dart';
import 'package:august/const/font/font.dart';
import 'package:august/const/icons/icons.dart';
import 'package:lottie/lottie.dart';
import 'package:august/get_api/timetable/send_timetable.dart';
import 'package:august/get_api/timetable/schedule.dart';
import 'package:august/pages/main/homepage.dart';
import 'package:august/provider/semester_provider.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../provider/courseprovider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class SelectPage extends StatefulWidget {
  final List<List<ScheduleList>> selectedCoursesData;
  SelectPage({
    Key? key,
    this.selectedCoursesData = const [],
  }) : super(key: key);
  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  int currentPageIndex = 0;
  late List<ValueNotifier<bool>> isButtonClicked;
  List<List<ScheduleList>> selectedCoursesData = [];
  final PageController pageController = PageController(viewportFraction: 0.92);

  List<List<ScheduleList>> coursesData = [];
  late String currentSemester;

  Future<void> saveTimetableToLocalStorage(
      List<List<ScheduleList>> newTimetable) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load existing timetables from local storage
    String? serializedExistingTimetables = prefs.getString('timetable');
    List<List<ScheduleList>> existingTimetables = [];

    if (serializedExistingTimetables != null) {
      dynamic deserializedExistingTimetables =
          jsonDecode(serializedExistingTimetables);
      // Check if the deserialized data is indeed a list
      if (deserializedExistingTimetables is List) {
        existingTimetables = deserializedExistingTimetables
            .map((timetableData) {
              // Ensure each item in the list is also a list before attempting to cast
              if (timetableData is List) {
                return timetableData
                    .map((courseData) => ScheduleList.fromJson(courseData))
                    .toList();
              } else {
                // If an item is not a list, return an empty list (or handle appropriately)
                return <ScheduleList>[];
              }
            })
            .toList()
            .cast<List<ScheduleList>>();
      }
    }
    // Filter out courses without an ID in the new timetable.
    newTimetable = newTimetable.map((courses) {
      return courses.where((course) => course.id != null).toList();
    }).toList();

    // Combine existing timetables with the new timetable
    existingTimetables.addAll(newTimetable);

    // Save all timetables to local storage
    String serializedAllTimetables = jsonEncode(existingTimetables
        .map((timetable) =>
            timetable.map((schedule) => schedule.toJson()).toList())
        .toList());

    await prefs.setString('timetable', serializedAllTimetables);
  }

  @override
  void initState() {
    super.initState();
    currentSemester =
        Provider.of<SemesterProvider>(context, listen: false).semester;

    coursesData = widget.selectedCoursesData;
    isButtonClicked = List<ValueNotifier<bool>>.generate(
      coursesData.length,
      (index) => ValueNotifier(false),
    );
    // Schedule resetAddedCoursesCount() to be called in the next frame.
    // pageController.addListener(() {
    //   if (pageController.page!.round() != currentPageIndex) {
    //     setState(() {
    //       currentPageIndex = pageController.page!.round();
    //     });
    //     Provider.of<CoursesProvider>(context, listen: false)
    //         .setCurrentPageIndex(currentPageIndex);
    //   }
    // });
    pageController.addListener(() {
      int newPageIndex = pageController.page!.floor();
      // 스와이프 감지 민감도를 높여 페이지가 조금이라도 넘어가면 즉시 반응하도록 설정
      if (pageController.page! - newPageIndex > 0.05) {
        newPageIndex += 1;
      }
      if (currentPageIndex != newPageIndex) {
        setState(() {
          currentPageIndex = newPageIndex;
        });
        Provider.of<CoursesProvider>(context, listen: false)
            .setCurrentPageIndex(currentPageIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(currentPageIndex);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leadingWidth: 80,
        toolbarHeight: 60,
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                final coursesProvider =
                    Provider.of<CoursesProvider>(context, listen: false);
                coursesProvider.resetSelectedCoursesData();
                coursesProvider.setzero(0);
                Navigator.pop(context);
                AnalyticsService().selectBack();
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
        titleSpacing: 0.0,
        title: Text(
          "Select Schedules",
          style: AugustFont.head4(color: Theme.of(context).colorScheme.outline),
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15, bottom: 12),
                child: Button(
                  onTap: () async {
                    final coursesProvider =
                        Provider.of<CoursesProvider>(context, listen: false);

                    // 선택된 코스가 없으면 리턴
                    if (coursesProvider.selectedCoursesData.isEmpty ||
                        coursesProvider.addedCoursesCount == 0) {
                      print("No Timetable has been selected. Cannot create.");

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            icon: Icon(
                              FeatherIcons.alertTriangle,
                              color: Colors.redAccent,
                              size: 45,
                            ),
                            title: Text(
                              textAlign: TextAlign.center,
                              '0 Schedules Selected',
                              style: AugustFont.head2(
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                            content: Text(
                              textAlign: TextAlign.center,
                              'Please select at least one schedule to create a timetable.',
                              style: AugustFont.subText2(color: Colors.grey),
                            ),
                            actions: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(); // 팝업 닫기
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  height: 55,
                                  width: MediaQuery.of(context).size.width - 80,
                                  decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'OK',
                                        style: AugustFont.head2(
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                      return;
                    }

                    int intCurrentSemester = int.parse(currentSemester);

                    loadingShowDialog(context);

                    if (coursesProvider.addedCoursesCount != 0) {
                      // 모든 선택된 타임테이블에 대해 반복
                      for (var selectedCourses
                          in coursesProvider.selectedCoursesData) {
                        List<int> sectionIds = selectedCourses
                            .where((course) => course.id != null)
                            .map((course) => course.id!)
                            .toList();

                        // sectionIds가 비어있지 않은 경우만 처리
                        if (sectionIds.isNotEmpty) {
                          String timetableName = "Schedule";

                          try {
                            // 현재 타임테이블을 서버에 전송
                            await sendTimetableToServer(
                                intCurrentSemester, timetableName, sectionIds);
                            print(
                                "Sending timetable with section IDs: $sectionIds");
                            print("Timetable sent successfully."); // 성공 처리
                          } catch (e) {
                            print("Failed to send timetable: $e"); // 실패 처리
                          }
                        }
                      }
                      coursesProvider.setCurrentPageIndex(0);
                      coursesProvider.setzero(0);
                      coursesProvider.resetSelectedCoursesData();
                      await AnalyticsService().selectDone();
                      Navigator.pushAndRemoveUntil(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => HomePage(),
                          ),
                          (route) => false);
                    }
                  },
                  buttonColor: Colors.blueAccent,
                  textColor: Colors.white,
                  text: 'Done',
                  width: 70,
                  height: 35,
                  borderColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ColorfulSafeArea(
        bottomColor: Colors.white.withOpacity(0),
        overflowRules: OverflowRules.all(true),
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, top: 5, bottom: 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 2),
                                child: Consumer<CoursesProvider>(
                                  builder: (context, provider, child) => Text(
                                    '${coursesData.length} ',
                                    style: AugustFont.scheduleTotalCount(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline),
                                  ),
                                ),
                              ),
                              Text(
                                'POSSIBLE\nSCHEDULES',
                                style: AugustFont.head1(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                              ),
                              Spacer(),
                            ],
                          ),
                          //  Text('data'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 40, bottom: 5),
                      child: Text(
                        "${currentPageIndex + 1} of ${coursesData.length} Schedules", // Display current timetable index
                        style: AugustFont.head4(
                            color: Theme.of(context).colorScheme.outline),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        color: Theme.of(context)
                            .colorScheme
                            .background, // 필요한 경우 배경색을 설정합니다.
                        child: TimeTables(
                          coursesData: coursesData,
                          pageController: pageController,
                          isSelectpage: true,
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Container(
                          height: 20,
                          width: 90,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: pageController,
                              count: coursesData.length,
                              effect: ScrollingDotsEffect(
                                activeStrokeWidth: 2,
                                activeDotScale: 1.3,
                                maxVisibleDots: 5,
                                isSelectPage: true,
                                radius: 8,
                                spacing: 8,
                                dotHeight: 8,
                                dotWidth: 8,
                                dotColor: Colors.grey,
                                activeDotColor:
                                    Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: AnimatedContainer(
          color: Theme.of(context).colorScheme.primary,
          padding: EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 30),
          width: double.infinity,
          duration: Duration(milliseconds: 100),
          curve: Curves.fastEaseInToSlowEaseOut,
          child: AnimatedBuilder(
            animation: isButtonClicked[currentPageIndex],
            builder: (context, child) {
              return AnimatedBuilder(
                animation: isButtonClicked[currentPageIndex],
                builder: (context, child) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        // 첫 번째 버튼을 Expanded 위젯으로 감싸서 유연하게 공간을 차지하도록 함
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.fastEaseInToSlowEaseOut,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () async {},
                            child: Consumer<CoursesProvider>(
                              builder: (context, provider, child) => Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 17.0), // 내부 여백 추가
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text:
                                                '${provider.addedCoursesCount}\n',
                                            style: AugustFont.head2(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline),
                                          ),
                                          TextSpan(
                                            text: 'selected',
                                            style: AugustFont.subText2(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .outline),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(
                                horizontal: 10,
                              )),
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) =>
                                          Colors.white.withOpacity(0.0)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        // 첫 번째 버튼을 Expanded 위젯으로 감싸서 유연하게 공간을 차지하도록 함
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.fastEaseInToSlowEaseOut,
                          decoration: BoxDecoration(
                            color: isButtonClicked[currentPageIndex].value
                                ? Colors.red
                                : Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              HapticFeedback.mediumImpact();

                              //여기여기임
                              double currentPage = pageController.page!;
                              int currentIndex;

                              if (currentPage - currentPageIndex > 0.5) {
                                // If the current page index has moved significantly enough, use ceil()
                                currentIndex = currentPage.floor();
                              } else {
                                // Otherwise, use floor() to determine the current page
                                currentIndex = currentPage.floor();
                              }
                              final coursesProvider =
                                  Provider.of<CoursesProvider>(context,
                                      listen: false);

                              // Toggle the button click state and add/remove the course accordingly.
                              if (isButtonClicked[currentIndex].value) {
                                // If already clicked, deselect the course.
                                coursesProvider
                                    .deSelectCourse(coursesData[currentIndex]);
                                isButtonClicked[currentIndex].value = false;
                                await AnalyticsService().deselect();
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    Future.delayed(Duration(milliseconds: 500),
                                        () {
                                      Navigator.of(context).pop(true);
                                    });
                                    return AlertDialog(
                                      backgroundColor: Colors.transparent,

                                      // AlertDialog를 정사각형 형태로 만들기 위해 Container 사용
                                      content: Container(
                                        width:
                                            250, // 정사각형 형태를 유지하기 위해 가로와 세로 크기를 동일하게 설정
                                        height: 250,
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(100000)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              AugustIcons.deselect,
                                              size: 80,
                                              color: Colors.redAccent,
                                            ), // 아이콘 크기 조정
                                            Text(
                                              'Deselected',
                                              textAlign: TextAlign.center,
                                              style: AugustFont.head1(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                                print(
                                    "Deselecting course with IDs: ${coursesData[currentIndex].map((c) => c.id).toList()}");
                              } else {
                                // If not clicked, add the course.
                                coursesProvider
                                    .addCourse(coursesData[currentIndex]);
                                isButtonClicked[currentIndex].value = true;
                                await AnalyticsService().select();
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    Future.delayed(Duration(milliseconds: 500),
                                        () {
                                      Navigator.of(context).pop(true);
                                    });
                                    return AlertDialog(
                                      backgroundColor: Colors.transparent,

                                      // AlertDialog를 정사각형 형태로 만들기 위해 Container 사용
                                      content: Container(
                                        width:
                                            250, // 정사각형 형태를 유지하기 위해 가로와 세로 크기를 동일하게 설정
                                        height: 250,
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(100000)),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              AugustIcons.check,
                                              size: 80,
                                              color: Colors.greenAccent,
                                            ), // 아이콘 크기 조정
                                            Text(
                                              'Selected',
                                              textAlign: TextAlign.center,
                                              style: AugustFont.head1(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );

                                print(
                                    "Selecting course with IDs: ${coursesData[currentIndex].map((c) => c.id).toList()}");
                              }

                              setState(() {});

                              // // Optionally, move to the next page if this is the desired behavior.
                              // if (pageController.hasClients &&
                              //     currentIndex < coursesData.length - 1) {
                              //   pageController.nextPage(
                              //       duration: Duration(milliseconds: 300),
                              //       curve: Curves.easeInOut);
                              // }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 18.0), // 내부 여백 추가
                              child: Text(
                                isButtonClicked[currentPageIndex].value
                                    ? 'DESELECT'
                                    : 'SELECT',
                                style: AugustFont.head2(color: Colors.white),
                              ),
                            ),
                            style: ButtonStyle(
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                      EdgeInsets.symmetric(horizontal: 10)),
                              overlayColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (states) =>
                                          Colors.white.withOpacity(0.0)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
