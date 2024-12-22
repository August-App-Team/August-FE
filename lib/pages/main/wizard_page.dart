import 'dart:async';
import 'dart:convert';

import 'package:august/components/firebase/firebase_analytics.dart';
import 'package:august/components/home/dialog.dart';
import 'package:august/const/customs/customwidget.dart';
import 'package:august/const/customs/stringwidget.dart';
import 'package:august/const/font/font.dart';
import 'package:august/const/icons/icons.dart';
import 'package:flutter/widgets.dart';
import 'package:sliding_number/sliding_number.dart';
import 'package:august/components/home/button.dart';
import 'package:august/get_api/wizard/send_api.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../../get_api/timetable/class.dart';
import '../../get_api/wizard/get_count.dart';
import '../../get_api/timetable/schedule.dart';
import 'select_page.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_bouncing_widgets/custom_bounce_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class GeneratePage extends StatefulWidget {
  final List<List<GroupList?>> containers;

  const GeneratePage({
    Key? key,
    required this.containers,
  }) : super(key: key);

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

String formatDuration(Duration d) {
  String twoDigits(int n) {
    return "$n";
  }

  String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
  int hours = d.inHours;

  if (hours == 0) {
    return "$twoDigitMinutes minutes";
  } else {
    String twoDigitHours = twoDigits(hours);
    return "$twoDigitHours hours $twoDigitMinutes minutes";
  }
}

String formatDurationInHours(Duration d) {
  return "${d.inHours} hours";
}

String formatForFirstSlider(Duration d) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  int twoDigitHours = d.inHours.remainder(24);
  String ampm = " AM";

  if (twoDigitHours >= 12) {
    ampm = " PM";
    if (twoDigitHours > 12) twoDigitHours -= 12;
  } else if (twoDigitHours == 0) {
    twoDigitHours = 12;
  }

  return "$twoDigitHours$ampm";
}

String formatForAPI(Duration d) {
  String twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
  String twoDigitHours = twoDigits(d.inHours);

  return "$twoDigitHours:$twoDigitMinutes";
}

class _GeneratePageState extends State<GeneratePage> {
  RangeValues values = RangeValues(5, 180);
  final _sliderUpdateController = StreamController<double>.broadcast();
  late StreamSubscription<int> _debounceSubscription;

  int counter = 0;

  //첫번째 슬라이더
  double _currentSliderValue1 = (9 * 60).toDouble();
  double _slider1Min = (6 * 60).toDouble();
  double _slider1Max = (17 * 60).toDouble();

  //두번째 슬라이더
  double _currentSliderValue2 = 10;
  double _slider2Min = (10).toDouble();
  double _slider2Max = (3 * 60).toDouble();

  //세번째 슬라이더
  late double _currentSliderValue3 = (6 * 60).toDouble();
  late double _slider3Min = (3 * 60).toDouble();
  double _slider3Max = (8 * 60).toDouble();

  //네번째 슬라이더
  double _currentSliderValue4 = 4;
  late double _slider4Min = 1;
  double _slider4Max = 4;

  String firstButton = 'Walk';
  String secondButton = 'Disallow';
  bool isButton2Pressed = false;
  bool isButton3Pressed = false;
  Future<int>? scheduleCount;
  Timer? debounceTimer;

  bool hasMeetings(GroupList course) {
    for (var instructor in course.instructors!) {
      for (var section in instructor.sections!) {
        if (section.meetingsExist == false) {
          return false;
        }
      }
    }
    return true;
  }

