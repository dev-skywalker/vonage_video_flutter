/// Represents a stream in a Vonage Video session
class VonageStream {
  /// The unique ID of the stream
  final String streamId;

  /// The name of the stream
  final String? name;

  /// Whether the stream has audio
  final bool hasAudio;

  /// Whether the stream has video
  final bool hasVideo;

  /// The connection ID of the client publishing the stream
  final String? connectionId;

  /// The creation time of the stream
  final int creationTime;

  const VonageStream({
    required this.streamId,
    this.name,
    required this.hasAudio,
    required this.hasVideo,
    this.connectionId,
    required this.creationTime,
  });

  factory VonageStream.fromMap(Map<dynamic, dynamic> map) {
    return VonageStream(
      streamId: map['streamId'] as String,
      name: map['name'] as String?,
      hasAudio: map['hasAudio'] as bool,
      hasVideo: map['hasVideo'] as bool,
      connectionId: map['connectionId'] as String?,
      creationTime: map['creationTime'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'streamId': streamId,
      'name': name,
      'hasAudio': hasAudio,
      'hasVideo': hasVideo,
      'connectionId': connectionId,
      'creationTime': creationTime,
    };
  }
}
