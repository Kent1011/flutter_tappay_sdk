# Flutter TapPay SDK

This project is a Flutter SDK for [TapPay](https://www.tappaysdk.com/), a popular payment gateway from Taiwan.

**Warning:** This is not an official SDK maintained by TapPay. Since TapPay does not provide an official SDK for Flutter, this project is created to wrap TapPay's official SDK.

## Features

- DirectPay (Get the payment card's prime)
- Apple Pay (Get the prime)
- Google Pay (Get the prime)

## Getting Started

### Android

- In your project's android folder, find AndroidManifest.xml and add the following attributes to the application tag

  ```xml
  <manifest xmlns:android="http://schemas.android.com/apk/res/android"
      xmlns:tools="http://schemas.android.com/tools" --> Don't forget this line
      >
    ...
    <application
        android:label="flutter_tappay_sdk_example"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        tools:replace="android:label" --> Add this line
        ...>
    ...
  ```

2. (Optional. Required if you need to use Google Pay.) In your project's android folder, change the MainActivity's parent class from FlutterActivity to FlutterFragmentActivity

   ```kotlin
   import io.flutter.embedding.android.FlutterFragmentActivity

   class MainActivity: FlutterFragmentActivity() {
       // ...
   }
   ```

### iOS

(Required if you need to use Apple Pay.) Open Xcode and open your project's Runner.xcworkspace file. In the Signing & Capabilities tab, add the Apple Pay capability. And don't forget to add the Apple Pay merchant ID in the capability.

### Dart / Flutter Project

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_tappay_sdk: ^0.3.0
```

## Usage

### DirectPay

```dart
import 'package:flutter_tappay_sdk/flutter_tappay_sdk.dart';

// ...

final tappay = FlutterTappaySdk();
tappay.init(
  appId: 'your app id',
  appKey: 'your app key',
  serverType: ServerType.sandbox, // or ServerType.production
);

// ...

final result = await tappay.getCardPrime(
  cardNumber: '4242424242424242',
  dueMonth: '01',
  dueYear: '23',
  cvv: '123',
);

if (result?.success) {
  print(result?.prime);
} else {
  print(result?.message);
}
```

More examples can be found in the [example](example) folder.
