import 'package:august/components/home/button.dart';
import 'package:august/const/font/font.dart';
import 'package:august/provider/course_color_provider.dart';
import 'package:august/const/colors/modify_color.dart';
import 'package:august/const/theme/dark_theme.dart';
import 'package:august/const/theme/light_theme.dart';
import 'package:flutter/material.dart';
import '../../get_api/timetable/class.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bouncing_widgets/custom_bounce_widget.dart';

class EditSimepleCourseTile extends StatefulWidget {
  final CourseList classes;
  final String sectionCode;
  final String instructorName;
  final String meetingTimes;
  final int fullSeat;
  final int openSeat;
  final int waitlist;
  final int holdfile;
  final void Function(BuildContext context)? onPressed;
  final void Function(BuildContext context)? onTap;
  final IconData icon;
  final IconData? toggledIcon;
  final Function? onIconToggled;
  final Color backgroundColor;
  final int index;

  // 네임드 파라미터를 사용하고 onPressed와 onTap을 nullable로 변경
  const EditSimepleCourseTile({
    Key? key,
    required this.classes,
    this.onPressed,
    this.onTap,
    required this.icon,
    this.toggledIcon,
    this.onIconToggled,
    required this.backgroundColor,
    required this.index,
    required this.sectionCode,
    required this.instructorName,
    required this.meetingTimes,
    required this.fullSeat,
    required this.openSeat,
    required this.waitlist,
    required this.holdfile,
  }) : super(key: key);

  @override
  _ClassTileState createState() => _ClassTileState();
}

class _ClassTileState extends State<EditSimepleCourseTile> {
  bool check = false;

  Widget seatButton(String text, Color buttonColor, final VoidCallback onTap) {
    TextStyle buttonTextStyle = TextStyle(
      // Define your text style here
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    double textWidth = calculateTextWidth(text, buttonTextStyle, context);
    double buttonWidth = textWidth - 20; // Add some padding to the text width

    return Container(
      width: buttonWidth,
      height: 16,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.only(left: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: AugustFont.captionSmall(color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
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
    return CustomBounceWidget(
      onPressed: () {
        widget.onPressed!(context);
      },
      isScrollable: true,
      duration: Duration(milliseconds: 100),
      child: Container(
        decoration: BoxDecoration(
          color: tileColors[widget.index % tileColors.length],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 10,
              offset: Offset(
                4,
                8,
              ),
            )
          ],
        ),
        margin: const EdgeInsets.only(bottom: 15.0, right: 15.0, left: 15.0),
        child: InkWell(
          onTap: widget.onTap != null ? () => widget.onTap!(context) : null,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 2),
                        Text(
                          widget.sectionCode,
                          style: AugustFont.searchedTitle(color: Colors.black),
                        ),
                        SizedBox(height: 2),
                        Text(
                          (widget.classes.name ?? '').length > 30
                              ? '${(widget.classes.name ?? '').substring(0, 30)}...'
                              : (widget.classes.name ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AugustFont.searchedCourseTitle(
                              color: Colors.black),
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.instructorName,
                          style: AugustFont.searchedProf(color: Colors.black),
                          // style: TextStyle(
                          //     fontSize: 16,
                          //     color: Colors.black,
                          //     fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          widget.meetingTimes ?? 'Online',
                          style: AugustFont.searchedTime(color: Colors.black),
                        ),
                        SizedBox(height: 2),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 100, // 너비 조절
                  height: 100, // 높이 조절
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // 수직 방향 중앙 정렬
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // 수평 방향 중앙 정렬
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 2),
                          child: Text(
                            'Seats: ${widget.fullSeat}',
                            style: AugustFont.searchedSeat(color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 2),
                          child: Text(
                            'Open: ${widget.openSeat}',
                            style: AugustFont.searchedSeat(color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 2),
                          child: Text(
                            'Waitlist: ${widget.waitlist}',
                            style: AugustFont.searchedSeat(color: Colors.black),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            'Holdfile: ${widget.holdfile}',
                            style: AugustFont.searchedSeat(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
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
