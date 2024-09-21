import 'package:august/components/mepage/stacked_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GPAWidget extends StatefulWidget {
  final String info;
  final String photo;
  final String subInfo;
  final Color photoBackground;
  final VoidCallback onTap;

  const GPAWidget({
    Key? key,
    required this.onTap,
    required this.info,
    required this.subInfo,
    required this.photo,
    required this.photoBackground,
  }) : super(key: key);

  @override
  _GPAWidgetState createState() => _GPAWidgetState();
}

class _GPAWidgetState extends State<GPAWidget> {
  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Container(
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
        width: 130,
        height: 130,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: widget.photoBackground,
                maxRadius: 20,
                child: SvgPicture.asset(
                  widget.photo,
                  width: 30,
                  height: 30,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.info,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                widget.subInfo,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Conditional wrapping with GestureDetector
    return GestureDetector(onTap: widget.onTap, child: content);
  }
}
