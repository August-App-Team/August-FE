import 'dart:convert';
import 'dart:ui';
import 'package:august/provider/course_color_provider.dart';
import 'package:august/const/colors/modify_color.dart';
import 'package:august/const/theme/dark_theme.dart';
import 'package:august/const/theme/light_theme.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class GradeCalcPage extends StatefulWidget {
  final int index;
  const GradeCalcPage({super.key, required this.index});

  @override
  State<GradeCalcPage> createState() => __GradeCalcPageState();
}

class Assignment {
  String name;
  String grade;
  String weight;
  bool weightButton;
  bool gradeButton;

  Assignment({
    this.name = '',
    this.grade = '0',
    this.weight = '0',
    this.weightButton = false,
    this.gradeButton = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'grade': grade,
      'weight': weight,
      'weightButton': weightButton,
      'gradeButton': gradeButton,
    };
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      name: json['name'],
      grade: json['grade'],
      weight: json['weight'],
      weightButton: json['weightButton'],
      gradeButton: json['gradeButton'],
    );
  }
}

class __GradeCalcPageState extends State<GradeCalcPage>
    with SingleTickerProviderStateMixin {
  List<Assignment> assignment = [];
  late final controller;
  double totalWeight = 0.0;
  double totalGpa = 0.0;

  @override
  void initState() {
    super.initState();
    controller = SlidableController(this);
    loadAssignments().then((_) {
      print("Assignments loaded successfully.");
    }).catchError((error) {
      print("Failed to load assignments: $error");
    });
  }

  Future<bool> saveAssignments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String key = 'course_assignments_${widget.index}';
      List<String> jsonAssignments = assignment
          .map((assignment) => json.encode(assignment.toJson()))
          .toList();

      // Save assignments
      await prefs.setStringList(key, jsonAssignments);

      // Save totalWeight and totalGpa
      await prefs.setDouble('totalWeight_${widget.index}', totalWeight);
      await prefs.setDouble('totalGpa_${widget.index}', totalGpa);

      print("Assignments, totalWeight, and totalGpa saved");
      return true;
    } catch (e) {
      print("Error saving data: $e");
      return false;
    }
  }

  Future<void> loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'course_assignments_${widget.index}';
    List<String> jsonAssignments = prefs.getStringList(key) ?? [];
    print("Loaded assignments: $jsonAssignments");
    if (jsonAssignments.isNotEmpty) {
      setState(() {
        assignment = jsonAssignments
            .map((jsonAssignment) =>
                Assignment.fromJson(json.decode(jsonAssignment)))
            .toList();
      });
    } else {
      print("No assignments found in local storage.");
    }
    totalWeight = prefs.getDouble('totalWeight_${widget.index}') ?? 0.0;
    totalGpa = prefs.getDouble('totalGpa_${widget.index}') ?? 0.0;
  }

  Future<void> clearAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    String key = 'course_assignments_${widget.index}';
    bool result = await prefs.remove(key);
    print("Clear assignments result: $result");
    if (result) {
      setState(() {
        assignment = [];
      });
    }
  }

  void addAssignment(Assignment newAssignment) {
    setState(() {
      assignment.add(newAssignment);
      saveAssignments();
    });
  }

  void removeAssignment(int index) {
    setState(() {
      assignment.removeAt(index);
      saveAssignments();
      recalculateTotalGPA();
    });
  }

  // Methods to update weight and grade
  void updateAssignmentWeight(int index, String weight) {
    setState(() {
      assignment[index].weight = weight;
      saveAssignments();
    });
  }

  void updateAssignmentGrade(int index, String grade) {
    setState(() {
      assignment[index].grade = grade;
      saveAssignments();
    });
  }

  String formatAssignmentName(String name) {
    List<String> words = name.split('');
    if (words.length > 7) {
      return words.take(6).join('') + '...';
    }
    return name;
  }

  Future<void> AssignmentList() async {
    // Controllers for the form fields
    TextEditingController nameController = TextEditingController();

    // Show modal and wait for the result
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      //  isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return AssignmentModal(context, nameController);
      },
    );

    if (result != null && result['name'].isNotEmpty) {
      setState(() {
        assignment.add(Assignment(
          name: result['name'],
          grade: "0",
          weight: "0",
          weightButton: false,
          gradeButton: false,
        ));
      });
    }
  }

  Widget AssignmentModal(
      BuildContext context, TextEditingController nameController) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        color: Theme.of(context).colorScheme.background,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              "Add Assignment",
              style: TextStyle(
                fontSize: 25,
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    autofocus: true,
                    controller: nameController,
                    placeholder: "Assignment Name",
                    placeholderStyle: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    cursorColor: Theme.of(context).colorScheme.outline,
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  ),
                ),
                SizedBox(
                    width:
                        10), // Provide some spacing between the text field and the button
                GestureDetector(
                  onTap: () {
                    // Collecting input data and popping the modal with result
                    Navigator.of(context).pop();
                    addAssignment(Assignment(name: nameController.text));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> GradeList(int index) async {
    TextEditingController gradeController = TextEditingController();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return GradeModal(context, gradeController, index);
      },
    );

    print("Grade modal result: $result"); // Check what the modal returns

    if (result != null && result['grade'].isNotEmpty) {
      double oldGrade = double.tryParse(assignment[index].grade) ?? 0.0;
      print(
          "Old Grade: ${assignment[index].grade}, New Grade: ${result['grade']}"); // Log before updating

      if (oldGrade != double.tryParse(result['grade'])) {
        setState(() {
          assignment[index].grade = result['grade'];
          assignment[index].gradeButton = true;
          recalculateTotalGPA(); // Recalculate the total GPA after updating the grade
        });
      }
    }
  }

  Widget GradeModal(
      BuildContext context, TextEditingController gradeController, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        color: Theme.of(context).colorScheme.background,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              "Grade?",
              style: TextStyle(
                fontSize: 25,
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    autofocus: true,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                    ],
                    controller: gradeController,
                    placeholder:
                        'Grade of ${formatAssignmentName(assignment[index].name)}',
                    placeholderStyle: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    cursorColor: Theme.of(context).colorScheme.outline,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  ),
                ),
                SizedBox(
                    width:
                        10), // Provide some spacing between the text field and the button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      assignment[index].grade = gradeController.text;
                    });
                    assignment[index].gradeButton = true;
                    // Collecting input data and popping the modal with result
                    recalculateTotalGPA();
                    updateAssignmentGrade(index, gradeController.text);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> WeightList(int index) async {
    TextEditingController weightController = TextEditingController();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return weightModal(context, weightController, index);
      },
    );

    if (result != null && result['weight'].isNotEmpty) {
      double oldWeight = double.tryParse(assignment[index].weight) ?? 0.0;
      setState(() {
        assignment[index].weight = result['weight'];
        // Adjust totalWeight by subtracting old weight and adding new weight
        totalWeight =
            totalWeight - oldWeight + double.parse(assignment[index].weight);
      });
    }
  }

  Widget weightModal(
      BuildContext context, TextEditingController weightController, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: Container(
        color: Theme.of(context).colorScheme.background,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              "Weight?",
              style: TextStyle(
                fontSize: 25,
                color: Theme.of(context).colorScheme.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(3),
                    ],
                    autofocus: true,
                    controller: weightController,
                    placeholder: 'Weight of ${assignment[index].name}',
                    placeholderStyle: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    cursorColor: Theme.of(context).colorScheme.outline,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  ),
                ),
                SizedBox(
                    width:
                        10), // Provide some spacing between the text field and the button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      assignment[index].weight = weightController.text;
                    });
                    totalWeight += double.parse(assignment[index].weight);
                    assignment[index].weightButton = true;
                    // Collecting input data and popping the modal with result
                    recalculateTotalGPA();
                    updateAssignmentWeight(index, weightController.text);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void recalculateTotalGPA() {
    double newTotalGpa = 0.0;
    double newTotalWeight = 0.0;
    for (var a in assignment) {
      double weight = double.tryParse(a.weight) ?? 0.0;
      double grade = double.tryParse(a.grade) ?? 0.0;

      newTotalGpa += (weight * grade);
      newTotalWeight += weight;
    }
    if (newTotalWeight > 0) {
      totalGpa = newTotalGpa / newTotalWeight;
    } else {
      totalGpa = 0.0;
    }
    print("New Total GPA: $totalGpa"); // Final GPA
    setState(() {
      totalWeight = newTotalWeight;
    });
  }

  String getLetterGrade(double grade) {
    if (grade >= 96) {
      return 'A+';
    } else if (grade >= 93) {
      return 'A';
    } else if (grade >= 90) {
      return 'A-';
    } else if (grade >= 87) {
      return 'B+';
    } else if (grade >= 83) {
      return 'B';
    } else if (grade >= 80) {
      return 'B-';
    } else if (grade >= 76) {
      return 'C+';
    } else if (grade >= 73) {
      return 'C';
    } else if (grade >= 70) {
      return 'C-';
    } else if (grade >= 66) {
      return 'D+';
    } else if (grade >= 63) {
      return 'D';
    } else if (grade >= 60) {
      return 'D-';
    } else {
      return 'F';
    }
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
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leadingWidth: 80,
        toolbarHeight: 60,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context, getLetterGrade(totalGpa));
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
        titleSpacing: 0.0,
        title: Text(
          "Grade Calculator",
          style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 10),
        child: ColorfulSafeArea(
          bottomColor: Colors.white.withOpacity(0),
          overflowRules: OverflowRules.only(bottom: true),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            "Current Grade",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: Text(
                            totalGpa.toStringAsFixed(2),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: MediaQuery.of(context).size.width / 2.2,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'Letter Grade',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Center(
                          child: Text(
                            getLetterGrade(
                                double.parse(totalGpa.toStringAsFixed(2))),
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text(
                          'Assignments',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            clearAssignments();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                              width: 80,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: Colors.red,
                              ),
                              child: Center(
                                child: Text(
                                  'Clear All',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            AssignmentList();
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              child: Center(
                                child: Icon(
                                  FeatherIcons.plus,
                                  size: 30,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: assignment.length, // 과제의 총 개수
                  itemBuilder: (context, index) {
                    // 각 과제에 대한 정보를 표시
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Slidable(
                        key: ValueKey(assignment[index]),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          dismissible: DismissiblePane(
                            onDismissed: () {
                              setState(() {
                                assignment.removeAt(index);
                              });
                            },
                          ),
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            SlidableAction(
                              borderRadius: BorderRadius.circular(
                                  10), // Smaller border radius for a more subtle effect
                              onPressed: (context) {
                                if (index >= 0 && index < assignment.length) {
                                  removeAssignment(index);
                                }
                              },
                              backgroundColor: Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 0),
                          child: Container(
                            height: 80,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Assignment ${index + 1}',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        formatAssignmentName(
                                            assignment[index].name),
                                        style: TextStyle(
                                          fontSize: 25,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => WeightList(
                                      index), // 성적 업데이트 함수를 호출할 때 인덱스 전달
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    child: Container(
                                      width: 85, // 너비 조절
                                      height: 60, // 높이 조절
                                      decoration: BoxDecoration(
                                        color: assignment[index].weightButton
                                            ? Colors.white.withOpacity(0.3)
                                            : tileColors[widget.index + 1],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Weight',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  assignment[index].weightButton
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .outline
                                                      : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            assignment[index]
                                                    .weight
                                                    .toString() +
                                                ' %',
                                            style: TextStyle(
                                              fontSize: 25,
                                              color:
                                                  assignment[index].weightButton
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .outline
                                                      : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                                GestureDetector(
                                  onTap: () => GradeList(
                                      index), // 성적 업데이트 함수를 호출할 때 인덱스 전달
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                    child: Container(
                                      width: 140, // 너비 조절
                                      height: 60, // 높이 조절
                                      decoration: BoxDecoration(
                                        color: assignment[index].gradeButton
                                            ? Colors.white.withOpacity(0.3)
                                            : tileColors[widget.index + 1],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Grade',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  assignment[index].gradeButton
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .outline
                                                      : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            assignment[index].grade.toString() +
                                                ' / 100',
                                            style: TextStyle(
                                              fontSize: 25,
                                              color:
                                                  assignment[index].gradeButton
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .outline
                                                      : Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
