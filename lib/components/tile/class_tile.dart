import 'package:august/components/home/button.dart';
import 'package:august/const/font/font.dart';
import 'package:august/provider/course_color_provider.dart';
import 'package:august/const/colors/modify_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../get_api/timetable/class.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bouncing_widgets/custom_bounce_widget.dart';

class ClassTile extends StatefulWidget {
  final GroupList classes;
  final List<GroupSection> sections;
  final void Function(BuildContext context)? onPressed;
  final void Function(BuildContext context)? onTap;
  final IconData icon;
  final IconData? toggledIcon;
  final Function? onIconToggled;
  final Color backgroundColor;
  final int index;
  final void Function(BuildContext context)? seats;
  // 네임드 파라미터를 사용하고 onPressed와 onTap을 nullable로 변경
  const ClassTile({
    Key? key,
    required this.classes,
    this.onPressed,
    this.onTap,
    required this.icon,
    this.toggledIcon,
    this.onIconToggled,
    required this.backgroundColor,
    required this.index,
    this.seats,
    required this.sections,
  }) : super(key: key);

  @override
  _ClassTileState createState() => _ClassTileState();
}

class _ClassTileState extends State<ClassTile> {
  bool check = false;

  Widget seatButton(String text, Color buttonColor, final VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(text, style: AugustFont.subText(color: Colors.black)),
            Text('Sections',
                style: AugustFont.captionSmallNormal2(color: Colors.black)),
          ],
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
        HapticFeedback.mediumImpact();
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
        child: Column(
          children: [
            GestureDetector(
              onTap: widget.onTap != null ? () => widget.onTap!(context) : null,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        widget.classes.courseCode!,
                        style: AugustFont.searchedTitle(color: Colors.black),
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.classes.name!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AugustFont.searchedCourseTitle(
                              color: Colors.black),
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Text(
                          widget.classes.instructors!
                              .map((instructor) => instructor.name)
                              .join(', '),
                          style: AugustFont.searchedProf(color: Colors.black),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                  trailing: seatButton(' + ${widget.sections.length}',
                      Colors.white.withOpacity(0.6), () {
                    HapticFeedback.selectionClick();
                    _showSeatInfoBottomSheet(context, widget.classes,
                        widget.sections, widget.index); // Add this line
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSeatInfoBottomSheet(BuildContext context, GroupList list,
      List<GroupSection> sections, int index) {
    final theme = Theme.of(context);
    List<Color> tileColors = theme.brightness == Brightness.dark
        ? darkenColors(
            lightenColors(
                Provider.of<CourseColorProvider>(context, listen: false).colors,
                0.102),
            0.05)
        : lightenColors(
            Provider.of<CourseColorProvider>(context, listen: false).colors,
            0.05);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          child: Container(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: tileColors[widget.index % tileColors.length],
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: Colors.grey, width: 0.2),
            ),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              // Wrap with SingleChildScrollView
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "${list.courseCode}",
                    style: AugustFont.head1(color: Colors.black),
                  ),

                  Text(
                    "${list.instructors?.map((instructor) => instructor.name).join(', ')}", // Display instructor names
                    style: AugustFont.head4(color: Colors.black),
                  ),
                  Divider(
                    color: Colors.black.withOpacity(0.3),
                  ),
                  //   SizedBox(height: 10),
                  // Iterate through each section and display its information
                  for (var section in sections) ...[
                    Text(
                      "${section.fullCode}",
                      style: AugustFont.head2(color: Colors.black),
                    ),
                    Text(
                      "Seats: ${section.seats}",
                      style: AugustFont.subText(color: Colors.black),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Open Seats: ${section.openSeats}",
                      style: AugustFont.subText2(color: Colors.black),
                    ),
                    Text(
                      "Waitlist: ${section.waitlist}",
                      style: AugustFont.subText2(color: Colors.black),
                    ),
                    Text(
                      "Holdfile: ${section.holdfile ?? 0}",
                      style: AugustFont.subText2(color: Colors.black),
                    ),
                    SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
