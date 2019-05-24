package com.andrehaueisen.facebook_audience

import android.content.Context
import android.view.View
import com.facebook.ads.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FacebookInStreamVideoAdPlugin(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        return FacebookInStreamVideoAdView(context, id, args as HashMap<*,*>, this.messenger)
    }
}

internal class FacebookInStreamVideoAdView(context: Context, id: Int, args: java.util.HashMap<*, *>, messenger: BinaryMessenger) : PlatformView, InstreamVideoAdListener {

    private val adView: InstreamVideoAdView?
    private val channel: MethodChannel = MethodChannel(messenger,
            FacebookConstants.IN_STREAM_VIDEO_CHANNEL + "_" + id)

    init {
        adView = InstreamVideoAdView(context, args["id"] as String?, getSize(args))
        adView.setAdListener(this)
        adView.loadAd()
    }

    override fun getView(): View? {
        return adView
    }

    override fun dispose() {
        //        if (adView != null)
        //        {
        //            adView.setAdListener(null);
        //            adView.destroy();
        //        }
    }

    private fun getSize(args: java.util.HashMap<*, *>): AdSize {
        val width = args["width"] as Int
        val height = args["height"] as Int

        return AdSize(width, height)
    }

    override fun onAdVideoComplete(ad: Ad) {
        val args = java.util.HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated

        channel.invokeMethod(FacebookConstants.IN_STREAM_VIDEO_COMPLETE_METHOD, args)
    }

    override fun onError(ad: Ad, adError: AdError) {
        val args = java.util.HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated
        args["error_code"] = adError.errorCode
        args["error_message"] = adError.errorMessage

        channel.invokeMethod(FacebookConstants.ERROR_METHOD, args)
    }

    override fun onAdLoaded(ad: Ad) {
        val args = java.util.HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated

        channel.invokeMethod(FacebookConstants.LOADED_METHOD, args)

        if (adView == null || !adView.isAdLoaded)
            return

        adView.show()
    }

    override fun onAdClicked(ad: Ad) {
        val args = java.util.HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated

        channel.invokeMethod(FacebookConstants.CLICKED_METHOD, args)
    }

    override fun onLoggingImpression(ad: Ad) {
        val args = java.util.HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated

        channel.invokeMethod(FacebookConstants.LOGGING_IMPRESSION_METHOD, args)
    }
}