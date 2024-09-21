import 'package:august/components/mepage/color_box.dart';
import 'package:august/const/font/font.dart';
import 'package:august/provider/course_color_provider.dart';
import 'package:august/components/timetable/timetable.dart';
import 'package:august/const/colors/course_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class ChangeCourseColorPage extends StatefulWidget {
  const ChangeCourseColorPage({super.key});

  @override
  State<ChangeCourseColorPage> createState() => _ChangeCourseColorPageState();
}

class _ChangeCourseColorPageState extends State<ChangeCourseColorPage> {
  @override
  Widget build(BuildContext context) {
    var colorProvider = Provider.of<CourseColorProvider>(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBody: true,
      body: ColorfulSafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Customize Course Color',
                    style: AugustFont.head1(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
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
            ),
            SizedBox(height: 10),
            SingleTimetable(
              courses: dummyData,
              index: 0,
              isCustomizeColor: true,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    colorProvider.resetColors();
                  },
                  child: Container(
                    height: 30,
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Reset',
                        style: AugustFont.subText(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    children: List<Widget>.generate(
                      colorProvider.colors.length,
                      (int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: SelectColorWidget(
                            title: '${index + 1}',
                            color: colorProvider.colors[index],
                            onColorChanged: (Color newColor) {
                              colorProvider.setColorAtIndex(index, newColor);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
