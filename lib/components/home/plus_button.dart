// UserInfoProvider remains the same, but ensure it is capable of handling new image data.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:avatar_glow/avatar_glow.dart';

class PlusButton extends StatefulWidget {
  const PlusButton({
    super.key,
  });

  @override
  PlusButtonState createState() => PlusButtonState();
}

class PlusButtonState extends State<PlusButton> {
  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      startDelay: const Duration(milliseconds: 1000),
      glowColor: Colors.blueAccent,
      glowShape: BoxShape.circle,
      glowRadiusFactor: 0.14,
      animate: true,
      curve: Curves.fastOutSlowIn,
      child: Container(
        height: 45,
        width: 45,
        decoration: const BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: const Icon(
            FeatherIcons.plus,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
/* 

*/