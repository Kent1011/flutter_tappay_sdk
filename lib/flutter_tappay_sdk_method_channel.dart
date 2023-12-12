import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_tappay_sdk_platform_interface.dart';
import 'models/tappay_init_result.dart';
import 'models/tappay_sdk_common_result.dart';
import 'models/tappay_prime.dart';
import 'tappay/auth_methods.dart';
import 'tappay/card_type.dart';

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
  Future<TapPayInitResult?> initTapPay({
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
      return TapPayInitResult(
          success: false,
          message:
              "Encountered an unknown error when initializing TapPay payment instance.");
    } else {
      return TapPayInitResult.fromMap(Map<String, dynamic>.from(initResult));
    }
  }

  @override
  Future<bool> isCardValid({
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
          message:
              "Encountered an unidentified error while creating a TapPay payment token.");
    } else {
      return TapPayPrime.fromMap(Map<String, dynamic>.from(result));
    }
  }

  @override
  Future<TapPaySdkCommonResult?> initGooglePay({
    required String merchantName,
    List<TapPayCardAuthMethod>? allowedAuthMethods =
        kDefaultTapPayAllowedCardAuthMethods,
    List<TapPayCardType>? allowedCardTypes = kDefaultTapPayAllowedCardTypes,
    bool? isPhoneNumberRequired = false,
    bool? isEmailRequired = false,
    bool? isBillingAddressRequired = false,
  }) async {
    final result = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('initGooglePay', {
      'merchantName': merchantName,
      'authMethods': allowedAuthMethods
              ?.map((TapPayCardAuthMethod authMethod) => authMethod.name)
              .toList() ??
          kDefaultTapPayAllowedCardAuthMethods
              .map((TapPayCardAuthMethod authMethod) => authMethod.name)
              .toList(),
      'cardTypes': allowedCardTypes
              ?.map((TapPayCardType cardType) => cardType.name)
              .toList() ??
          kDefaultTapPayAllowedCardTypes
              .map((TapPayCardType cardType) => cardType.name)
              .toList(),
      'isPhoneNumberRequired': isPhoneNumberRequired,
      'isEmailRequired': isEmailRequired,
      'isBillingAddressRequired': isBillingAddressRequired,
    });

    if (result == null) {
      return TapPaySdkCommonResult(
          success: false,
          message:
              "Encountered an unidentified error while checking if Google Pay is available.");
    } else {
      return TapPaySdkCommonResult.fromMap(Map<String, dynamic>.from(result));
    }
  }

  @override
  Future<TapPayPrime?> requestGooglePay({
    required double price,
    required String currencyCode,
  }) async {
    if (Platform.isAndroid == false) {
      return TapPayPrime(
          success: false,
          message: "Google Pay is only available on Android devices.");
    }

    final result = await methodChannel
        .invokeMethod<Map<Object?, Object?>>('requestGooglePay', {
      'price': price,
      'currencyCode': currencyCode,
    });

    if (result == null) {
      return TapPayPrime(
          success: false,
          message:
              "Encountered an unidentified error while requesting Google Pay.");
    } else {
      return TapPayPrime.fromMap(Map<String, dynamic>.from(result));
    }
  }
}
