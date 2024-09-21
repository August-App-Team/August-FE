import 'dart:io';

import 'package:august/components/ad/ad_helper.dart';
import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

class googleAdMobContainer extends StatefulWidget {
  final bool isGroup;
  final bool isMedium;
  const googleAdMobContainer({
    super.key,
    required this.isGroup,
    this.isMedium = false,
  });

  @override
  State<googleAdMobContainer> createState() => _googleAdMobContainerState();
}

class _googleAdMobContainerState extends State<googleAdMobContainer> {
  NativeAd? _nativeAd;
  bool isAdsLoaded = false;

  @override
  void initState() {
    _nativeAd = NativeAd(
      factoryId: widget.isMedium ? 'listTileMedium' : 'listTile',
      adUnitId: AdHelper.nativeAdUnitId,
      request: const AdRequest(),

      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (!isAdsLoaded) {
            setState(() {
              isAdsLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a native ad: ${err.message}');
          isAdsLoaded = false;
          ad.dispose();
        },
      ),
      // nativeAdOptions: NativeAdOptions(),
      // nativeTemplateStyle: NativeTemplateStyle(templateType: templateType),
    );
    _nativeAd!.load();
    super.initState();
  }

  @override
  void dispose() {
    _nativeAd!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isAdsLoaded
        ? Padding(
            padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
            child: Container(
              padding: widget.isGroup
                  ? const EdgeInsets.all(0)
                  : const EdgeInsets.all(0),
              width: double.infinity,
              height: widget.isGroup ? 100 : 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AdWidget(ad: _nativeAd!),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(
              bottom: 15,
              left: 15,
              right: 15,
            ),
            child: Container(
              height: widget.isGroup ? 100 : 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Shimmer.fromColors(
                  period: const Duration(milliseconds: 800),
                  baseColor: Colors
                      .grey[500]!, // Adjust the base color to match your theme
                  highlightColor: Colors.grey[
                      100]!, // Adjust the highlight color to match your theme
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Text(
                      'August',
                      style: AugustFont.head2(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
