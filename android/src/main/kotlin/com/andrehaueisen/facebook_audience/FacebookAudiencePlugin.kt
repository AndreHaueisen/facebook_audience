package com.andrehaueisen.facebook_audience

import android.app.Activity
import android.graphics.Color
import android.media.FaceDetector
import android.util.DisplayMetrics

import com.facebook.ads.*

import java.util.HashMap

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar

class FacebookAudiencePlugin(val activity: Activity): MethodCallHandler {

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {

      // Main channel for initialization
      val channel = MethodChannel(registrar.messenger(),
              FacebookConstants.MAIN_CHANNEL)
      channel.setMethodCallHandler(FacebookAudiencePlugin(registrar.activity()))

      // Interstitial Ad channel
      val interstitialAdChannel = MethodChannel(registrar.messenger(), FacebookConstants.INTERSTITIAL_AD_CHANNEL)
      interstitialAdChannel.setMethodCallHandler(FacebookInterstitialAdPlugin(registrar.context(),
                      interstitialAdChannel))

      // Rewarded video Ad channel
      val rewardedAdChannel = MethodChannel(registrar.messenger(),
              FacebookConstants.REWARDED_VIDEO_CHANNEL)
      rewardedAdChannel
              .setMethodCallHandler(FacebookRewardedVideoAdPlugin(registrar.context(),
                      rewardedAdChannel))

      // Banner Ad PlatformView channel
      registrar.platformViewRegistry().registerViewFactory(FacebookConstants.BANNER_AD_CHANNEL,
              FacebookBannerAdPlugin(registrar.messenger()))

      // InStream Video Ad PlatformView channel
      registrar.platformViewRegistry().registerViewFactory(FacebookConstants.IN_STREAM_VIDEO_CHANNEL,
              FacebookInStreamVideoAdPlugin(registrar.messenger()))

      // Native Ad PlatformView channel
      registrar.platformViewRegistry().registerViewFactory(FacebookConstants.NATIVE_AD_CHANNEL,
              FacebookNativeAdPlugin(registrar.messenger()))
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {

    if (call.method == FacebookConstants.INIT_METHOD)
      result.success(init(call.arguments as HashMap<*, *>))
    else
      result.notImplemented()
  }

  private fun init( initValues : HashMap<*, *>): Boolean {

    val testingId : String? = initValues["testingId"] as String?

    AudienceNetworkAds.initialize(activity.applicationContext)
    if(testingId != null) {
      AdSettings.addTestDevice(testingId)
    }

    return true
  }
}
