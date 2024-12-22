import 'dart:convert';
import 'dart:io';
import 'package:august/components/firebase/firebase_analytics.dart';
import 'package:august/components/home/dialog.dart';
import 'package:august/components/mepage/course_color.dart';
import 'package:august/components/mepage/customize_icon.dart';
import 'package:august/components/mepage/cuztomize_box.dart';
import 'package:august/components/mepage/feedback.dart';
import 'package:august/components/mepage/info_box.dart';
import 'package:august/components/mepage/item_tile.dart';
import 'package:august/components/mepage/premium.dart';
import 'package:august/components/mepage/send_email.dart';
import 'package:august/components/profile/profile.dart';
import 'package:august/const/font/font.dart';
import 'package:august/pages/deleteAccount/delete_confirm_page.dart';
import 'package:august/pages/friends/friends_page.dart';
import 'package:august/pages/friends/my_code.dart';
import 'package:august/pages/profile/change_icon_page.dart';
import 'package:august/provider/admin_provider.dart';
import 'package:august/provider/course_color_provider.dart';
import 'package:august/provider/courseprovider.dart';
import 'package:august/provider/friends_provider.dart';
import 'package:august/get_api/gpa/gpa_courses.dart';
import 'package:august/get_api/onboard/get_semester.dart';
import 'package:august/login/initialpage.dart';
import 'package:august/login/login.dart';
import 'package:august/onboard/major.dart';
import 'package:august/onboard/profile.dart';
import 'package:august/onboard/semester.dart';
import 'package:august/onboard/grade.dart';
import 'package:august/onboard/univ.dart';
import 'package:august/pages/profile/change_color_page.dart';
import 'package:august/provider/semester_provider.dart';
import 'package:august/provider/user_info_provider.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class MypageWithTile extends StatefulWidget {
  const MypageWithTile({
    Key? key,
  }) : super(key: key);

  State<MypageWithTile> createState() => _MypageWithTileState();
}

class _MypageWithTileState extends State<MypageWithTile> {
  int bottomIndex = 0;
  Map<int, String> selectedGrades = {};
  bool isJustGPA = true;
  bool isJustCredit = true;
  List<TotalGPA> totalSemester = [];
  int numCourses = 0;
  bool? isSavedAdmin;
  List<String> adminEmails = [
    'kwj0011288@gmail.com',
    'kevinshin@u.sogang.ac.kr',
    'improving.kevinshin@gmail.com',
    'kevinshin123@gmail.com'
  ];

  void initState() {
    super.initState();
  }

