import 'dart:ui';

import 'package:august/components/home/button.dart';
import 'package:august/const/font/font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget buildButton(String text, Color buttonColor, final VoidCallback onTap,
    Color textColor, FontWeight textWeight, BuildContext context) {
  TextStyle buttonTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  double textWidth = calculateTextWidth(text, buttonTextStyle, context);
  double buttonWidth = textWidth + 10; // Add some padding to the text width

  // AnimatedContainer for background color animation
  return AnimatedContainer(
    duration: Duration(milliseconds: 200), // Duration of the animation
    width: buttonWidth,
    height: 30,
    decoration: BoxDecoration(
      color: buttonColor,
      borderRadius: BorderRadius.circular(40),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(
          // AnimatedSwitcher for text change animation
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              text,
              key: ValueKey<String>(text), // Unique key for AnimatedSwitcher
              style:
                  AugustFont.subText4(color: textColor, textWeight: textWeight),
            ),
          ),
        ),
      ),
    ),
  );
}
