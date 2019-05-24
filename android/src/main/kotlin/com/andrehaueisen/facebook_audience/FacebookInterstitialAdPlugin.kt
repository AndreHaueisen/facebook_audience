package com.andrehaueisen.facebook_audience

import android.content.Context
import android.os.Handler
import com.facebook.ads.Ad
import com.facebook.ads.AdError
import com.facebook.ads.InterstitialAd
import com.facebook.ads.InterstitialAdListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

internal class FacebookInterstitialAdPlugin(private val context: Context, private val channel: MethodChannel) : MethodChannel.MethodCallHandler, InterstitialAdListener {

    private var interstitialAd: InterstitialAd? = null
    private val _delayHandler: Handler = Handler()

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {

        when (methodCall.method) {
            FacebookConstants.SHOW_INTERSTITIAL_METHOD -> result.success(showAd(methodCall.arguments as HashMap<*, *>))
            FacebookConstants.LOAD_INTERSTITIAL_METHOD -> result.success(loadAd(methodCall.arguments as HashMap<*, *>))
            FacebookConstants.DESTROY_INTERSTITIAL_METHOD -> result.success(destroyAd())
            else -> result.notImplemented()
        }
    }

    private fun loadAd(args: HashMap<*, *>): Boolean {
        val placementId = args["id"] as String?

        if (interstitialAd == null) {
            interstitialAd = InterstitialAd(context, placementId)
            interstitialAd!!.setAdListener(this)
        }
        try {
            if (!interstitialAd!!.isAdLoaded)
                interstitialAd!!.loadAd()
        } catch (e: Exception) {
            return false
        }

        return true
    }

    private fun showAd(args: HashMap<*, *>): Boolean {
        val delay = args["delay"] as Int

        if (interstitialAd == null || !interstitialAd!!.isAdLoaded)
            return false

        if (interstitialAd!!.isAdInvalidated)
            return false

        if (delay <= 0)
            interstitialAd!!.show()
        else {
            _delayHandler.postDelayed(Runnable {
                if (interstitialAd == null || !interstitialAd!!.isAdLoaded)
                    return@Runnable

                if (interstitialAd!!.isAdInvalidated)
                    return@Runnable

                interstitialAd!!.show()
            }, delay.toLong())
        }
        return true
    }

    private fun destroyAd(): Boolean {
        if (interstitialAd == null)
            return false
        else {
            interstitialAd!!.setAdListener(null)
            interstitialAd!!.destroy()
            interstitialAd = null
        }
        return true
    }

    override fun onInterstitialDisplayed(ad: Ad) {
        val args = HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated

        channel.invokeMethod(FacebookConstants.DISPLAYED_METHOD, args)
    }

    override fun onInterstitialDismissed(ad: Ad) {
        val args = HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated

        channel.invokeMethod(FacebookConstants.DISMISSED_METHOD, args)
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
}