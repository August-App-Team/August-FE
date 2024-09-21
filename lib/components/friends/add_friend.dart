import 'dart:async';

import 'package:august/const/colors/tile_color.dart';
import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';

Widget animationFriend(Color color, String imagePath) {
  return Container(
    child: Builder(
      builder: (context) {
        return Transform.translate(
          offset: const Offset(0.0, 5.0),
          child: Container(
            padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 130,
                  height: 150,
                  child: CircleAvatar(
                    backgroundImage: AssetImage(imagePath),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "August",
                  style: AugustFont.head2(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class AnimationFriends extends StatefulWidget {
  @override
  _AnimationFriendsState createState() => _AnimationFriendsState();
}

class _AnimationFriendsState extends State<AnimationFriends>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Timer _timer = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastEaseInToSlowEaseOut,
    );
    _startAnimationCycle();
  }

  void _startAnimationCycle() {
    _controller.forward().then((_) {
      _timer = Timer(Duration(seconds: 3), () {
        _controller.reverse().then((_) {
          _timer = Timer(Duration(seconds: 3), () {
            _startAnimationCycle(); // 다시 애니메이션 사이클 시작
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget animatedFriendOffset(Widget child, double begin, double end) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double dx = begin + (_animation.value * (end - begin));
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Constants
    const double distance = 50.0;
    const double farDistance = 90.0;
    const double scaleSide = 0.9;
    const double scaleFarSide = 0.8;
    const double scaleCenter = 1.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Far left widget
        animatedFriendOffset(
          Transform.scale(
            scale: scaleFarSide,
            child: animationFriend(Theme.of(context).colorScheme.onSecondary,
                "assets/memoji/Memoji1.png"),
          ),
          0,
          -farDistance,
        ),
        // Left widget
        animatedFriendOffset(
          Transform.scale(
            scale: scaleSide,
            child: animationFriend(
                makeBrighter(Theme.of(context).colorScheme.onSecondary, 0.1),
                "assets/memoji/Memoji2.png"),
          ),
          0,
          -distance,
        ),
        // Far right widget
        animatedFriendOffset(
          Transform.scale(
            scale: scaleFarSide,
            child: animationFriend(Theme.of(context).colorScheme.onSecondary,
                "assets/memoji/Memoji5.png"),
          ),
          0,
          farDistance,
        ),
        // Right widget
        animatedFriendOffset(
          Transform.scale(
            scale: scaleSide,
            child: animationFriend(
                makeBrighter(Theme.of(context).colorScheme.onSecondary, 0.1),
                "assets/memoji/Memoji4.png"),
          ),
          0,
          distance,
        ),

        // Center widget
        Transform.scale(
          scale: scaleCenter,
          child: animationFriend(Theme.of(context).colorScheme.onSecondary,
              "assets/memoji/Memoji3.png"),
        ),
      ],
    );
  }
}
