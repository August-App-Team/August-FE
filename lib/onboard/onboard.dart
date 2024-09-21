import 'dart:typed_data';

import 'package:august/get_api/onboard/get_univ.dart';
import 'package:august/onboard/done.dart';
import 'package:august/onboard/grade.dart';
import 'package:august/onboard/major.dart';
import 'package:august/onboard/profile.dart';
import 'package:august/onboard/semester.dart';
import 'package:august/onboard/univ.dart';
import 'package:august/pages/main/homepage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardPage extends StatefulWidget {
  const OnBoardPage({
    super.key,
  });

  @override
  _OnBoardPageState createState() => _OnBoardPageState();
}

class _OnBoardPageState extends State<OnBoardPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPrevious() {
    if (_currentPage > 0) {
      // 현재 페이지가 첫 페이지가 아니라면, 이전 페이지로 이동
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToNextOrHome() async {
    try {
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('hasSeenOnboard', true);

        Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
            ));
      }
    } catch (e) {
      print('Failed to set shared preferences or navigate: $e');
      // Optionally, handle the error by showing a user-friendly message or retry mechanism.
    }
  }

  List<Widget> get _pages => [
        NamePage(
          onboard: true,
          onTap: _navigateToNextOrHome,
        ),
        UnivPage(
          onboard: true,
          gonext: _navigateToNextOrHome,
          goBack: _navigateToPrevious,
        ),
        SemesterPage(
          onboard: true,
          gonext: _navigateToNextOrHome,
          goBack: _navigateToPrevious,
        ),
        GradePage(
          onboard: true,
          gonext: _navigateToNextOrHome,
          goBack: _navigateToPrevious,
        ),
        MajorPage(
          onboard: true,
          gonext: _navigateToNextOrHome,
          goBack: _navigateToPrevious,
        ),
        OnBoardDonePage(
          goBack: _navigateToPrevious,
          gonext: _navigateToNextOrHome,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          if (mounted)
            setState(() {
              _currentPage = page;
            });
        },
        physics: const NeverScrollableScrollPhysics(), // 스와이프로 페이지 넘김 방지
        children: _pages,
      ),
    );
  }
}
