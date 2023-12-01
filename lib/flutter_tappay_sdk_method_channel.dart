import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_tappay_sdk_platform_interface.dart';

/// An implementation of [FlutterTapPaySdkPlatform] that uses method channels.
class MethodChannelFlutterTapPaySdk extends FlutterTapPaySdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_tappay_sdk');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
