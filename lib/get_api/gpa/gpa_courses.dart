class PreviousGPA {
  String semester;
  double grade;

  PreviousGPA({
    required this.semester,
    required this.grade,
  });

  Map<String, dynamic> toJson() => {
        'semester': semester,
        'grade': grade,
      };

  factory PreviousGPA.fromJson(Map<String, dynamic> json) => PreviousGPA(
        semester: json['semester'],
        grade: json['grade'],
      );
}

class CurrentGPA {
  String semester;
  String title;
  int credits;
  double grade;
  bool isMajor;

  CurrentGPA({
    required this.semester,
    required this.title,
    required this.credits,
    required this.grade,
    this.isMajor = false,
  });

  Map<String, dynamic> toJson() => {
        'semester': semester,
        'title': title,
        'credits': credits,
        'grade': grade,
        'isMajor': isMajor,
      };

  factory CurrentGPA.fromJson(Map<String, dynamic> json) => CurrentGPA(
        semester: json['semester'],
        title: json['title'],
        credits: json['credits'],
        grade: json['grade'],
        isMajor: json['isMajor'],
      );
}

class TotalGPA {
  String semester;
  double grade;

  TotalGPA({
    required this.semester,
    required this.grade,
  });

  Map<String, dynamic> toJson() => {
        'semester': semester,
        'grade': grade,
      };

  factory TotalGPA.fromJson(Map<String, dynamic> json) => TotalGPA(
        semester: json['semester'],
        grade: json['grade'],
      );
}
