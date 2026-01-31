import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'src/models/vonage_publisher_settings.dart';
import 'src/models/vonage_session_event.dart';
import 'src/models/vonage_session_options.dart';
import 'vonage_video_flutter_method_channel.dart';

abstract class VonageVideoFlutterPlatform extends PlatformInterface {
  /// Constructs a VonageVideoFlutterPlatform.
  VonageVideoFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static VonageVideoFlutterPlatform _instance = MethodChannelVonageVideoFlutter();

  /// The default instance of [VonageVideoFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelVonageVideoFlutter].
  static VonageVideoFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VonageVideoFlutterPlatform] when
  /// they register themselves.
  static set instance(VonageVideoFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Session Methods

  /// Create and connect to a session
  Future<void> connect(VonageSessionOptions options) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  /// Disconnect from the current session
  Future<void> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  /// Send a signal to the session
  Future<void> sendSignal({
    required String type,
    String? data,
    String? connectionId,
  }) {
    throw UnimplementedError('sendSignal() has not been implemented.');
  }

  // Publisher Methods

  /// Initialize the publisher with settings
  Future<void> initPublisher(VonagePublisherSettings settings) {
    throw UnimplementedError('initPublisher() has not been implemented.');
  }

  /// Publish the local stream to the session
  Future<void> publish() {
    throw UnimplementedError('publish() has not been implemented.');
  }

  /// Unpublish the local stream
  Future<void> unpublish() {
    throw UnimplementedError('unpublish() has not been implemented.');
  }

  /// Toggle audio publishing
  Future<void> setPublishAudio(bool enabled) {
    throw UnimplementedError('setPublishAudio() has not been implemented.');
  }

  /// Toggle video publishing
  Future<void> setPublishVideo(bool enabled) {
    throw UnimplementedError('setPublishVideo() has not been implemented.');
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() {
    throw UnimplementedError('switchCamera() has not been implemented.');
  }

  // Subscriber Methods

  /// Subscribe to a stream
  Future<void> subscribe(String streamId) {
    throw UnimplementedError('subscribe() has not been implemented.');
  }

  /// Unsubscribe from a stream
  Future<void> unsubscribe(String streamId) {
    throw UnimplementedError('unsubscribe() has not been implemented.');
  }

  /// Toggle audio for a subscriber
  Future<void> setSubscribeToAudio(String streamId, bool enabled) {
    throw UnimplementedError('setSubscribeToAudio() has not been implemented.');
  }

  /// Toggle video for a subscriber
  Future<void> setSubscribeToVideo(String streamId, bool enabled) {
    throw UnimplementedError('setSubscribeToVideo() has not been implemented.');
  }

  // Event Stream

  /// Stream of session events
  Stream<VonageSessionEvent> get sessionEvents {
    throw UnimplementedError('sessionEvents has not been implemented.');
  }
}
