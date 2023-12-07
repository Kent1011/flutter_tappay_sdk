// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// Model for getting card's prime
///
class TapPayPrime {
  TapPayPrime({
    required this.success,
    this.status,
    this.message,
    this.prime,
  });

  /// The result of getting card's prime
  ///
  final bool success;

  /// Failure status code of getting card's prime
  ///
  final int? status;

  /// Failure message of getting card's prime
  ///
  final String? message;

  /// The prime of the card
  ///
  final String? prime;

  TapPayPrime copyWith({
    bool? success,
    int? status,
    String? message,
    String? prime,
  }) {
    return TapPayPrime(
      success: success ?? this.success,
      status: status ?? this.status,
      message: message ?? this.message,
      prime: prime ?? this.prime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'success': success,
      'status': status,
      'message': message,
      'prime': prime,
    };
  }

  factory TapPayPrime.fromMap(Map<String, dynamic> map) {
    return TapPayPrime(
      success: map['success'] as bool,
      status: map['status'] != null ? map['status'] as int : null,
      message: map['message'] != null ? map['message'] as String : null,
      prime: map['prime'] != null ? map['prime'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory TapPayPrime.fromJson(String source) =>
      TapPayPrime.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TapPayPrime(success: $success, status: $status, message: $message, prime: $prime)';
  }

  @override
  bool operator ==(covariant TapPayPrime other) {
    if (identical(this, other)) return true;

    return other.success == success &&
        other.status == status &&
        other.message == message &&
        other.prime == prime;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        status.hashCode ^
        message.hashCode ^
        prime.hashCode;
  }
}
