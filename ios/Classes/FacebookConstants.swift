//
//  FacebookConstants.swift
//  facebook_audience
//
//  Created by Andre Haueisen on 14/06/19.
//

import Foundation

class FacebookConstants {
    static let MAIN_CHANNEL:String = "facebook_audience"
    static let BANNER_AD_CHANNEL:String = "\(MAIN_CHANNEL)/bannerAd"
    static let INTERSTITIAL_AD_CHANNEL:String = "\(MAIN_CHANNEL)/interstitialAd"
    static let NATIVE_AD_CHANNEL:String = "\(MAIN_CHANNEL)/nativeAd"
    static let REWARDED_VIDEO_CHANNEL:String = "\(MAIN_CHANNEL)/rewardedAd"
    static let IN_STREAM_VIDEO_CHANNEL:String = "\(MAIN_CHANNEL)/inStreamAd"
    
    static let INIT_METHOD:String = "init"
    static let SHOW_INTERSTITIAL_METHOD:String = "showInterstitialAd"
    static let LOAD_INTERSTITIAL_METHOD:String = "loadInterstitialAd"
    static let DESTROY_INTERSTITIAL_METHOD:String = "destroyInterstitialAd"
    
    static let SHOW_REWARDED_VIDEO_METHOD:String = "showRewardedAd"
    static let LOAD_REWARDED_VIDEO_METHOD:String = "loadRewardedAd"
    static let DESTROY_REWARDED_VIDEO_METHOD:String = "destroyRewardedAd"
    
    static let DISPLAYED_METHOD:String = "displayed"
    static let DISMISSED_METHOD:String = "dismissed"
    static let ERROR_METHOD:String = "error"
    static let LOADED_METHOD:String = "loaded"
    static let CLICKED_METHOD:String = "clicked"
    static let LOGGING_IMPRESSION_METHOD:String = "logging_impression"
    static let REWARDED_VIDEO_COMPLETE_METHOD:String = "rewarded_complete"
    static let REWARDED_VIDEO_CLOSED_METHOD:String = "rewarded_closed"
    
    static let IN_STREAM_VIDEO_COMPLETE_METHOD:String = "in_stream_complete"
    
    static let MEDIA_DOWNLOADED_METHOD:String = "media_downloaded"
}
