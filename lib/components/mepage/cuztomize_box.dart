import 'package:august/components/mepage/stacked_photo.dart';
import 'package:august/const/font/font.dart';
import 'package:august/provider/appIcon_provider.dart';
import 'package:august/provider/course_color_provider.dart';
import 'package:august/provider/friends_provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class CustomizeWidget extends StatefulWidget {
  final String title;
  final bool isCourseColor;
  final VoidCallback onTap;

  const CustomizeWidget({
    Key? key,
    required this.title,
    required this.onTap,
    required this.isCourseColor,
  }) : super(key: key);

  @override
  _CustomizeWidgetState createState() => _CustomizeWidgetState();
}

class _CustomizeWidgetState extends State<CustomizeWidget> {
  @override
  Widget build(BuildContext context) {
    void initState() {
      super.initState();
    }

    var courseColorProvider = Provider.of<CourseColorProvider>(context);
    var appIconProvider = Provider.of<AppIconProvider>(context);

    print(appIconProvider.iconName);

    Widget content = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
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
        ],
      ),
      width: 145,
      height: 145,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              maxRadius: 25,
              backgroundColor: Colors.white,
              child: widget.isCourseColor
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: courseColorProvider.colors,
                          stops: courseColorProvider.stops,
                        ),
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
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10), // 원하는 반경 값으로 설정
                      child: Image.asset(
                        appIconProvider.iconName == ' '
                            ? 'assets/launch/dark_prime.png'
                            : 'assets/launch/${appIconProvider.iconName}.png',
                        width: 90,
                        height: 90,
                      ),
                    ),
            ),

            //    String iconAsset = 'assets/launch/$name.png';
            SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Text(
                  widget.title,
                  style: AugustFont.head6(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            Text(
              'Tab to customize',
              style: AugustFont.captionBoldUniv(
                color: Colors.grey,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );

    // Conditional wrapping with GestureDetector
    return Column(
      children: [GestureDetector(onTap: widget.onTap, child: content)],
    );
  }
}
