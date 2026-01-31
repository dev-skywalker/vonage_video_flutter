import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'src/models/vonage_publisher_settings.dart';
import 'src/models/vonage_session_event.dart';
import 'src/models/vonage_session_options.dart';
import 'vonage_video_flutter_platform_interface.dart';

/// An implementation of [VonageVideoFlutterPlatform] that uses method channels.
class MethodChannelVonageVideoFlutter extends VonageVideoFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vonage_video_flutter');

  /// The event channel for session events
  @visibleForTesting
  final eventChannel = const EventChannel('vonage_video_flutter/events');

  Stream<VonageSessionEvent>? _sessionEventsStream;

  @override
  Stream<VonageSessionEvent> get sessionEvents {
    _sessionEventsStream ??= eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => VonageSessionEvent.fromMap(event as Map<dynamic, dynamic>));
    return _sessionEventsStream!;
  }

  // Session Methods

  @override
  Future<void> connect(VonageSessionOptions options) async {
    await methodChannel.invokeMethod<void>('connect', options.toMap());
  }

  @override
  Future<void> disconnect() async {
    await methodChannel.invokeMethod<void>('disconnect');
  }

  @override
  Future<void> sendSignal({
    required String type,
    String? data,
    String? connectionId,
  }) async {
    await methodChannel.invokeMethod<void>('sendSignal', {
      'type': type,
      'data': data,
      'connectionId': connectionId,
    });
  }

  // Publisher Methods

  @override
  Future<void> initPublisher(VonagePublisherSettings settings) async {
    await methodChannel.invokeMethod<void>('initPublisher', settings.toMap());
  }

  @override
  Future<void> publish() async {
    await methodChannel.invokeMethod<void>('publish');
  }

  @override
  Future<void> unpublish() async {
    await methodChannel.invokeMethod<void>('unpublish');
  }

  @override
  Future<void> setPublishAudio(bool enabled) async {
    await methodChannel.invokeMethod<void>('setPublishAudio', {'enabled': enabled});
  }

  @override
  Future<void> setPublishVideo(bool enabled) async {
    await methodChannel.invokeMethod<void>('setPublishVideo', {'enabled': enabled});
  }

  @override
  Future<void> switchCamera() async {
    await methodChannel.invokeMethod<void>('switchCamera');
  }

  // Subscriber Methods

  @override
  Future<void> subscribe(String streamId) async {
    await methodChannel.invokeMethod<void>('subscribe', {'streamId': streamId});
  }

  @override
  Future<void> unsubscribe(String streamId) async {
    await methodChannel.invokeMethod<void>('unsubscribe', {'streamId': streamId});
  }

  @override
  Future<void> setSubscribeToAudio(String streamId, bool enabled) async {
    await methodChannel.invokeMethod<void>('setSubscribeToAudio', {
      'streamId': streamId,
      'enabled': enabled,
    });
  }

  @override
  Future<void> setSubscribeToVideo(String streamId, bool enabled) async {
    await methodChannel.invokeMethod<void>('setSubscribeToVideo', {
      'streamId': streamId,
      'enabled': enabled,
    });
  }
}
