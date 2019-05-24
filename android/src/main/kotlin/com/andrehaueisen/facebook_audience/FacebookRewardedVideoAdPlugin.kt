package com.andrehaueisen.facebook_audience

import android.content.Context
import android.os.Handler
import com.facebook.ads.Ad
import com.facebook.ads.AdError
import com.facebook.ads.RewardedVideoAd
import com.facebook.ads.RewardedVideoAdListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

internal class FacebookRewardedVideoAdPlugin(private val context: Context, private val channel: MethodChannel) : MethodChannel.MethodCallHandler, RewardedVideoAdListener {

    private var rewardedVideoAd: RewardedVideoAd? = null

    private val _delayHandler: Handler

    init {

        _delayHandler = Handler()
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {

        when (methodCall.method) {
            FacebookConstants.SHOW_REWARDED_VIDEO_METHOD -> result.success(showAd(methodCall.arguments as HashMap<*, *>))
            FacebookConstants.LOAD_REWARDED_VIDEO_METHOD -> result.success(loadAd(methodCall.arguments as HashMap<*, *>))
            FacebookConstants.DESTROY_REWARDED_VIDEO_METHOD -> result.success(destroyAd())
            else -> result.notImplemented()
        }
    }

    private fun loadAd(args: HashMap<*, *>): Boolean {
        val placementId = args["id"] as String?

        if (rewardedVideoAd == null) {
            rewardedVideoAd = RewardedVideoAd(context, placementId)
            rewardedVideoAd!!.setAdListener(this)
        }
        try {
            if (!rewardedVideoAd!!.isAdLoaded)
                rewardedVideoAd!!.loadAd()
        } catch (e: Exception) {
            return false
        }

        return true
    }

    private fun showAd(args: HashMap<*, *>): Boolean {
        val delay = args["delay"] as Int

        if (rewardedVideoAd == null || !rewardedVideoAd!!.isAdLoaded)
            return false

        if (rewardedVideoAd!!.isAdInvalidated)
            return false

        if (delay <= 0)
            rewardedVideoAd!!.show()
        else {
            _delayHandler.postDelayed(Runnable {
                if (rewardedVideoAd == null || !rewardedVideoAd!!.isAdLoaded)
                    return@Runnable

                if (rewardedVideoAd!!.isAdInvalidated)
                    return@Runnable

                rewardedVideoAd!!.show()
            }, delay.toLong())
        }
        return true
    }

    private fun destroyAd(): Boolean {
        if (rewardedVideoAd == null)
            return false
        else {
            rewardedVideoAd!!.setAdListener(null)
            rewardedVideoAd!!.destroy()
            rewardedVideoAd = null
        }
        return true
    }

    override fun onError(ad: Ad, adError: AdError) {
        val args = HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated
        args["error_code"] = adError.errorCode
        args["error_message"] = adError.errorMessage

        channel.invokeMethod(FacebookConstants.ERROR_METHOD, args)
    }

    override fun onAdLoaded(ad: Ad) {
        val args = HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated

        channel.invokeMethod(FacebookConstants.LOADED_METHOD, args)
    }

    override fun onAdClicked(ad: Ad) {
        val args = HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated

        channel.invokeMethod(FacebookConstants.CLICKED_METHOD, args)
    }

    override fun onLoggingImpression(ad: Ad) {
        val args = HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated

        channel.invokeMethod(FacebookConstants.LOGGING_IMPRESSION_METHOD, args)
    }

    override fun onRewardedVideoCompleted() {
        channel.invokeMethod(FacebookConstants.REWARDED_VIDEO_COMPLETE_METHOD, true)
    }

    override fun onRewardedVideoClosed() {
        channel.invokeMethod(FacebookConstants.REWARDED_VIDEO_CLOSED_METHOD, true)
    }
}