//
//  FacebookInterstitialAdFactory.swift
//  facebook_audience
//
//  Created by Andre Haueisen on 06/07/19.
//

import Foundation
import Flutter
import FBAudienceNetwork.FBAudienceNetworkAds

public class FacebookInterstitialAdPlugin:  NSObject, FBInterstitialAdDelegate  {
    
    let viewController: UIViewController
    let channel: FlutterMethodChannel
    var interstitalAd: FBInterstitialAd?
    
    
    public required init(channel: FlutterMethodChannel, viewController: UIViewController) {
        self.viewController = viewController
        self.channel = channel
        
        super.init()
        
        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            
            switch call.method{
            case FacebookConstants.SHOW_INTERSTITIAL_METHOD: result(self.showAd(args: call.arguments as! [String: Any?]))
            case FacebookConstants.LOAD_INTERSTITIAL_METHOD: result(self.loadAd(args: call.arguments as! [String: Any?]))
            case FacebookConstants.DESTROY_INTERSTITIAL_METHOD: result(self.destroyAd())
            default: result(nil)
            }
        })
        
    }
    
    private func showAd(args: [String: Any?]) -> Bool{
        let delay = args["delay"] as? Int ?? 0
        
        if self.interstitalAd == nil || !self.interstitalAd!.isAdValid {
            return false
        }
        
        if delay <= 0 {
            self.interstitalAd?.show(fromRootViewController: self.viewController)
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay), execute: {
                self.interstitalAd!.show(fromRootViewController: self.viewController)
            })
        }
        
        return true
    }
 
    private func loadAd(args: [String: Any?]) -> Bool {
        let placementId = args["id"] as? String
        
        if(interstitalAd == nil) {
            interstitalAd = FBInterstitialAd.init(placementID: placementId!)
            interstitalAd?.delegate = self
        }
        
        interstitalAd?.load()
       
        if interstitalAd!.isAdValid {
            return true;
        } else {
            return false;
        }
        
    }
    
    private func destroyAd() -> Bool{
        
        if(self.interstitalAd == nil){
            return false
        } else {
            self.interstitalAd?.delegate = nil
            self.interstitalAd = nil
            return true
        }
    }
    
    //Sent when an FBInterstitialAd successfully loads an ad.
    public func interstitialAdDidLoad(_ interstitialAd: FBInterstitialAd) {
        var args: [String: Any] = [:]
        
        args["placement_id"] = interstitalAd?.placementID
        args["invalidated"] = !interstitalAd!.isAdValid
        
        channel.invokeMethod(FacebookConstants.LOADED_METHOD, arguments: args)
    }
    
    // Use this function as indication for a user's click on the ad.
    public func interstitialAdDidClick(_ interstitialAd: FBInterstitialAd) {
        var args: [String: Any] = [:]
        
        args["placement_id"] = interstitalAd?.placementID
        args["invalidated"] = !interstitalAd!.isAdValid
        
        channel.invokeMethod(FacebookConstants.CLICKED_METHOD, arguments: args)
    }
    
    // Use this function as indication for a user's impression on the ad.
    public func interstitialAdWillLogImpression(_ interstitialAd: FBInterstitialAd) {
        var args: [String: Any] = [:]
        
        args["placement_id"] = interstitalAd?.placementID
        args["invalidated"] = !interstitalAd!.isAdValid
        
        channel.invokeMethod(FacebookConstants.LOGGING_IMPRESSION_METHOD, arguments: args)
    }
    
    // Consider to add code here to resume your app's flow
    public func interstitialAdWillClose(_ interstitialAd: FBInterstitialAd) {
        var args: [String: Any] = [:]
        
        args["placement_id"] = interstitalAd?.placementID
        args["invalidated"] = !interstitalAd!.isAdValid
        
        channel.invokeMethod(FacebookConstants.DISMISSED_METHOD, arguments: args)
    }
    
    // Consider to add code here to resume your app's flow
    public func interstitialAdDidClose(_ interstitialAd: FBInterstitialAd) {
        destroyAd()
    }
    
    /**
     Sent when an FBInterstitialAd failes to load an ad.
     
     @param interstitialAd An FBInterstitialAd object sending the message.
     @param error An error object containing details of the error.
     */
    public func interstitialAd(_ interstitialAd: FBInterstitialAd, didFailWithError error: Error) {
        var args: [String: Any] = [:]
        
        args["placement_id"] = interstitalAd?.placementID
        args["invalidated"] = !interstitalAd!.isAdValid
        args["error_message"] = error.localizedDescription
        args["error_code"] = -1
        
        channel.invokeMethod(FacebookConstants.ERROR_METHOD, arguments: args)
    }
}
