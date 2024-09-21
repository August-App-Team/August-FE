import 'package:august/get_api/onboard/get_user_info.dart';
import 'package:august/login/login.dart';
import 'package:flutter/cupertino.dart';

class UserInfoProvider with ChangeNotifier {
  UserDetails? _userInfo;
  int? _userPk;

  UserInfoProvider() {
    loadUserInfo();
  }

  UserDetails? get userInfo => _userInfo;
  int? get userPk => _userPk;

  set userInfo(UserDetails? value) {
    _userInfo = value;
    notifyListeners();
  }

  void getUserPk() async {
    _userPk = await fetchUserPk();
  }

  Future<void> loadUserInfo() async {
    try {
      var fetchedDetails = await fetchUserDetails();
      if (fetchedDetails != null) {
        _userInfo = fetchedDetails;
        notifyListeners();
      } else {
        _userInfo = null;
        notifyListeners();
      }
    } catch (e) {
      print('Failed to load user info: $e');
      _userInfo = null;
      notifyListeners();
    }
  }

  void updateUserInfoFromJson(Map<String, dynamic> json) {
    _userInfo = UserDetails.fromJson(json);
    notifyListeners();
  }

  void updateUserEmail(String email) {
    if (_userInfo != null) {
      _userInfo?.email = email;
      notifyListeners();
    }
  }

  void updateUserName(String name) {
    if (_userInfo != null) {
      _userInfo?.name = name;
      notifyListeners(); // Notify all listening widgets to rebuild
    }
  }

  void updateUserInstitution(int institutionId, String institutionFullname,
      String institutionNickname, String institutionLogo) {
    if (_userInfo != null) {
      _userInfo?.institution = Institution(
        id: institutionId,
        fullName: institutionFullname,
        nickname: institutionNickname,
        logo: institutionLogo,
      );
      notifyListeners();
    }
  }

  void updateUserDepartment(int? departmentId, String? departmentFullname,
      String? departmentNickname, int departmentInstitutionId) {
    if (_userInfo != null) {
      _userInfo?.department = Department(
        id: departmentId,
        fullName: departmentFullname!,
        nickname: departmentNickname!,
        institutionId: departmentInstitutionId,
      );

      notifyListeners();
    } else {
      print('User info is null');
    }
  }

  void updateUserProfileImage(String newImageUrl) {
    if (_userInfo != null) {
      _userInfo?.profileImage = newImageUrl;
      notifyListeners(); // Notify all listening widgets to rebuild
    }
  }

  void updateUserYearInSchool(String yearInSchool) {
    if (_userInfo != null) {
      _userInfo?.yearInSchool = yearInSchool;
      notifyListeners(); // Notify all listening widgets to rebuild
    }
  }
}
