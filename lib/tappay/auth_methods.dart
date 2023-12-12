enum TapPayCardAuthMethod {
  // For typical credit card transactions, it is possible to accept credit cards stored in the cloud, including those available on Google Play.
  panOnly,

  // Token card transactions can only accept token cards stored on mobile devices (e.g., Google Pay).
  cryptogram3DS;

  String get name {
    switch (this) {
      case TapPayCardAuthMethod.panOnly:
        return 'panOnly';
      case TapPayCardAuthMethod.cryptogram3DS:
        return 'cryptogram3DS';
    }
  }
}

const kDefaultTapPayAllowedCardAuthMethods = [
  TapPayCardAuthMethod.panOnly,
  TapPayCardAuthMethod.cryptogram3DS
];
