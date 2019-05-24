package com.andrehaueisen.facebook_audience

internal object FacebookConstants {
    val MAIN_CHANNEL = "fb.audience.network.io"
    val BANNER_AD_CHANNEL = "$MAIN_CHANNEL/bannerAd"
    val INTERSTITIAL_AD_CHANNEL = "$MAIN_CHANNEL/interstitialAd"
    val NATIVE_AD_CHANNEL = "$MAIN_CHANNEL/nativeAd"
    val REWARDED_VIDEO_CHANNEL = "$MAIN_CHANNEL/rewardedAd"
    val IN_STREAM_VIDEO_CHANNEL = "$MAIN_CHANNEL/inStreamAd"

    val INIT_METHOD = "init"
    val SHOW_INTERSTITIAL_METHOD = "showInterstitialAd"
    val LOAD_INTERSTITIAL_METHOD = "loadInterstitialAd"
    val DESTROY_INTERSTITIAL_METHOD = "destroyInterstitialAd"

    val SHOW_REWARDED_VIDEO_METHOD = "showRewardedAd"
    val LOAD_REWARDED_VIDEO_METHOD = "loadRewardedAd"
    val DESTROY_REWARDED_VIDEO_METHOD = "destroyRewardedAd"

    val DISPLAYED_METHOD = "displayed"
    val DISMISSED_METHOD = "dismissed"
    val ERROR_METHOD = "error"
    val LOADED_METHOD = "loaded"
    val CLICKED_METHOD = "clicked"
    val LOGGING_IMPRESSION_METHOD = "logging_impression"
    val REWARDED_VIDEO_COMPLETE_METHOD = "rewarded_complete"
    val REWARDED_VIDEO_CLOSED_METHOD = "rewarded_closed"

    val IN_STREAM_VIDEO_COMPLETE_METHOD = "in_stream_complete"

    val MEDIA_DOWNLOADED_METHOD = "media_downloaded"
}