package com.august.android

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register native ad factories for "listTile" and "listTileMedium"
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "listTile",  ListTileNativeAdFactory(context)
        )
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "listTileMedium", ListTileNativeAdFactoryMedium (context)
        )

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine, "gridTile", GridTileNativeAdFactory (context)
        )

    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)

        // Unregister both native ad factories
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTileMedium")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "gridTile")

    }
}
