import 'package:flutter_tappay_sdk/models/tappay_prime.dart';

import 'flutter_tappay_sdk_platform_interface.dart';
import 'models/initialization_tappay_result.dart';

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
  /// return [InitializationTapPayResult] with value [success] as [true] if success
  /// return [InitializationTapPayResult] with value [success] as [false] if fail
  /// return [InitializationTapPayResult] with value [message] as [String] if fail
  /// return [null] if the initialization is incomplete
  ///
  Future<InitializationTapPayResult?> initTapPay({
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
  /// return [null] if the card information is incomplete
  ///
  Future<bool?> isCardValid({
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
}
