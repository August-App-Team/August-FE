import 'package:august/const/font/font.dart';
import 'package:august/provider/courseprovider.dart';
import 'package:august/components/tile/onboardTile/grade_tile.dart';
import 'package:august/get_api/onboard/get_semester.dart';
import 'package:august/login/login.dart';
import 'package:august/provider/user_info_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:colorful_safe_area/colorful_safe_area.dart';

class GradePage extends StatefulWidget {
  final bool onboard;
  final VoidCallback goBack;
  final VoidCallback gonext;
  GradePage({
    super.key,
    required this.onboard,
    required this.goBack,
    required this.gonext,
  });

  @override
  _GradePageState createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  String? selectGrade;

  @override
  void dispose() {
    super.dispose();
  }

// initState에서 _loadInfo 호출
  @override
  void initState() {
    super.initState();
    var infoProvider =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo;
    selectGrade =
        convertShortentoFull(infoProvider!.yearInSchool!); //JR 이렇게 받아옴
  }

  Future<void> _saveInfo() async {
    String convertedDepartment = convertDepartment(selectGrade!);
    Provider.of<UserInfoProvider>(context, listen: false)
        .updateUserYearInSchool(convertedDepartment);
  }

  String convertShortentoFull(String department) {
    switch (department) {
      case 'FR':
        department = 'Freshman';
        break;
      case 'SO':
        department = 'Sophomore';
        break;
      case 'JR':
        department = 'Junior';
        break;
      case 'SR':
        department = 'Senior';
        break;
      case 'GR':
        department = 'Graduated';
        break;
      default:
        department = 'New?'; // 기본값 또는 오류 처리
    }
    return department;
  }

  String convertDepartment(String department) {
    switch (department) {
      case 'Freshman':
        department = 'FR';
        break;
      case 'Sophomore':
        department = 'SO';
        break;
      case 'Junior':
        department = 'JR';
        break;
      case 'Senior':
        department = 'SR';
        break;
      case 'Graduated':
        department = 'GR';
        break;
      default:
        department = 'New?'; // 기본값 또는 오류 처리
    }
    return department;
  }

// 'Done' 버튼이 클릭될 때 _saveInfo 호출
  Future<void> _saveAndClose() async {
    checkAccessToken();
    await _saveInfo();

    widget.onboard ? null : Navigator.pop(context);

    int? userPk = await fetchUserPk();

    if (userPk == null) {
      print("Failed to fetch userPk");
      return;
    }
    String convertedDepartment = convertDepartment(selectGrade!);
    if (selectGrade!.isNotEmpty) {
      // updateInstitution을 백그라운드에서 호출
      updateGrade(userPk, convertedDepartment!).then((_) {
        print('Grade updated successfully');
      }).catchError((error) {
        print('Failed to update Grade: $error');
      });
    }
  }

  void _onGradeChanged(String? value) {
    setState(() {
      selectGrade = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double minHeightForLargeDevice = 812.0;
    bool isLargeDevice = screenSize.height > minHeightForLargeDevice;
    print('Current selectGrade value: $selectGrade');
    List<String> grades = [
      'Freshman',
      'Sophomore',
      'Junior',
      'Senior',
      'Graduated'
    ];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ColorfulSafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    if (widget.onboard == true)
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            widget.goBack();
                            _saveAndClose();
                          },
                          child: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.background,
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
                    Spacer(),
                    if (widget.onboard == false)
                      Padding(
                        padding: const EdgeInsets.only(
                            right: 20, top: 5, bottom: 10),
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
                if (widget.onboard == true) SizedBox(height: 10),
                Text(
                  widget.onboard ? "Select Grade" : "Senior Yet?",
                  style: AugustFont.head3(
                      color: Theme.of(context).colorScheme.outline),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "How much longer until I finish school?\nChoose your grade to get started",
                  textAlign: TextAlign.center,
                  style: AugustFont.head4(color: Colors.grey),
                ),
                SizedBox(height: 40),
                Expanded(
                  child: ListView.builder(
                    itemCount: grades.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GradeTile(
                        grade: grades[index],
                        tileColor: selectGrade == grades[index]
                            ? Theme.of(context)
                                .colorScheme
                                .primary // Selected color
                            : Theme.of(context)
                                .colorScheme
                                .primaryContainer, // Non-selected color
                        isShadow: selectGrade == grades[index],
                        onTap: () {
                          _onGradeChanged(grades[index]);
                          setState(() {
                            selectGrade = grades[index];
                          });
                        },
                      );
                    },
                  ),
                ),
                // Container(
                //   child: Form(
                //     child: SingleChildScrollView(
                //       child: Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         children: grades.map((grade) {
                //           return GradeTile(
                //             grade: grade,
                //             tileColor: selectGrade == grade
                //                 ? Theme.of(context)
                //                     .colorScheme
                //                     .primary // Selected color
                //                 : Theme.of(context)
                //                     .colorScheme
                //                     .primaryContainer, // Non-selected color
                //             isShadow: selectGrade == grade,
                //             onTap: () {
                //               _onGradeChanged(grade);
                //               setState(() {
                //                 selectGrade = grade;
                //               });
                //             },
                //           );
                //         }).toList(),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: isLargeDevice
            ? const EdgeInsets.only(left: 15, right: 15, bottom: 40, top: 40)
            : const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 15),
        child: widget.onboard
            ? GestureDetector(
                onTap: () {
                  if (selectGrade != null) {
                    HapticFeedback.mediumImpact();
                    widget.gonext();
                    _saveAndClose();
                  } else {
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
                            'Please select a university',
                            textAlign: TextAlign.center,
                            style: AugustFont.head2(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          content: Text(
                            'You must select a university to continue.',
                            textAlign: TextAlign.center,
                            style: AugustFont.subText2(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          actions: <Widget>[
                            GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pop();
                                HapticFeedback.lightImpact();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                height: 55,
                                width: MediaQuery.of(context).size.width - 80,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'OK',
                                      style:
                                          AugustFont.head4(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  height: 60,
                  width: MediaQuery.of(context).size.width - 80,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'NEXT',
                        style: AugustFont.head2(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            : GestureDetector(
                onTap: () {
                  _saveAndClose();
                  HapticFeedback.mediumImpact();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  height: 55,
                  width: MediaQuery.of(context).size.width - 80,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(60)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DONE',
                        style: AugustFont.head2(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
