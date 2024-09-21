import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendsProvider extends ChangeNotifier {
  int _friendsCount = 0;
  List<String> _friendsPhotos = [];
  List<String> _friendsPhotosInMePage = [];

  int get friendsCount => _friendsCount;
  List get friendsPhoto => _friendsPhotos;
  List get friendsPhotosInMePage => _friendsPhotosInMePage;

  Future<void> setFriendsCount(int count) async {
    _friendsCount = count;

    notifyListeners();
  }

  Future<void> setFriendsPhoto(List<String> photos) async {
    _friendsPhotos = photos;
    notifyListeners();
  }

  Future<void> setFriendsPhotosInMePage(List<String> photos) async {
    _friendsPhotosInMePage = photos;
    notifyListeners();
  }
}
