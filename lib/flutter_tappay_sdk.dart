import 'package:flutter_tappay_sdk/models/tappay_prime.dart';

import 'flutter_tappay_sdk_platform_interface.dart';
import 'models/tappay_init_result.dart';
import 'models/tappay_sdk_common_result.dart';
import 'tappay/auth_methods.dart';
import 'tappay/card_type.dart';
import 'tappay/cart_item.dart';

class FlutterTapPaySdk {
  /// To get the native SDK version
  ///
  /// This information is different from the Flutter plugin version.
  /// It is the version of the TapPay's native SDK that the this plugin is using
  ///
  /// return [String] with the native SDK version
  /// return [null] if the native SDK version is not available
  ///
  Future<String?> get tapPaySdkVersion {
    return FlutterTapPaySdkPlatform.instance.tapPaySdkVersion;
  }

  /// Initialize TapPay payment SDK
  ///
  /// [appId] is the App ID assigned by TapPay
  /// [appKey] is the App Key assigned by TapPay
  /// [isSandbox] is a boolean value to indicate whether to use sandbox mode
  ///
  /// return [TapPayInitResult] with value [success] as [true] if success
  /// return [TapPayInitResult] with value [success] as [false] if fail
  /// return [TapPayInitResult] with value [message] as [String] if fail
  /// return [null] if the initialization is incomplete
  ///
  Future<TapPayInitResult?> initTapPay({
    required int appId,
    required String appKey,
    bool isSandbox = false,
  }) {
    return FlutterTapPaySdkPlatform.instance.initTapPay(
      appId: appId,
      appKey: appKey,
      isSandbox: isSandbox,
    );
  }

  /// Verify card information
  ///
  /// [cardNumber] is the card number
  /// [dueMonth] is the month of the card's expiration date
  /// [dueYear] is the year of the card's expiration date
  /// [cvv] is the card's CVV(Card Verification Value)
  ///
  /// return [bool] with value [true] if the card is valid
  /// return [bool] with value [false] if the card is invalid
  ///
  Future<bool> isCardValid({
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String cvv,
  }) {
    return FlutterTapPaySdkPlatform.instance.isCardValid(
      cardNumber: cardNumber,
      dueMonth: dueMonth,
      dueYear: dueYear,
      cvv: cvv,
    );
  }

  /// Get card's prime
  ///
  /// [cardNumber] is the card number
  /// [dueMonth] is the month of the card's expiration date
  /// [dueYear] is the year of the card's expiration date
  /// [cvv] is the card's CVV(Card Verification Value)
  ///
  /// return [TapPayPrime] with value [success] as [true] if success.
  /// return [TapPayPrime] with value [success] as [false] if fail.
  /// return [TapPayPrime] with value [status] as [int] if fail. (The value of [status] is defined by TapPay.)
  /// return [TapPayPrime] with value [message] as [String] if fail.
  /// return [TapPayPrime] with value [prime] as [String] if success.
  /// return [null] if the card information is incomplete
  ///
  Future<TapPayPrime?> getCardPrime({
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String cvv,
  }) {
    return FlutterTapPaySdkPlatform.instance.getCardPrime(
      cardNumber: cardNumber,
      dueMonth: dueMonth,
      dueYear: dueYear,
      cvv: cvv,
    );
  }

  /// Initialize Google Pay
  ///
  /// [merchantName] is the name of the merchant. (e.g., "Google Pay Merchant")
  /// [allowedAuthMethods] is the list of allowed authentication methods. Default value is [TapPayCardAuthMethod.panOnly] and [TapPayCardAuthMethod.cryptogram3DS]
  /// [allowedCardTypes] is the list of allowed card networks. Default value is [TapPayCardType.visa], [TapPayCardType.masterCard], [TapPayCardType.americanExpress], [TapPayCardType.jcb]
  /// [isPhoneNumberRequired] is a boolean value to indicate whether to require phone number. Default value is [false]
  /// [isEmailRequired] is a boolean value to indicate whether to require email. Default value is [false]
  /// [isBillingAddressRequired] is a boolean value to indicate whether to require billing address. Default value is [false]
  ///
  /// return [GooglePayInitResult] with value [success] as [true] if success.
  /// return [GooglePayInitResult] with value [success] as [false] if fail.
  /// return [GooglePayInitResult] with value [message] as [String] if fail.
  /// return [null] if the initialization is incomplete
  ///
  Future<TapPaySdkCommonResult?> initGooglePay({
    required String merchantName,
    List<TapPayCardAuthMethod>? allowedAuthMethods =
        kDefaultTapPayAllowedCardAuthMethods,
    List<TapPayCardType>? allowedCardTypes = kDefaultTapPayAllowedCardTypes,
    bool? isPhoneNumberRequired = false,
    bool? isEmailRequired = false,
    bool? isBillingAddressRequired = false,
  }) {
    return FlutterTapPaySdkPlatform.instance.initGooglePay(
        merchantName: merchantName,
        allowedAuthMethods: allowedAuthMethods,
        allowedCardTypes: allowedCardTypes,
        isPhoneNumberRequired: isPhoneNumberRequired,
        isEmailRequired: isEmailRequired,
        isBillingAddressRequired: isBillingAddressRequired);
  }

