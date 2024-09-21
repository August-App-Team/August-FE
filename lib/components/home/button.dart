import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.onTap,
    required this.buttonColor,
    required this.textColor,
    required this.text,
    required this.width,
    required this.height,
    required this.borderColor,
  });

  final VoidCallback onTap;
  final Color buttonColor;
  final Color textColor;
  final Color borderColor;
  final String text;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(0),
            child: Center(
              child: Text(
                text,
                style: AugustFont.button(color: textColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double calculateTextWidth(String text, TextStyle style, BuildContext context) {
  final TextPainter textPainter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);

  return textPainter.size.width;
}
