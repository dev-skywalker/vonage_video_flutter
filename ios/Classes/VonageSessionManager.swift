import Flutter
import OpenTok

class VonageSessionManager: NSObject, FlutterStreamHandler {
    private var session: OTSession?
    private var publisher: OTPublisher?
    private var subscribers: [String: OTSubscriber] = [:]
    private var eventSink: FlutterEventSink?
    private var streams: [String: OTStream] = [:]

    // MARK: - FlutterStreamHandler

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    // MARK: - Session Methods

    func connect(apiKey: String, sessionId: String, token: String) {
        // Clean up any existing session/publisher before connecting
        if session != nil || publisher != nil {
            cleanup()
        }
        session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
        var error: OTError?
        session?.connect(withToken: token, error: &error)

        if let error = error {
            sendEvent([
                "type": "sessionError",
                "error": [
                    "code": String(error.code.rawValue),
                    "message": error.localizedDescription
                ]
            ])
        }
    }

    func disconnect() {
        var error: OTError?
        session?.disconnect(&error)
        cleanup()
    }

    func sendSignal(type: String, data: String?, connectionId: String?) {
        var error: OTError?
        session?.signal(withType: type, string: data, connection: nil, error: &error)
    }

    // MARK: - Publisher Methods

    func initPublisher(name: String?, publishAudio: Bool, publishVideo: Bool, cameraPosition: String) {
        let settings = OTPublisherSettings()
        settings.name = name
        settings.audioTrack = publishAudio
        settings.videoTrack = publishVideo
        settings.cameraPosition = cameraPosition == "back" ? .back : .front

        publisher = OTPublisher(delegate: self, settings: settings)
    }

    func publish() {
        guard let publisher = publisher else { return }
        var error: OTError?
        session?.publish(publisher, error: &error)

        if let error = error {
            sendEvent([
                "type": "publisherError",
                "error": [
                    "code": String(error.code.rawValue),
                    "message": error.localizedDescription
                ]
            ])
        }
    }

    func unpublish() {
        guard let publisher = publisher else { return }
        var error: OTError?
        session?.unpublish(publisher, error: &error)
    }

    func setPublishAudio(enabled: Bool) {
        publisher?.publishAudio = enabled
    }

    func setPublishVideo(enabled: Bool) {
        publisher?.publishVideo = enabled
    }

    func switchCamera() {
        if publisher?.cameraPosition == .front {
            publisher?.cameraPosition = .back
        } else {
            publisher?.cameraPosition = .front
        }
    }

    // MARK: - Subscriber Methods

    func subscribe(streamId: String) {
        guard let stream = streams[streamId] else { return }

        let subscriber = OTSubscriber(stream: stream, delegate: self)
        subscribers[streamId] = subscriber

        var error: OTError?
        session?.subscribe(subscriber, error: &error)

        if let error = error {
            sendEvent([
                "type": "subscriberError",
                "streamId": streamId,
                "error": [
                    "code": String(error.code.rawValue),
                    "message": error.localizedDescription
                ]
            ])
        }
    }

    func unsubscribe(streamId: String) {
        guard let subscriber = subscribers[streamId] else { return }
        var error: OTError?
        session?.unsubscribe(subscriber, error: &error)
        subscribers.removeValue(forKey: streamId)
    }

    func setSubscribeToAudio(streamId: String, enabled: Bool) {
        subscribers[streamId]?.subscribeToAudio = enabled
    }

    func setSubscribeToVideo(streamId: String, enabled: Bool) {
        subscribers[streamId]?.subscribeToVideo = enabled
    }

    // MARK: - View Accessors

    func getPublisherView() -> UIView? {
        return publisher?.view
    }

    func getSubscriberView(streamId: String) -> UIView? {
        return subscribers[streamId]?.view
    }

    // MARK: - Helper Methods

    private func sendEvent(_ event: [String: Any]) {
        eventSink?(event)
    }

    private func streamToMap(_ stream: OTStream) -> [String: Any] {
        return [
            "streamId": stream.streamId,
            "name": stream.name ?? NSNull(),
            "hasAudio": stream.hasAudio,
            "hasVideo": stream.hasVideo,
            "connectionId": stream.connection?.connectionId ?? NSNull(),
            "creationTime": Int(stream.creationTime.timeIntervalSince1970 * 1000)
        ]
    }

    func cleanup() {
        publisher = nil
        subscribers.removeAll()
        streams.removeAll()
        session = nil
    }
}

// MARK: - OTSessionDelegate

extension VonageSessionManager: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        sendEvent(["type": "sessionConnected"])
    }

    func sessionDidDisconnect(_ session: OTSession) {
        sendEvent(["type": "sessionDisconnected"])
    }

    func session(_ session: OTSession, streamCreated stream: OTStream) {
        streams[stream.streamId] = stream
        sendEvent([
            "type": "streamReceived",
            "stream": streamToMap(stream)
        ])
    }

    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        streams.removeValue(forKey: stream.streamId)
        subscribers.removeValue(forKey: stream.streamId)
        sendEvent([
            "type": "streamDropped",
            "stream": streamToMap(stream)
        ])
    }

    func session(_ session: OTSession, didFailWithError error: OTError) {
        sendEvent([
            "type": "sessionError",
            "error": [
                "code": String(error.code.rawValue),
                "message": error.localizedDescription
            ]
        ])
    }
}

// MARK: - OTPublisherDelegate

extension VonageSessionManager: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        sendEvent(["type": "publisherStarted"])
    }

    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        sendEvent(["type": "publisherStopped"])
    }

    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        sendEvent([
            "type": "publisherError",
            "error": [
                "code": String(error.code.rawValue),
                "message": error.localizedDescription
            ]
        ])
    }
}

// MARK: - OTSubscriberDelegate

extension VonageSessionManager: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriber: OTSubscriberKit) {
        if let streamId = subscriber.stream?.streamId {
            sendEvent([
                "type": "subscriberConnected",
                "streamId": streamId
            ])
        }
    }

    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        if let streamId = subscriber.stream?.streamId {
            sendEvent([
                "type": "subscriberError",
                "streamId": streamId,
                "error": [
                    "code": String(error.code.rawValue),
                    "message": error.localizedDescription
                ]
            ])
        }
    }
}
