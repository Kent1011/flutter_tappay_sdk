// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// Model for the result of initializing TapPay SDK
///
class InitializationTapPayResult {
  InitializationTapPayResult({
    required this.success,
    this.message,
  });

  /// The result of initializing TapPay SDK
  ///
  final bool success;

  /// The failure message of initializing TapPay SDK
  ///
  final String? message;

  InitializationTapPayResult copyWith({
    bool? success,
    String? message,
  }) {
    return InitializationTapPayResult(
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'message': message,
    };
  }

  factory InitializationTapPayResult.fromMap(Map<String, dynamic> map) {
    return InitializationTapPayResult(
      success: map['success'] as bool,
      message: map['message'] != null ? map['message'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory InitializationTapPayResult.fromJson(String source) =>
      InitializationTapPayResult.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'InitializationTapPayResult(success: $success, message: $message)';

  @override
  bool operator ==(covariant InitializationTapPayResult other) {
    if (identical(this, other)) return true;

    return other.success == success && other.message == message;
  }

  @override
  int get hashCode => success.hashCode ^ message.hashCode;
}
