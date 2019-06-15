import Flutter
import UIKit
import FBAudienceNetwork


public class SwiftFacebookAudiencePlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        
        // Main channel for initialization
        let channel = FlutterMethodChannel(name: FacebookConstants.MAIN_CHANNEL, binaryMessenger: registrar.messenger())
        
        let delegate = FacebookAudiencePlugin()
        registrar.addMethodCallDelegate(delegate, channel: channel)
        
        // interstitial ad channel
        //let interstitialAdChannel:FlutterMethodChannel = FlutterMethodChannel(name: FacebookConstants.INTERSTITIAL_AD_CHANNEL, binaryMessenger: registrar.messenger())
        //interstitialAdChannel.setMethodCallHandler(FacebookInterstitialAdPlugin())
        
        // rewarded video ad channel
        //let rewardedAdChannel = FlutterMethodChannel(name: FacebookConstants.REWARDED_VIDEO_CHANNEL, binaryMessenger: registrar.messenger())
        //rewardedAdChannel.setMethodCallHandler(FacebookRewardedVideoAdPlugin())
        
        registrar.register(FacebookNativeAdFactory(messenger: registrar.messenger()), withId: FacebookConstants.NATIVE_AD_CHANNEL)
        
        let instance = FacebookAudiencePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? NSDictionary
        
        if call.method.elementsEqual(FacebookConstants.INIT_METHOD) {
            let testingId: String? = args?["testingId"] as? String
            
            // TODO see if needs initializing
            
            if testingId != nil {
                FBAdSettings.addTestDevice(testingId!)
                result("iOS testingId: \(testingId!)")
            } else {
                result("iOS testingId is nil")
            }
            
        } else {
            result("Method not implemented")
        }
    }
    
}

