/// Represents an error from the Vonage Video API
class VonageError {
  /// The error code
  final String code;

  /// The error message
  final String message;

  const VonageError({
    required this.code,
    required this.message,
  });

  factory VonageError.fromMap(Map<dynamic, dynamic> map) {
    return VonageError(
      code: map['code'] as String,
      message: map['message'] as String,
    );
  }

  @override
  String toString() => 'VonageError(code: $code, message: $message)';
}
