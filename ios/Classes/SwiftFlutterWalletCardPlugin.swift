import Flutter
import PassKit
import UIKit

public class SwiftFlutterWalletCardPlugin: NSObject, FlutterPlugin {
  private let viewController: UIViewController
  private var addPassesFlutterResult: FlutterResult?
  private var initialPassCount: Int?
  private let passLibrary = PKPassLibrary()
    
  init(controller: UIViewController) {
    self.viewController = controller
    super.init()
  }
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    guard let controller = UIApplication.shared.delegate?.window??.rootViewController else {
      fatalError("Unable to get root view controller")
    }
    let channel = FlutterMethodChannel(name: "flutter_wallet_card", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterWalletCardPlugin(controller: controller)

    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
      
    case "addWalletCard":
      addWalletCard(call: call, result: result)
      
    case "addWalletCardFromUrl":
      addWalletCardFromUrl(call: call, result: result)
        
    case "addMultipleWalletCards":
      addMultipleWalletCards(call: call, result: result)
      
    case "isWalletAvailable":
      result(PKAddPassesViewController.canAddPasses())
      
    case "isWalletCardAdded":
      isWalletCardAdded(call: call, result: result)
      
    case "viewWalletCardInWallet":
      viewWalletCardInWallet(call: call, result: result)
      
    case "validatePass":
      validatePass(call: call, result: result)
      
    case "getPassInfo":
      getPassInfo(call: call, result: result)
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  // MARK: - Private Methods
  
  private func addWalletCard(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let filePath = arguments["path"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid file path", details: nil))
      return
    }
    
    guard FileManager.default.fileExists(atPath: filePath) else {
      result(FlutterError(code: "FILE_NOT_FOUND", message: "Pass file not found at path: \(filePath)", details: nil))
      return
    }
    
    guard let passData = NSData(contentsOfFile: filePath) else {
      result(FlutterError(code: "FILE_READ_ERROR", message: "Unable to read pass file", details: nil))
      return
    }
    
    do {
      let pass = try PKPass(data: passData as Data)
      
      // Check if pass is already in wallet
      if passLibrary.containsPass(pass) {
        result(FlutterError(code: "PASS_ALREADY_EXISTS", message: "Pass is already in wallet", details: nil))
        return
      }
      
      guard let addPassVC = PKAddPassesViewController(pass: pass) else {
        result(FlutterError(code: "CANNOT_ADD_PASS", message: "Cannot add this pass to wallet", details: nil))
        return
      }
      
      addPassVC.delegate = self
      addPassesFlutterResult = result
      initialPassCount = passLibrary.passes().count
      
      DispatchQueue.main.async {
        self.viewController.present(addPassVC, animated: true)
      }
      
    } catch {
      result(FlutterError(code: "INVALID_PASS", message: "Invalid pass file: \(error.localizedDescription)", details: nil))
    }
  }
  
  private func addWalletCardFromUrl(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let urlString = arguments["url"] as? String,
          let url = URL(string: urlString) else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid URL", details: nil))
      return
    }
    
    let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
      DispatchQueue.main.async {
        if let error = error {
          result(FlutterError(code: "DOWNLOAD_ERROR", message: "Failed to download pass: \(error.localizedDescription)", details: nil))
          return
        }
        
        guard let data = data else {
          result(FlutterError(code: "NO_DATA", message: "No data received from URL", details: nil))
          return
        }
        
        do {
          let pass = try PKPass(data: data)
          
          if self?.passLibrary.containsPass(pass) == true {
            result(FlutterError(code: "PASS_ALREADY_EXISTS", message: "Pass is already in wallet", details: nil))
            return
          }
          
          guard let addPassVC = PKAddPassesViewController(pass: pass) else {
            result(FlutterError(code: "CANNOT_ADD_PASS", message: "Cannot add this pass to wallet", details: nil))
            return
          }
          
          addPassVC.delegate = self
          self?.addPassesFlutterResult = result
          self?.initialPassCount = self?.passLibrary.passes().count
          
          self?.viewController.present(addPassVC, animated: true)
          
        } catch {
          result(FlutterError(code: "INVALID_PASS", message: "Invalid pass data: \(error.localizedDescription)", details: nil))
        }
      }
    }
    
