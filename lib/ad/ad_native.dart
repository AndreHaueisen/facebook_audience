import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:facebook_audience/constants.dart';

enum NativeAdType {
  /// Customizable Native Ad.
  NATIVE_AD,

  /// Customizable Native Banner Ad.
  NATIVE_BANNER_AD,
}

enum NativeAdResult {
  /// Native Ad error.
  ERROR,

  /// Native Ad loaded successfully.
  LOADED,

  /// Native Ad clicked.
  CLICKED,

  /// Native Ad impression logged.
  LOGGING_IMPRESSION,

  /// Native Ad media loaded successfully.
  MEDIA_DOWNLOADED,
}

/// Defines the size of Native Banner Ads. Only three ad sizes are supported.
/// The width is flexible with predefined heights as follow:
///
/// * [HEIGHT_50] (Includes: Icon, Title, Context and CTA button)
/// * [HEIGHT_100] (Includes: Icon, Title, Context and CTA button)
/// * [HEIGHT_120] (Includes: Icon, Title, Context, Description and CTA button)
class NativeBannerAdAndroidSize {
  final int height;

  static const NativeBannerAdAndroidSize HEIGHT_50 = NativeBannerAdAndroidSize(height: 50);
  static const NativeBannerAdAndroidSize HEIGHT_100 = NativeBannerAdAndroidSize(height: 100);
  static const NativeBannerAdAndroidSize HEIGHT_120 = NativeBannerAdAndroidSize(height: 120);

  const NativeBannerAdAndroidSize({this.height});
}

class NativeBannerAdIOSSize {
  final int height;

  static const NativeBannerAdIOSSize HEIGHT_100 = NativeBannerAdIOSSize(height: 100);
  static const NativeBannerAdIOSSize HEIGHT_120 = NativeBannerAdIOSSize(height: 120);

  const NativeBannerAdIOSSize({this.height});
}

class NativeAdIOSSize {
  final int height;

  static const NativeAdIOSSize HEIGHT_300 = NativeAdIOSSize(height: 300);
  static const NativeAdIOSSize HEIGHT_400 = NativeAdIOSSize(height: 400);

  const NativeAdIOSSize({this.height});
}

class FacebookNativeAd extends StatefulWidget {
  /// Replace the default one with your placement ID for the release build.
  final String placementId;

  /// Native Ad listener.
  final void Function(NativeAdResult, dynamic) listener;

  /// Choose between [NativeAdType.NATIVE_AD] and
  /// [NativeAdType.NATIVE_BANNER_AD]
  final NativeAdType adType;

  /// If [adType] is [NativeAdType.NATIVE_BANNER_AD] you can choose between
  /// three predefined Ad sizes.
  final NativeBannerAdAndroidSize bannerAdAndroidSize;

  final NativeBannerAdIOSSize bannerAdIOSSize;
  final NativeAdIOSSize adIOSSize;

  /// Recommended width is between **280-500** for Native Ads. You can use
  /// [double.infinity] as the width to match the parent widget width.
  final double width;

  /// Recommended width is between **250-500** for Native Ads. Native Banner Ad
  /// height is predefined in [bannerAdAndroidSize] and cannot be
  /// changed through this parameter.
  final double height;

  /// This defines the background color of the Native Ad.
  final Color backgroundColor;

  /// This defines the title text color of the Native Ad.
  final Color titleColor;

  /// This defines the description text color of the Native Ad.
  final Color descriptionColor;

  /// This defines the button color of the Native Ad.
  final Color buttonColor;

  /// This defines the button text color of the Native Ad.
  final Color buttonTitleColor;

  /// This defines the button border color of the Native Ad.
  final Color buttonBorderColor;

  /// This widget can be used to display customizable native ads and native
  /// banner ads. 
  FacebookNativeAd({
    Key key,
    this.placementId = "YOUR_PLACEMENT_ID",
    this.listener,
    @required this.adType,
    this.bannerAdAndroidSize = NativeBannerAdAndroidSize.HEIGHT_50,
    this.bannerAdIOSSize = NativeBannerAdIOSSize.HEIGHT_100,
    this.adIOSSize = NativeAdIOSSize.HEIGHT_300,
    this.width = double.infinity,
    this.height = 250,
    this.backgroundColor,
    this.titleColor,
    this.descriptionColor,
    this.buttonColor,
    this.buttonTitleColor,
    this.buttonBorderColor,
  }) : super(key: key);

