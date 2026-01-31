import 'vonage_error.dart';
import 'vonage_stream.dart';

/// Base class for all session events
abstract class VonageSessionEvent {
  const VonageSessionEvent();

  factory VonageSessionEvent.fromMap(Map<dynamic, dynamic> map) {
    final type = map['type'] as String;

    switch (type) {
      case 'sessionConnected':
        return SessionConnectedEvent();
      case 'sessionDisconnected':
        return SessionDisconnectedEvent();
      case 'streamReceived':
        return StreamReceivedEvent(
          stream: VonageStream.fromMap(map['stream']),
        );
      case 'streamDropped':
        return StreamDroppedEvent(
          stream: VonageStream.fromMap(map['stream']),
        );
      case 'sessionError':
        return SessionErrorEvent(
          error: VonageError.fromMap(map['error']),
        );
      case 'publisherStarted':
        return PublisherStartedEvent();
      case 'publisherStopped':
        return PublisherStoppedEvent();
      case 'publisherError':
        return PublisherErrorEvent(
          error: VonageError.fromMap(map['error']),
        );
      case 'subscriberConnected':
        return SubscriberConnectedEvent(
          streamId: map['streamId'] as String,
        );
      case 'subscriberDisconnected':
        return SubscriberDisconnectedEvent(
          streamId: map['streamId'] as String,
        );
      case 'subscriberError':
        return SubscriberErrorEvent(
          streamId: map['streamId'] as String,
          error: VonageError.fromMap(map['error']),
        );
      default:
        throw UnimplementedError('Unknown event type: $type');
    }
  }
}

/// Event fired when successfully connected to the session
class SessionConnectedEvent extends VonageSessionEvent {}

/// Event fired when disconnected from the session
class SessionDisconnectedEvent extends VonageSessionEvent {}

/// Event fired when a new stream is created in the session
class StreamReceivedEvent extends VonageSessionEvent {
  final VonageStream stream;

  const StreamReceivedEvent({required this.stream});
}

/// Event fired when a stream is destroyed in the session
class StreamDroppedEvent extends VonageSessionEvent {
  final VonageStream stream;

  const StreamDroppedEvent({required this.stream});
}

/// Event fired when a session error occurs
class SessionErrorEvent extends VonageSessionEvent {
  final VonageError error;

  const SessionErrorEvent({required this.error});
}

/// Event fired when publishing starts
class PublisherStartedEvent extends VonageSessionEvent {}

/// Event fired when publishing stops
class PublisherStoppedEvent extends VonageSessionEvent {}

/// Event fired when a publisher error occurs
class PublisherErrorEvent extends VonageSessionEvent {
  final VonageError error;

  const PublisherErrorEvent({required this.error});
}

/// Event fired when a subscriber connects
class SubscriberConnectedEvent extends VonageSessionEvent {
  final String streamId;

  const SubscriberConnectedEvent({required this.streamId});
}

/// Event fired when a subscriber disconnects
class SubscriberDisconnectedEvent extends VonageSessionEvent {
  final String streamId;

  const SubscriberDisconnectedEvent({required this.streamId});
}

/// Event fired when a subscriber error occurs
class SubscriberErrorEvent extends VonageSessionEvent {
  final String streamId;
  final VonageError error;

  const SubscriberErrorEvent({
    required this.streamId,
    required this.error,
  });
}
