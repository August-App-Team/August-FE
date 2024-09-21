import 'package:august/components/home/button.dart';
import 'package:august/components/home/dialog.dart';
import 'package:august/components/home/loading.dart';
import 'package:august/const/font/font.dart';
import 'package:august/provider/courseprovider.dart';
import 'package:august/components/tile/onboardTile/univ_tile.dart';
import 'package:august/get_api/onboard/get_semester.dart';
import 'package:august/get_api/onboard/get_univ.dart';
import 'package:august/login/login.dart';
import 'package:august/provider/Institution_provider.dart';
import 'package:august/provider/user_info_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:animated_hint_textfield/animated_hint_textfield.dart';

class UnivPage extends StatefulWidget {
  final bool onboard;
  final VoidCallback goBack;
  final VoidCallback gonext;
  UnivPage({
    Key? key,
    required this.onboard,
    required this.goBack,
    required this.gonext,
  }) : super(key: key);

  @override
  _UnivPageState createState() => _UnivPageState();
}

class _UnivPageState extends State<UnivPage> {
  /* --- check selected school info ---  */
  String? selectedSchoolFullname;
  String? selectedSchoolNickname;
  int? selectedSchoolIndex;
  String? selectedSchoolLogo;
  /* --- schoool list --- */
  List<Institution> schoolsList = []; // Updated to hold Institution objects
  List<Institution> filteredSchoolList = [];

  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

// initState에서 _loadInfo 호출
  @override
  void initState() {
    super.initState();
    var provider = Provider.of<InstitutionProvider>(context, listen: false);
    var infoProvider =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo;

    /* --- school list --- */
    schoolsList = provider.institutionList;
    filteredSchoolList = schoolsList;

    /* --- school info from the user info provider --- */
    selectedSchoolFullname = infoProvider?.institution?.fullName;
    selectedSchoolNickname = infoProvider?.institution?.nickname;
    selectedSchoolIndex = infoProvider?.institution?.id;
    selectedSchoolLogo = infoProvider?.institution?.logo;

    Future.delayed(Duration(seconds: 1), () {
      print('check filter list ${filteredSchoolList.length}');
    });

    provider.addListener(_updateSchoolsList);

    isLoading = schoolsList.isEmpty;
  }

  void _updateSchoolsList() {
    if (mounted) {
      setState(() {
        var provider = Provider.of<InstitutionProvider>(context, listen: false);
        schoolsList = provider.institutionList;
        filteredSchoolList = schoolsList;
        isLoading = false;
      });
    }
  }

  void _filterSchoolList(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSchoolList = schoolsList;
      } else {
        filteredSchoolList = schoolsList.where((school) {
          // Ensure the nickname is not null
          String nickname = school.nickname.toLowerCase();
          return nickname.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Future<void> _saveInfo() async {
    if (!mounted) return;
    Provider.of<UserInfoProvider>(context, listen: false).updateUserInstitution(
        selectedSchoolIndex!,
        selectedSchoolFullname!,
        selectedSchoolNickname!,
        selectedSchoolLogo!);
  }

// 'Done' 버튼이 클릭될 때 _saveInfo 호출
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

    if (selectedSchoolFullname!.isNotEmpty && selectedSchoolIndex != null) {
      // updateInstitution을 백그라운드에서 호출
      updateInstitution(userPk, selectedSchoolIndex!).then((_) {
        print('Institution updated successfully');
      }).catchError((error) {
        print('Failed to update institution: $error');
      });
    }

    // 바로 다음 화면으로 넘어가거나 현재 화면을 닫음
  }

  void _onSchoolChanged(String? value) {
    if (!mounted) return;
    var selectedInstitution = schoolsList.firstWhere(
      (institution) => institution.fullName == value,
    );
    setState(() {
      selectedSchoolFullname = value;
      if (selectedInstitution != null) {
        selectedSchoolNickname = selectedInstitution.nickname;
        selectedSchoolIndex = selectedInstitution.id; // 선택한 기관의 id를 저장합니다.

        // print('Selected School Fullname: $_selectedSchoolFullname');
        // print('Selected School Nickname: $_selectedSchoolNickname');
        // print('id: $_selectedSchoolIndex');
        // print('logo: $_selectedSchoolLogo');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  widget.onboard
                      ? "Select Your University"
                      : "Change Your University",
                  style: AugustFont.head3(
                      color: Theme.of(context).colorScheme.outline),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Your university choice determines\ncourse availabilities.",
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
                        'UMD',
                        'NYU',
                        'CMU',
                        'BU',
                        'UCB',
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
                      onChanged: _filterSchoolList,
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
                                  5, (index) => UnivLoading(context)),
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredSchoolList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return UniversityTile(
                              logo: filteredSchoolList[index].logo,
                              fullname: filteredSchoolList[index].fullName,
                              nickname: filteredSchoolList[index].nickname,
                              tileColor: selectedSchoolFullname ==
                                      filteredSchoolList[index].fullName
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                              isShadow: selectedSchoolFullname ==
                                  filteredSchoolList[index].fullName,
                              onTap: () {
                                _onSchoolChanged(
                                    filteredSchoolList[index].fullName);
                                setState(
                                  () {
                                    selectedSchoolFullname =
                                        filteredSchoolList[index].fullName;
                                    selectedSchoolNickname =
                                        filteredSchoolList[index].nickname;
                                    selectedSchoolIndex =
                                        filteredSchoolList[index].id;
                                    selectedSchoolLogo =
                                        filteredSchoolList[index].logo;
                                  },
                                );
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
        ),
        child: widget.onboard
            ? GestureDetector(
                onTap: () {
                  if (selectedSchoolFullname != null &&
                      selectedSchoolFullname!.isNotEmpty) {
                    HapticFeedback.mediumImpact();
                    widget.gonext();
                    _saveAndClose();
                  } else {
                    if (mounted) {
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'OK',
                                        style: AugustFont.head4(
                                            color: Colors.white),
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
