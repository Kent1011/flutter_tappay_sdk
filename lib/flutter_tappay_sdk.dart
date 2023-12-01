import 'flutter_tappay_sdk_platform_interface.dart';

class FlutterTappaySdk {
  Future<String?> getPlatformVersion() {
    return FlutterTapPaySdkPlatform.instance.getPlatformVersion();
  }
}
