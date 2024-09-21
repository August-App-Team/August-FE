import 'dart:ui';
import 'dart:convert';
import 'package:august/provider/semester_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:august/components/gpa/calculate.dart';
import 'package:august/components/gpa/gpa_box.dart';
import 'package:august/components/gpa/gpa_tile.dart';
import 'package:august/components/mepage/gpa_graph.dart';
import 'package:august/get_api/gpa/gpa_courses.dart';
import 'package:august/onboard/semester.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'dart:math' as math;

class GPAPage extends StatefulWidget {
  final String semester;
  const GPAPage({Key? key, required this.semester}) : super(key: key);

  @override
  State<GPAPage> createState() => _GPAPageState();
}

class _GPAPageState extends State<GPAPage> with TickerProviderStateMixin {
  List<PreviousGPA> previousSemester = [
    PreviousGPA(semester: "Spring 2023", grade: 3.8),
    PreviousGPA(semester: "Fall 2023", grade: 3.6),
    PreviousGPA(semester: "Summer 2023", grade: 3.9),
  ];

  List<CurrentGPA> currentSemester = [
    CurrentGPA(
        semester: "Spring 2024",
        title: "CMSC 240",
        credits: 4,
        grade: 3.5,
        isMajor: false),
    CurrentGPA(
        semester: "Spring 2024",
        title: "CMSC350",
        credits: 3,
        grade: 3.7,
        isMajor: true),
    CurrentGPA(
        semester: "Spring 2024",
        title: "CMSC 216",
        credits: 3,
        grade: 4.0,
        isMajor: false),
    CurrentGPA(
        semester: "Spring 2024",
        title: "CMSC 216",
        credits: 3,
        grade: 2.0,
        isMajor: false),
  ];

  List<TotalGPA> totalSemester = [];

  /* --- for edit --- */
  AnimationController? _controller;
  AnimationController? _jiggleController;
  bool isEdit = false;

  /* ---------------- */
  void toggleisEdit(int friendListLength) {
    setState(() {
      isEdit = friendListLength > 0 ? !isEdit : false;
    });
    if (isEdit) {
      _controller?.forward(); // Safely call forward
    } else {
      _controller?.reverse(); // Safely call reverse
    }
  }