  void _navigateToPageProfile() async {
    await Navigator.push<Map<String, dynamic>>(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return NamePage(
            onboard: false,
            onTap: () {},
          );
        },
      ),
    );
  }

  void _navigateToPageSemester() async {
    await Navigator.push<Map<String, dynamic>>(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: (context) {
          return SemesterPage(
            onboard: false,
            goBack: () {},
            gonext: () {},
          );
        },
      ),
    );
  }

  void _navigateToPageMajor() async {
    await Navigator.push<Map<String, dynamic>>(
      context,
      CupertinoPageRoute(
          fullscreenDialog: true,
          builder: (context) {
            return MajorPage(
              onboard: false,
              goBack: () {},
              gonext: () {},
            );
          }),
    );
  }

  void _navigateToPageUniv() async {
    var result = await Navigator.push<Map<String, dynamic>>(
      context,
      CupertinoPageRoute(
          fullscreenDialog: true,
          builder: (context) {
            return UnivPage(
              onboard: false,
              goBack: () {},
              gonext: () {},
            );
          }),
    );
  }

  void _navigateToPageGrade() async {
    await Navigator.push<Map<String, dynamic>>(
      context,
      CupertinoPageRoute(
          fullscreenDialog: true,
          builder: (context) {
            return GradePage(
              onboard: false,
              goBack: () {},
              gonext: () {},
            );
          }),
    );
    // if (result != null) {
    //   setState(() {
    //     // 반환된 데이터를 사용하여 상태를 업데이트

    //     _grade = result['grade'] ?? _grade;

    //     _schoolFullname = result['fullname'] ?? _schoolFullname;
    //     _schoolNickname = result['nickname'] ?? _schoolNickname;
    //   });

    //   saveUserInfo(); // 상태를 업데이트한 후에 사용자 정보를 저장합니다.
    // }
  }

  void _launchURL() async {
    const url = 'https://forms.gle/2ytdRmXgFps7pK567';
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppBrowserView,
    );
  }

  void termsOfUse() async {
    const url =
        'https://extra-mile.notion.site/Terms-Conditions-c312612c53a141978c3503da5028680f?pvs=4';
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void privaryPolicy() async {
    const url = 'http://extra-mile.notion.site';
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void augustSupport() async {
    const url =
        'https://extra-mile.notion.site/August-386d285ad6ee4ec19a3cdfcd4faa3309';
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  String convertDepartment(String department) {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UserInfoProvider>(
      builder: (context, userProvider, child) {
        var userDetails = userProvider.userInfo;
        if (userDetails == null) {
          return Center(child: CircularProgressIndicator());
        }
        if (adminEmails.contains(userDetails.email)) {
          Provider.of<AdminProvider>(context, listen: false).isAdmin = true;
        }

        print(userDetails.yearInSchool);
        String departmentNickname =
            userDetails.department?.nickname ?? 'Undecided';
        return ClipRRect(
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ColorfulSafeArea(
                bottomColor: Colors.white.withOpacity(0),
                overflowRules: OverflowRules.only(bottom: true),
                child: SingleChildScrollView(
                  controller: ScrollController(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15, top: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile',
                                  style: AugustFont.head1(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                        ],
                      ),
                      //
                      //
                      //
                      MeTile(
                        name: '${userDetails.name}',
                        email: '${userDetails.email}',
                        onTap: () {
                          checkAccessToken();
                          HapticFeedback.lightImpact();
                          _navigateToPageProfile();
                        },
                        isProfile: true,
                      ),
                      MeTile(
                        title: 'Invitation Code',
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          var result = await Navigator.push(
                            context,
                            PageRouteBuilder(
                              opaque: false,
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      InvitationCodePage(),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration: Duration(milliseconds: 200),
                            ),
                          );

                          // if (result != null) {
                          //   _ownInvitationCode = result;
                          //   print("Received invitation code: $result");
                          //   // You can use the `result` here to perform further operations
                          // }
                        },
                        icons: Icon(FeatherIcons.users),
                      ),

                      Divider(
                        color: Theme.of(context).colorScheme.scrim,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        child: Text(
                          "About Me",
                          style: AugustFont.head6(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                      Consumer<SemesterProvider>(
                        builder: (context, semesterProvider, child) {
                          return MeTile(
                            isSemester: true,
                            semesterIcon:
                                "assets/season/${extractSeason(formatSemester(semesterProvider.semester))}.svg",
                            backgroundColor: determineColor(
                                formatSemester(semesterProvider.semester)),
                            title: formatSemester(semesterProvider.semester),
                            onTap: () {
                              checkAccessToken();
                              HapticFeedback.lightImpact();
                              _navigateToPageSemester();
                            },
                          );
                        },
                      ),
                      MeTile(
                        isUniv: true,
                        univPhoto: '${userDetails.institution?.logo}',
                        title:
                            '${userDetails.institution?.nickname} (${userDetails.institution?.fullName})',
                        onTap: () {
                          checkAccessToken();
                          HapticFeedback.lightImpact();
                          _navigateToPageUniv();
                        },
                      ),
                      MeTile(
                        title:
                            (convertDepartment('${userDetails.yearInSchool}')),
                        onTap: () {
                          checkAccessToken();
                          HapticFeedback.lightImpact();
                          _navigateToPageGrade();
                        },
                        icons: Icon(FeatherIcons.briefcase),
                      ),
                      MeTile(
                        title: '$departmentNickname',
                        onTap: () {
                          checkAccessToken();
                          HapticFeedback.lightImpact();
                          _navigateToPageMajor();
                        },
                        icons: Icon(FeatherIcons.bookOpen),
                      ),
                      Divider(
                        color: Theme.of(context).colorScheme.scrim,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        child: Text(
                          "Customize",
                          style: AugustFont.head6(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),

                      MeTile(
                        title: 'Course Colors',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => ChangeCourseColorPage(),
                            ),
                          );
                          checkAccessToken();
                        },
                        icons: Icon(FeatherIcons.layout),
                      ),
                      MeTile(
                        title: 'App Icon',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              fullscreenDialog: true,
                              builder: (context) => ChangeIconPage(),
                            ),
                          );
                          checkAccessToken();
                        },
                        icons: Icon(FeatherIcons.edit3),
                      ),

                      Divider(
                        color: Theme.of(context).colorScheme.scrim,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        child: Text(
                          "Support",
                          style: AugustFont.head6(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),

                      MeTile(
                        title: 'Support',
                        onTap: () {
                          augustSupport();
                        },
                        icons: Icon(FeatherIcons.helpCircle),
                      ),
                      MeTile(
                        title: 'Report a bug',
                        onTap: () {
                          EmailUtils.sendEmail(context);
                        },
                        icons: Icon(Icons.bug_report_outlined),
                      ),
                      MeTile(
                        title: 'Feedback',
                        onTap: () {
                          _launchURL();
                        },
                        icons: Icon(Icons.feedback_outlined),
                      ),
                      LogoutTile(
                        title: 'Log out',
                        onTap: () async {
                          showAlertDialog(
                              context,
                              'Sign out',
                              'Are you sure you want to log out?',
                              'Sign out',
                              'Stay',
                              false, () async {
                            Navigator.of(context).pop(); // Close the dialog
                            HapticFeedback.lightImpact();
                            await logoutUser(); // Perform the logout operation
                            Navigator.pushReplacement(
                              // Navigate to the initial page
                              context,
                              CupertinoPageRoute(
                                builder: (context) => InitialPage(),
                              ),
                            );
                          }, () {
                            Navigator.of(context).pop(false);
                          }, () {});
                        },
                      ),
//

                      ///
                      ///
/////
                      ///
                      ///
                      ///
                      ///

                      SizedBox(height: 25),
                      terms(),
                      SizedBox(height: 10),
                      /* for admin */
                      if (adminEmails.contains(userDetails.email))
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20),
                            Divider(
                              color: Theme.of(context).colorScheme.scrim,
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: Consumer<AdminProvider>(
                                builder: (context, adminProvider, child) {
                                  return SwitchListTile(
                                    title: Text(
                                      'Admin Mode',
                                      style: AugustFont.head1(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                    ),
                                    value: adminProvider.isAdmin,
                                    onChanged: (bool value) {
                                      adminProvider.isAdmin = value;
                                    },
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                '지금은 광고 제거용임',
                                style: AugustFont.head8(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget terms() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            termsOfUse();
          },
          child: Text(
            'Terms of Service',
            style: AugustFont.captionSmall(color: Colors.grey),
          ),
        ),
        SizedBox(width: 5),
        Text(
          '|',
          style: AugustFont.captionSmall(
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            privaryPolicy();
          },
          child: Text(
            'Privacy Policy',
            style: AugustFont.captionSmall(color: Colors.grey),
          ),
        ),
        SizedBox(width: 5),
        Text(
          '|',
          style: AugustFont.captionSmall(
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            EmailUtils.sendEmail(context);
          },
          child: Text(
            'Error Report',
            style: AugustFont.captionSmall(color: Colors.grey),
          ),
        ),
        SizedBox(width: 5),
        Text(
          '|',
          style: AugustFont.captionSmall(
            color: Colors.grey,
          ),
        ),
        SizedBox(width: 5),
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              // Navigate to the initial page
              context,
              CupertinoPageRoute(
                fullscreenDialog: true,
                builder: (context) => DeleteConfirmPage(),
              ),
            );
          },
          child: Text(
            'Delete Account',
            style: AugustFont.captionSmall(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
