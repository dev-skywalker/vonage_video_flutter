# Vonage Video Flutter Plugin

A comprehensive Flutter plugin for Vonage Video (formerly OpenTok) that provides full access to video call features with native rendering on both Android and iOS.

## Features

- ✅ **Session Management**: Connect and disconnect from Vonage Video sessions
- ✅ **Publisher**: Publish your camera and microphone to the session
- ✅ **Subscriber**: Subscribe to other participants' streams
- ✅ **Native Video Rendering**: Uses PlatformView for optimal performance
- ✅ **Audio/Video Controls**: Toggle audio/video on/off during calls
- ✅ **Camera Switching**: Switch between front and back cameras
- ✅ **Event Streaming**: Real-time events via EventChannel
- ✅ **Signaling**: Send custom signals to other participants
- ✅ **Full API Access**: Access to all Vonage Video SDK features

## Platform Support

| Platform | Minimum Version |
|----------|----------------|
| Android  | API Level 24+ (Android 7.0+) |
| iOS      | iOS 15.0+ |

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  vonage_video_flutter: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Platform Configuration

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />

<uses-feature android:name="android.hardware.camera" android:required="true" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
<uses-feature android:name="android.hardware.microphone" android:required="true" />
```

### iOS

Add the following to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs access to your camera for video calls</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone for audio calls</string>
```

## Usage

### 1. Initialize the Plugin

```dart
import 'package:vonage_video_flutter/vonage_video_flutter.dart';

final vonageVideo = VonageVideoFlutter();
```

### 2. Listen to Session Events

```dart
vonageVideo.sessionEvents.listen((event) {
  if (event is SessionConnectedEvent) {
    print('Connected to session');
  } else if (event is StreamReceivedEvent) {
    print('New stream: ${event.stream.streamId}');
    // Subscribe to the stream
    vonageVideo.subscribe(event.stream.streamId);
  } else if (event is StreamDroppedEvent) {
    print('Stream dropped: ${event.stream.streamId}');
  } else if (event is SessionErrorEvent) {
    print('Session error: ${event.error.message}');
  }
});
```

### 3. Connect to a Session

```dart
await vonageVideo.connect(
  VonageSessionOptions(
    apiKey: 'YOUR_API_KEY',
    sessionId: 'YOUR_SESSION_ID',
    token: 'YOUR_TOKEN',
  ),
);
```

### 4. Initialize and Publish

```dart
// Initialize publisher with settings
await vonageVideo.initPublisher(
  VonagePublisherSettings(
    name: 'My Publisher',
    publishAudio: true,
    publishVideo: true,
    cameraPosition: CameraPosition.front,
    resolution: VideoResolution.medium,
    frameRate: VideoFrameRate.fps30,
  ),
);

// Start publishing
await vonageVideo.publish();
```

### 5. Display Publisher View

```dart
VonagePublisherView(
  onViewCreated: (viewId) {
    print('Publisher view created: $viewId');
  },
)
```

### 6. Subscribe to Remote Streams

```dart
// Subscribe to a stream
await vonageVideo.subscribe(streamId);

// Display subscriber view
VonageSubscriberView(
  streamId: streamId,
  onViewCreated: (viewId) {
    print('Subscriber view created: $viewId');
  },
)
```

### 7. Control Audio and Video

```dart
// Toggle audio
await vonageVideo.setPublishAudio(false); // Mute
await vonageVideo.setPublishAudio(true);  // Unmute

// Toggle video
await vonageVideo.setPublishVideo(false); // Stop video
await vonageVideo.setPublishVideo(true);  // Start video

// Switch camera
await vonageVideo.switchCamera();

// Control subscriber audio/video
await vonageVideo.setSubscribeToAudio(streamId, false);
await vonageVideo.setSubscribeToVideo(streamId, false);
```

### 8. Send Signals

```dart
await vonageVideo.sendSignal(
  type: 'chat',
  data: 'Hello everyone!',
);
```

### 9. Disconnect

