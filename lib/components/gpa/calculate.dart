import 'package:august/get_api/gpa/gpa_courses.dart';

class GPACalculations {
  double totalCredits = 0;
  double totalWeightedGradePoints = 0;

  GPACalculations(List<CurrentGPA> currentSemester) {
    for (var course in currentSemester) {
      totalCredits += course.credits;
      totalWeightedGradePoints += course.credits * course.grade;
    }
  }

  double get weightedGPA =>
      (totalCredits != 0) ? totalWeightedGradePoints / totalCredits : 0.0;
}
