import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bouncing_widgets/custom_bounce_widget.dart';

class CustomIconTile extends StatefulWidget {
  final String iconAsset;
  final String name;
  final VoidCallback onTap;
  final Color tileColor;
  final bool isShadow;

  // 네임드 파라미터를 사용하고 onTap와 onTap을 nullable로 변경
  const CustomIconTile({
    Key? key,
    required this.iconAsset,
    required this.name,
    required this.onTap,
    required this.tileColor,
    required this.isShadow,
  }) : super(key: key);

  @override
  _CustomIconTileState createState() => _CustomIconTileState();
}

String convertIconName(String name) {
  if (name == 'dark_prime') {
    return 'Default Dark Mode';
  } else if (name == 'light_prime') {
    return 'Default Light Mode';
  } else if (name == 'dark_pencil') {
    return 'Customize Dark 1';
  } else if (name == 'light_pencil') {
    return 'Customize Light 1';
  } else {
    return '....';
  }
}

class _CustomIconTileState extends State<CustomIconTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
      child: CustomBounceWidget(
        duration: Duration(milliseconds: 100),
        isScrollable: true,
        onPressed: widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          height: 120,
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow,
                        blurRadius: 10, // 블러 효과를 줄여서 그림자를 더 세밀하게
                        offset: Offset(4, -1), // 좌우 그림자의 길이를 줄임
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.shadow,
                        blurRadius: 10,
                        offset: Offset(-1, 0), // 좌우 그림자의 길이를 줄임
                      ),
                    ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.asset(
                    widget.iconAsset,
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Text(
                convertIconName(widget.name),
                style: AugustFont.head2(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
