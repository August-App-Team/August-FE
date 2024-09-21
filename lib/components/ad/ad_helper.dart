import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  static String get bannerAdUnitId {
    if (kReleaseMode) {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        throw new UnsupportedError('Unsupported platform');
      }
    } else {
      if (Platform.isAndroid) {
        return 'ca-app-pub-3940256099942544/6300978111';
      } else if (Platform.isIOS) {
        return 'ca-app-pub-3940256099942544/2934735716';
      } else {
        throw new UnsupportedError('Unsupported platform');
      }
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/1033173712";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get nativeAdUnitId {
    if (kReleaseMode) {
      //release mode
      if (Platform.isAndroid) {
        return "ca-app-pub-8909142959557772/6698132378";
      } else if (Platform.isIOS) {
        return "ca-app-pub-8909142959557772/2483345763";
      } else {
        throw new UnsupportedError("Unsupported platform");
      }
    } else {
      //debug mode
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/2247696110";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/3986624511";
      } else {
        throw new UnsupportedError("Unsupported platform");
      }
    }
  }
}
