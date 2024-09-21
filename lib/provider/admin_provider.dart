import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminProvider with ChangeNotifier {
  bool _isAdmin = false;

  bool get isAdmin => _isAdmin;

  set isAdmin(bool value) {
    _isAdmin = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  Future<void> loadAdminStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAdmin = prefs.getBool('isAdmin') ?? false;
    print("Loaded isAdmin: $_isAdmin");
  }

  void toggleAdmin() {
    _isAdmin = !_isAdmin;
    print("isAdmin: $_isAdmin");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
