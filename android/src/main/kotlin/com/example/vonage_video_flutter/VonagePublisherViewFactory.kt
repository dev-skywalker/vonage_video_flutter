package com.example.vonage_video_flutter

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class VonagePublisherViewFactory(
    private val sessionManager: VonageSessionManager,
    codec: MessageCodec<Any>
) : PlatformViewFactory(codec) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return VonagePublisherPlatformView(context, sessionManager)
    }
}

class VonagePublisherPlatformView(
    context: Context,
    private val sessionManager: VonageSessionManager
) : PlatformView {

    private val containerView: FrameLayout = FrameLayout(context)

    init {
        // Add publisher view to container
        sessionManager.getPublisherView()?.let { publisherView ->
            containerView.addView(publisherView)
        }
    }

    override fun getView(): View = containerView

    override fun dispose() {
        containerView.removeAllViews()
    }
}
