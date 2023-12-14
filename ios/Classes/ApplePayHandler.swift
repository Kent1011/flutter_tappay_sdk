//
//  ApplePayHandler.swift
//  flutter_tappay_sdk
//
//  Created by Kent C on 2023/12/13.
//

import TPDirect

typealias ApplePayHandlerCheckCallback = (TapPaySdkCommonResult) -> Void

typealias AppPayHandlerPaymentCallback = (ApplePayPaymentResult) -> Void

class ApplePayHandler: NSObject {
  
  var merchant: TPDMerchant!
  var consumer: TPDConsumer!
  var cart: TPDCart!
  var applePay : TPDApplePay!
  
  private var isApplePayAvailable: Bool = false
  private var isPaymentProcessing: Bool = false
  
  private var onApplePayResult: AppPayHandlerPaymentCallback?
  
  func initApplePay(
    merchantId: String? = nil,
    merchantName: String? = nil,
    cardTypes: [String]? = ["visa", "masterCard", "amex", "jcb"],
    isConsumerNameRequired: Bool? = false,
    isPhoneNumberRequired: Bool? = false,
    isBillingAddressRequired: Bool? = false,
    isEmailRequired: Bool? = false,
    onApplePayCheck: ApplePayHandlerCheckCallback?
  ) {
    if (isPaymentProcessing) {
      onApplePayCheck?(TapPaySdkCommonResult(success: false, message: "Previous payment is still processing."))
      return
    }
    
    if (merchantId == nil || merchantName == nil) {
      onApplePayCheck?(TapPaySdkCommonResult(success: false, message: "Missing required parameters for \"initApplePay\" method."))
      return
    }
    
    var supportNetworks = convertCardTypes(cardTypes: cardTypes)
    if (supportNetworks.isEmpty) {
      supportNetworks = [.visa, .masterCard, .amex, .JCB]
    }
    
    // Setup merchant
    merchant = TPDMerchant()
    merchant.applePayMerchantIdentifier = merchantId
    merchant.merchantName = merchantName
    merchant.merchantCapability = .capability3DS
    merchant.supportedNetworks = supportNetworks
    
    // Setup consumer
    consumer = TPDConsumer()
    consumer.requiredBillingAddressFields = (isBillingAddressRequired ?? false) ? [.postalAddress]: []
    consumer.requiredShippingAddressFields = []
    if (isConsumerNameRequired ?? false) {
      consumer.requiredShippingAddressFields.insert(.name)
    }
    if (isPhoneNumberRequired ?? false) {
      consumer.requiredShippingAddressFields.insert(.phone)
    }
    if (isEmailRequired ?? false) {
      consumer.requiredShippingAddressFields.insert(.email)
    }
    
    if (TPDApplePay.canMakePayments(usingNetworks: merchant.supportedNetworks)) {
      isApplePayAvailable = true
      onApplePayCheck?(TapPaySdkCommonResult(success: true, message: "Apple Pay is available."))
    } else {
      isApplePayAvailable = false
      onApplePayCheck?(TapPaySdkCommonResult(success: false, message: "Apple Pay is not available."))
    }
  }
  
  func requestApplePay(
    cartItems: [[String: Any]]? = nil,
    currencyCode: String? = nil,
    countryCode: String? = nil,
    isAmountPending: Bool? = false,
    isShowTotalAmount: Bool? = true,
    onApplePayResult: AppPayHandlerPaymentCallback?
  ) {
    if (isPaymentProcessing) {
      onApplePayResult?(ApplePayPaymentResult(success: false, status: nil, message: "Previous payment is still processing.", prime: nil))
      return
    }
    
    if (!isApplePayAvailable) {
      print("Apple Pay is not available. Please check if the device supports Apple Pay. Or initApplePay() first.")
      onApplePayResult?(ApplePayPaymentResult(success: false, status: nil, message: "Apple Pay is not available", prime: nil))
      return
    }
    
    if (cartItems == nil || currencyCode == nil || countryCode == nil) {
      onApplePayResult?(ApplePayPaymentResult(success: false, status: nil, message: "Missing required parameters for \"requestApplePay\" method.", prime: nil))
      return
    }
    
    let items = cartItems?.compactMap { CartItem.fromDictionary($0) } ?? []
    if (items.isEmpty) {
      onApplePayResult?(ApplePayPaymentResult(success: false, status: nil, message: "Missing required parameters \"cartItems\" for \"requestApplePay\" method.", prime: nil))
      return
    }
    
    self.onApplePayResult = onApplePayResult
    
    // Setup country code and currency code
    merchant.countryCode = countryCode
    merchant.currencyCode = currencyCode
    
    // Setup cart
    cart = TPDCart()
    cart.isAmountPending = false
    cart.isShowTotalAmount = true
    
    // Add payment items
    for item in items {
      let paymentItem = TPDPaymentItem(itemName: item.name, withAmount: NSDecimalNumber(string: String(item.price)), withIsVisible: true)
      cart.add(paymentItem)
    }
    
    applePay = TPDApplePay.setupWthMerchant(merchant, with: consumer, with: cart, withDelegate: self)
    applePay.startPayment()
  }
  
  func applePayResult(result: Bool) -> TapPaySdkCommonResult {
    if (!isPaymentProcessing) {
      return TapPaySdkCommonResult(success: false, message: "No payment is processing.")
    }
    applePay.showPaymentResult(result)
    return TapPaySdkCommonResult(success: true, message: nil)
  }
  
  private func convertCardTypes(cardTypes: [String]?) -> [PKPaymentNetwork] {
    return cardTypes?.compactMap { mapCardType(cardTypeString: $0) } ?? []
  }
  
  private func mapCardType(cardTypeString: String) -> PKPaymentNetwork? {
    switch cardTypeString {
    case "visa":
      return .visa
    case "masterCard":
      return .masterCard
    case "amex":
      return .amex
    case "jcb":
      return .JCB
    default:
      return nil
    }
  }
}


extension ApplePayHandler : TPDApplePayDelegate {
  
  func tpdApplePay(_ applePay: TPDApplePay!, didReceivePrime prime: String!, withExpiryMillis expiryMillis: Int, with cardInfo: TPDCardInfo!, withMerchantReferenceInfo merchantReferenceInfo: [AnyHashable : Any]!) {
    print("Apple Pay did receive prime: \(prime ?? "")")
    onApplePayResult?(ApplePayPaymentResult(success: true, status: nil, message: "Apple Pay payment was successful.", prime: prime))
  }
  
  func tpdApplePay(_ applePay: TPDApplePay!, didSuccessPayment result: TPDTransactionResult!) {
    print("Apple Pay did success payment: \(result.status)")
  }
  
  func tpdApplePay(_ applePay: TPDApplePay!, didFailurePayment result: TPDTransactionResult!) {
    print("Apple Pay did failure payment: \(result.status), message: \(result.message ?? "")")
  }
  
  func tpdApplePayDidCancelPayment(_ applePay: TPDApplePay!) {
    onApplePayResult?(ApplePayPaymentResult(success: false, status: nil, message: "Apple Pay payment was canceled.", prime: nil))
  }
  
  func tpdApplePayDidStartPayment(_ applePay: TPDApplePay!) {
    print("Apple Pay did start payment")
    isPaymentProcessing = true
  }
  
  func tpdApplePayDidFinishPayment(_ applePay: TPDApplePay!) {
    print("Apple Pay did finish payment")
    isPaymentProcessing = false
//    onApplePayResult = nil
  }
  
}
