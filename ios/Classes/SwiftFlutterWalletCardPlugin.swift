import Flutter
import PassKit
import UIKit

public class SwiftFlutterWalletCardPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_wallet_card", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterWalletCardPlugin()

    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

    switch(call.method) {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        break;
        case "addWalletCard":
            guard let arguments = call.arguments as? [String : Any] else {return}
                let filePath = arguments["path"] as! String;
                let pkFile : NSData = NSData(contentsOfFile: filePath)!

                do {
                    let pass = try PKPass.init(data: pkFile as Data)
                    let vc = PKAddPassesViewController(pass: pass)
                    controller.show(vc.unsafelyUnwrapped, sender: self)
                    
                    result(true)
                }
                catch {
                    result(false)
                }
        break;
        default:
            result(FlutterMethodNotImplemented);
        break;
    }
  }
}
