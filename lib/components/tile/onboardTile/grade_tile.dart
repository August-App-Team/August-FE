import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bouncing_widgets/custom_bounce_widget.dart';

class GradeTile extends StatefulWidget {
  final String grade;
  final VoidCallback onTap;
  final Color tileColor;
  final bool isShadow;

  // 네임드 파라미터를 사용하고 onTap와 onTap을 nullable로 변경
  const GradeTile({
    Key? key,
    required this.grade,
    required this.onTap,
    required this.tileColor,
    required this.isShadow,
  }) : super(key: key);

  @override
  _GradeTileState createState() => _GradeTileState();
}

class _GradeTileState extends State<GradeTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: CustomBounceWidget(
        isScrollable: true,
        duration: Duration(milliseconds: 100),
        onPressed: widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          height: 60,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  widget.grade,
                  style: AugustFont.head2(
                      color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
