package com.example.vonage_video_flutter

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class VonageSubscriberViewFactory(
    private val sessionManager: VonageSessionManager,
    codec: MessageCodec<Any>
) : PlatformViewFactory(codec) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<*, *>
        val streamId = params?.get("streamId") as? String
            ?: throw IllegalArgumentException("streamId is required")

        return VonageSubscriberPlatformView(context, sessionManager, streamId)
    }
}

class VonageSubscriberPlatformView(
    context: Context,
    private val sessionManager: VonageSessionManager,
    private val streamId: String
) : PlatformView {

    private val containerView: FrameLayout = FrameLayout(context)

    init {
        // Add subscriber view to container
        sessionManager.getSubscriberView(streamId)?.let { subscriberView ->
            containerView.addView(subscriberView)
        }
    }

    override fun getView(): View = containerView

    override fun dispose() {
        containerView.removeAllViews()
    }
}
