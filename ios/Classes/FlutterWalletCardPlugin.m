#import "FlutterWalletCardPlugin.h"
#if __has_include(<flutter_wallet_card/flutter_wallet_card-Swift.h>)
#import <flutter_wallet_card/flutter_wallet_card-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_wallet_card-Swift.h"
#endif

@implementation FlutterWalletCardPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterWalletCardPlugin registerWithRegistrar:registrar];
}
@end
