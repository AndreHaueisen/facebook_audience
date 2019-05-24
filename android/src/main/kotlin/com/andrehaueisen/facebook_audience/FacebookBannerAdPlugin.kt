package com.andrehaueisen.facebook_audience

import android.content.Context
import android.view.View
import com.facebook.ads.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.HashMap

class FacebookBannerAdPlugin internal constructor(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, id: Int, args: Any): PlatformView {
        return FacebookBannerAdView(context, id, args as HashMap<*, *>, this.messenger)
    }
}

internal class FacebookBannerAdView
//    private final boolean isDisposable;

(context: Context, id: Int, args: HashMap<*, *>, messenger: BinaryMessenger) : PlatformView, AdListener {
    private val adView: AdView
    private val channel: MethodChannel = MethodChannel(messenger,
            FacebookConstants.BANNER_AD_CHANNEL + "_" + id)

    init {

        //        isDisposable = (boolean) args.get("dispose");

        adView = AdView(context,
                args["id"] as String?,
                getBannerSize(args))

        adView.setAdListener(this)
        adView.loadAd()
    }

    private fun getBannerSize(args: HashMap<*, *>): AdSize {
        //        final int width = (int) args.get("width");
        val height = args["height"] as Int

        if (height >= 250)
            return AdSize.RECTANGLE_HEIGHT_250
        return if (height >= 90)
            AdSize.BANNER_HEIGHT_90
        else
            AdSize.BANNER_HEIGHT_50
    }

    override fun getView(): View {
        return adView
    }

    override fun dispose() {
        //        if (adView != null && isDisposable)
        //        {
        //            Log.d("FacebookBannerAdPlugin", "Banner Ad disposed");
        //            adView.setAdListener(null);
        //            adView.destroy();
        //        }
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