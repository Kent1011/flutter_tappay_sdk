// Issuing organization
enum TapPayCardType {
  visa,
  masterCard,
  jcb,
  americanExpress,
  unionPay;

  String get name {
    switch (this) {
      case TapPayCardType.visa:
        return 'visa';
      case TapPayCardType.masterCard:
        return 'masterCard';
      case TapPayCardType.jcb:
        return 'jcb';
      case TapPayCardType.americanExpress:
        return 'amex';
      case TapPayCardType.unionPay:
        return 'unionPay';
    }
  }
}

/// Default allowed card types
const kDefaultTapPayAllowedCardTypes = [
  TapPayCardType.visa,
  TapPayCardType.masterCard,
  TapPayCardType.jcb,
  TapPayCardType.americanExpress,
];
