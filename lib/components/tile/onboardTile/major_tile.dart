import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bouncing_widgets/custom_bounce_widget.dart';

class MajorTile extends StatefulWidget {
  final String fullname;
  final String nickname;
  final VoidCallback onTap;
  final Color tileColor;
  final bool isShadow;
  // 네임드 파라미터를 사용하고 onTap와 onTap을 nullable로 변경
  const MajorTile({
    Key? key,
    required this.fullname,
    required this.nickname,
    required this.onTap,
    required this.tileColor,
    required this.isShadow,
  }) : super(key: key);

  @override
  _MajorTileState createState() => _MajorTileState();
}

class _MajorTileState extends State<MajorTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: CustomBounceWidget(
        isScrollable: true,
        onPressed: widget.onTap,
        duration: Duration(milliseconds: 100),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nickname,
                  style: AugustFont.head2(
                      color: Theme.of(context).colorScheme.outline),
                ),
                Text(
                  widget.fullname,
                  style: AugustFont.captionBold(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
