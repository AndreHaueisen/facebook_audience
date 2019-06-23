import 'package:flutter/material.dart';
import 'package:facebook_audience/facebook_audience.dart';

void main() => runApp(AdExampleApp());

class AdExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FB Audience Network Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        buttonTheme: ButtonThemeData(
          textTheme: ButtonTextTheme.primary,
          buttonColor: Colors.blue,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "FB Audience Network Example",
          ),
        ),
        body: AdsPage(),
      ),
    );
  }
}

class AdsPage extends StatefulWidget {
  @override
  AdsPageState createState() => AdsPageState();
}

class AdsPageState extends State<AdsPage> {
  bool _isInterstitialAdLoaded = false;
  bool _isRewardedAdLoaded = false;
  bool _isRewardedVideoComplete = false;

  /// All widget ads are stored in this variable. When a button is pressed, its
  /// respective ad widget is set to this variable and the view is rebuilt using
  /// setState().
  Widget _currentAd = SizedBox(
    width: 0.0,
    height: 0.0,
  );

  @override
  void initState() {
    super.initState();

    FacebookAudience.init(
      testingId: "ee1c07ec-07cf-4cf8-bc31-fdf9100d8b17",
    );

    //_loadInterstitialAd();
    //_loadRewardedVideoAd();
  }

//  void _loadInterstitialAd() {
//    FacebookInterstitialAd.loadInterstitialAd(
//      placementId: "YOUR_PLACEMENT_ID",
//      listener: (result, value) {
//        print("Interstitial Ad: $result --> $value");
//        if (result == InterstitialAdResult.LOADED)
//          _isInterstitialAdLoaded = true;
//        /// Once an Interstitial Ad has been dismissed and becomes invalidated,
//        /// load a fresh Ad by calling this function.
//        if (result == InterstitialAdResult.DISMISSED &&
//            value["invalidated"] == true) {
//          _isInterstitialAdLoaded = false;
//          _loadInterstitialAd();
//        }
//      },
//    );
//  }

//  void _loadRewardedVideoAd() {
//    FacebookRewardedVideoAd.loadRewardedVideoAd(
//      placementId: "YOUR_PLACEMENT_ID",
//      listener: (result, value) {
//        print("Rewarded Ad: $result --> $value");
//        if (result == RewardedVideoAdResult.LOADED) _isRewardedAdLoaded = true;
//        if (result == RewardedVideoAdResult.VIDEO_COMPLETE)
//          _isRewardedVideoComplete = true;
//        /// Once a Rewarded Ad has been closed and becomes invalidated,
//        /// load a fresh Ad by calling this function.
//        if (result == RewardedVideoAdResult.VIDEO_CLOSED &&
//            value["invalidated"] == true) {
//          _isRewardedAdLoaded = false;
//          _loadRewardedVideoAd();
//        }
//      },
//    );
//  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Align(
            alignment: Alignment(0, -1.0),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _getAllButtons(),
            ),
          ),
          fit: FlexFit.tight,
          flex: 2,
        ),
        Flexible(
          child: Align(
            alignment: Alignment(0, 1.0),
            child: _currentAd,
          ),
          fit: FlexFit.tight,
          flex: 3,
        )
      ],
    );
  }

  Widget _getAllButtons() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 3,
      children: <Widget>[
        //_getRaisedButton(title: "Banner Ad", onPressed: _showBannerAd),
        _getRaisedButton(title: "Native Ad", onPressed: _showNativeAd),
        _getRaisedButton(title: "Native Banner Ad", onPressed: _showNativeBannerAd),
//        _getRaisedButton(
//            title: "Intestitial Ad", onPressed: _showInterstitialAd),
//        _getRaisedButton(title: "Rewarded Ad", onPressed: _showRewardedAd),
//        _getRaisedButton(title: "InStream Ad", onPressed: _showInStreamAd),
      ],
    );
  }

  Widget _getRaisedButton({String title, void Function() onPressed}) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: RaisedButton(
        onPressed: onPressed,
        child: Text(
          title,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

//  _showInterstitialAd() {
//    if (_isInterstitialAdLoaded == true)
//      FacebookInterstitialAd.showInterstitialAd();
//    else
//      print("Interstial Ad not yet loaded!");
//  }
//
//  _showRewardedAd() {
//    if (_isRewardedAdLoaded == true)
//      FacebookRewardedVideoAd.showRewardedVideoAd();
//    else
//      print("Rewarded Ad not yet loaded!");
//  }

//  _showInStreamAd() {
//    setState(() {
//      _currentAd = FacebookInStreamVideoAd(
//        height: 300,
//        listener: (result, value) {
//          print("In-Stream Ad: $result -->  $value");
//          if (result == InStreamVideoAdResult.VIDEO_COMPLETE) {
//            setState(() {
//              _currentAd = SizedBox(
//                height: 0,
//                width: 0,
//              );
//            });
//          }
//        },
//      );
//    });
//  }

//  _showBannerAd() {
//    setState(() {
//      _currentAd = FacebookBannerAd(
//        bannerSize: BannerSize.STANDARD,
//        listener: (result, value) {
//          print("Banner Ad: $result -->  $value");
//        },
//      );
//    });
//  }

  _showNativeBannerAd() {
    setState(() {
      _currentAd = FacebookNativeAd(
        adType: NativeAdType.NATIVE_BANNER_AD,
        bannerAdAndroidSize: NativeBannerAdAndroidSize.HEIGHT_100,
        width: double.infinity,
        backgroundColor: Colors.blue,
        titleColor: Colors.white,
        descriptionColor: Colors.white,
        buttonColor: Colors.deepPurple,
        buttonTitleColor: Colors.white,
        buttonBorderColor: Colors.white,
        listener: (result, value) {
          print("Native Banner Ad: $result --> $value");
        },
      );
    });
  }

  _showNativeAd() {
    setState(() {
      _currentAd = FacebookNativeAd(
        placementId: "2308590955894730_2398882150198943",
        adType: NativeAdType.NATIVE_AD,
        width: double.infinity,
        height: 300,
        backgroundColor: Colors.blue,
        titleColor: Colors.white,
        descriptionColor: Colors.white,
        buttonColor: Colors.deepPurple,
        buttonTitleColor: Colors.white,
        buttonBorderColor: Colors.white,
        listener: (result, value) {
          print("Native Ad: $result --> $value");
        },
      );
    });
  }
}
