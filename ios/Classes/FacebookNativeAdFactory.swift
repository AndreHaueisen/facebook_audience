//
//  FacebookNativeAdFactory.swift
//  facebook_audience
//
//  Created by Andre Haueisen on 14/06/19.
//

import Foundation
import Flutter
import FBAudienceNetwork.FBAudienceNetworkAds


public class FacebookNativeAdFactory : NSObject, FlutterPlatformViewFactory {
    
    private let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger){
        self.messenger = messenger
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return FacebookNativeAdView(viewId: viewId, args: args as? [String : Any] ?? [:], frame: frame, messenger: messenger)
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

private class FacebookNativeAdView : NSObject, FBNativeAdDelegate, FlutterPlatformView{
    
    private var nativeAd: FBNativeAd?
    private var channel: FlutterMethodChannel?
    
    private let frame: CGRect
    private let args: [String : Any]
    let contentView: UIView;
    
    private var messenger: FlutterBinaryMessenger?

    required init(viewId: Int64, args: [String : Any], frame:CGRect, messenger: FlutterBinaryMessenger) {
        self.args = args
        self.frame = frame
        self.messenger = messenger
        self.contentView = UIView(frame: frame)
        
        super.init()
        
        channel = FlutterMethodChannel(name: FacebookConstants.NATIVE_AD_CHANNEL as String + "_" + String(viewId), binaryMessenger: messenger)
        
        nativeAd = FBNativeAd.init(placementID: self.args["id"] as! String)
        nativeAd!.delegate = self
        nativeAd!.loadAd()
        
    }
    
    func view() -> UIView {
        return contentView
    }
    
    /**
     Sent when an FBNativeAd has been successfully loaded.
     
     - Parameter nativeAd: An FBNativeAd object sending the message.
     */
    func nativeAdDidLoad(_ ad: FBNativeAd ){
        var args: [String : Any] = [String : Any]()
        
        args["placement_id"] = ad.placementID
        args["invalidated"] = !ad.isAdValid
        
        print("View loaded!")
        self.nativeAd = ad
        
    
        if(ad.isAdValid){
            self.nativeAd?.unregisterView()
            
            let viewType = getNativeAdSize(args: self.args)
            let nativeAdView = FBNativeAdView.init(nativeAd: ad, with: viewType, with: getViewAttributes(args: self.args))
            //nativeAdView.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.width)
            nativeAdView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
            
            contentView.addSubview(nativeAdView)

        }

        channel?.invokeMethod(FacebookConstants.LOADED_METHOD as String, arguments: args)
    }
    
    private func getNativeAdSize(args: [AnyHashable : Any]) -> FBNativeAdViewType {
        switch(args["height"] as! Int){
        case 300: return FBNativeAdViewType.genericHeight300
        case 400: return FBNativeAdViewType.genericHeight400
        default:
            return FBNativeAdViewType.genericHeight400
        }
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
        
        print("View downloaded!")
        
        channel?.invokeMethod(FacebookConstants.MEDIA_DOWNLOADED_METHOD as String, arguments: args)
    }
    
    /**
     Sent immediately before the impression of an FBNativeAd object will be logged.
     
     - Parameter nativeAd: An FBNativeAd object sending the message.
     */
    func nativeAdWillLogImpression(_ ad: FBNativeAd){
        var args: [String : Any] = [String : Any]()
        args["placement_id"] = ad.placementID
        args["invalidated"] = !ad.isAdValid
        
        print("View impression loged!")
        
        channel?.invokeMethod(FacebookConstants.LOGGING_IMPRESSION_METHOD as String, arguments: args)
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
        
        print("View loade failed!")
        
        channel?.invokeMethod(FacebookConstants.ERROR_METHOD as String, arguments: args)
    }
    
    /**
     Sent after an ad has been clicked by the person.
     
     - Parameter nativeAd: An FBNativeAd object sending the message.
     */
    func nativeAdDidClick(_ ad: FBNativeAd ){
        var args: [String : Any] = [String : Any]()
        args["placement_id"] = ad.placementID
        args["invalidated"] = !ad.isAdValid
        
        print("View clicked!")
        
        channel?.invokeMethod(FacebookConstants.CLICKED_METHOD as String, arguments: args)
    }
    
    /**
     When an ad is clicked, the modal view will be presented. And when the user finishes the
     interaction with the modal view and dismiss it, this message will be sent, returning control
     to the application.
     
     - Parameter nativeAd: An FBNativeAd object sending the message.
     */
    func nativeAdDidFinishHandlingClick (_ ad: FBNativeAd ){
        print("Model view finished!")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