    task.resume()
  }
  
  private func addMultipleWalletCards(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let filePaths = arguments["paths"] as? [String] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid file paths", details: nil))
      return
    }
    
    var passes: [PKPass] = []
    
    for filePath in filePaths {
      guard FileManager.default.fileExists(atPath: filePath) else {
        result(FlutterError(code: "FILE_NOT_FOUND", message: "Pass file not found at path: \(filePath)", details: nil))
        return
      }
      
      guard let passData = NSData(contentsOfFile: filePath) else {
        result(FlutterError(code: "FILE_READ_ERROR", message: "Unable to read pass file at: \(filePath)", details: nil))
        return
      }
      
      do {
        let pass = try PKPass(data: passData as Data)
        
        // Skip passes that are already in wallet
        if !passLibrary.containsPass(pass) {
          passes.append(pass)
        }
      } catch {
        result(FlutterError(code: "INVALID_PASS", message: "Invalid pass file at \(filePath): \(error.localizedDescription)", details: nil))
        return
      }
    }
    
    guard !passes.isEmpty else {
      result(FlutterError(code: "NO_NEW_PASSES", message: "All passes are already in wallet", details: nil))
      return
    }
    
    guard let addPassVC = PKAddPassesViewController(passes: passes) else {
      result(FlutterError(code: "CANNOT_ADD_PASSES", message: "Cannot add these passes to wallet", details: nil))
      return
    }
    
    addPassVC.delegate = self
    addPassesFlutterResult = result
    initialPassCount = passLibrary.passes().count
    
    DispatchQueue.main.async {
      self.viewController.present(addPassVC, animated: true)
    }
  }
  
  private func isWalletCardAdded(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let serialNumber = arguments["serialNumber"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid serial number", details: nil))
      return
    }
    
    let isAdded = passLibrary.passes().contains { pass in
      pass.serialNumber == serialNumber
    }
    
    result(isAdded)
  }
  
  private func viewWalletCardInWallet(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let serialNumber = arguments["serialNumber"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid serial number", details: nil))
      return
    }
    
    guard let pass = passLibrary.passes().first(where: { $0.serialNumber == serialNumber }) else {
      result(FlutterError(code: "PASS_NOT_FOUND", message: "Pass with serial number \(serialNumber) not found in wallet", details: nil))
      return
    }
    
    guard let passURL = pass.passURL else {
      result(FlutterError(code: "NO_PASS_URL", message: "Pass does not have a valid URL", details: nil))
      return
    }
    
    UIApplication.shared.open(passURL) { success in
      result(success)
    }
  }
  
  private func validatePass(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let filePath = arguments["path"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid file path", details: nil))
      return
    }
    
    guard FileManager.default.fileExists(atPath: filePath) else {
      result(["isValid": false, "error": "File not found"])
      return
    }
    
    guard let passData = NSData(contentsOfFile: filePath) else {
      result(["isValid": false, "error": "Unable to read file"])
      return
    }
    
    do {
      let pass = try PKPass(data: passData as Data)
      result([
        "isValid": true,
        "serialNumber": pass.serialNumber ?? "",
        "organizationName": pass.organizationName ?? "",
        "description": pass.localizedDescription ?? "",
        "passTypeIdentifier": pass.passTypeIdentifier ?? ""
      ])
    } catch {
      result(["isValid": false, "error": error.localizedDescription])
    }
  }
  
  private func getPassInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any],
          let serialNumber = arguments["serialNumber"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing or invalid serial number", details: nil))
      return
    }
    
    guard let pass = passLibrary.passes().first(where: { $0.serialNumber == serialNumber }) else {
      result(FlutterError(code: "PASS_NOT_FOUND", message: "Pass with serial number \(serialNumber) not found in wallet", details: nil))
      return
    }
    
    let passInfo: [String: Any] = [
      "serialNumber": pass.serialNumber ?? "",
      "organizationName": pass.organizationName ?? "",
      "description": pass.localizedDescription ?? "",
      "passTypeIdentifier": pass.passTypeIdentifier ?? "",
      "relevantDate": pass.relevantDate?.timeIntervalSince1970 ?? NSNull(),
      "expirationDate": NSNull(), // PKPass doesn't expose expiration date directly
      "isExpired": false, // Cannot determine without parsing pass.json
      "passURL": pass.passURL?.absoluteString ?? ""
    ]
    
    result(passInfo)
  }
}

// MARK: - PKAddPassesViewControllerDelegate
extension SwiftFlutterWalletCardPlugin: PKAddPassesViewControllerDelegate {
  public func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
    controller.dismiss(animated: true) { [weak self] in
      guard let self = self,
            let initialPassCount = self.initialPassCount,
            let addPassesFlutterResult = self.addPassesFlutterResult else {
        return
      }
      
      let newPassCount = self.passLibrary.passes().count
      let wasAdded = newPassCount > initialPassCount
      
      // Clean up
      self.addPassesFlutterResult = nil
      self.initialPassCount = nil
      
      addPassesFlutterResult(wasAdded)
    }
  }
}
