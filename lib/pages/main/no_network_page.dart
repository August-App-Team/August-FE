import 'dart:convert';
import 'package:august/const/font/font.dart';
import 'package:august/const/theme/dark_theme.dart';
import 'package:august/const/theme/light_theme.dart';
import 'package:august/get_api/timetable/schedule.dart';
import 'package:august/login/initialpage.dart';
import 'package:august/main.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/timetable/timetable.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NoNetworkPage extends StatefulWidget {
  const NoNetworkPage({
    super.key,
  });
  @override
  State<NoNetworkPage> createState() => _NoNetworkPageState();
}

class _NoNetworkPageState extends State<NoNetworkPage> {
  String formattedDate = DateFormat.MMMMEEEEd().format(DateTime.now());
  Uint8List? profilePhoto;
  List<ScheduleList> _firstTimetableCourses = [];
  @override
  void initState() {
    super.initState();
    loadFirstTimetable();
    loadProfilePhoto();
  }

  Future<void> loadFirstTimetable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('timetable');

    if (jsonString != null) {
      try {
        List<dynamic> decodedJson = jsonDecode(jsonString);
        if (decodedJson.isNotEmpty) {
          List<dynamic> firstTimetableDataList = decodedJson[0];
          List<ScheduleList> firstTimetableCourses = firstTimetableDataList
              .map((e) => ScheduleList.fromJson(e as Map<String, dynamic>))
              .toList();

          setState(() {
            _firstTimetableCourses = firstTimetableCourses;
          });
        }
      } catch (e) {
        print("Error loading timetable: $e");
      }
    } else {
      print("No timetable data found in SharedPreferences.");
    }
  }

  Future<void> loadProfilePhoto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Image = prefs.getString('contactPhoto');
    if (base64Image != null) {
      setState(() {
        profilePhoto = base64Decode(base64Image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: dartTheme,
      home: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: ColorfulSafeArea(
            bottomColor: Colors.white.withOpacity(0),
            overflowRules: OverflowRules.only(bottom: true),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 15, right: 0, top: 15),
                      child: GestureDetector(
                          onTap: () {},
                          child: CircleAvatar(
                            maxRadius: 25,
                            backgroundColor: Colors.grey,
                            backgroundImage: profilePhoto != null
                                ? MemoryImage(profilePhoto!)
                                : null,
                            child: profilePhoto == null
                                ? Icon(FeatherIcons.user, size: 40)
                                : null,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Offline',
                            style: AugustFont.head3(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                          Text(
                            'Please check your internet connection',
                            style: AugustFont.subText(
                                color: Theme.of(context).colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: SingleTimetable(
                    courses: _firstTimetableCourses,
                    index: 0,
                    forceFixedTimeRange: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
