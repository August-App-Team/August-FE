import 'dart:io';
import 'dart:math';

import 'package:august/components/firebase/firebase_analytics.dart';
import 'package:august/components/home/my_bottombar.dart';
import 'package:august/components/profile/profile.dart';
import 'package:august/const/device/device_util.dart';
import 'package:august/const/customs/save_image.dart';
import 'package:august/const/font/font.dart';
import 'package:august/get_api/onboard/get_user_info.dart';
import 'package:august/login/login.dart';
import 'package:august/onboard/onboard.dart';
import 'package:august/pages/group/group_page.dart';
import 'package:august/pages/manual/manual_page.dart';
import 'package:august/pages/profile/me_page_tile.dart';
import 'package:august/provider/user_info_provider.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:august/pages/profile/me_page.dart';
import 'package:august/pages/search/search_page.dart';
import 'package:august/provider/semester_provider.dart';
import 'package:provider/provider.dart';
import 'package:august/pages/friends/friends_page.dart';
import 'package:august/pages/main/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1;
  String? currentSemester;
  bool isLoading = true;
  List<Widget> _pages = [];
  Map<String, dynamic>? userInfo;
  bool isFirst = true;
  bool _showBottomBar = false;

  void checkAndShowOnBoarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? onBoard = prefs.getBool('hasSeenOnboard') ?? false;
    if (isFirst || !onBoard) {
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => OnBoardPage(),
          ),
        );
      }

      prefs.setBool('hasSeenOnboard', true);
      await prefs.setBool('isFirst', false);
      print('isFirst updated to: $isFirst');
      //logger.log('isFirst updated to: $isFirst');
    }
  }

  @override
  void initState() {
    super.initState();
    initializeApp();
    _showBottomBar = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentSemester = Provider.of<SemesterProvider>(context).semester;
  }

  Future<void> initializeApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // isFirst 값이 로컬ㄹ에 저장되었는지 확인
    bool? hasCheckedFirst = prefs.getBool('hasCheckedFirst');
    isFirst = prefs.getBool('isFirst') ?? false;

    /* --- load user info --- */
    UserInfoProvider userInfoProvider =
        Provider.of<UserInfoProvider>(context, listen: false);
    await userInfoProvider.loadUserInfo();

    UserDetails? userDetails = userInfoProvider.userInfo;

    /* --- send user id to firebase --- */
    FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    await FirebaseAnalytics.instance.setUserId(id: userDetails!.id.toString());

    /* --- check if user access it for the first time */
    if (hasCheckedFirst == null) {
      String dateJoined = userDetails?.dateJoined ?? '2021-01-01T00:00:00.000Z';
      print(dateJoined);
      print('dateJoined: $dateJoined');
      isFirst = isTodayOrWithin5min(dateJoined);
      await prefs.setBool('hasCheckedFirst', true);
      await prefs.setBool('isFirst', isFirst);
    } else {
      // 이미 저장된 isFirst 값을 사용
      isFirst = prefs.getBool('isFirst') ?? false;
      updateAndPrintIsFirst(isFirst); // or false
    }

    // if (!isFirst) {
    //   fetchAndSetUserInfo(isFirst);
    // }

    // await Future.wait([
    //   if (isFirst) fetchAndSetUserInfo(isFirst),
    // ]);

    if (isFirst == true) {
      // isFirst가 true인 경우에만 onBoarding 체크
      Future.delayed(Duration(milliseconds: 0), () async {
        checkAndShowOnBoarding();
      });
    } else {
      _initializePages();
    }
    if (mounted)
      setState(() {
        isLoading = false;
      });
  }

  bool isTodayOrWithin5min(String dateJoinedStr) {
    DateTime dateJoined = DateTime.parse(dateJoinedStr);
    DateTime now = DateTime.now().toUtc();
    // Print the current time and the parsed time
    print('Now: $now');
    print('Joined: $dateJoined');

    print("compare year: ${now.year}  ${dateJoined.year}");
    print("compare month: ${now.month}  ${dateJoined.month}");
    print("compare day: ${now.day}  ${dateJoined.day}");
    print("compare minutes: ${now.minute}  ${dateJoined.minute}");

    // 현재 시간과 dateJoined의 날짜, 시간, 분을 비교하여 10분 이내 차이나는지 확인
    Duration difference = now.difference(dateJoined);
    bool isTodayAndWithin5Minutes = now.year == dateJoined.year &&
        now.month == dateJoined.month &&
        now.day == dateJoined.day &&
        difference.inMinutes.abs() <= 1;

    return isTodayAndWithin5Minutes;
  }

  void _initializePages() {
    // 페이지 초기화 로직을 별도 함수로 분리하여, 필요한 경우에만 호출
    _pages = [
      SearchPage(),
      SchedulePage(),
      GestureDetector(
        onTap: () {
          newSchedule(); // Call the dialog when tapped
        },
      ),
      FriendsPage(),
      MypageWithTile()
    ];
  }

  void newSchedule() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              AnalyticsService().groupCreate();
              Navigator.pop(context);
              Navigator.push(context,
                  CupertinoPageRoute(builder: (context) => GroupPage()));
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Pick Your Favorite!',
                    style: AugustFont.head1(
                        color: Theme.of(context).colorScheme.outline),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                blurRadius: 10,
                                offset: const Offset(6, 4),
                              ),
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                blurRadius: 10,
                                offset: const Offset(-2, 0),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Transform.rotate(
                                angle: -5 * (pi / 180),
                                child: Image.asset(
                                  'assets/icons/wand.png',
                                  height: 80,
                                  width: 80,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Auto\nGenerate',
                                style: AugustFont.head2(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20), // 버튼 사이의 간격
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ManualPage(),
                              ),
                            );
                          },
                          child: Container(
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow,
                                  blurRadius: 10,
                                  offset: const Offset(6, 4),
                                ),
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.shadow,
                                  blurRadius: 10,
                                  offset: const Offset(-2, 0),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Transform.rotate(
                                  angle: 1 * (pi / 180),
                                  child: Image.asset(
                                    'assets/icons/manual.png',
                                    height: 80,
                                    width: 80,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Manually\nCreate',
                                  style: AugustFont.head2(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void updateAndPrintIsFirst(bool newValue) {
    if (mounted)
      setState(() {
        isFirst = newValue;
        print('isFirst updated to: $isFirst');
      });
  }

  String convertGrade(String code) {
    switch (code) {
      case 'FR':
        return 'Freshman';
      case 'SO':
        return 'Sophomore';
      case 'JR':
        return 'Junior';
      case 'SR':
        return 'Senior';
      case 'GR':
        return 'Graduated';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: <Widget>[
          DeviceUtils.isTablet(context) ? tabBar() : Container(),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children:
                  _pages, // Assuming _pages contains the content for each tab
            ),
          ),
        ],
      ),
      bottomNavigationBar: DeviceUtils.isTablet(context) ? null : bottomBar(),
    );
  }

  Widget bottomBar() {
    Size screenSize = MediaQuery.of(context).size;
    double minHeightForLargeDevice = 812.0;
    bool isLargeDevice = screenSize.height > minHeightForLargeDevice;
    return Padding(
      padding: Platform.isIOS
          ? isLargeDevice
              ? const EdgeInsets.only(top: 10)
              : const EdgeInsets.only(top: 10, bottom: 10)
          : const EdgeInsets.only(top: 10, bottom: 10),
      child: AnimatedOpacity(
        opacity: _showBottomBar ? 1.0 : 0.0,
        duration: Duration(seconds: 1),
        child: BottomBar(
          onIndexChanged: (index) async {
            if (index == 2) {
              newSchedule();
            } else {
              await AnalyticsService().bottomNavBar(index);
              checkAccessToken();
              if (_currentIndex != index) {
                if (mounted)
                  setState(() {
                    _currentIndex = index;
                  });
              }
            }
          },
        ),
      ),
    );
  }

  Widget tabBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: CustomSlidingSegmentedControl(
        innerPadding: EdgeInsets.all(5),
        curve: Curves.easeInOutCirc,
        children: {
          1: Container(
            width: 50,
            child: Icon(
              FeatherIcons.layout,
            ),
          ),
          2: Container(
            width: 50,
            child: Icon(
              Icons.people,
            ),
          ),
          3: Container(
            width: 50,
            child: ProfileWidget(
              isBottomBar: true,
            ),
          )
        },
        onValueChanged: (index) {
          if (mounted)
            setState(() {
              _currentIndex = index;
            });
        },
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(100),
        ),
        thumbDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background.withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}
