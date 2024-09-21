import 'package:august/components/ad/ad_helper.dart';
import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';

class googleAdMobGridList extends StatefulWidget {
  const googleAdMobGridList({super.key});

  @override
  State<googleAdMobGridList> createState() => _googleAdMobGridListState();
}

class _googleAdMobGridListState extends State<googleAdMobGridList> {
  NativeAd? _nativeAd;
  bool isAdsLoaded = false;

  @override
  void initState() {
    _nativeAd = NativeAd(
      factoryId: 'gridTile',
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
    );
    _nativeAd!.load();
    super.initState();
  }

  @override
  void dispose() {
    _nativeAd!.dispose();
    super.dispose();
  }

  /* 
  Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10,
                    offset: Offset(6, 4),
                  ),
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10,
                    offset: Offset(-2, 0),
                  ),
                ],
              ),
              child: AdWidget(ad: _nativeAd!),
            ),
          )
  */

  @override
  Widget build(BuildContext context) {
    return isAdsLoaded
        ? Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 10,
                  offset: Offset(6, 4),
                ),
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 10,
                  offset: Offset(-2, 0),
                ),
              ],
            ),
            child: AdWidget(ad: _nativeAd!))
        : Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 10,
                  offset: Offset(6, 4),
                ),
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 10,
                  offset: Offset(-2, 0),
                ),
              ],
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
          );
  }
}
