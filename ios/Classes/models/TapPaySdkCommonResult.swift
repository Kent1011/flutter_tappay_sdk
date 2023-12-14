//
//  TapPaySdkCommonResult.swift
//  flutter_tappay_sdk
//
//  Created by Kent C on 2023/12/13.
//

class TapPaySdkCommonResult {
  var success: Bool
  var message: String?
  
  init(success: Bool, message: String?) {
    self.success = success
    self.message = message
  }
  
  func toDictionary() -> [String: Any?] {
    return [
      "success": success,
      "message": message
    ]
  }
}
