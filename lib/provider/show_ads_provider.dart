import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ShowAdProvider with ChangeNotifier {
  bool _hideAd = false;

  bool get hideAd => _hideAd;

  ShowAdProvider() {
    loadHideAd();
  }

  set hideAd(bool value) {
    _hideAd = value;
    notifyListeners();
  }

  Future<void> loadHideAd() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _hideAd = prefs.getBool('hideAd') ?? false;
    notifyListeners();
  }
}
