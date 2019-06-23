import Flutter
import UIKit
import FBAudienceNetwork.FBAudienceNetworkAds


public class SwiftFacebookAudiencePlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        // Main channel for initialization
        let channel = FlutterMethodChannel(name: FacebookConstants.MAIN_CHANNEL, binaryMessenger: registrar.messenger())
        
        let plugin = SwiftFacebookAudiencePlugin()
        //registrar.addApplicationDelegate(delegate)
        registrar.addApplicationDelegate(plugin)
        registrar.addMethodCallDelegate(plugin, channel: channel)
        
        // interstitial ad channel
        //let interstitialAdChannel:FlutterMethodChannel = FlutterMethodChannel(name: FacebookConstants.INTERSTITIAL_AD_CHANNEL, binaryMessenger: registrar.messenger())
        //interstitialAdChannel.setMethodCallHandler(FacebookInterstitialAdPlugin())
        
        // rewarded video ad channel
        //let rewardedAdChannel = FlutterMethodChannel(name: FacebookConstants.REWARDED_VIDEO_CHANNEL, binaryMessenger: registrar.messenger())
        //rewardedAdChannel.setMethodCallHandler(FacebookRewardedVideoAdPlugin())
        
        let nativeAdFactory = FacebookNativeAdFactory(messenger: registrar.messenger())
        
        registrar.register(nativeAdFactory, withId: FacebookConstants.NATIVE_AD_CHANNEL)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? NSDictionary

        if call.method.elementsEqual(FacebookConstants.INIT_METHOD) {
            let testingId: String = args?["testingId"] as? String ?? ""

            //let settings = FBAdInitSettings.init()
            //FBAudienceNetworkAds.initialize(with: settings, completionHandler: <#T##((FBAdInitResults) -> Void)?##((FBAdInitResults) -> Void)?##(FBAdInitResults) -> Void#>)
            
            let settings = FBAdInitSettings.init(placementIDs: [testingId], mediationService: "facebook")
            FBAudienceNetworkAds.initialize(with: settings) { (results) in
                result(results.isSuccess)
            }

            result(true)

        } else {
            result(false)
        }
    }
    
}

