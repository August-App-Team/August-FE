import 'package:august/const/font/font.dart';
import 'package:august/get_api/onboard/get_semester.dart';
import 'package:august/provider/semester_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class NewSemButton extends StatefulWidget {
  final VoidCallback help;
  final VoidCallback newSemester;

  NewSemButton({
    required this.help,
    required this.newSemester,
  });

  @override
  _NewSemButtonState createState() => _NewSemButtonState();
}

class _NewSemButtonState extends State<NewSemButton> {
  String displayedText = ''; // To control which text is displayed first
  bool showFullText = false;
  int toggleCount = 0; // Counter for number of text toggles
  bool isDisposed = false; // Track whether the widget is disposed

  @override
  void initState() {
    super.initState();
    // Start the text switcher in a loop
    WidgetsBinding.instance.addPostFrameCallback((_) {
      toggleText();
    });
  }

  @override
  void dispose() {
    isDisposed = true; // Mark the widget as disposed
    super.dispose();
  }

  void toggleText() {
    // Increment toggle count and update text state
    if (isDisposed) return; // If disposed, stop any further actions

    if (mounted) {
      setState(() {
        toggleCount++;
        showFullText = !showFullText;
      });
    }

    // If toggle count hasn't reached 10, continue toggling text
    if (toggleCount < 10) {
      Future.delayed(Duration(seconds: 3), toggleText);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Consumer<SemesterProvider>(
        builder: (context, semesterProvider, child) {
          // 현재 학기 가져오기
          String currentSemester = semesterProvider.semester;
          // 현재 학기 뒤에 있는 모든 학기 가져오기
          int currentIndex =
              semesterProvider.semestersList.indexOf(currentSemester);
          String nextSemestersText = '';

          final DateTime now = DateTime.now();
          final String currentYearMonth =
              '${now.year}${now.month.toString().padLeft(2, '0')}';

          // 현재 학기 뒤에 있는 모든 학기들을 가져와서 formatSemester 적용 후 텍스트로 변환
          if (currentIndex >= 0 &&
              currentIndex < semesterProvider.semestersList.length - 1) {
            List<String> nextSemesters =
                semesterProvider.semestersList.sublist(currentIndex + 1);

            // Filter semesters that are strictly after the currentMonth
            nextSemesters = nextSemesters
                .where((semester) =>
                    int.parse(semester) > int.parse(currentYearMonth))
                .toList();
            print("nextSemesters: $nextSemesters");

            // Check if there are any valid next semesters after currentMonth
            if (nextSemesters.isNotEmpty) {
              nextSemestersText = nextSemesters
                  .map((semester) =>
                      formatSemester(semester)) // Apply formatSemester
                  .join('\n'); // Join formatted semesters with newlines
            } else {
              nextSemestersText =
                  ''; // No valid semesters after the current month
            }
          } else {
            nextSemestersText =
                ''; // Handle edge case where no semesters exist after the current one
          }

          // Show the newly added semester text first, then transition
          String initialText = "Semesters\nUpdated !"; // 초기 텍스트

          // Control what text is displayed based on `showFullText`
          displayedText = showFullText && nextSemestersText.isNotEmpty
              ? nextSemestersText
              : initialText;

          // If the toggleCount has reached 10, show the help button
          if (toggleCount >= 10) {
            return GestureDetector(
              onTap: () {
                widget.help();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.background,
                  child: Center(
                    child: Image.asset(
                      'assets/icons/help.png',
                      height: 25,
                      width: 25,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ),
            );
          }

          return nextSemestersText.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    widget.newSemester();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: Container(
                      width: 100, // 텍스트를 모두 보여줄 수 있도록 너비를 넓게 설정
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            displayedText,
                            key: ValueKey<String>(displayedText),
                            style: AugustFont.captionSmallNormal4(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    widget.help();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15),
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.background,
                      child: Center(
                        child: Image.asset(
                          'assets/icons/help.png',
                          height: 25,
                          width: 25,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
