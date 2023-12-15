#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_tappay_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_tappay_sdk'
  s.version          = '0.3.0'
  s.summary          = 'A Flutter plugin for TapPay SDK.'
  s.description      = <<-DESC
A Flutter plugin for TapPay SDK.
                       DESC
  s.homepage         = 'https://github.com/Kent1011/flutter_tappay_sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Kent Chien' => 'kent1011@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '11.0'

  s.vendored_frameworks = 'TPDirect.xcframework'
  s.resources = 'TPDirectResource/**/*'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