  /// Request Google Pay
  ///
  /// [price] is the price of the transaction
  /// [currencyCode] is the currency code of the transaction. Default value is 'TWD'
  ///
  /// return [TapPayPrime] with value [success] as [true] if success.
  /// return [TapPayPrime] with value [success] as [false] if fail.
  /// return [TapPayPrime] with value [status] as [int] if fail. (The value of [status] is defined by TapPay.)
  /// return [TapPayPrime] with value [message] as [String] if fail.
  /// return [TapPayPrime] with value [prime] as [String] if success.
  /// return [null] if the card information is incomplete
  ///
  Future<TapPayPrime?> requestGooglePay({
    required double price,
    String currencyCode = 'TWD',
  }) {
    return FlutterTapPaySdkPlatform.instance.requestGooglePay(
      price: price,
      currencyCode: currencyCode,
    );
  }

  /// Initialize Apple Pay
  ///
  /// [merchantId] is Apple Pay's merchant ID
  /// [merchantName] is the name of the merchant. (e.g., "Apple Pay Merchant")
  /// [allowedCardTypes] is the list of allowed card networks. Default value is [TapPayCardType.visa], [TapPayCardType.masterCard], [TapPayCardType.americanExpress], [TapPayCardType.jcb]
  /// [isConsumerNameRequired] is a boolean value to indicate whether to require consumer name. Default value is [false]
  /// [isPhoneNumberRequired] is a boolean value to indicate whether to require phone number. Default value is [false]
  /// [isEmailRequired] is a boolean value to indicate whether to require email. Default value is [false]
  /// [isBillingAddressRequired] is a boolean value to indicate whether to require billing address. Default value is [false]
  ///
  /// return [ApplePayInitResult] with value [success] as [true] if success.
  /// return [ApplePayInitResult] with value [success] as [false] if fail.
  /// return [ApplePayInitResult] with value [message] as [String] if fail.
  /// return [null] if the initialization is incomplete
  ///
  Future<TapPaySdkCommonResult?> initApplePay({
    required String merchantId,
    required String merchantName,
    List<TapPayCardType>? allowedCardTypes = kDefaultTapPayAllowedCardTypes,
    bool? isConsumerNameRequired = false,
    bool? isPhoneNumberRequired = false,
    bool? isEmailRequired = false,
    bool? isBillingAddressRequired = false,
  }) {
    return FlutterTapPaySdkPlatform.instance.initApplePay(
      merchantId: merchantId,
      merchantName: merchantName,
      allowedCardTypes: allowedCardTypes,
      isConsumerNameRequired: isConsumerNameRequired,
      isPhoneNumberRequired: isPhoneNumberRequired,
      isEmailRequired: isEmailRequired,
      isBillingAddressRequired: isBillingAddressRequired,
    );
  }

  /// Request Apple Pay
  ///
  /// [cartItems] is the list of payment items
  /// [currencyCode] is the currency code of the transaction. Default value is 'TWD'
  /// [countryCode] is the country code of the transaction. Default value is 'TW'
  ///
  /// return [TapPayPrime] with value [success] as [true] if success.
  /// return [TapPayPrime] with value [success] as [false] if fail.
  /// return [TapPayPrime] with value [status] as [int] if fail. (The value of [status] is defined by TapPay.)
  /// return [TapPayPrime] with value [message] as [String] if fail.
  /// return [TapPayPrime] with value [prime] as [String] if success.
  /// return [null] if the card information is incomplete
  ///
  Future<TapPayPrime?> requestApplePay({
    required List<CartItem> cartItems,
    String currencyCode = 'TWD',
    String countryCode = 'TW',
  }) {
    return FlutterTapPaySdkPlatform.instance.requestApplePay(
      cartItems: cartItems,
      currencyCode: currencyCode,
      countryCode: countryCode,
    );
  }

  /// Report Apple Pay result
  ///
  /// When you send the prime to your server and get the result, you can report the result to TapPay.
  ///
  /// [result] is the result of the transaction.
  ///
  /// return [TapPaySdkCommonResult] with value [success] as [true] if success.
  /// return [TapPaySdkCommonResult] with value [success] as [false] if fail.
  /// return [TapPaySdkCommonResult] with value [message] as [String] if fail.
  ///
  Future<TapPaySdkCommonResult?> applePayResult({required bool result}) {
    return FlutterTapPaySdkPlatform.instance.applePayResult(result: result);
  }
}
