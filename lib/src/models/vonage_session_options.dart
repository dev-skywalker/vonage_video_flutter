/// Options for creating a Vonage Video session
class VonageSessionOptions {
  /// The API key for your Vonage Video API project
  final String apiKey;

  /// The session ID for the session
  final String sessionId;

  /// The token for authenticating to the session
  final String token;

  const VonageSessionOptions({
    required this.apiKey,
    required this.sessionId,
    required this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'apiKey': apiKey,
      'sessionId': sessionId,
      'token': token,
    };
  }
}
