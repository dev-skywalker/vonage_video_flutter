import Flutter
import UIKit

public class VonageVideoFlutterPlugin: NSObject, FlutterPlugin {
    private var sessionManager: VonageSessionManager?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "vonage_video_flutter",
            binaryMessenger: registrar.messenger()
        )

        let eventChannel = FlutterEventChannel(
            name: "vonage_video_flutter/events",
            binaryMessenger: registrar.messenger()
        )

        let instance = VonageVideoFlutterPlugin()
        instance.sessionManager = VonageSessionManager()

        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance.sessionManager)

        // Register platform views
        let publisherFactory = VonagePublisherViewFactory(sessionManager: instance.sessionManager!)
        registrar.register(
            publisherFactory,
            withId: "vonage_video_flutter/publisher_view"
        )

        let subscriberFactory = VonageSubscriberViewFactory(sessionManager: instance.sessionManager!)
        registrar.register(
            subscriberFactory,
            withId: "vonage_video_flutter/subscriber_view"
        )
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let sessionManager = sessionManager else {
            result(FlutterError(code: "NO_SESSION", message: "Session manager not initialized", details: nil))
            return
        }

        switch call.method {
        case "connect":
            guard let args = call.arguments as? [String: Any],
                  let apiKey = args["apiKey"] as? String,
                  let sessionId = args["sessionId"] as? String,
                  let token = args["token"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing required arguments", details: nil))
                return
            }
            sessionManager.connect(apiKey: apiKey, sessionId: sessionId, token: token)
            result(nil)

        case "disconnect":
            sessionManager.disconnect()
            result(nil)

        case "sendSignal":
            guard let args = call.arguments as? [String: Any],
                  let type = args["type"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing type argument", details: nil))
                return
            }
            let data = args["data"] as? String
            let connectionId = args["connectionId"] as? String
            sessionManager.sendSignal(type: type, data: data, connectionId: connectionId)
            result(nil)

        case "initPublisher":
            let args = call.arguments as? [String: Any]
            let name = args?["name"] as? String
            let publishAudio = args?["publishAudio"] as? Bool ?? true
            let publishVideo = args?["publishVideo"] as? Bool ?? true
            let cameraPosition = args?["cameraPosition"] as? String ?? "front"

            sessionManager.initPublisher(
                name: name,
                publishAudio: publishAudio,
                publishVideo: publishVideo,
                cameraPosition: cameraPosition
            )
            result(nil)

        case "publish":
            sessionManager.publish()
            result(nil)

        case "unpublish":
            sessionManager.unpublish()
            result(nil)

        case "setPublishAudio":
            guard let args = call.arguments as? [String: Any],
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing enabled argument", details: nil))
                return
            }
            sessionManager.setPublishAudio(enabled: enabled)
            result(nil)

        case "setPublishVideo":
            guard let args = call.arguments as? [String: Any],
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing enabled argument", details: nil))
                return
            }
            sessionManager.setPublishVideo(enabled: enabled)
            result(nil)

        case "switchCamera":
            sessionManager.switchCamera()
            result(nil)

        case "subscribe":
            guard let args = call.arguments as? [String: Any],
                  let streamId = args["streamId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing streamId", details: nil))
                return
            }
            sessionManager.subscribe(streamId: streamId)
            result(nil)

        case "unsubscribe":
            guard let args = call.arguments as? [String: Any],
                  let streamId = args["streamId"] as? String else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing streamId", details: nil))
                return
            }
            sessionManager.unsubscribe(streamId: streamId)
            result(nil)

        case "setSubscribeToAudio":
            guard let args = call.arguments as? [String: Any],
                  let streamId = args["streamId"] as? String,
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }
            sessionManager.setSubscribeToAudio(streamId: streamId, enabled: enabled)
            result(nil)

        case "setSubscribeToVideo":
            guard let args = call.arguments as? [String: Any],
                  let streamId = args["streamId"] as? String,
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGS", message: "Missing arguments", details: nil))
                return
            }
            sessionManager.setSubscribeToVideo(streamId: streamId, enabled: enabled)
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
