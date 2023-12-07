import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_tappay_sdk_platform_interface.dart';
import 'models/initialization_tappay_result.dart';
import 'models/tappay_prime.dart';

/// An implementation of [FlutterTapPaySdkPlatform] that uses method channels.
class MethodChannelFlutterTapPaySdk extends FlutterTapPaySdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_tappay_sdk');

  @override
  Future<String?> get tapPaySdkVersion async {
    final sdkVersion = await methodChannel.invokeMethod<String>('sdkVersion');
    return sdkVersion;
  }

  @override
  Future<InitializationTapPayResult?> initTapPay({
    required int appId,
    required String appKey,
    bool isSandbox = false,
  }) async {
    var initResult = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'initPayment',
      <String, dynamic>{
        'appId': appId,
        'appKey': appKey,
        'isSandbox': isSandbox,
      },
    );

    if (initResult == null) {
      return InitializationTapPayResult(
          success: false,
          message:
              "Encountered an unknown error when initializing TapPay payment instance.");
    } else {
      return InitializationTapPayResult.fromMap(
          Map<String, dynamic>.from(initResult));
    }
  }

  @override
  Future<bool?> isCardValid({
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String cvv,
  }) async {
    final result = await methodChannel.invokeMethod<bool>('isValidCard', {
      'cardNumber': cardNumber,
      'mm': dueMonth,
      'yy': dueYear,
      'cvv': cvv,
    });

    return result ?? false;
  }

  @override
  Future<TapPayPrime?> getCardPrime({
    required String cardNumber,
    required String dueMonth,
    required String dueYear,
    required String cvv,
  }) async {
    final result = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('getPrimeByCardInfo', {
      'cardNumber': cardNumber,
      'mm': dueMonth,
      'yy': dueYear,
      'cvv': cvv,
    });

    if (result == null) {
      return TapPayPrime(
          success: false,
          message: "Unknown error when create a TapPay payment token.");
    } else {
      return TapPayPrime.fromMap(Map<String, dynamic>.from(result));
    }
  }
}
