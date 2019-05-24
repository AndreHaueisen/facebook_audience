package com.andrehaueisen.facebook_audience

import android.content.Context
import android.graphics.Color
import android.view.View
import android.widget.LinearLayout
import com.facebook.ads.*
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class FacebookNativeAdPlugin(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, id: Int, args: Any): PlatformView{
        return FacebookNativeAdView(context, id, args as HashMap<*, *>, this.messenger)
    }
}

internal class FacebookNativeAdView(private val context: Context, id: Int, private val args: java.util.HashMap<*, *>, messenger: BinaryMessenger) : PlatformView, NativeAdListener {

    private val adView: LinearLayout = LinearLayout(context)
    private val channel: MethodChannel = MethodChannel(messenger,
            FacebookConstants.NATIVE_AD_CHANNEL + "_" + id)

    private var nativeAd: NativeAd? = null
    private var bannerAd: NativeBannerAd? = null

    init {
        if (args["banner_ad"] as Boolean) {
            bannerAd = NativeBannerAd(context, this.args["id"] as String?)
            bannerAd!!.setAdListener(this)
            bannerAd!!.loadAd()
        } else {
            nativeAd = NativeAd(context, this.args["id"] as String?)
            nativeAd!!.setAdListener(this)
            nativeAd!!.loadAd()
        }
    }

    private fun getViewAttributes(context: Context, args: java.util.HashMap<*, *>): NativeAdViewAttributes {
        val viewAttributes = NativeAdViewAttributes(context)

        if (args["bg_color"] != null)
            viewAttributes.backgroundColor = Color.parseColor(args["bg_color"] as String?)
        if (args["title_color"] != null)
            viewAttributes.titleTextColor = Color.parseColor(args["title_color"] as String?)
        if (args["desc_color"] != null)
            viewAttributes.descriptionTextColor = Color.parseColor(args["desc_color"] as String?)
        if (args["button_color"] != null)
            viewAttributes.buttonColor = Color.parseColor(args["button_color"] as String?)
        if (args["button_title_color"] != null)
            viewAttributes.buttonTextColor = Color.parseColor(args["button_title_color"] as String?)
        if (args["button_border_color"] != null)
            viewAttributes.buttonBorderColor = Color.parseColor(args["button_border_color"] as String?)

        return viewAttributes
    }

    private fun getBannerSize(args: java.util.HashMap<*, *>): NativeBannerAdView.Type {

        return when (args["height"] as Int) {
            50 -> NativeBannerAdView.Type.HEIGHT_50
            100 -> NativeBannerAdView.Type.HEIGHT_100
            120 -> NativeBannerAdView.Type.HEIGHT_120
            else -> NativeBannerAdView.Type.HEIGHT_120
        }
    }

    override fun getView(): View {
        return adView
    }

    override fun dispose() {

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

        if (adView.childCount > 0)
            adView.removeAllViews()

        if (this.args["banner_ad"] as Boolean) {
            adView.addView(NativeBannerAdView.render(this.context,
                    this.bannerAd!!,
                    getBannerSize(this.args),
                    getViewAttributes(this.context, this.args)))
        } else {
            adView.addView(NativeAdView.render(this.context,
                    this.nativeAd!!,
                    getViewAttributes(this.context, this.args)))
        }

        channel.invokeMethod(FacebookConstants.LOADED_METHOD, args)
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

    override fun onMediaDownloaded(ad: Ad) {
        val args = java.util.HashMap<String, Any>()
        args["placement_id"] = ad.placementId
        args["invalidated"] = ad.isAdInvalidated

        channel.invokeMethod(FacebookConstants.MEDIA_DOWNLOADED_METHOD, args)
    }
}