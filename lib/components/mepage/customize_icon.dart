import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';

class CustomizeIcon extends StatefulWidget {
  final VoidCallback onTap;

  CustomizeIcon({required this.onTap});

  @override
  _CustomizeIconState createState() => _CustomizeIconState();
}

class _CustomizeIconState extends State<CustomizeIcon> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // color: Theme.of(context).colorScheme.outline,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.withOpacity(0.5),
                Theme.of(context).colorScheme.outline,
                //  Color.fromARGB(255, 171, 255, 235),
              ],
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Change App Icon',
                      style: AugustFont.head2(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Theme.of(context).colorScheme.outline,
                      size: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
