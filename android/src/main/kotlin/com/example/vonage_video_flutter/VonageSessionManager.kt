package com.example.vonage_video_flutter

import android.content.Context
import com.opentok.android.OpentokError
import com.opentok.android.Publisher
import com.opentok.android.PublisherKit
import com.opentok.android.Session
import com.opentok.android.Stream
import com.opentok.android.Subscriber
import com.opentok.android.SubscriberKit
import io.flutter.plugin.common.EventChannel

class VonageSessionManager(private val context: Context) : EventChannel.StreamHandler {
    private var session: Session? = null
    private var publisher: Publisher? = null
    private val subscribers = mutableMapOf<String, Subscriber>()
    private var eventSink: EventChannel.EventSink? = null

    // Session callbacks
    private val sessionListener = object : Session.SessionListener {
        override fun onConnected(session: Session) {
            sendEvent(mapOf("type" to "sessionConnected"))
        }

        override fun onDisconnected(session: Session) {
            sendEvent(mapOf("type" to "sessionDisconnected"))
        }

        override fun onStreamReceived(session: Session, stream: Stream) {
            sendEvent(
                mapOf(
                    "type" to "streamReceived",
                    "stream" to streamToMap(stream)
                )
            )
        }

        override fun onStreamDropped(session: Session, stream: Stream) {
            sendEvent(
                mapOf(
                    "type" to "streamDropped",
                    "stream" to streamToMap(stream)
                )
            )
            // Clean up subscriber if it exists
            subscribers.remove(stream.streamId)
        }

        override fun onError(session: Session, error: OpentokError) {
            sendEvent(
                mapOf(
                    "type" to "sessionError",
                    "error" to mapOf(
                        "code" to error.errorCode.toString(),
                        "message" to error.message
                    )
                )
            )
        }
    }

    // Publisher callbacks
    private val publisherListener = object : PublisherKit.PublisherListener {
        override fun onStreamCreated(publisher: PublisherKit, stream: Stream) {
            sendEvent(mapOf("type" to "publisherStarted"))
        }

        override fun onStreamDestroyed(publisher: PublisherKit, stream: Stream) {
            sendEvent(mapOf("type" to "publisherStopped"))
        }

        override fun onError(publisher: PublisherKit, error: OpentokError) {
            sendEvent(
                mapOf(
                    "type" to "publisherError",
                    "error" to mapOf(
                        "code" to error.errorCode.toString(),
                        "message" to error.message
                    )
                )
            )
        }
    }

    // Connect to session
    fun connect(apiKey: String, sessionId: String, token: String) {
        session = Session.Builder(context, apiKey, sessionId).build().apply {
            setSessionListener(sessionListener)
            connect(token)
        }
    }

    // Disconnect from session
    fun disconnect() {
        session?.disconnect()
        cleanup()
    }

    // Send signal
    fun sendSignal(type: String, data: String?, connectionId: String?) {
        session?.sendSignal(type, data)
    }

    // Initialize publisher
    fun initPublisher(name: String?, publishAudio: Boolean, publishVideo: Boolean, cameraPosition: String) {
        publisher = Publisher.Builder(context).apply {
            name?.let { name(it) }
            audioTrack(publishAudio)
            videoTrack(publishVideo)
            if (cameraPosition == "back") {
                cameraId(Publisher.CameraId.BACK)
            } else {
                cameraId(Publisher.CameraId.FRONT)
            }
        }.build().apply {
            setPublisherListener(publisherListener)
        }
    }

    // Publish stream
    fun publish() {
        publisher?.let { pub ->
            session?.publish(pub)
        }
    }

    // Unpublish stream
    fun unpublish() {
        publisher?.let { pub ->
            session?.unpublish(pub)
        }
    }

    // Set publish audio
    fun setPublishAudio(enabled: Boolean) {
        publisher?.publishAudio = enabled
    }

    // Set publish video
    fun setPublishVideo(enabled: Boolean) {
        publisher?.publishVideo = enabled
    }

    // Switch camera
    fun switchCamera() {
        publisher?.cycleCamera()
    }

    // Subscribe to stream
    fun subscribe(streamId: String) {
        val stream = session?.streams?.find { it.streamId == streamId } ?: return

        val subscriber = Subscriber.Builder(context, stream).build().apply {
            setSubscriberListener(object : SubscriberKit.SubscriberListener {
                override fun onConnected(subscriber: SubscriberKit) {
                    sendEvent(
                        mapOf(
                            "type" to "subscriberConnected",
                            "streamId" to streamId
                        )
                    )
                }

                override fun onDisconnected(subscriber: SubscriberKit) {
                    sendEvent(
                        mapOf(
                            "type" to "subscriberDisconnected",
                            "streamId" to streamId
                        )
                    )
                }

                override fun onError(subscriber: SubscriberKit, error: OpentokError) {
                    sendEvent(
                        mapOf(
                            "type" to "subscriberError",
                            "streamId" to streamId,
                            "error" to mapOf(
                                "code" to error.errorCode.toString(),
                                "message" to error.message
                            )
                        )
                    )
                }
            })
        }

        subscribers[streamId] = subscriber
        session?.subscribe(subscriber)
    }

    // Unsubscribe from stream
    fun unsubscribe(streamId: String) {
        subscribers[streamId]?.let { subscriber ->
            session?.unsubscribe(subscriber)
            subscribers.remove(streamId)
        }
    }

    // Set subscribe to audio
    fun setSubscribeToAudio(streamId: String, enabled: Boolean) {
        subscribers[streamId]?.subscribeToAudio = enabled
    }

    // Set subscribe to video
    fun setSubscribeToVideo(streamId: String, enabled: Boolean) {
        subscribers[streamId]?.subscribeToVideo = enabled
    }

    // Get publisher view
    fun getPublisherView() = publisher?.view

    // Get subscriber view
    fun getSubscriberView(streamId: String) = subscribers[streamId]?.view

    // EventChannel.StreamHandler implementation
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    // Helper methods
    private fun sendEvent(event: Map<String, Any?>) {
        eventSink?.success(event)
    }

    private fun streamToMap(stream: Stream): Map<String, Any?> {
        return mapOf(
            "streamId" to stream.streamId,
            "name" to stream.name,
            "hasAudio" to stream.hasAudio(),
            "hasVideo" to stream.hasVideo(),
            "connectionId" to stream.connection?.connectionId,
            "creationTime" to stream.creationTime.time
        )
    }

    fun cleanup() {
        publisher?.destroy()
        publisher = null
        subscribers.values.forEach { it.destroy() }
        subscribers.clear()
        session = null
    }
}
