//
//  CartItem.swift
//  flutter_tappay_sdk
//
//  Created by Kent C on 2023/12/13.
//

struct CartItem {
  var name: String
  var price: Double
  
  init(name: String, price: Double) {
    self.name = name
    self.price = price
  }
  
  func toDictionary() -> [String: Any] {
    return [
      "name": name,
      "price": price
    ]
  }
  
  static func fromDictionary(_ dictionary: [String: Any]) -> CartItem? {
    guard let name = dictionary["name"] as? String,
          let price = dictionary["price"] as? Double else {
      return nil
    }
    
    return CartItem(name: name, price: price)
  }
}
