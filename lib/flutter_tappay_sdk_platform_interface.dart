import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_tappay_sdk_method_channel.dart';
import 'models/initialization_tappay_result.dart';
import 'models/tappay_prime.dart';

/// The interface that implementations of flutter_tappay_sdk must implement.
abstract class FlutterTapPaySdkPlatform extends PlatformInterface {
  FlutterTapPaySdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTapPaySdkPlatform _instance = MethodChannelFlutterTapPaySdk();

  static FlutterTapPaySdkPlatform get instance => _instance;

  static set instance(FlutterTapPaySdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// To get the native SDK version
  ///
  /// This information is different from the Flutter plugin version.
  /// It is the version of the TapPay's native SDK that the this plugin is using
  ///
  /// return [String] with the native SDK version
  /// return [null] if the native SDK version is not available
  ///
  Future<String?> get tapPaySdkVersion;

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
  });

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
  });

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
  });
}
