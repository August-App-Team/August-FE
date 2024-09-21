import 'package:august/components/firebase/firebase_analytics.dart';
import 'package:august/components/home/button.dart';
import 'package:august/const/font/font.dart';
import 'package:august/const/icons/icons.dart';
import 'package:august/provider/course_color_provider.dart';
import 'package:august/const/colors/modify_color.dart';
import 'package:august/pages/group/group_search_page.dart';
import 'package:august/pages/main/wizard_page.dart';
import 'package:august/provider/semester_provider.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../get_api/timetable/class.dart';
import '../../get_api/timetable/add_course_to_group.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

@override
class GroupPage extends StatefulWidget {
  const GroupPage({
    Key? key,
  });

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  List<List<GroupList?>> containers = List.generate(10, (index) => []);
  ValueNotifier<List<GroupList>> addedCoursesNotifier = ValueNotifier([]);
  String? currentSemester;

  @override
  void initState() {
    super.initState();

    currentSemester =
        Provider.of<SemesterProvider>(context, listen: false).semester;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    List<Color> tileColors = theme.brightness == Brightness.dark
        ? darkenColors(
            lightenColors(
                Provider.of<CourseColorProvider>(context).colors, 0.102),
            0.05)
        : lightenColors(Provider.of<CourseColorProvider>(context).colors, 0.05);

    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leadingWidth: 80,
        toolbarHeight: 60,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: Padding(
          padding: const EdgeInsets.only(left: 0, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
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
                padding: const EdgeInsets.only(right: 15, bottom: 10, top: 15),
                child: Button(
                    onTap: () async {
                      if (containers.every((container) => container.isEmpty)) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
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
                                'No courses selected',
                                style: AugustFont.head2(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                              ),
                              content: Text(
                                textAlign: TextAlign.center,
                                "Please add course(s) to class block.",
                                style: AugustFont.subText2(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                              ),
                              actions: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30),
                                    height: 55,
                                    width:
                                        MediaQuery.of(context).size.width - 80,
                                    decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius:
                                            BorderRadius.circular(60)),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'OK',
                                          style: AugustFont.head4(
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
                      } else {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Dialog(
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                              child: Center(
                                child: Container(
                                  width: 100, // Adjust as needed
                                  height: 100, // Adjust as needed
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        20), // Adjust as needed
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            );
                          },
                        );

                        try {
                          Navigator.pop(context); // Close the dialog

                          //확인해봐야함
                          HapticFeedback.mediumImpact();
                          await AnalyticsService().groupCreate();
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => GeneratePage(
                                      containers: containers,
                                    )),
                          );
                        } catch (e) {
                          Navigator.pop(context); // Close the dialog

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to get data: $e')),
                          );
                        }
                      }
                    },
                    buttonColor: Colors.blueAccent,
                    textColor: Colors.white,
                    text: 'Create',
                    width: 70,
                    height: 35,
                    borderColor: Colors.blueAccent),
              ),
            ],
          ),
        ],
      ),

      /* 
      */
      body: ColorfulSafeArea(
        bottom: false,
        overflowRules: OverflowRules.all(true),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, bottom: 0),
                child: Text(
                  'Class Blocks',
                  style: AugustFont.head3(
                      color: Theme.of(context).colorScheme.outline),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 22, bottom: 10),
                        child: Text(
                          'Select at least one course per block.\nA course will be chosen from each block to generate\nall possible schedules based on your selections.',
                          style: AugustFont.captionNormal(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: containers
                              .asMap()
                              .entries
                              .map(
                                (entry) => Stack(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(16),
                                      margin:
                                          EdgeInsets.only(top: 5, bottom: 10),
                                      decoration: BoxDecoration(
                                        color: tileColors[
                                            entry.key % tileColors.length],
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .shadow,
                                            blurRadius: 10,
                                            offset: Offset(4, 8),
                                          )
                                        ],
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 400,
                                        minHeight: 120,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Class Block ${entry.key + 1}',
                                              style: AugustFont.head4(
                                                  color: Colors.black)),
                                          SizedBox(height: 5),
                                          Divider(
                                              thickness: 1, color: Colors.grey),
                                          SizedBox(height: 3),
                                          ...entry.value
                                              .map((course) => AddCourseToGroup(
                                                    addedCourses:
                                                        containers[entry.key],
                                                    index: containers[entry.key]
                                                        .indexOf(course),
                                                    onRemove: () {
                                                      HapticFeedback
                                                          .mediumImpact();
                                                      setState(() {
                                                        containers[entry.key]
                                                            .remove(course);
                                                      });
                                                    },
                                                  ))
                                              .toList(),
                                          SizedBox(height: 5),
                                          GestureDetector(
                                            onTap: () {
                                              HapticFeedback.mediumImpact();
                                              _navigateToPage(entry.key);
                                            },
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          AugustIcons
                                                              .addCourses,
                                                          color: Colors.black,
                                                          size: 15,
                                                        ),
                                                        SizedBox(width: 5),
                                                        Text(
                                                          'Add Courses',
                                                          style: AugustFont
                                                              .subText2(
                                                                  color: Colors
                                                                      .black),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Positioned(
                                    //   top: 10,
                                    //   right: 40,
                                    //   child: IconButton(
                                    //     onPressed: () {
                                    //       HapticFeedback.mediumImpact();
                                    //       _navigateToPage(entry.key);
                                    //     },
                                    //     icon: Icon(
                                    //       AugustIcons.addCourses,
                                    //       color: Colors.black,
                                    //       size: 20,
                                    //     ),
                                    //   ),
                                    // ),
                                    Positioned(
                                      top: 9,
                                      right: 15,
                                      child: IconButton(
                                        onPressed: () {
                                          HapticFeedback.mediumImpact();
                                          _removeContainer(entry.key);
                                        },
                                        icon: Icon(
                                          AugustIcons.deleteCourses,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(int containerIndex) async {
    showCupertinoModalBottomSheet<Map<String, dynamic>>(
      topRadius: Radius.circular(30),
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pop(
                context); // Close the bottom sheet when the area outside the sheet is tapped
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
              expand: false,
              initialChildSize: 1,
              maxChildSize: 1,
              minChildSize: 1,
              builder: (BuildContext context,
                  ScrollController sheetScrollController) {
                return GestureDetector(
                  onTap:
                      () {}, // Prevent the inner tap event from propagating to the outer GestureDetector
                  child: GroupSearchPage(
                    onCourseSelected: (selectedCourse) {
                      setState(() {
                        containers[containerIndex].add(selectedCourse);
                      });
                      addedCoursesNotifier.value = [
                        ...addedCoursesNotifier.value,
                        selectedCourse
                      ];
                    },
                    addedCoursesNotifier: addedCoursesNotifier,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _removeContainer(int containerIndex) {
    setState(() {
      containers[containerIndex].clear();
      // Remove the courses from the notifier list as well
      addedCoursesNotifier.value = addedCoursesNotifier.value
          .where((course) => !containers[containerIndex].contains(course))
          .toList();
    });
  }
}
