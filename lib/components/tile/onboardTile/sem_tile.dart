import 'package:august/const/font/font.dart';
import 'package:august/get_api/onboard/get_semester.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bouncing_widgets/custom_bounce_widget.dart';

class SemesterTile extends StatefulWidget {
  final String semester;
  final VoidCallback onTap;
  final String semesterIcon;
  final Color tileColor;
  final Color backgroundColor;
  final bool isShadow;

  // 네임드 파라미터를 사용하고 onTap와 onTap을 nullable로 변경
  const SemesterTile({
    Key? key,
    required this.semester,
    required this.onTap,
    required this.tileColor,
    required this.semesterIcon,
    required this.backgroundColor,
    required this.isShadow,
  }) : super(key: key);

  @override
  _SemesterTileState createState() => _SemesterTileState();
}

class _SemesterTileState extends State<SemesterTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: CustomBounceWidget(
        isScrollable: true,
        duration: Duration(milliseconds: 100),
        onPressed: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.tileColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                if (!widget.isShadow)
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10, // 블러 효과를 줄여서 그림자를 더 세밀하게
                    offset: Offset(4, -1), // 좌우 그림자의 길이를 줄임
                  ),
                if (!widget.isShadow)
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10,
                    offset: Offset(-1, 0), // 좌우 그림자의 길이를 줄임
                  ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: widget.backgroundColor,
                  maxRadius: 30,
                  child: SvgPicture.asset(
                    widget.semesterIcon,
                    width: 30,
                    height: 30,
                  ),
                ),
                SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatSemester(widget.semester),
                      style: AugustFont.head2(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
