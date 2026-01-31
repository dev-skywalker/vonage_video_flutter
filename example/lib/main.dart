import 'package:flutter/material.dart';
import 'dart:async';
import 'package:vonage_video_flutter/vonage_video_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vonage Video Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const VideoCallScreen(),
    );
  }
}

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _vonageVideo = VonageVideoFlutter();
  final _apiKeyController = TextEditingController();
  final _sessionIdController = TextEditingController();
  final _tokenController = TextEditingController();

  bool _isConnected = false;
  bool _isPublishing = false;
  bool _publishAudio = true;
  bool _publishVideo = true;
  final List<VonageStream> _streams = [];
  final List<String> _subscribedStreams = [];
  StreamSubscription? _eventSubscription;
  String _status = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _listenToEvents();
  }

  void _listenToEvents() {
    _eventSubscription = _vonageVideo.sessionEvents.listen((event) {
      setState(() {
        if (event is SessionConnectedEvent) {
          _status = 'Connected to session';
          _isConnected = true;
        } else if (event is SessionDisconnectedEvent) {
          _status = 'Disconnected from session';
          _isConnected = false;
          _isPublishing = false;
          _streams.clear();
          _subscribedStreams.clear();
        } else if (event is StreamReceivedEvent) {
          _status = 'Stream received: ${event.stream.name ?? event.stream.streamId}';
          _streams.add(event.stream);
        } else if (event is StreamDroppedEvent) {
          _status = 'Stream dropped: ${event.stream.name ?? event.stream.streamId}';
          _streams.removeWhere((s) => s.streamId == event.stream.streamId);
          _subscribedStreams.remove(event.stream.streamId);
        } else if (event is PublisherStartedEvent) {
          _status = 'Publishing started';
          _isPublishing = true;
        } else if (event is PublisherStoppedEvent) {
          _status = 'Publishing stopped';
          _isPublishing = false;
        } else if (event is SessionErrorEvent) {
          _status = 'Session error: ${event.error.message}';
          _showError('Session Error', event.error.message);
        } else if (event is PublisherErrorEvent) {
          _status = 'Publisher error: ${event.error.message}';
          _showError('Publisher Error', event.error.message);
        } else if (event is SubscriberErrorEvent) {
          _status = 'Subscriber error: ${event.error.message}';
          _showError('Subscriber Error', event.error.message);
        }
      });
    });
  }

  void _showError(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _connect() async {
    if (_apiKeyController.text.isEmpty ||
        _sessionIdController.text.isEmpty ||
        _tokenController.text.isEmpty) {
      _showError('Error', 'Please fill in all credentials');
      return;
    }

    try {
      await _vonageVideo.connect(
        VonageSessionOptions(
          apiKey: _apiKeyController.text,
          sessionId: _sessionIdController.text,
          token: _tokenController.text,
        ),
      );

      // Initialize and publish after connecting
      await _vonageVideo.initPublisher(
        const VonagePublisherSettings(
          name: 'Flutter Publisher',
          publishAudio: true,
          publishVideo: true,
          cameraPosition: CameraPosition.front,
        ),
      );
    } catch (e) {
      _showError('Connection Error', e.toString());
    }
  }

  Future<void> _disconnect() async {
    try {
      await _vonageVideo.disconnect();
    } catch (e) {
      _showError('Disconnect Error', e.toString());
    }
  }

  Future<void> _publish() async {
    try {
      await _vonageVideo.publish();
    } catch (e) {
      _showError('Publish Error', e.toString());
    }
  }

  Future<void> _unpublish() async {
    try {
      await _vonageVideo.unpublish();
    } catch (e) {
      _showError('Unpublish Error', e.toString());
    }
  }

  Future<void> _toggleAudio() async {
    setState(() => _publishAudio = !_publishAudio);
    await _vonageVideo.setPublishAudio(_publishAudio);
  }

  Future<void> _toggleVideo() async {
    setState(() => _publishVideo = !_publishVideo);
    await _vonageVideo.setPublishVideo(_publishVideo);
  }

  Future<void> _switchCamera() async {
    await _vonageVideo.switchCamera();
  }

  Future<void> _subscribe(String streamId) async {
    try {
      await _vonageVideo.subscribe(streamId);
      setState(() => _subscribedStreams.add(streamId));
    } catch (e) {
      _showError('Subscribe Error', e.toString());
    }
  }

  Future<void> _unsubscribe(String streamId) async {
    try {
      await _vonageVideo.unsubscribe(streamId);
      setState(() => _subscribedStreams.remove(streamId));
    } catch (e) {
      _showError('Unsubscribe Error', e.toString());
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _apiKeyController.dispose();
    _sessionIdController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vonage Video Call'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: _isConnected ? Colors.green : Colors.grey,
            child: Text(
              _status,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),

          // Connection form
          if (!_isConnected)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter Vonage Video Credentials',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _sessionIdController,
                      decoration: const InputDecoration(
                        labelText: 'Session ID',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        labelText: 'Token',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _connect,
                      child: const Text('Connect'),
                    ),
                  ],
                ),
              ),
            ),

          // Video views when connected
          if (_isConnected)
            Expanded(
              child: Column(
                children: [
                  // Publisher view
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.black,
                      child: Stack(
                        children: [
                          if (_isPublishing)
                            const Center(child: VonagePublisherView())
                          else
                            const Center(
                              child: Text(
                                'Not Publishing',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              color: Colors.black54,
                              child: const Text(
                                'You',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Subscribers list
                  if (_streams.isNotEmpty)
                    Expanded(
                      flex: 1,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _streams.length,
                        itemBuilder: (context, index) {
                          final stream = _streams[index];
                          final isSubscribed = _subscribedStreams.contains(stream.streamId);

                          return Container(
                            color: Colors.black,
                            child: Stack(
                              children: [
                                if (isSubscribed)
                                  Center(
                                    child: VonageSubscriberView(
                                      streamId: stream.streamId,
                                    ),
                                  )
                                else
                                  Center(
                                    child: ElevatedButton(
                                      onPressed: () => _subscribe(stream.streamId),
                                      child: const Text('Subscribe'),
                                    ),
                                  ),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    color: Colors.black54,
                                    child: Text(
                                      stream.name ?? 'Unknown',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                if (isSubscribed)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      onPressed: () => _unsubscribe(stream.streamId),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Control buttons
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.grey[200],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!_isPublishing)
                          ElevatedButton.icon(
                            onPressed: _publish,
                            icon: const Icon(Icons.videocam),
                            label: const Text('Publish'),
                          )
                        else
                          ElevatedButton.icon(
                            onPressed: _unpublish,
                            icon: const Icon(Icons.videocam_off),
                            label: const Text('Unpublish'),
                          ),
                        IconButton(
                          onPressed: _toggleAudio,
                          icon: Icon(_publishAudio ? Icons.mic : Icons.mic_off),
                          color: _publishAudio ? Colors.blue : Colors.red,
                        ),
                        IconButton(
                          onPressed: _toggleVideo,
                          icon: Icon(_publishVideo ? Icons.videocam : Icons.videocam_off),
                          color: _publishVideo ? Colors.blue : Colors.red,
                        ),
                        IconButton(
                          onPressed: _switchCamera,
                          icon: const Icon(Icons.cameraswitch),
                        ),
                        ElevatedButton.icon(
                          onPressed: _disconnect,
                          icon: const Icon(Icons.call_end),
                          label: const Text('Disconnect'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