```dart
// Unpublish first
await vonageVideo.unpublish();

// Then disconnect
await vonageVideo.disconnect();
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:vonage_video_flutter/vonage_video_flutter.dart';

class VideoCallScreen extends StatefulWidget {
  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _vonageVideo = VonageVideoFlutter();
  final List<String> _streamIds = [];

  @override
  void initState() {
    super.initState();
    _setupVideoCall();
  }

  Future<void> _setupVideoCall() async {
    // Listen to events
    _vonageVideo.sessionEvents.listen((event) {
      if (event is StreamReceivedEvent) {
        setState(() => _streamIds.add(event.stream.streamId));
        _vonageVideo.subscribe(event.stream.streamId);
      } else if (event is StreamDroppedEvent) {
        setState(() => _streamIds.remove(event.stream.streamId));
      }
    });

    // Connect to session
    await _vonageVideo.connect(
      VonageSessionOptions(
        apiKey: 'YOUR_API_KEY',
        sessionId: 'YOUR_SESSION_ID',
        token: 'YOUR_TOKEN',
      ),
    );

    // Initialize and publish
    await _vonageVideo.initPublisher(
      VonagePublisherSettings(
        name: 'Flutter User',
        publishAudio: true,
        publishVideo: true,
      ),
    );
    await _vonageVideo.publish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Call')),
      body: Column(
        children: [
          // Publisher view
          Expanded(
            child: VonagePublisherView(),
          ),
          // Subscribers grid
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: _streamIds.length,
              itemBuilder: (context, index) {
                return VonageSubscriberView(
                  streamId: _streamIds[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _vonageVideo.disconnect();
    super.dispose();
  }
}
```

## API Reference

### Classes

#### `VonageVideoFlutter`
Main class for interacting with the Vonage Video API.

#### `VonageSessionOptions`
Configuration for connecting to a session:
- `apiKey`: Your Vonage API key
- `sessionId`: The session ID to connect to
- `token`: Authentication token

#### `VonagePublisherSettings`
Configuration for the publisher:
- `name`: Stream name (optional)
- `publishAudio`: Enable audio (default: true)
- `publishVideo`: Enable video (default: true)
- `cameraPosition`: Camera position (front/back)
- `resolution`: Video resolution (low/medium/high)
- `frameRate`: Video frame rate (1/7/15/30 fps)

#### `VonageStream`
Represents a stream in the session:
- `streamId`: Unique stream identifier
- `name`: Stream name
- `hasAudio`: Whether stream has audio
- `hasVideo`: Whether stream has video
- `connectionId`: Connection ID of the publisher
- `creationTime`: Stream creation timestamp

### Events

- `SessionConnectedEvent`: Connected to session
- `SessionDisconnectedEvent`: Disconnected from session
- `StreamReceivedEvent`: New stream available
- `StreamDroppedEvent`: Stream removed
- `SessionErrorEvent`: Session error occurred
- `PublisherStartedEvent`: Publishing started
- `PublisherStoppedEvent`: Publishing stopped
- `PublisherErrorEvent`: Publisher error occurred
- `SubscriberConnectedEvent`: Subscribed to stream
- `SubscriberDisconnectedEvent`: Unsubscribed from stream
- `SubscriberErrorEvent`: Subscriber error occurred

### Widgets

#### `VonagePublisherView`
Displays the local publisher's video.

#### `VonageSubscriberView`
Displays a remote subscriber's video.

## Getting Vonage Credentials

1. Sign up for a Vonage Video API account at [tokbox.com](https://tokbox.com/account/user/signup)
2. Create a project to get your API key
3. Generate session IDs and tokens using the Vonage Video API server SDK

## Architecture

This plugin uses:
- **MethodChannel**: For method calls between Flutter and native code
- **EventChannel**: For streaming session events to Flutter
- **PlatformView**: For rendering native video views in Flutter

### Android Implementation
- Uses Vonage Video Android SDK 2.30.0+
- Supports Android 7.0+ (API Level 24+)
- Native Kotlin implementation

### iOS Implementation
- Uses Vonage Video iOS SDK 2.29.0+
- Supports iOS 15.0+
- Native Swift implementation

## Troubleshooting

### Android

**Issue**: Black screen when publishing/subscribing
- Ensure camera and microphone permissions are granted
- Check that hardware acceleration is enabled in AndroidManifest.xml

**Issue**: Build errors
- Make sure minimum SDK version is 24 or higher
- Run `flutter clean` and rebuild

### iOS

**Issue**: Camera/microphone not working
- Verify Info.plist has usage descriptions
- Check app permissions in iOS Settings

**Issue**: Pod install fails
- Run `pod repo update`
- Try `pod install --repo-update`

## Additional Resources

- [Vonage Video API Documentation](https://tokbox.com/developer/)
- [Vonage Video API Android SDK](https://tokbox.com/developer/sdks/android/)
- [Vonage Video API iOS SDK](https://tokbox.com/developer/sdks/ios/)

## License

This plugin is licensed under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

