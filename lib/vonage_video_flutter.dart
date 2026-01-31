library vonage_video_flutter;

export 'src/models/vonage_error.dart';
export 'src/models/vonage_publisher_settings.dart';
export 'src/models/vonage_session_event.dart';
export 'src/models/vonage_session_options.dart';
export 'src/models/vonage_stream.dart';
export 'src/widgets/vonage_publisher_view.dart';
export 'src/widgets/vonage_subscriber_view.dart';
export 'vonage_video_flutter_platform_interface.dart';

import 'src/models/vonage_publisher_settings.dart';
import 'src/models/vonage_session_event.dart';
import 'src/models/vonage_session_options.dart';
import 'vonage_video_flutter_platform_interface.dart';

/// Main class for interacting with Vonage Video API
class VonageVideoFlutter {
  /// Stream of session events
  Stream<VonageSessionEvent> get sessionEvents =>
      VonageVideoFlutterPlatform.instance.sessionEvents;

  // Session Methods

  /// Connect to a Vonage Video session
  Future<void> connect(VonageSessionOptions options) {
    return VonageVideoFlutterPlatform.instance.connect(options);
  }

  /// Disconnect from the current session
  Future<void> disconnect() {
    return VonageVideoFlutterPlatform.instance.disconnect();
  }

  /// Send a signal to the session
  Future<void> sendSignal({
    required String type,
    String? data,
    String? connectionId,
  }) {
    return VonageVideoFlutterPlatform.instance.sendSignal(
      type: type,
      data: data,
      connectionId: connectionId,
    );
  }

  // Publisher Methods

  /// Initialize the publisher with settings
  Future<void> initPublisher(VonagePublisherSettings settings) {
    return VonageVideoFlutterPlatform.instance.initPublisher(settings);
  }

  /// Publish the local stream to the session
  Future<void> publish() {
    return VonageVideoFlutterPlatform.instance.publish();
  }

  /// Unpublish the local stream
  Future<void> unpublish() {
    return VonageVideoFlutterPlatform.instance.unpublish();
  }

  /// Toggle audio publishing
  Future<void> setPublishAudio(bool enabled) {
    return VonageVideoFlutterPlatform.instance.setPublishAudio(enabled);
  }

  /// Toggle video publishing
  Future<void> setPublishVideo(bool enabled) {
    return VonageVideoFlutterPlatform.instance.setPublishVideo(enabled);
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() {
    return VonageVideoFlutterPlatform.instance.switchCamera();
  }

  // Subscriber Methods

  /// Subscribe to a stream
  Future<void> subscribe(String streamId) {
    return VonageVideoFlutterPlatform.instance.subscribe(streamId);
  }

  /// Unsubscribe from a stream
  Future<void> unsubscribe(String streamId) {
    return VonageVideoFlutterPlatform.instance.unsubscribe(streamId);
  }

  /// Toggle audio for a subscriber
  Future<void> setSubscribeToAudio(String streamId, bool enabled) {
    return VonageVideoFlutterPlatform.instance.setSubscribeToAudio(streamId, enabled);
  }

  /// Toggle video for a subscriber
  Future<void> setSubscribeToVideo(String streamId, bool enabled) {
    return VonageVideoFlutterPlatform.instance.setSubscribeToVideo(streamId, enabled);
  }
}