  @override
  void initState() {
    super.initState();
    totalSemester = calculateTotalGPA();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Adjust duration as needed
      vsync: this,
    );
    _jiggleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller?.dispose(); // Safe dispose
    _jiggleController?.dispose(); // Safe dispose
    super.dispose();
  }

  List<TotalGPA> calculateTotalGPA() {
    Map<String, List<double>> semesterGrades = {};
    Map<String, int> semesterCredits = {};

    // Collect all GPAs and credits from previousSemester
    for (var gpa in previousSemester) {
      semesterGrades[gpa.semester] = [
        gpa.grade * 1
      ]; // Assume 1 credit for previous GPAs for simplicity
      semesterCredits[gpa.semester] =
          1; // This can be adjusted based on real data
    }

    // Collect and weight GPAs and credits from currentSemester
    for (var gpa in currentSemester) {
      if (semesterGrades.containsKey(gpa.semester)) {
        semesterGrades[gpa.semester]!.add(gpa.grade * gpa.credits);
        semesterCredits[gpa.semester] =
            semesterCredits[gpa.semester]! + gpa.credits;
      } else {
        semesterGrades[gpa.semester] = [gpa.grade * gpa.credits];
        semesterCredits[gpa.semester] = gpa.credits;
      }
    }

    List<TotalGPA> totals = [];
    semesterGrades.forEach((semester, grades) {
      double totalWeightedGrades =
          grades.reduce((value, element) => value + element);
      int totalCredits = semesterCredits[semester]!;
      double totalGPA = totalWeightedGrades / totalCredits;
      totals.add(TotalGPA(semester: semester, grade: totalGPA));
    });

    return totals;
  }

  //save total gpa for the graph on the mepage
  Future<void> saveTotalGPA(List<TotalGPA> totalGPAList) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> gpaStringList =
        totalGPAList.map((gpa) => jsonEncode(gpa.toJson())).toList();
    await prefs.setStringList('totalGPA', gpaStringList);
  }

  Widget JiggleTrashIcon() {
    return AnimatedBuilder(
      animation: _jiggleController!,
      child: Icon(FeatherIcons.trash2, color: Colors.black, size: 40),
      builder: (context, child) {
        // Use sin function to create the jiggle effect
        final angle = math.sin(_jiggleController!.value * 5 * math.pi) *
            0.1; // Adjust amplitude for more/less jiggle
        return Transform.rotate(
          angle: angle,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: ColorfulSafeArea(
          bottom: false,
          child: SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2, top: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GPA Calculator',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          // Consumer<SavedSemesterProvider>(
                          //   builder: (context, semesterProvider, child) {
                          //     return Text(
                          //       '${semesterProvider.selectedSemester}',
                          //       style:
                          //           TextStyle(fontSize: 15, color: Colors.grey),
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 2, right: 10, top: 5, bottom: 20),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.background,
                          child: Center(
                            child: Icon(
                              FeatherIcons.x,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                gpaGraph(),
                SizedBox(height: 20),
                previousGPA(),
                SizedBox(height: 20),
                currentGPA(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget gpaGraph() {
    // Create a list of GraphData objects from the totalSemester list
    List<GraphData> chartData = totalSemester.map((data) {
      return GraphData(data.semester, data.grade);
    }).toList();

    // If no total GPA data is available, fall back to previous semester data
    if (chartData.isEmpty) {
      chartData = previousSemester.map((data) {
        return GraphData(data.semester, data.grade);
      }).toList();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
      child: GPAGraph(
        chartData: chartData,
      ),
    );
  }

  // Helper function to extract season from semester string
  String extractSeason(String semester) {
    return semester
        .split(" ")[0]
        .toLowerCase(); // Assuming format "Season Year"
  }

// Adjusted determineColor function to use lowercase season names
  Color determineColor(String semester) {
    String season = extractSeason(semester);
    switch (season) {
      case "spring":
        return Color(0xFFffe6ea);
      case "summer":
        return Color(0xFFfff7e6);
      case "fall":
        return Color(0xFFffefe5);
      default:
        return Color(0xFFbac9f7); // Default for "winter" and any others
    }
  }

  List<Widget> generateGPAWidgets(List<PreviousGPA> gpaList) {
    List<Widget> widgets = [];

    widgets.add(SizedBox(width: 10));

    for (int i = 0; i < gpaList.length; i++) {
      widgets.add(GPAWidget(
        onTap: () {},
        info: gpaList[i].grade.toString(),
        subInfo: gpaList[i].semester,
        photo: "assets/season/${extractSeason(gpaList[i].semester)}.svg",
        photoBackground: determineColor(gpaList[i].semester),
      ));

      widgets.add(SizedBox(width: 20));
    }

    widgets.last = SizedBox(width: 10);

    return widgets;
  }

  Widget previousGPA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              "Previous",
              style: TextStyle(
                fontSize: 25,
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  isEdit = !isEdit;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 5, right: 10),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: 30,
                  width: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isEdit
                        ? Colors.blueAccent
                        : Theme.of(context).colorScheme.primary,
                  ),
                  child: Center(
                    child: Text(
                      isEdit ? 'Done' : 'Edit',
                      style: TextStyle(
                        fontSize: 15,
                        color: Theme.of(context).colorScheme.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SingleChildScrollView(
          controller: ScrollController(),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...generateGPAWidgets(previousSemester),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow,
                        blurRadius: 10, // 블러 효과를 줄여서 그림자를 더 세밀하게
                        offset: Offset(4, -1), // 좌우 그림자의 길이를 줄임
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow,
                        blurRadius: 10,
                        offset: Offset(-1, 0), // 좌우 그림자의 길이를 줄임
                      ),
                    ],
                  ),
                  width: 130,
                  height: 130,
                  child: Icon(
                    FeatherIcons.plus,
                    size: 40,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                "Click\nplus button\nto add\nprevious semester",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }

  Widget currentGPA() {
    GPACalculations gpaCalculations = GPACalculations(currentSemester);
    double weightedGPA = gpaCalculations.weightedGPA;
    return Column(
      children: [
        Row(
          children: [
            Consumer<SemesterProvider>(
              builder: (context, semesterProvider, child) {
                return Text(
                  '${semesterProvider.semester}',
                  style: TextStyle(
                    fontSize: 25,
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(top: 5, right: 10),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: 30,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Center(
                  child: Text(
                    'GPA: ${weightedGPA.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Title",
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Credit",
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Grade",
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Major",
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 10,
                  offset: Offset(4, -1),
                ),
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 10,
                  offset: Offset(-1, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                if (currentSemester.isNotEmpty)
                  ...List<Widget>.generate(currentSemester.length * 2 - 1,
                      (index) {
                    if (index % 2 == 0) {
                      final course = currentSemester[index ~/ 2];
                      return GPATile(
                        classTitle: course.title,
                        classCredit: course.credits.toString(),
                        classGrade: course.grade.toString(),
                        major: course.isMajor,
                        onTap: () {},
                      );
                    } else {
                      return Divider(
                        color: Theme.of(context).colorScheme.scrim,
                      );
                    }
                  }),
                if (currentSemester.isNotEmpty)
                  Divider(
                    color: Theme.of(context).colorScheme.scrim,
                  ),
                // Always visible Plus button at the end of the list or standalone if the list is empty
                GestureDetector(
                  onTap: () {
                    print("saved");
                    saveTotalGPA(totalSemester);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    height: 55,
                    child: Center(
                      child: Icon(
                        FeatherIcons.plus,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(
          "Click plus button to add a new course",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