  @override
  _FacebookNativeAdState createState() => _FacebookNativeAdState();
}

class _FacebookNativeAdState extends State<FacebookNativeAd> {
  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        width: widget.width,
        height: widget.adType == NativeAdType.NATIVE_AD
            ? widget.height
            : widget.bannerAdAndroidSize.height.toDouble(),
        child: AndroidView(
          viewType: NATIVE_AD_CHANNEL,
          onPlatformViewCreated: _onNativeAdViewCreated,
          creationParamsCodec: StandardMessageCodec(),
          creationParams: <String, dynamic>{
            "id": widget.placementId,
            "banner_ad":
                widget.adType == NativeAdType.NATIVE_BANNER_AD ? true : false,
            // height param is only for Banner Ads. Native Ad's height is
            // governed by container.
            "height": widget.bannerAdAndroidSize.height,
            "bg_color": widget.backgroundColor == null
                ? null
                : _getHexStringFromColor(widget.backgroundColor),
            "title_color": widget.titleColor == null
                ? null
                : _getHexStringFromColor(widget.titleColor),
            "desc_color": widget.descriptionColor == null
                ? null
                : _getHexStringFromColor(widget.descriptionColor),
            "button_color": widget.buttonColor == null
                ? null
                : _getHexStringFromColor(widget.buttonColor),
            "button_title_color": widget.buttonTitleColor == null
                ? null
                : _getHexStringFromColor(widget.buttonTitleColor),
            "button_border_color": widget.buttonBorderColor == null
                ? null
                : _getHexStringFromColor(widget.buttonBorderColor),
          },
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        width: widget.width,
        height: widget.adType == NativeAdType.NATIVE_AD
            ? widget.height
            : widget.bannerAdIOSSize.height.toDouble(),
        child: UiKitView(
          viewType: NATIVE_AD_CHANNEL,
          onPlatformViewCreated: _onNativeAdViewCreated,
          creationParamsCodec: StandardMessageCodec(),
          creationParams: <String, dynamic>{
            "id": widget.placementId,
            "banner_ad":
            widget.adType == NativeAdType.NATIVE_BANNER_AD ? true : false,
            // height param is only for Banner Ads. Native Ad's height is
            // governed by container.
            "height": widget.adType == NativeAdType.NATIVE_BANNER_AD ? widget.bannerAdIOSSize : widget.adIOSSize,
            "bg_color": widget.backgroundColor == null
                ? null
                : _getHexStringFromColor(widget.backgroundColor),
            "title_color": widget.titleColor == null
                ? null
                : _getHexStringFromColor(widget.titleColor),
            "desc_color": widget.descriptionColor == null
                ? null
                : _getHexStringFromColor(widget.descriptionColor),
            "button_color": widget.buttonColor == null
                ? null
                : _getHexStringFromColor(widget.buttonColor),
            "button_title_color": widget.buttonTitleColor == null
                ? null
                : _getHexStringFromColor(widget.buttonTitleColor),
            "button_border_color": widget.buttonBorderColor == null
                ? null
                : _getHexStringFromColor(widget.buttonBorderColor),
          },
        ),
      );
    } else {
      return Container(
        width: widget.width,
        height: widget.height,
        child: Text("Banner Ads for this platform is currently not supported"),
      );
    }
  }

  String _getHexStringFromColor(Color color) =>
      '#${color.value.toRadixString(16)}';

  void _onNativeAdViewCreated(int id) {
    final channel = MethodChannel('${NATIVE_AD_CHANNEL}_$id');

    channel.setMethodCallHandler((MethodCall call) {
      switch (call.method) {
        case ERROR_METHOD:
          if (widget.listener != null)
            widget.listener(NativeAdResult.ERROR, call.arguments);
          break;
        case LOADED_METHOD:
          if (widget.listener != null)
            widget.listener(NativeAdResult.LOADED, call.arguments);
          setState(() {});
          break;
        case CLICKED_METHOD:
          if (widget.listener != null)
            widget.listener(NativeAdResult.CLICKED, call.arguments);
          break;
        case LOGGING_IMPRESSION_METHOD:
          if (widget.listener != null)
            widget.listener(NativeAdResult.LOGGING_IMPRESSION, call.arguments);
          break;
        case MEDIA_DOWNLOADED_METHOD:
          if (widget.listener != null)
            widget.listener(NativeAdResult.MEDIA_DOWNLOADED, call.arguments);
          break;
      }
    });
  }
}
