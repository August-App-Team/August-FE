import 'package:august/get_api/friends/invitation_code.dart';
import 'package:flutter/cupertino.dart';

class MyCodeProvider with ChangeNotifier {
  String _myCode = '';

  String get myCode => _myCode;

  MyCodeProvider() {
    loadMyCode();
  }

  set myCode(String value) {
    _myCode = value;
    notifyListeners();
  }

  Future<void> loadMyCode() async {
    FriendsRequestCode requestCode =
        await FriendRequestService().createFriendRequestCode();

    _myCode = requestCode.code;
    notifyListeners();
  }
}
