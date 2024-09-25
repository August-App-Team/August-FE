import 'dart:convert';
import 'dart:ui';
import 'package:august/components/firebase/firebase_analytics.dart';
import 'package:august/components/home/button.dart';
import 'package:august/const/font/font.dart';
import 'package:august/get_api/timetable/set_timetable_name.dart';
import 'package:august/provider/courseprovider.dart';
import 'package:august/components/timetable/timetable.dart';
import 'package:august/get_api/timetable/edit_timetable.dart';
import 'package:august/pages/edit/edit_search_page.dart';
import 'package:august/pages/main/homepage.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../get_api/timetable/schedule.dart';

class EditPage extends StatefulWidget {
  final int? index;
  final String? name;
  final ScheduleList? newCourse;
  ValueNotifier<List<ScheduleList>>? addedCoursesNotifier;
  final String semester;

  EditPage({
    super.key,
    this.index,
    this.newCourse,
    this.addedCoursesNotifier,
    required this.semester,
    this.name,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  List<ScheduleList> _courses = [];
  TextEditingController _nameController = TextEditingController();

  Future<void> loadCourseDataAtIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('timetable');

    if (jsonString != null) {
      List<dynamic> coursesDataMapList = jsonDecode(jsonString);
      if (index >= 0 && index < coursesDataMapList.length) {
        List<dynamic> courseData = coursesDataMapList[index];

        // Parsing and converting the data into List<ScheduleList>
        List<ScheduleList> courses = (courseData as List)
            .map((scheduleItem) => ScheduleList.fromJson(scheduleItem))
            .toList();

        // Use Provider to update the courses in the provider
        Provider.of<CoursesProvider>(context, listen: false)
            .setCoursesforEditingPage(courses);

        print(
            "course Info ${courses.map((course) => course.toJson()).toList()}");
        setState(() {}); // Call setState to update the UI if necessary
      }
    }
  }

  Future<void> sendAddedOrRemovedCourse() async {
    //added list
    final provider = Provider.of<CoursesProvider>(context, listen: false);

    List<int?> addedCourseIds =
        provider.addedCourseList.map((course) => course.id).toList();

    List<int?> removedCourseIds = provider.removedCourseList;

    for (int? courseId in removedCourseIds) {
      removeCourse(widget.semester, widget.index!, courseId!);
    }
    addCourses(widget.semester, widget.index!, addedCourseIds);

    print("removed list $removedCourseIds");
    print("added list $addedCourseIds");

    provider.resetAddedandRemovedCourseList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.index != null) {
      loadCourseDataAtIndex(widget.index!);
    }
    widget.addedCoursesNotifier?.addListener(_onCoursesAdded);
    print("Listener added to addedCoursesNotifier");
  }

  void _onCoursesAdded() {
    var newCourses = widget.addedCoursesNotifier!.value;
    print(
        "Updated courses list: ${jsonEncode(newCourses.map((e) => e.toJson()).toList())}");
    setState(() {
      _courses = newCourses;
    });
  }

  @override
  void dispose() {
    // Remove the listener
    widget.addedCoursesNotifier?.removeListener(_onCoursesAdded);
    super.dispose();
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
              provider.resetAddedandRemovedCourseList();
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
                    Icons.arrow_back_ios,
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
                  text: 'Done',
                  width: 70,
                  height: 35,
                  onTap: () async {
                    sendAddedOrRemovedCourse();
                    await AnalyticsService().editCreate();
                    updateTimetableName(
                        widget.semester, widget.index!, _nameController.text);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  borderColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
      body: ColorfulSafeArea(
        bottomColor: Colors.white.withOpacity(0),
        topColor: Colors.white.withOpacity(0),
        overflowRules: OverflowRules.all(true),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CupertinoTextField(
                        textAlign: TextAlign.center,
                        controller: _nameController,
                        padding: EdgeInsets.all(10),
                        placeholder: "${widget.name}",
                        placeholderStyle: AugustFont.profileName(
                          color: Theme.of(context).colorScheme.surfaceTint,
                        ),
                        style: AugustFont.profileName(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        cursorColor: Theme.of(context).colorScheme.outline,
                        cursorHeight: 40,
                        onChanged: (text) {
                          setState(() {}); // 텍스트 필드의 내용이 변경될 때마다 UI 업데이트
                        },
                        onSubmitted: (text) {
                          updateTimetableName(widget.semester, widget.index!,
                              _nameController.text);
                        },
                        maxLength: 12,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Consumer<CoursesProvider>(
                    builder: (context, provider, child) {
                      return SingleTimetable(
                        courses: provider.courses,
                        index: widget.index ?? -1,
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
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.18,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.1),
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3),
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.5),
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.7),
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(1.0),
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
              ),
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
                  icon: Icon(FeatherIcons.plus, size: 40),
                  color: Colors.white,
                  onPressed: _navigateToPage,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage() async {
    var addedCoursesNotifier = ValueNotifier<List<ScheduleList>>([]);
    if (widget.addedCoursesNotifier == null) {
      widget.addedCoursesNotifier = ValueNotifier<List<ScheduleList>>([]);
    }
    showCupertinoModalBottomSheet<Map<String, dynamic>>(
      topRadius: Radius.circular(30),
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return NotificationListener<ScrollNotification>(
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
            builder:
                (BuildContext context, ScrollController sheetScrollController) {
              return EditSearchPage(
                addedCoursesNotifier: widget.addedCoursesNotifier!,
                semester: widget.semester,
              );
            },
          ),
        );
      },
    );
  }
}
