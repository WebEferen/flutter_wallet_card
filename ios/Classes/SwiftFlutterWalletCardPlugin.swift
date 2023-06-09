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
        
        case "addMultipleWalletCards":
            guard let arguments = call.arguments as? [String : Any] else {return}
                let filePaths = arguments["paths"] as! [String];
                var passes = [PKPass]();
                for filePath in filePaths {
                    let pkFile : NSData = NSData(contentsOfFile: filePath)!
                    do {
                        let pass = try PKPass.init(data: pkFile as Data)
                        passes.append(pass)
                    }
                    catch {
                        result(false)
                    }
                }
                let vc = PKAddPassesViewController(passes: passes)
                self.viewController.show(vc.unsafelyUnwrapped, sender: self)
                
                result(true)
        break;
        case "isWalletAvailable":
            result(PKAddPassesViewController.canAddPasses())
        break;

        case "didAddedToTheWallet":
            /// get the serial number of the pass from the arguments 
            guard let arguments = call.arguments as? [String : Any] else {return}
            let serialNumber = arguments["serialNumber"] as! String;
            /// get the first index of the pass from the wallet by serialNumber, first where serialNumber == pass.serialNumber
            let passSerialNumber = PKPassLibrary().passes().first(where: { $0.serialNumber == serialNumber })?.serialNumber
            /// check if the pass is added to the wallet
            if passSerialNumber == serialNumber {
                result(true)
            } else {
                result(false)
            }
        default:
            result(FlutterMethodNotImplemented);
        break;
    }
  }
}
