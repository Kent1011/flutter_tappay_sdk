import Flutter
import UIKit
import TPDirect
import PassKit

public class FlutterTapPaySdkPlugin: NSObject, FlutterPlugin {
  
  var applePayHandler: ApplePayHandler
  
  override init() {
    applePayHandler = ApplePayHandler()
  }
  
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
        print("Missing required parameters for \"initPayment\" method.")
        result(TapPaySdkCommonResult(success: false, message: "args cast error").toDictionary())
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
        print("Missing required parameters for \"isValidCard\" method.")
        result(false)
        return
      }
      
      let carNumber = args["cardNumber"] as? String
      let expiryMonth = args["mm"] as? String
      let expiryYear = args["yy"] as? String
      let cvv = args["cvv"] as? String
      
      result(validateCard(cardNumber: carNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvv: cvv))
      
    case "getPrimeByCardInfo":
      guard let args = call.arguments as? [String:Any] else {
        print("Missing required parameters for \"getPrimeByCardInfo\" method.")
        result(CreateCardTokenByCardInfoResult(success: false, status: nil, message: "Missing required parameters for \"getPrimeByCardInfo\" method.", prime: nil).toDictionary())
        return
      }
      
      let carNumber = args["cardNumber"] as? String
      let expiryMonth = args["mm"] as? String
      let expiryYear = args["yy"] as? String
      let cvv = args["cvv"] as? String
      
      createTokenByCardInfo(cardNumber: carNumber, expiryMonth: expiryMonth, expiryYear: expiryYear, cvv: cvv) {
        response in result(response)
      }
      
    case "initApplePay":
      guard let args = call.arguments as? [String:Any] else {
        print("Missing required parameters for \"initApplePay\" method.")
        result(TapPaySdkCommonResult(success: false, message: "Missing required parameters for \"initApplePay\" method.").toDictionary())
        return
      }
      
      initApplePay(
        merchantId: args["merchantId"] as? String,
        merchantName: args["merchantName"] as? String,
        cardTypes: args["cardTypes"] as? [String],
        isConsumerNameRequired: args["isConsumerNameRequired"] as? Bool,
        isPhoneNumberRequired: args["isPhoneNumberRequired"] as? Bool,
        isBillingAddressRequired: args["isBillingAddressRequired"] as? Bool,
        isEmailRequired: args["isEmailRequired"] as? Bool
      ) {
        response in result(response)
      }
      
    case "requestApplePay":
      guard let args = call.arguments as? [String:Any] else {
        print("Missing required parameters for \"requestApplePay\" method.")
        result(TapPaySdkCommonResult(success: false, message: "Missing required parameters for \"requestApplePay\" method.").toDictionary())
        return
      }
      
      requestApplePay(
        cartItems: args["cartItems"] as? [[String: Any]],
        currencyCode: args["currencyCode"] as? String,
        countryCode: args["countryCode"] as? String
      ) {
        response in result(response)
      }
      
    case "applePayResult":
      guard let args = call.arguments as? [String:Any] else {
        print("Missing required parameters for \"appPayResult\" method.")
        result(TapPaySdkCommonResult(success: false, message: "Missing required parameters for \"appPayResult\" method.").toDictionary())
        return
      }
      
      if let resultValue = args["result"] as? Bool {
        let response = applePayHandler.applePayResult(result: resultValue)
        result(response.toDictionary())
      } else {
        result(TapPaySdkCommonResult(success: false, message: "Missing required \"result\" for \"appPayResult\" method.").toDictionary())
      }
      
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func initTapPay(appId: Int32?, appKey: String?, isSandbox: Bool?, onResult: @escaping([String: Any?]) -> Void) {
    if (appId == nil || appKey == nil || appKey == "") {
      let error = TapPaySdkCommonResult(success: false, message: "\"appId\" and \"appKey\" are required.")
      onResult(error.toDictionary())
      return
    }
    
    let serverType: TPDServerType = isSandbox == true ?
    TPDServerType.sandBox : TPDServerType.production
    
    TPDSetup.setWithAppId(appId!, withAppKey: appKey!, with: serverType)
    
    let result = TapPaySdkCommonResult(success: true, message: nil)
    onResult(result.toDictionary())
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
      onResult(CreateCardTokenByCardInfoResult(success: false, status: nil, message: "Missing required parameters for \"getPrimeByCardInfo\" method.", prime: nil).toDictionary())
      return
    }
    
    TPDCard.setWithCardNumber(cardNumber!, withDueMonth: expiryMonth!, withDueYear: expiryYear!, withCCV: cvv!)
      .onSuccessCallback { (prime, cardInfo, cardIdentifier, merchantReferenceInfo) in
        onResult(CreateCardTokenByCardInfoResult(success: true, status: nil, message: nil, prime: prime).toDictionary())
      }
      .onFailureCallback { (status, message) in
        onResult(CreateCardTokenByCardInfoResult(success: false, status: status, message: message, prime: nil).toDictionary())
      }
      .createToken(withGeoLocation: "UNKNOWN")
  }
  
  private func initApplePay(
    merchantId: String? = nil,
    merchantName: String? = nil,
    cardTypes: [String]? = ["visa", "masterCard", "amex", "jcb"],
    isConsumerNameRequired: Bool? = false,
    isPhoneNumberRequired: Bool? = false,
    isBillingAddressRequired: Bool? = false,
    isEmailRequired: Bool? = false,
    onResult: @escaping ([String: Any?]) -> Void
  ) {
    if (merchantName == nil) {
      onResult(TapPaySdkCommonResult(success: false, message: "Missing required parameters \"merchantName\" for \"initApplePay\" method.").toDictionary())
      return
    }
    
    let callbackDelegate: (TapPaySdkCommonResult) -> Void = { result in
      onResult(result.toDictionary())
    }
    
    applePayHandler.initApplePay(
      merchantId: merchantId,
      merchantName: merchantName,
      cardTypes: cardTypes,
      isConsumerNameRequired: isConsumerNameRequired,
      isPhoneNumberRequired: isPhoneNumberRequired,
      isBillingAddressRequired: isBillingAddressRequired,
      isEmailRequired: isEmailRequired,
      onApplePayCheck: callbackDelegate
    )
  }
  
  private func requestApplePay(
    cartItems: [[String: Any]]? = nil,
    currencyCode: String? = nil,
    countryCode: String? = nil,
    onResult: @escaping ([String: Any?]) -> Void
  ) {
    if (cartItems == nil || currencyCode == nil || countryCode == nil) {
      onResult(TapPaySdkCommonResult(success: false, message: "Missing required parameters for \"requestApplePay\" method.").toDictionary())
      return
    }
    
    let callbackDelegate: (ApplePayPaymentResult) -> Void = { result in
      onResult(result.toDictionary())
    }
    
    applePayHandler.requestApplePay(
      cartItems: cartItems,
      currencyCode: currencyCode,
      countryCode: countryCode,
      onApplePayResult: callbackDelegate
    )
  }
}
