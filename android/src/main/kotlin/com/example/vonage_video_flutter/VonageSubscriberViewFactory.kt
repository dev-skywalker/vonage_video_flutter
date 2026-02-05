package com.example.vonage_video_flutter

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
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
    private val handler = Handler(Looper.getMainLooper())
    private var retryCount = 0
    private val maxRetries = 50 // Try for up to 5 seconds (50 * 100ms)

    private val checkViewRunnable = object : Runnable {
        override fun run() {
            val subscriberView = sessionManager.getSubscriberView(streamId)
            if (subscriberView != null) {
                addSubscriberView(subscriberView)
            } else if (retryCount < maxRetries) {
                retryCount++
                handler.postDelayed(this, 100)
            }
        }
    }

    init {
        containerView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )

        // Try to add subscriber view immediately or retry
        val subscriberView = sessionManager.getSubscriberView(streamId)
        if (subscriberView != null) {
            addSubscriberView(subscriberView)
        } else {
            handler.post(checkViewRunnable)
        }
    }

    private fun addSubscriberView(subscriberView: View) {
        handler.removeCallbacks(checkViewRunnable)

        // Remove from previous parent if needed
        (subscriberView.parent as? ViewGroup)?.removeView(subscriberView)

        containerView.removeAllViews()
        subscriberView.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        containerView.addView(subscriberView)
    }

    override fun getView(): View = containerView

    override fun dispose() {
        handler.removeCallbacks(checkViewRunnable)
        containerView.removeAllViews()
    }
}
