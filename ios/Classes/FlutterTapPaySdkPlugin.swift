import Flutter
import UIKit
import TPDirect

public class FlutterTapPaySdkPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_tappay_sdk", binaryMessenger: registrar.messenger())
    let instance = FlutterTapPaySdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "sdkVersion":
      result(TPDSetup.version())
    case "initPayment":
      guard let args = call.arguments as? [String:Any] else {
        result("args cast error")
        return
      }
      
      let appId = args["appId"] as? Int32
      let appKey = args["appKey"] as? String
      let isSandbox = (args["isSandbox"] as? Bool ?? false)
      
      initTapPay(appId: appId, appKey: appKey, isSandbox: isSandbox, onResult: {
        response in result(response)
      })
      
    case "isValidCard":
      guard let args = call.arguments as? [String:Any] else {
        result("args cast error")
        return
      }
      
      let carNumber = args["cardNumber"] as? String
      let expiryMonth = args["mm"] as? String
      let expiryYear = args["yy"] as? String
      let cvv = args["cvv"] as? String
      
      result(validateCard(cardNumber: carNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvv: cvv))
      
    case "getPrimeByCardInfo":
      guard let args = call.arguments as? [String:Any] else {
        result("args cast error")
        return
      }
      
      let carNumber = args["cardNumber"] as? String
      let expiryMonth = args["mm"] as? String
      let expiryYear = args["yy"] as? String
      let cvv = args["cvv"] as? String
      
      createTokenByCardInfo(cardNumber: carNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvv: cvv) {
        response in result(response)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func initTapPay(appId: Int32?, appKey: String?, isSandbox: Bool?, onResult: @escaping([String: Any?]) -> Void) {
    if (appId == nil || appKey == nil || appKey == "") {
      var error = [String: Any]()
      error["success"] = false
      error["message"] = "\"appId\" and \"appKey\" are required."
      onResult(error)
      return
    }
    
    let serverType: TPDServerType = isSandbox == true ?
    TPDServerType.sandBox : TPDServerType.production
    
    TPDSetup.setWithAppId(appId!, withAppKey: appKey!, with: serverType)
    
    var result = [String: Any]()
    result["success"] = true
    result["message"] = nil
    onResult(result)
  }
  
  private func validateCard(cardNumber: String?, expiryMonth: String?, expiryYear: String?, cvv: String?) -> Bool {
    if (cardNumber == nil || expiryMonth == nil || expiryYear == nil || cvv == nil) {
      return false
    }
    
    guard let result = TPDCard.validate(withCardNumber: cardNumber!, withDueMonth: expiryMonth!, withDueYear: expiryYear!, withCCV: cvv!) else {
      return false
    }
    
    return result.isCardNumberValid && result.isExpiryDateValid && result.isCCVValid
  }
  
  private func createTokenByCardInfo(cardNumber: String?, expiryMonth: String?, expiryYear: String?, cvv: String?, onResult: @escaping([String: Any?]) -> Void) {
    if (cardNumber == nil || expiryMonth == nil || expiryYear == nil || cvv == nil) {
      onResult(self.generateTokenResult(success: false, status: nil, message: "Missing required parameters for \"getPrimeByCardInfo\" method.", prime: nil))
      return
    }
    
    TPDCard.setWithCardNumber(cardNumber!, withDueMonth: expiryMonth!, withDueYear: expiryYear!, withCCV: cvv!)
      .onSuccessCallback { (prime, cardInfo, cardIdentifier, merchantReferenceInfo) in
        onResult(self.generateTokenResult(success: true, status: nil, message: nil, prime: prime))
      }
      .onFailureCallback { (status, message) in
        onResult(self.generateTokenResult(success: false, status: status, message: message, prime: nil))
      }
      .createToken(withGeoLocation: "UNKNOWN")
  }
  
  private func generateTokenResult(success: Bool, status: Int?, message: String?, prime: String?) -> [String: Any?] {
    var result = [String: Any?]()
    
    result["success"] = success
    result["status"] = status
    result["message"] = message ?? ""
    result["prime"] = prime ?? ""
    
    return result
  }
}
