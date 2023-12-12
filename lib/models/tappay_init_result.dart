// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// Model for the result of initializing TapPay SDK
///
class TapPayInitResult {
  TapPayInitResult({
    required this.success,
    this.message,
  });

  /// The result of initializing TapPay SDK
  ///
  final bool success;

  /// The failure message of initializing TapPay SDK
  ///
  final String? message;

  TapPayInitResult copyWith({
    bool? success,
    String? message,
  }) {
    return TapPayInitResult(
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

  factory TapPayInitResult.fromMap(Map<String, dynamic> map) {
    return TapPayInitResult(
      success: map['success'] as bool,
      message: map['message'] != null ? map['message'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TapPayInitResult.fromJson(String source) =>
      TapPayInitResult.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'TapPayInitResult(success: $success, message: $message)';

  @override
  bool operator ==(covariant TapPayInitResult other) {
    if (identical(this, other)) return true;

    return other.success == success && other.message == message;
  }

  @override
  int get hashCode => success.hashCode ^ message.hashCode;
}
