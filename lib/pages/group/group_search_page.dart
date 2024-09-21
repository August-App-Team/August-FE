import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:august/components/ad/ad_list.dart';
import 'package:august/components/home/loading.dart';
import 'package:august/const/font/font.dart';
import 'package:august/const/icons/icons.dart';
import 'package:august/get_api/onboard/get_semester.dart';
import 'package:august/provider/semester_provider.dart';
import 'package:flutter/material.dart';
import '../../get_api/timetable/class.dart';
import '../../get_api/search/get_api.dart';
import '../../components/tile/class_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class GroupSearchPage extends StatefulWidget {
  final void Function(GroupList) onCourseSelected;
  final ValueNotifier<List<GroupList>> addedCoursesNotifier;
  final String? title;

  GroupSearchPage({
    Key? key,
    required this.onCourseSelected,
    required this.addedCoursesNotifier,
    this.title,
  }) : super(key: key);

  @override
  State<GroupSearchPage> createState() => _GroupSearchPageState();
}

class InstructorCourse {
  final GroupList course;
  final GroupInstructor instructor;
  final List<GroupSection> sections;
  InstructorCourse(this.course, this.instructor, this.sections);
}

class _GroupSearchPageState extends State<GroupSearchPage>
    with SingleTickerProviderStateMixin {
  List<GroupList> _foundCourses = [];
  late TextEditingController _keywordController;
  Future<List<GroupList>>? _coursesFuture;
  List<String> _searchKeywords = [];
  late String currentSemetser;

  void addToGroup(GroupList classes) {
    widget.onCourseSelected(classes);
  }

  void removeFromGroup(GroupList course) {
    widget.addedCoursesNotifier.value.remove(course);
  }

  /* 
  _foundCourses[0].instructors![0].sections![0].meetingsExist
  */

  bool hasMeetings(List<GroupSection> sections) {
    for (var section in sections) {
      if (!section.meetingsExist) {
        print("Section without meetings found: ${section.fullCode}");
        return false; // Return false immediately if any section does not have meetings
      }
    }
    return true; // Return true only if all sections have meetings
  }

  Future<List<GroupList>> _runSearch(String enteredKeyword) async {
    FetchGroup _courses = FetchGroup();

    String querytype = 'code';

    List<GroupList> apiData = await _courses.getGroupList(
        querytype: querytype, semester: currentSemetser, query: enteredKeyword);

    if (mounted) {
      setState(() {
        _foundCourses = apiData;
      });
    }
    print(
        'foudned courses meeting info ${_foundCourses[0].instructors![0].sections![0].meetingsExist}');
    await _storeSearchKeyword(enteredKeyword);

    //sort the courses by course code
    apiData.sort((a, b) => a.courseCode!.compareTo(b.courseCode!));
    return apiData;
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
  void initState() {
    super.initState();
    currentSemetser =
        Provider.of<SemesterProvider>(context, listen: false).semester;
    // Initialize the keyword controller and add listener
    this._keywordController = TextEditingController();

    //검색어 저장
    _loadSearchKeywords();
  }

  @override
  void dispose() {
    _keywordController.dispose();

    super.dispose();
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
          forceMaterialTransparency: true,
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
                      formatSemester(currentSemetser),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.only(
                    top: 0.0, bottom: 10.0, left: 15.0, right: 15.0),
                child: AnimatedTextField(
                    style: AugustFont.textField(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    animationType: Animationtype.typer,
                    cursorColor: Theme.of(context).colorScheme.outline,
                    controller: _keywordController,
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
                      hintText: 'Search Courses',
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
                        icon: Icon(AugustIcons.delete,
                            size: 20,
                            color: Theme.of(context).colorScheme.outline),
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
              child: FutureBuilder<List<GroupList>>(
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
                                      color:
                                          Theme.of(context).colorScheme.outline,
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
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          )
                        else
                          Container(
                              margin: EdgeInsets.only(left: 10, top: 5),
                              child: Wrap(
                                spacing: 8.0, // 가로 간격
                                runSpacing: 4.0, // 세로 간격
                                children: List.generate(_searchKeywords.length,
                                    (index) {
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
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
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
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return SingleChildScrollView(
                      child: Center(
                        child: Column(
                          children: List<Widget>.generate(
                              7, (index) => GroupLoading1(context)),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    // 사용자 인터페이스에서 에러 메시지 표시
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
                    // Flatten the list of instructors.
                    List<InstructorCourse> instructorCourses = [];

                    for (var course in _foundCourses) {
                      // Create a map to track instructors and their sections
                      Map<String, List<GroupSection>> instructorSectionMap = {};

                      for (var instructor in course.instructors!) {
                        // Initialize the list for this instructor if not already done
                        instructorSectionMap.putIfAbsent(
                            instructor.name!, () => []);

                        // Add all sections of this instructor to the map
                        instructorSectionMap[instructor.name]!
                            .addAll(instructor.sections!);
                      }

                      // Now create InstructorCourse objects using the map
                      instructorSectionMap.forEach((instructorName, sections) {
                        var instructor = course.instructors!
                            .firstWhere((inst) => inst.name == instructorName);
                        instructorCourses.add(
                            InstructorCourse(course, instructor, sections));
                      });
                    }

                    return ListView.builder(
                      itemCount: instructorCourses.length +
                          ((instructorCourses.length < 4 ||
                                  instructorCourses.length % 5 == 0)
                              ? 1
                              : 0) +
                          (instructorCourses.length / 5).floor(),
                      itemBuilder: (context, index) {
                        int actualIndex = index - (index / 6).floor();

                        if ((instructorCourses.length < 4 &&
                                index == instructorCourses.length) ||
                            (index % 6 == 5)) {
                          return googleAdMobContainer(isGroup: true);
                        } else if (actualIndex < instructorCourses.length) {
                          var course = instructorCourses[actualIndex].course;
                          var instructor =
                              instructorCourses[actualIndex].instructor;
                          var section = instructorCourses[actualIndex].sections;

                          return ClassTile(
                            classes: GroupList(
                              name: course.name,
                              courseCode: course.courseCode,
                              credits: course.credits,
                              instructors: [instructor],
                            ),
                            onPressed: (context) {
                              Navigator.pop(context);

                              if (hasMeetings(section)) {
                                print(
                                    'check this course has meeting ${course.courseCode.toString()}');
                                addToGroup(GroupList(
                                  name: course.name,
                                  courseCode: course.courseCode,
                                  credits: course.credits,
                                  instructors: [instructor],
                                ));
                              } else {
                                print(
                                    'check this course does not have meeting ${course.courseCode.toString()}');
                                addToGroup(GroupList(
                                  name: course.name,
                                  courseCode: course.courseCode,
                                  credits: course.credits,
                                  instructors: [instructor],
                                ));
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      icon: Icon(
                                        FeatherIcons.alertTriangle,
                                        color: Colors.redAccent,
                                        size: 45,
                                      ),
                                      title: Text(
                                          textAlign: TextAlign.center,
                                          '${course.courseCode} (ONLINE)',
                                          style: AugustFont.head2(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .outline)),
                                      content: Text(
                                          textAlign: TextAlign.center,
                                          'This course will not appear on the schedule.',
                                          style: AugustFont.subText2(
                                              color: Colors.grey)),
                                      actions: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context)
                                                .pop(); // 팝업 닫기
                                          },
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30),
                                            height: 55,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                80,
                                            decoration: BoxDecoration(
                                                color: Colors.redAccent,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                              }
                            },
                            icon: AugustIcons.addCoursetoGroup,
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
                            index: actualIndex,
                            sections: section,
                          );
                        }
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