  Future<int> getCountWithTimeout(String jsonData) async {
    try {
      // getCount 함수 호출과 타임아웃 로직을 함께 구현
      final result = await getCount(jsonData).timeout(
        Duration(seconds: 13), // 15초 후 타임아웃
        onTimeout: () {
          // 타임아웃 발생 시 사용자에게 알림
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.background,
                icon: Icon(
                  FeatherIcons.alertTriangle,
                  color: Colors.redAccent,
                  size: 45,
                ),
                title: Text(
                  textAlign: TextAlign.center,
                  'Too many possibilities!',
                  style: AugustFont.head2(
                      color: Theme.of(context).colorScheme.outline),
                ),
                content: Text(
                  textAlign: TextAlign.center,
                  'Please adjust options to\nminimize the possibilities',
                  style: AugustFont.subText2(color: Colors.grey),
                ),
                actions: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(); // 팝업 닫기
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      height: 55,
                      width: MediaQuery.of(context).size.width - 80,
                      decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'OK',
                            style: AugustFont.head2(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          return 0; // 타임아웃 발생 시 반환할 기본 값
        },
      );
      return result;
    } catch (e) {
      print("Error fetching schedules: $e");
      return 0; // 에러 발생 시 반환할 기본 값
    }
  }

  String generateJSON() {
    Map<String, dynamic> options = {};

    options["minimum_start_time"] =
        formatForAPI(Duration(minutes: _currentSliderValue1.round()));

    options["minimum_interval"] =
        formatForAPI(Duration(minutes: _currentSliderValue2.round()));

    options["maximum_interval"] =
        formatForAPI(Duration(minutes: _currentSliderValue3.round()));
    options["allow_consec"] = _currentSliderValue4.round().toInt();

    options["allow_one_class_a_day"] = isButton2Pressed ? 0 : 1;
    options["allow_only_open_section"] = isButton3Pressed ? 1 : 0;

    List<dynamic> groupCourses = [];
    for (int i = 0; i < widget.containers.length; i++) {
      var groupData = widget.containers[i]
          .where((classList) => classList != null)
          .map((course) {
            // 여기서 각 과목에 대해 hasMeetings 함수를 호출하여 검사합니다.
            if (hasMeetings(course!)) {
              return course.instructors!
                  .expand((instructor) =>
                      instructor.sections!.map((section) => section.id))
                  .toList();
            }
            return [];
          })
          .expand((element) => element)
          .toList();
      if (groupData.isNotEmpty) {
        // 비어있지 않은 그룹만 추가합니다.
        groupCourses.add(groupData);
      }
    }

    Map<String, dynamic> data = {
      "groups": groupCourses,
      "options": options,
    };
    return jsonEncode(data);
  }

  List<List<ScheduleList>> convertToGroupLists(List<dynamic> rawJsonData) {
    return rawJsonData.map((schedule) {
      return (schedule as List).map((courseJson) {
        return ScheduleList.fromJson(courseJson as Map<String, dynamic>);
      }).toList();
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    scheduleCount = getCountWithTimeout(generateJSON());
    _currentSliderValue3 = math.max(_slider2Max, (6 * 60).toDouble());

    var debounceStreamTransformer = StreamTransformer<double, int>.fromHandlers(
        handleData: (data, sink) async {
      await Future.delayed(Duration(milliseconds: 500));
      sink.add(await getCountWithTimeout(generateJSON()));
    });

    _debounceSubscription = _sliderUpdateController.stream
        .transform(debounceStreamTransformer)
        .listen((newScheduleCount) {
      setState(() {
        scheduleCount = Future.value(newScheduleCount);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _sliderUpdateController.close();
    _debounceSubscription.cancel();
  }

  void onSliderChanged(double value, String optionName) {
    setState(() {
      // 슬라이더 값에 따라 상태 업데이트
      switch (optionName) {
        case "start_time":
          _currentSliderValue1 = value;
          break;
        case "min_interval":
          _currentSliderValue2 = value;
          break;
        case "max_interval":
          _currentSliderValue3 = value;
          break;
        case "allow_consec":
          _currentSliderValue4 = value;
          break;
      }

      // 로딩 상태로 설정
      scheduleCount = null;
    });

    // debounceTimer를 사용하여 너무 빈번한 API 호출 방지
    debounceTimer?.cancel(); // 이전 타이머 취소
    debounceTimer = Timer(Duration(milliseconds: 1000), () async {
      // API 호출 및 스케줄 수 업데이트
      int newScheduleCount = await getCountWithTimeout(generateJSON());
      setState(() => scheduleCount = Future.value(newScheduleCount));
    });
  }

  void onButtonPressed(String buttonName) async {
    switch (buttonName) {
      case "allow_one_class_a_day":
        setState(() {
          isButton2Pressed = !isButton2Pressed;
        });
        setState(() => scheduleCount = null);
        break;
      case "allow_only_open_section":
        setState(() {
          isButton3Pressed = !isButton3Pressed;
        });
        setState(() => scheduleCount = null);
        break;
    }

    // Add this to make an API request after the button state changes.
    if (debounceTimer != null) {
      debounceTimer!.cancel();
    }

    debounceTimer = Timer(Duration(milliseconds: 800), () async {
      int newScheduleCount = await getCountWithTimeout(generateJSON());

      setState(() {
        scheduleCount = Future.value(newScheduleCount);
      });
    });
  }

  void onSliderEnd(double value, String optionName) {
    setState(() {
      Future.delayed(Duration(milliseconds: 100), () {
        scheduleCount = null;
      });
    });

    if (debounceTimer != null) {
      debounceTimer!.cancel();
    }

    debounceTimer = Timer(Duration(milliseconds: 100), () async {
      int newScheduleCount = await getCountWithTimeout(generateJSON());

      setState(() {
        scheduleCount = Future.value(newScheduleCount);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leadingWidth: 80,
        toolbarHeight: 60,
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                AnalyticsService().wizardBack();
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
        title: Text(
          "Filters",
          style: AugustFont.head4(color: Theme.of(context).colorScheme.outline),
        ),
        actions: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 15, bottom: 10, top: 15),
                child: Button(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      String jsonData = generateJSON();

                      loadingShowDialog(context);

                      int? count = await scheduleCount;
                      if (count! >= 1000) {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
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
                                  textAlign: TextAlign.center,
                                  'More than 1000 Schedules Created!',
                                  style: AugustFont.head2(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                                content: Text(
                                  textAlign: TextAlign.center,
                                  'Please try to adjust the options to minimize the possibilities',
                                  style:
                                      AugustFont.subText2(color: Colors.grey),
                                ),
                                actions: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop(); // 팝업 닫기
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 30),
                                      height: 55,
                                      width: MediaQuery.of(context).size.width -
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
                            });
                        return;
                      }

                      try {
                        List<dynamic> fetchedRawData =
                            await sendJsonData(jsonData);

                        if (fetchedRawData.isEmpty) {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
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
                                    '0 Possible Schedules!',
                                    style: AugustFont.head2(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline),
                                  ),
                                  content: Text(
                                      textAlign: TextAlign.center,
                                      'Please adjust the options to create schedules',
                                      style: AugustFont.subText2(
                                          color: Colors.grey)),
                                  actions: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop(); // 팝업 닫기
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 30),
                                        height: 55,
                                        width:
                                            MediaQuery.of(context).size.width -
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
                              });
                          return;
                        } else {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);

                          //   showDialog(
                          //       context: context,
                          //       builder: (BuildContext context) {
                          //         return AlertDialog(
                          //             title: Text('Schedules Found'),
                          //             content: SingleChildScrollView(
                          //                 // Make sure it's scrollable for long data
                          //                 child: Text(jsonData.toString())),
                          //             actions: <Widget>[
                          //               TextButton(
                          //                   child: Text('Copy',
                          //                       style: TextStyle(
                          //                           color: Colors.black)),
                          //                   onPressed: () {
                          //                     Clipboard.setData(ClipboardData(
                          //                             text: jsonData.toString()))
                          //                         .then((_) {
                          //                       ScaffoldMessenger.of(context)
                          //                           .showSnackBar(SnackBar(
                          //                               content: Text(
                          //                                   'Data copied to clipboard!')));
                          //                     });
                          //                   }),
                          //               TextButton(
                          //                   child: Text('Done',
                          //                       style: TextStyle(
                          //                           color: Colors.black)),
                          //                   onPressed: () {
                          //                     Navigator.of(context)
                          //                         .pop(); // Close the dialog
                          //                     List<List<ScheduleList>>
                          //                         fetchedCourses =
                          //                         convertToGroupLists(
                          //                             fetchedRawData);
                          //                     Navigator.push(
                          //                         context,
                          //                         CupertinoPageRoute(
                          //                             builder: (context) =>
                          //                                 SelectPage(
                          //                                   selectedCoursesData:
                          //                                       fetchedCourses,
                          //                                 )));
                          //                   })
                          //             ]);
                          //       });
                          // }
                          List<List<ScheduleList>> fetchedCourses =
                              convertToGroupLists(fetchedRawData);

                          HapticFeedback.mediumImpact();
                          AnalyticsService().wizardCreate(counter.toString());
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => SelectPage(
                                selectedCoursesData: fetchedCourses,
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to get data')),
                        );
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
      body: ColorfulSafeArea(
        bottomColor: Colors.white.withOpacity(0),
        overflowRules: OverflowRules.all(true),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FutureBuilder<int>(
                    future: scheduleCount,
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 180,
                              child: Center(
                                child: AnimatedTextKit(
                                  repeatForever: true,
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      "Calculating...",
                                      textStyle: AugustFont.scheduleLoading(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline),
                                      textAlign: TextAlign.center,
                                      speed: Duration(milliseconds: 100),
                                    ),
                                  ],
                                  isRepeatingAnimation: true,
                                  pause: Duration(milliseconds: 10),
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (scheduleCount == null && snapshot.hasData) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Shimmer.fromColors(
                              period: const Duration(milliseconds: 800),
                              baseColor: Colors.grey[
                                  500]!, // Adjust the base color to match your theme
                              highlightColor: Colors.grey[
                                  100]!, // Adjust the highlight color to match your theme
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 145,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CustomSlidingNumber(
                                        number: snapshot.data ?? 0,
                                        curve: Curves.fastEaseInToSlowEaseOut,
                                        style: AugustFont.scheduleCount(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Shimmer.fromColors(
                              period: const Duration(milliseconds: 800),
                              baseColor: Colors.grey[
                                  500]!, // Adjust the base color to match your theme
                              highlightColor: Colors.grey[
                                  100]!, // Adjust the highlight color to match your theme
                              child: Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Text(
                                  'SCHEDULES CREATED',
                                  style: AugustFont.head1(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.data! >= 1000) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 145,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: StringSlidingNumber(
                                  number: 1000,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.fastEaseInToSlowEaseOut,
                                  style: AugustFont.scheduleCount(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Text(
                                'SCHEDULES CREATED',
                                style: AugustFont.head1(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Navigator.pop(context);
                        });
                        return Text(
                          'Error',
                          style: AugustFont.head1(
                              color: Theme.of(context).colorScheme.outline),
                          textAlign: TextAlign.center,
                        );
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 145,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: SlidingNumber(
                                  number: snapshot.data ?? 0,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.fastEaseInToSlowEaseOut,
                                  style: AugustFont.scheduleCount(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Center(
                                child: Text(
                                  'SCHEDULES CREATED',
                                  style: AugustFont.head1(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 2,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, bottom: 10),
                      child: Text(
                        'Calculating the number of possible timetables may take up to 30 seconds.',
                        style: AugustFont.captionSmall(
                            color: Theme.of(context).colorScheme.outline),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.shadow,
                              blurRadius: (10),
                              offset: (Offset(0, 1)),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 15, left: 25),
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Class starts at  ',
                                      style:
                                          AugustFont.head5(color: Colors.grey),
                                    ),
                                    TextSpan(
                                      text: formatForFirstSlider(Duration(
                                          minutes:
                                              _currentSliderValue1.round())),
                                      style: AugustFont.head2(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 15),
                                  inactiveTrackColor: Colors.grey,
                                  activeTrackColor: Colors.blueAccent,
                                  thumbColor: Colors.white,
                                  inactiveTickMarkColor:
                                      Theme.of(context).colorScheme.outline,
                                ),
                                child: Slider(
                                  value: _currentSliderValue1,
                                  min: _slider1Min,
                                  max: _slider1Max,
                                  divisions: (_slider1Max - _slider1Min) ~/
                                      60, // 여기서 수정
                                  onChanged: (double newValue) {
                                    HapticFeedback.mediumImpact();
                                    setState(() {
                                      _currentSliderValue1 = newValue;

                                      Duration(
                                          minutes:
                                              _currentSliderValue1.round());
                                    });
                                    onSliderChanged(newValue, "start_time");
                                  },
                                  onChangeEnd: (double endVal) {
                                    onSliderEnd(endVal, "start_time");
                                    setState(() {
                                      counter++;
                                      print(counter);
                                    });
                                  },
                                ),
                              ),
                            ),
                            // Divider(
                            //   color: Theme.of(context).colorScheme.background,
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5, left: 25),
                              child: RichText(
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Allow  ',
                                      style:
                                          AugustFont.head5(color: Colors.grey),
                                    ),
                                    TextSpan(
                                      text: _currentSliderValue4
                                          .round()
                                          .toString(),
                                      style: AugustFont.head2(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '  lectures in a row',
                                      style:
                                          AugustFont.head5(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: RoundSliderThumbShape(
                                      enabledThumbRadius: 15),
                                  inactiveTrackColor:
                                      Colors.grey, // 선택되지 않은 트랙의 색상
                                  activeTrackColor:
                                      Colors.blueAccent, // 진행바(활성 트랙)의 색상
                                  thumbColor:
                                      Colors.white, // 이곳에 원하는 색상을 설정합니다.
                                  inactiveTickMarkColor:
                                      Theme.of(context).colorScheme.outline,
                                ),
                                child: Slider(
                                  value: _currentSliderValue4,
                                  min: _slider4Min,
                                  max: _slider4Max,

                                  divisions: (_slider4Max - _slider4Min)
                                      .round(), // 여기서 수정
                                  onChanged: (double newValue) {
                                    HapticFeedback.mediumImpact();
                                    onSliderChanged(newValue, "allow_consec");
                                  },
                                  onChangeEnd: (double endVal) {
                                    onSliderEnd(endVal, "allow_consec");
                                    setState(() {
                                      counter++;
                                      print(counter);
                                    });
                                  },
                                ),
                              ),
                            ),

                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 10, left: 25),
                                  child: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: 'Min. Break  :  ',
                                            style: AugustFont.head5(
                                                color: Colors.grey)),
                                        TextSpan(
                                          text: formatDuration(Duration(
                                              minutes: _currentSliderValue2
                                                  .round())),
                                          style: AugustFont.head2(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 15),
                                      inactiveTrackColor: Colors.grey,
                                      activeTrackColor: Colors.blueAccent,
                                      thumbColor: Colors.white,
                                      inactiveTickMarkColor:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                    child: Slider(
                                      value: _currentSliderValue2,
                                      min: _slider2Min,
                                      max: _slider2Max,
                                      divisions: (_slider2Max - _slider2Min) ~/
                                          10, // 여기서 수정
                                      onChanged: (double newValue) {
                                        HapticFeedback.mediumImpact();
                                        onSliderChanged(
                                            newValue, "min_interval");
                                      },
                                      onChangeEnd: (double endVal) {
                                        onSliderEnd(endVal, "min_interval");
                                        setState(() {
                                          counter++;
                                          print(counter);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 5, left: 25),
                                  child: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Max. Break  :  ',
                                          style: AugustFont.head5(
                                              color: Colors.grey),
                                        ),
                                        TextSpan(
                                          text: formatDurationInHours(Duration(
                                              minutes: _currentSliderValue3
                                                  .round())),
                                          style: AugustFont.head2(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 15),
                                      inactiveTrackColor:
                                          Colors.grey, // 선택되지 않은 트랙의 색상
                                      activeTrackColor:
                                          Colors.blueAccent, // 진행바(활성 트랙)의 색상
                                      thumbColor:
                                          Colors.white, // 이곳에 원하는 색상을 설정합니다.
                                      inactiveTickMarkColor:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                    child: Slider(
                                      value: _currentSliderValue3,
                                      min: _slider3Min,
                                      max: _slider3Max,
                                      divisions:
                                          ((_slider3Max - _slider3Min) / 60)
                                              .round(), // 여기서 수정
                                      onChanged: (double newValue) {
                                        HapticFeedback.mediumImpact();
                                        onSliderChanged(
                                            newValue, "max_interval");
                                      },
                                      onChangeEnd: (double endVal) {
                                        onSliderEnd(endVal, "max_interval");
                                        setState(() {
                                          counter++;
                                          print(counter);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 10, bottom: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomBounceWidget(
                                    duration: Duration(milliseconds: 100),
                                    child: AnimatedContainer(
                                      decoration: BoxDecoration(
                                        color: isButton2Pressed
                                            ? Colors.redAccent
                                            : Colors.blueAccent,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      height: 90,
                                      width: MediaQuery.of(context).size.width /
                                          2.5,
                                      duration: Duration(milliseconds: 250),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Text(
                                                  isButton2Pressed
                                                      ? 'Disallow'
                                                      : 'Allow',
                                                  style: AugustFont.head2(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                'One Class In a Day',
                                                style: AugustFont.subText(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    onPressed: () {
                                      onButtonPressed("allow_one_class_a_day");
                                      setState(() {
                                        counter++;
                                        print(counter);
                                      });
                                      HapticFeedback.mediumImpact();
                                    },
                                  ),
                                  SizedBox(width: 15),
                                  CustomBounceWidget(
                                      duration: Duration(milliseconds: 100),
                                      child: AnimatedContainer(
                                        decoration: BoxDecoration(
                                          color: isButton3Pressed
                                              ? Colors.blueAccent
                                              : Colors.redAccent,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(20),
                                          ),
                                        ),
                                        height: 90,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2.5,
                                        duration: Duration(milliseconds: 250),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Center(
                                                  child: Text(
                                                    isButton3Pressed
                                                        ? 'Only'
                                                        : 'All',
                                                    style: AugustFont.head2(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  isButton3Pressed
                                                      ? 'Open Sections'
                                                      : "Available Sections",
                                                  style: AugustFont.subText(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      onPressed: () {
                                        onButtonPressed(
                                            "allow_only_open_section");
                                        setState(() {
                                          counter++;
                                          print(counter);
                                        });
                                        HapticFeedback.mediumImpact();
                                      }),
                                  SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
