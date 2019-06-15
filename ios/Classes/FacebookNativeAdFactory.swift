//
//  FacebookNativeAdFactory.swift
//  facebook_audience
//
//  Created by Andre Haueisen on 14/06/19.
//

import Foundation
import Flutter
import FBAudienceNetwork


public class FacebookNativeAdFactory : NSObject, FlutterPlatformViewFactory {
    
    private let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger){
        self.messenger = messenger
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return FacebookNativeAdView(viewId: viewId, args: args as! [String : Any], frame: frame, messenger: messenger)
    }
}

private class FacebookNativeAdView : UIView, FBNativeAdDelegate ,FBNativeBannerAdDelegate, FlutterPlatformView{
    
    private var nativeAd: FBNativeAd?
    private var bannerAd: FBNativeBannerAd?
    private var channel: FlutterMethodChannel?
    private var shouldSetupConstraints: Bool = true
    
    private var viewId: Int64?
    private var args: [String : Any]?
    
    private var messenger: FlutterBinaryMessenger?
    
    //Views TODO see if they have any utility
//    private var adIconImageView: FBAdIconView!
//    private var adTitleLabel: UILabel!
//    private var adCoverMediaView: FBMediaView!
//    private var adSocialContext: UILabel!
//    private var adCallToActionButton: UIButton!
//    private var adChoicesView: FBAdChoicesView!
//    private var adBodyLabel: UILabel!
//    private var sponsoredLabel: UILabel!
    
    required init(viewId: Int64, args: [String : Any], frame:CGRect, messenger: FlutterBinaryMessenger) {
        super.init(frame: frame)
        
        self.viewId = viewId
        self.args = args
        self.frame = frame
        self.messenger = messenger
        
        channel = FlutterMethodChannel(name: FacebookConstants.NATIVE_AD_CHANNEL + "_" + String(self.viewId!), binaryMessenger: messenger)
        
        if self.args!["bannedAd"] as! Bool {
            bannerAd = FBNativeBannerAd(placementID: self.args!["id"] as! String)
            bannerAd!.delegate = self
            bannerAd!.loadAd()
        } else {
            nativeAd = FBNativeAd(placementID: self.args!["id"] as! String)
            nativeAd!.delegate = self
            nativeAd!.loadAd()
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func view() -> UIView {
        return self
    }
    
    override func updateConstraints() {
        if(shouldSetupConstraints) {
            // AutoLayout constraints
            shouldSetupConstraints = false
        }
        super.updateConstraints()
    }
    
    private func getBannerSize(args: [AnyHashable : Any]) -> FBNativeBannerAdViewType {
        switch(args["height"] as! Int){
        case 100: return FBNativeBannerAdViewType.genericHeight100
        case 120: return FBNativeBannerAdViewType.genericHeight120
        default:
            return FBNativeBannerAdViewType.genericHeight120
        }
    }
    
    private func getNativeAdSize(args: [AnyHashable : Any]) -> FBNativeAdViewType {
        switch(args["height"] as! Int){
        case 300: return FBNativeAdViewType.genericHeight300
        case 400: return FBNativeAdViewType.genericHeight400
        default:
            return FBNativeAdViewType.genericHeight400
        }
    }
    
    /**
     Sent when an FBNativeAd has been successfully loaded.
     
     - Parameter nativeAd: An FBNativeAd object sending the message.
     */
    func nativeAdDidLoad(_ ad: FBNativeAd ){
        var args: [String : Any] = [String : Any]()
        
        args["placement_id"] = ad.placementID
        args["invalidated"] = !ad.isAdValid
        
        if self.subviews.count > 0 {
            for view in self.subviews {
                view.removeFromSuperview()
            }
        }
        
        if(self.args!["banner_ad"] as! Bool){
            self.addSubview(FBNativeBannerAdView.init(nativeBannerAd: bannerAd!, with: getBannerSize(args: self.args!), with: getViewAttributes(args: self.args!)))
        } else {
            self.addSubview(FBNativeAdView.init(nativeAd: nativeAd!
                , with: getNativeAdSize(args: self.args!), with: getViewAttributes(args: self.args!)))
        }
        
        channel?.invokeMethod(FacebookConstants.LOADED_METHOD, arguments: args)
    }
    
    private func getViewAttributes(args: [AnyHashable : Any] ) -> FBNativeAdViewAttributes {
        let viewAttributes = FBNativeAdViewAttributes()
        
        if args["bg_color"] != nil {
            viewAttributes.backgroundColor = UIColor.init(hex: args["bg_color"] as! String)
        }
        if args["title_color"] != nil {
            viewAttributes.titleColor = UIColor.init(hex: args["title_color"] as! String)
        }
        if args["desc_color"] != nil {
            viewAttributes.descriptionColor = UIColor.init(hex: args["desc_color"] as! String)
        }
        if args["button_color"] != nil {
            viewAttributes.buttonColor = UIColor.init(hex: args["button_color"] as! String)
        }
        if args["button_title_color"] != nil {
            viewAttributes.buttonTitleColor = UIColor.init(hex: args["button_title_color"] as! String)
        }
        if args["button_border_color"] != nil {
            viewAttributes.buttonBorderColor = UIColor.init(hex: args["button_border_color"] as! String)
        }
        
        return viewAttributes
    }
    
    /**
     Sent when an FBNativeAd has succesfully downloaded all media
     */
    func nativeAdDidDownloadMedia(_ ad: FBNativeAd){
        var args: [String : Any] = [String : Any]()
        args["placement_id"] = ad.placementID
        args["invalidated"] = !ad.isAdValid
        
        channel?.invokeMethod(FacebookConstants.MEDIA_DOWNLOADED_METHOD, arguments: args)
    }
    
    /**
     Sent immediately before the impression of an FBNativeAd object will be logged.
     
     - Parameter nativeAd: An FBNativeAd object sending the message.
     */
    func nativeAdWillLogImpression(_ ad: FBNativeAd){
        var args: [String : Any] = [String : Any]()
        args["placement_id"] = ad.placementID
        args["invalidated"] = !ad.isAdValid
        
        channel?.invokeMethod(FacebookConstants.LOGGING_IMPRESSION_METHOD, arguments: args)
    }
    
    /**
     Sent when an FBNativeAd is failed to load.
     
     - Parameter nativeAd: An FBNativeAd object sending the message.
     - Parameter error: An error object containing details of the error.
     */
    func nativeAd(_ ad: FBNativeAd,  _ didFailWithError: NSError){
        var args: [String : Any] = [String : Any]()
        args["placement_id"] = ad.placementID
        args["invalidated"] = !ad.isAdValid
        args["error_code"] = didFailWithError.code
        args["error_message"] = didFailWithError.description
        
        channel?.invokeMethod(FacebookConstants.ERROR_METHOD, arguments: args)
    }
    
    /**
     Sent after an ad has been clicked by the person.
     
     - Parameter nativeAd: An FBNativeAd object sending the message.
     */
    func nativeAdDidClick(_ ad: FBNativeAd ){
        var args: [String : Any] = [String : Any]()
        args["placement_id"] = ad.placementID
        args["invalidated"] = !ad.isAdValid
        
        channel?.invokeMethod(FacebookConstants.CLICKED_METHOD, arguments: args)
    }
    
    /**
     When an ad is clicked, the modal view will be presented. And when the user finishes the
     interaction with the modal view and dismiss it, this message will be sent, returning control
     to the application.
     
     - Parameter nativeAd: An FBNativeAd object sending the message.
     */
    func nativeAdDidFinishHandlingClick (_ ad: FBNativeAd ){
        // TODO see if this has any utility
    }
    
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }
}
