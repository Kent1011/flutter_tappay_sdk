//
//  ApplePayPaymentResult.swift
//  flutter_tappay_sdk
//
//  Created by Kent C on 2023/12/13.
//

struct ApplePayPaymentResult {
  var success: Bool
  var status: Int?
  var message: String
  var prime: String
  
  init(success: Bool, status: Int?, message: String?, prime: String?) {
    self.success = success
    self.status = status
    self.message = message ?? ""
    self.prime = prime ?? ""
  }
  
  func toDictionary() -> [String: Any?] {
    let result: [String: Any?] = ["success": success, "status": status, "message": message, "prime": prime]
    return result
  }
}
