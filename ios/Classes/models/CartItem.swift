//
//  CartItem.swift
//  flutter_tappay_sdk
//
//  Created by Kent C on 2023/12/13.
//

struct CartItem {
  var name: String
  var price: Int
  
  init(name: String, price: Int) {
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
          let price = dictionary["price"] as? Int else {
      return nil
    }
    
    return CartItem(name: name, price: price)
  }
}
