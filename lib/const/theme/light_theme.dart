import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
  fontFamily: 'Nanum',
  brightness: Brightness.light,
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Color(0xFFffffff),
  ),
  colorScheme: ColorScheme.light(
    background: Color(0xFFffffff), //백그라운드 색 (가장 밝음)
    primaryContainer: Colors.white, // 타임테이블 색 (2번째 밝음)
    primary: Color.fromARGB(255, 225, 224, 224), // 버튼 색  (3번째 밝음)
    secondary: Color.fromARGB(255, 46, 46, 50), // ??? 색 (4번째 밝음)
    secondaryContainer: Color.fromARGB(255, 46, 46, 50), // ??? 색 (5번째 밝음)

    ///////////
    inversePrimary: Colors.grey.shade100,

    surfaceTint: Colors.grey, // 타임테이블 색 (2번째 밝음)

    ///////////////
    shadow: Colors.grey.shade300,
    outline: Colors.black, // for icons and text

    tertiaryContainer: Colors.grey.shade100, // 로딩 배경
    tertiary: Colors.black.withOpacity(0.04), //로딩 안쪽

    onSecondary: Color.fromARGB(255, 216, 215, 215),
    /* --- 그래프 색 */

    scrim: Colors.grey.shade200,

    /* --- semester select color */
    onInverseSurface: Color.fromARGB(255, 225, 224, 224),
  ),
);
