/// Settings for configuring a publisher
class VonagePublisherSettings {
  /// The name of the publisher stream
  final String? name;

  /// Whether to publish audio
  final bool publishAudio;

  /// Whether to publish video
  final bool publishVideo;

  /// The camera position (front or back)
  final CameraPosition cameraPosition;

  /// Video resolution
  final VideoResolution resolution;

  /// Video frame rate
  final VideoFrameRate frameRate;

  const VonagePublisherSettings({
    this.name,
    this.publishAudio = true,
    this.publishVideo = true,
    this.cameraPosition = CameraPosition.front,
    this.resolution = VideoResolution.medium,
    this.frameRate = VideoFrameRate.fps30,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'publishAudio': publishAudio,
      'publishVideo': publishVideo,
      'cameraPosition': cameraPosition.name,
      'resolution': resolution.name,
      'frameRate': frameRate.value,
    };
  }
}

enum CameraPosition {
  front,
  back,
}

enum VideoResolution {
  low,
  medium,
  high,
}

enum VideoFrameRate {
  fps1(1),
  fps7(7),
  fps15(15),
  fps30(30);

  const VideoFrameRate(this.value);
  final int value;
}
