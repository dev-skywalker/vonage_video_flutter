import Flutter
import UIKit

class VonagePublisherViewFactory: NSObject, FlutterPlatformViewFactory {
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
        return VonagePublisherPlatformView(
            frame: frame,
            viewIdentifier: viewId,
            sessionManager: sessionManager
        )
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

class VonagePublisherPlatformView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private weak var sessionManager: VonageSessionManager?

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        sessionManager: VonageSessionManager?
    ) {
        self.containerView = UIView(frame: frame)
        self.sessionManager = sessionManager
        super.init()

        // Add publisher view if available
        if let publisherView = sessionManager?.getPublisherView() {
            publisherView.frame = containerView.bounds
            publisherView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            containerView.addSubview(publisherView)
        }
    }

    func view() -> UIView {
        return containerView
    }
}
