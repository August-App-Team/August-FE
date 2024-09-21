import 'dart:math';

import 'package:flutter/material.dart';

//background color for entire app
const tileColor1 = Color(0xFFe5fff9);
const tileColor2 = Color(0xFFe2fbff);
const tileColor3 = Color(0xFFe3ecff);
const tileColor4 = Color(0xFFe9e2ff);
const tileColor5 = Color(0xFFffefe5);
const tileColor6 = Color(0xFFffe6ea);
const tileColor7 = Color(0xFFfff7e6);

const infoColor1 = Color(0xFFe5f5f8);
const infoBorder1 = Color(0xFFb2dde2);
const infoColor2 = Color(0xFFfff6e6);
const infoBorder2 = Color(0xFFfedeaa);
const infoColor3 = Color(0xFFe0e8fc);
const infoBorder3 = Color(0xFFbac9f7);
const infoColor4 = Color(0xFFf5e1e6);
const infoBorder4 = Color(0xFFde97a3);

const infoText1 = Color(0xFF6ec1c9);
const infoText2 = Color(0xFFfcba53);
const infoText3 = Color(0xFF7595ee);
const infoText4 = Color(0xFFcc5d72);

const removeButton = Color(0xFFee5d68);
const removeText = Colors.white;

const editButton = Color(0xFF7cd78c);
const editText = Color(0xFFe0fddd);

const setMainButton = Color(0xFFee5d68);
const setMainText = Colors.white;

const searchColor1 = Color.fromARGB(255, 221, 255, 247);
const searchColor2 = Color.fromARGB(255, 208, 249, 255);
const searchColor3 = Color.fromARGB(255, 212, 226, 255);
const searchColor4 = Color.fromARGB(255, 223, 213, 255);
const searchColor5 = Color.fromARGB(255, 255, 231, 216);
const searchColor6 = Color.fromARGB(255, 255, 213, 220);
const searchColor7 = Color.fromARGB(255, 255, 243, 218);

Color makeDarker(Color color, double amount) {
  return Color.fromARGB(
    color.alpha,
    max(0, color.red - (255 * amount).toInt()),
    max(0, color.green - (255 * amount).toInt()),
    max(0, color.blue - (255 * amount).toInt()),
  );
}

Color makeBrighter(Color color, double amount) {
  return Color.fromARGB(
    color.alpha,
    min(255, color.red + (255 * amount).toInt()),
    min(255, color.green + (255 * amount).toInt()),
    min(255, color.blue + (255 * amount).toInt()),
  );
}
