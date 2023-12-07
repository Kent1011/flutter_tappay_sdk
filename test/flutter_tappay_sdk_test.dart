// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_tappay_sdk/flutter_tappay_sdk.dart';
// import 'package:flutter_tappay_sdk/flutter_tappay_sdk_platform_interface.dart';
// import 'package:flutter_tappay_sdk/flutter_tappay_sdk_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockFlutterTappaySdkPlatform
//     with MockPlatformInterfaceMixin
//     implements FlutterTapPaySdkPlatform {
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final FlutterTapPaySdkPlatform initialPlatform =
//       FlutterTapPaySdkPlatform.instance;

//   test('$MethodChannelFlutterTapPaySdk is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelFlutterTapPaySdk>());
//   });

//   test('getPlatformVersion', () async {
//     FlutterTapPaySdk flutterTappaySdkPlugin = FlutterTapPaySdk();
//     MockFlutterTappaySdkPlatform fakePlatform = MockFlutterTappaySdkPlatform();
//     FlutterTapPaySdkPlatform.instance = fakePlatform;

//     expect(await flutterTappaySdkPlugin.getPlatformVersion(), '42');
//   });
// }
