import Flutter
import UIKit

class VonageSubscriberViewFactory: NSObject, FlutterPlatformViewFactory {
    private weak var sessionManager: VonageSessionManager?

    init(sessionManager: VonageSessionManager) {
        self.sessionManager = sessionManager
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        let params = args as? [String: Any]
        let streamId = params?["streamId"] as? String ?? ""

        return VonageSubscriberPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            sessionManager: sessionManager,
            streamId: streamId
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class VonageSubscriberPlatformView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private weak var sessionManager: VonageSessionManager?
    private let streamId: String

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        sessionManager: VonageSessionManager?,
        streamId: String
    ) {
        self.containerView = UIView(frame: frame)
        self.sessionManager = sessionManager
        self.streamId = streamId
        super.init()

        // Add subscriber view if available
        if let subscriberView = sessionManager?.getSubscriberView(streamId: streamId) {
            subscriberView.frame = containerView.bounds
            subscriberView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(subscriberView)
        }
    }

    func view() -> UIView {
        return containerView
    }
}
