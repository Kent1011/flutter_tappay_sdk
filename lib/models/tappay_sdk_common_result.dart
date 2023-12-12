// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TapPaySdkCommonResult {
  TapPaySdkCommonResult({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;

  TapPaySdkCommonResult copyWith({
    bool? success,
    String? message,
  }) {
    return TapPaySdkCommonResult(
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

  factory TapPaySdkCommonResult.fromMap(Map<String, dynamic> map) {
    return TapPaySdkCommonResult(
      success: map['success'] as bool,
      message: map['message'] != null ? map['message'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TapPaySdkCommonResult.fromJson(String source) =>
      TapPaySdkCommonResult.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TapPaySdkCommonResult(success: $success, message: $message)';

  @override
  bool operator ==(covariant TapPaySdkCommonResult other) {
    if (identical(this, other)) return true;

    return other.success == success && other.message == message;
  }

  @override
  int get hashCode => success.hashCode ^ message.hashCode;
}
