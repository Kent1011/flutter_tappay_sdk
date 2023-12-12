import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_tappay_sdk/flutter_tappay_sdk.dart';

import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _tapPaySdk = FlutterTapPaySdk();

  String _tapPaySdkVersion = 'Unknown';
  bool _isTapPayReady = false;

  @override
  void initState() {
    super.initState();
    initTapPay();
  }

  Future<void> initTapPay() async {
    String tapPaySdkVersion = 'Unknown';
    bool isTapPayReady = false;

    try {
      var initResult = await _tapPaySdk.initTapPay(
          appId: kTapPayAppId, appKey: kTapPayAppKey, isSandbox: true);
      log(initResult?.toJson() ?? 'no initResult');
      isTapPayReady = initResult?.success == true;

      if (isTapPayReady) {
        tapPaySdkVersion =
            await _tapPaySdk.tapPaySdkVersion ?? 'Unknown TapPay SDK version';
      }
    } on PlatformException {
      log('PlatformException');
    }

    if (!mounted) return;

    setState(() {
      _tapPaySdkVersion = tapPaySdkVersion;
      _isTapPayReady = isTapPayReady;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter TapPay SDK Example'),
        ),
        body: ListView(
          children: [
            Text('TapPay SDK initial result: $_isTapPayReady'),

            // show the TapPay SDK version
            Text('TapPay SDK version: $_tapPaySdkVersion'),

            // Get the prime with the payment card information
            if (_isTapPayReady)
              ListTile(
                title: const Text('Get Prime by Payment Card'),
                onTap: () async {
                  try {
                    final prime = await _tapPaySdk.getCardPrime(
                      cardNumber: kDefaultTestingCardNumber,
                      dueMonth: kDefaultTestingDueMonth,
                      dueYear: kDefaultTestingDueYear,
                      cvv: kDefaultTestingCvv,
                    );
                    log('prime: ${prime?.toJson()}');
                  } on PlatformException {
                    log('PlatformException');
                  }
                },
              ),

            if (_isTapPayReady)
              ListTile(
                title: const Text('Start Google Pay'),
                onTap: () async {
                  try {
                    final isGooglePayReady = await _tapPaySdk.initGooglePay(
                        merchantName: 'Flutter Cafe');
                    log('isGooglePayReady: ${isGooglePayReady?.toJson()}');

                    if (isGooglePayReady?.success == true) {
                      var payResult =
                          await _tapPaySdk.requestGooglePay(price: 2);
                      log('payResult: ${payResult?.toJson()}');
                    }
                  } on PlatformException {
                    log('PlatformException');
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
