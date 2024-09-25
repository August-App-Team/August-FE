import 'package:august/const/colors/tile_color.dart';
import 'package:flutter/material.dart';

ThemeData dartTheme = ThemeData(
  splashColor: Colors.transparent,
  highlightColor: Colors.transparent,
  hoverColor: Colors.transparent,
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Color.fromRGBO(37, 37, 37, 1),
  ),
  scaffoldBackgroundColor: Color.fromRGBO(37, 37, 37, 1),
  fontFamily: 'Nanum',
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Color.fromRGBO(37, 37, 37, 1), //백그라운드 색 (가장 어두움_)
    primaryContainer: Color(0xFF333333), // 타임테이블  색(2번째 어두움)
    primary: Color(0xFF4d4d4d), // 버튼 색 (3번째 어두움)
    secondary: Color(0xFF666666), // ??? 색 (4번째 어두움)
    secondaryContainer: Color.fromARGB(255, 117, 78, 78), // ??? 색 (5번째 어두움)

    ///////////
    inversePrimary: Color(0xFF666666),
    surfaceTint: Colors.grey, // 타임테이블  색(2번째 어두움)
    /////////////////////////
    shadow: Colors.transparent,
    outline: Colors.white, // for icons and text

    tertiaryContainer: Colors.grey.shade900, // 로딩 배경
    tertiary: Colors.black.withOpacity(0.3), //로딩 안쪽

    onSecondary: Color(0xFF4d4d4d),

    /* --- 그래프 색 */

    scrim: Colors.grey.shade700,

    /* --- semester select color */
    onInverseSurface: Color.fromARGB(255, 84, 84, 84),
  ),
);


//Color.fromARGB(255, 44, 44, 47),

