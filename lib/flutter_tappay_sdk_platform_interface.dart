import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_tappay_sdk_method_channel.dart';

abstract class FlutterTapPaySdkPlatform extends PlatformInterface {
  /// Constructs a FlutterTappaySdkPlatform.
  FlutterTapPaySdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterTapPaySdkPlatform _instance = MethodChannelFlutterTapPaySdk();

  /// The default instance of [FlutterTapPaySdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterTapPaySdk].
  static FlutterTapPaySdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterTapPaySdkPlatform] when
  /// they register themselves.
  static set instance(FlutterTapPaySdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
