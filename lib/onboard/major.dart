import 'package:august/components/home/loading.dart';
import 'package:august/components/tile/onboardTile/major_tile.dart';
import 'package:august/const/font/font.dart';
import 'package:august/login/login.dart';
import 'package:august/provider/department_provider.dart';
import 'package:august/provider/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:august/get_api/onboard/get_department.dart'; // Make sure this import is correct
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter_svg/svg.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:animated_hint_textfield/animated_hint_textfield.dart';
import 'package:provider/provider.dart';

class MajorPage extends StatefulWidget {
  final bool onboard;
  final VoidCallback goBack;
  final VoidCallback gonext;
  MajorPage({
    Key? key,
    required this.onboard,
    required this.goBack,
    required this.gonext,
  }) : super(key: key);

  @override
  _MajorPageState createState() => _MajorPageState();
}

class _MajorPageState extends State<MajorPage> {
  /* --- check selected major name --- */
  String? selectedMajorFullname;
  String? selectedMajorNickname;
  int? selectedMajorIndex = 0;

  /* --- department list --- */
  List<String>? departmentList = [];
  List<String> filteredDepartments = [];

  /* --- is loading --- */
  bool isLoading = true;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /* --- department list --- */
    var provider = Provider.of<DepartmentProvider>(context, listen: false);
    departmentList = provider.departmentList;
    filteredDepartments = departmentList!;

    var infoProvider =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo;

    /* --- deaprtment info from the user info provider --- */
    selectedMajorFullname = infoProvider?.department?.fullName;
    selectedMajorNickname = infoProvider?.department?.nickname;
    selectedMajorIndex = infoProvider?.department?.id;

    provider.addListener(_updateDepartmentList);

    isLoading = departmentList!.isEmpty;
  }

  void _updateDepartmentList() {
    if (mounted) {
      setState(() {
        var provider = Provider.of<DepartmentProvider>(context, listen: false);
        departmentList = provider.departmentList;
        filteredDepartments = departmentList!;
        isLoading = false;
      });
    }
  }

  void _filterDepartments(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredDepartments = departmentList!;
      });
    } else {
      setState(() {
        filteredDepartments = departmentList!.where((dept) {
          final parts = dept.split(', ');
          final fullnameAndNickname = parts.sublist(1).join(", ");

          final nickname = fullnameAndNickname.contains("(")
              ? fullnameAndNickname.split(" (")[1].replaceAll(")", "")
              : '';
          return nickname.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  Future<void> _selectMajor(String selectedDept) async {
    // 선택된 항목 문자열을 분석하여 ID, 전체 이름, 별명 추출
    // 예상 형식: "ID: 1, Computer Science (CMSC)"
    final parts = selectedDept.split(', ');
    final idPart = parts[0];
    final fullnameAndNickname = parts.sublist(1).join(", "); // ID 이후 부분 재조합
    final fullName = fullnameAndNickname.split(" (")[0];
    final nickname = fullnameAndNickname.contains("(")
        ? fullnameAndNickname.split(" (")[1].replaceAll(")", "")
        : '';

    // ID 추출
    final id = int.tryParse(idPart.split(': ')[1]) ?? null;

    setState(() {
      selectedMajorIndex = id;
      selectedMajorFullname = fullName;
      selectedMajorNickname = nickname;
    });
  }

  Future<void> _saveInfo() async {
    if (!mounted) return;
    var provider = Provider.of<UserInfoProvider>(context, listen: false);
    provider.updateUserDepartment(
      selectedMajorIndex,
      selectedMajorFullname!,
      selectedMajorNickname!,
      provider.userInfo!.institution!.id!,
    );
  }

  Future<void> _saveAndClose() async {
    if (!mounted) return;
    checkAccessToken();
    await _saveInfo();
    widget.onboard ? null : Navigator.pop(context);
    int? userPk = await fetchUserPk();

    if (userPk == null) {
      print("Failed to fetch userPk");
      return;
    }

    updateDepartment(userPk, selectedMajorIndex).then((_) {
      print(selectedMajorIndex);
      print('Department updated successfully with $selectedMajorIndex');
    }).catchError((error) {
      print('Failed to update department: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Current selectedMajor value: $selectedMajorNickname');
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ColorfulSafeArea(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
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
                  widget.onboard ? "Select Major" : "Change Major",
                  style: AugustFont.head3(
                      color: Theme.of(context).colorScheme.outline),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Selected major will be displayed on your profile and visible to your friends.',
                    textAlign: TextAlign.center,
                    style: AugustFont.head4(color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 15.0, bottom: 15.0, left: 10.0, right: 10.0),
                  child: AnimatedTextField(
                      style: AugustFont.textField(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      animationType: Animationtype.typer,
                      cursorColor: Theme.of(context).colorScheme.outline,
                      controller: searchController,
                      hintTexts: const [
                        'CMSC',
                        'BMGT',
                        'INST',
                        'HIST',
                        'BIOL',
                        'MATH',
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
                        prefixIcon: Icon(
                          FeatherIcons.search,
                          size: 25.0,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      onChanged: _filterDepartments,
                      // onTap: () {
                      //   _saveAndClose();
                      // },
                      onSubmitted: (value) {
                        // This is called when the done button is pressed.
                        FocusScope.of(context).unfocus();
                      },
                      textInputAction: TextInputAction.done),
                ),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: SingleChildScrollView(
                            child: Column(
                              children: List<Widget>.generate(
                                  5, (index) => MajorLoading(context)),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredDepartments.length,
                          itemBuilder: (BuildContext context, int index) {
                            final parts =
                                filteredDepartments[index].split(', ');
                            final fullnameAndNickname =
                                parts.sublist(1).join(", ");
                            final fullname = fullnameAndNickname.split(" (")[0];
                            final nickname = fullnameAndNickname.contains("(")
                                ? fullnameAndNickname
                                    .split(" (")[1]
                                    .replaceAll(")", "")
                                : '';
                            return MajorTile(
                              fullname: fullname,
                              nickname: nickname,
                              tileColor: selectedMajorNickname == nickname
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                              isShadow: selectedMajorNickname == nickname,
                              onTap: () {
                                setState(() {
                                  _selectMajor(filteredDepartments[index]);
                                });
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: 60,
          top: 20,
        ),
        child: widget.onboard
            ? GestureDetector(
                onTap: () {
                  if (selectedMajorIndex != 0) {
                    HapticFeedback.mediumImpact();
                    _saveAndClose();
                    widget.gonext();
                    FocusScope.of(context).unfocus();
                  } else {
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
                            'Please Select a Major',
                            textAlign: TextAlign.center,
                            style: AugustFont.head2(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          content: Text(
                            'You must select your major to continue.',
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
                  //     FocusScope.of(context).unfocus();
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
