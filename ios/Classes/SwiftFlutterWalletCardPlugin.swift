import Flutter
import PassKit
import UIKit

public class SwiftFlutterWalletCardPlugin: NSObject, FlutterPlugin {
  let viewController: UIViewController
    
  init(controller: UIViewController) {
    self.viewController = controller
  }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let controller : UIViewController = (UIApplication.shared.delegate?.window??.rootViewController)!
    let channel = FlutterMethodChannel(name: "flutter_wallet_card", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterWalletCardPlugin(controller: controller)

    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

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
                    self.viewController.show(vc.unsafelyUnwrapped, sender: self)
                    
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
