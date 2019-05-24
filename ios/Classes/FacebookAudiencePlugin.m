#import "FacebookAudiencePlugin.h"
#import <facebook_audience/facebook_audience-Swift.h>

@implementation FacebookAudiencePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFacebookAudiencePlugin registerWithRegistrar:registrar];
}
@end
