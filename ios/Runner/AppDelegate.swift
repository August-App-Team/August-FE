import Flutter
import UIKit
// TODO: Import google_mobile_ads
import google_mobile_ads

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      
     
    // TODO: Register ListTileNativeAdFactory
    GADMobileAds.sharedInstance().start(completionHandler: nil)
     let listTileFactory = ListTileNativeAdFactory()
     FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
         self, factoryId: "listTile", nativeAdFactory: listTileFactory)
      
      let listTileMediumFactory = ListTileNativeMediumFactory()
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
          self, factoryId: "listTileMedium", nativeAdFactory: listTileMediumFactory)
      
      let gridTileFactory = GridTileNativeAdFactory()
      FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
          self, factoryId: "gridTile", nativeAdFactory: gridTileFactory)
      
   
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
