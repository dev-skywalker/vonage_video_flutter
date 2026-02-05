package com.example.vonage_video_flutter

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class VonagePublisherViewFactory(
    private val sessionManager: VonageSessionManager,
    codec: MessageCodec<Any>
) : PlatformViewFactory(codec) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d("VonagePublisher", "Creating new publisher platform view, id: $viewId")
        return VonagePublisherPlatformView(context, sessionManager, viewId)
    }
}

class VonagePublisherPlatformView(
    context: Context,
    private val sessionManager: VonageSessionManager,
    private val viewId: Int
) : PlatformView {

    private val containerView: FrameLayout = FrameLayout(context)
    private val handler = Handler(Looper.getMainLooper())
    private var retryCount = 0
    private val maxRetries = 100 // Try for up to 10 seconds (100 * 100ms)
    private var viewAdded = false

    private val checkViewRunnable = object : Runnable {
        override fun run() {
            val publisherView = sessionManager.getPublisherView()
            Log.d("VonagePublisher", "[$viewId] Retry $retryCount - Publisher view: ${publisherView != null}")
            if (publisherView != null) {
                addPublisherView(publisherView)
            } else if (retryCount < maxRetries) {
                retryCount++
                handler.postDelayed(this, 100)
            } else {
                Log.e("VonagePublisher", "[$viewId] Max retries reached, publisher view not available")
            }
        }
    }

    init {
        containerView.layoutParams = ViewGroup.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        containerView.setBackgroundColor(Color.BLACK)

        // Try to add publisher view immediately or retry
        val publisherView = sessionManager.getPublisherView()
        Log.d("VonagePublisher", "[$viewId] Init - Publisher view available: ${publisherView != null}")
        if (publisherView != null) {
            addPublisherView(publisherView)
        } else {
            handler.post(checkViewRunnable)
        }
    }

    private fun addPublisherView(publisherView: View) {
        if (viewAdded) {
            Log.d("VonagePublisher", "[$viewId] View already added, skipping")
            return
        }

        handler.removeCallbacks(checkViewRunnable)

        // Remove from previous parent if needed
        val parent = publisherView.parent as? ViewGroup
        if (parent != null && parent != containerView) {
            Log.d("VonagePublisher", "[$viewId] Removing from previous parent")
            parent.removeView(publisherView)
        }

        containerView.removeAllViews()
        publisherView.layoutParams = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT
        )
        containerView.addView(publisherView)
        viewAdded = true
        Log.d("VonagePublisher", "[$viewId] Publisher view added successfully")
    }

    override fun getView(): View = containerView

    override fun dispose() {
        Log.d("VonagePublisher", "[$viewId] Disposing")
        handler.removeCallbacks(checkViewRunnable)
        // Don't remove the publisher view - it might be used by another platform view
        // Just clear our reference
        viewAdded = false
    }
}
