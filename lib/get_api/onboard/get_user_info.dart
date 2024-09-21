class UserDetails {
  int? id;
  String? email;
  String? name;
  Institution? institution;
  Department? department;
  String? profileImage;
  String? yearInSchool;
  String? dateJoined;

  UserDetails({
    this.id,
    this.email,
    this.name,
    this.institution,
    this.department,
    this.profileImage,
    this.yearInSchool,
    this.dateJoined,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      institution: json['institution'] != null
          ? Institution.fromJson(json['institution'])
          : null,
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
      profileImage: json['profile_image'],
      yearInSchool: json['year_in_school'],
      dateJoined: json['date_joined'],
    );
  }
}

class Institution {
  int? id;
  String? fullName;
  String? nickname;
  String? logo;

  Institution({
    this.id,
    this.fullName,
    this.nickname,
    this.logo,
  });

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'],
      fullName: json['full_name'],
      nickname: json['nickname'],
      logo: json['inst_logo'],
    );
  }
}

class Department {
  int? id;
  String? fullName;
  String? nickname;
  int? institutionId;

  Department({
    this.id,
    this.fullName,
    this.nickname,
    this.institutionId,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      fullName: json['full_name'],
      nickname: json['nickname'],
      institutionId: json['institution'],
    );
  }
}
