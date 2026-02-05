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
    private var retryTimer: Timer?
    private var retryCount = 0
    private let maxRetries = 50 // Try for up to 5 seconds (50 * 100ms)

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

        containerView.backgroundColor = .black

        // Try to add subscriber view immediately or start retry timer
        if let subscriberView = sessionManager?.getSubscriberView(streamId: streamId) {
            addSubscriberView(subscriberView)
        } else {
            startRetryTimer()
        }
    }

    private func startRetryTimer() {
        retryTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if let subscriberView = self.sessionManager?.getSubscriberView(streamId: self.streamId) {
                self.addSubscriberView(subscriberView)
                self.retryTimer?.invalidate()
                self.retryTimer = nil
            } else {
                self.retryCount += 1
                if self.retryCount >= self.maxRetries {
                    self.retryTimer?.invalidate()
                    self.retryTimer = nil
                }
            }
        }
    }

    private func addSubscriberView(_ subscriberView: UIView) {
        // Remove from previous parent if needed
        subscriberView.removeFromSuperview()

        // Clear container
        containerView.subviews.forEach { $0.removeFromSuperview() }

        // Add subscriber view
        subscriberView.frame = containerView.bounds
        subscriberView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(subscriberView)
    }

    func view() -> UIView {
        return containerView
    }

    deinit {
        retryTimer?.invalidate()
    }
}
