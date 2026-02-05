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
    private var retryTimer: Timer?
    private var retryCount = 0
    private let maxRetries = 50 // Try for up to 5 seconds (50 * 100ms)

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        sessionManager: VonageSessionManager?
    ) {
        self.containerView = UIView(frame: frame)
        self.sessionManager = sessionManager
        super.init()

        containerView.backgroundColor = .black

        // Try to add publisher view immediately or start retry timer
        if let publisherView = sessionManager?.getPublisherView() {
            addPublisherView(publisherView)
        } else {
            startRetryTimer()
        }
    }

    private func startRetryTimer() {
        retryTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if let publisherView = self.sessionManager?.getPublisherView() {
                self.addPublisherView(publisherView)
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

    private func addPublisherView(_ publisherView: UIView) {
        // Remove from previous parent if needed
        publisherView.removeFromSuperview()

        // Clear container
        containerView.subviews.forEach { $0.removeFromSuperview() }

        // Add publisher view
        publisherView.frame = containerView.bounds
        publisherView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(publisherView)
    }

    func view() -> UIView {
        return containerView
    }

    deinit {
        retryTimer?.invalidate()
    }
}
