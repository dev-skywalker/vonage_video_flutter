package com.example.vonage_video_flutter

import android.content.Context
import android.util.Log
import com.opentok.android.OpentokError
import com.opentok.android.Publisher
import com.opentok.android.PublisherKit
import com.opentok.android.Session
import com.opentok.android.Stream
import com.opentok.android.Subscriber
import com.opentok.android.SubscriberKit
import io.flutter.plugin.common.EventChannel

class VonageSessionManager(private val context: Context) : EventChannel.StreamHandler {
    companion object {
        private const val TAG = "VonageSessionManager"
    }

    private var session: Session? = null
    private var publisher: Publisher? = null
    private val subscribers = mutableMapOf<String, Subscriber>()
    private val sessionStreams = mutableMapOf<String, Stream>()
    private var eventSink: EventChannel.EventSink? = null
    private var initialCameraPosition: String = "front"

    // Session callbacks
    private val sessionListener = object : Session.SessionListener {
        override fun onConnected(session: Session) {
            Log.d(TAG, "Session connected successfully. Session ID: ${session.sessionId}")
            sendEvent(mapOf("type" to "sessionConnected"))
        }

        override fun onDisconnected(session: Session) {
            Log.d(TAG, "Session disconnected. Session ID: ${session.sessionId}")
            sendEvent(mapOf("type" to "sessionDisconnected"))
        }

        override fun onStreamReceived(session: Session, stream: Stream) {
            Log.d(TAG, "Stream received. Stream ID: ${stream.streamId}, Name: ${stream.name}")
            sessionStreams[stream.streamId] = stream
            sendEvent(
                mapOf(
                    "type" to "streamReceived",
                    "stream" to streamToMap(stream)
                )
            )
        }

        override fun onStreamDropped(session: Session, stream: Stream) {
            Log.d(TAG, "Stream dropped. Stream ID: ${stream.streamId}")
            sendEvent(
                mapOf(
                    "type" to "streamDropped",
                    "stream" to streamToMap(stream)
                )
            )
            // Clean up subscriber and stream if it exists
            subscribers.remove(stream.streamId)
            sessionStreams.remove(stream.streamId)
        }

        override fun onError(session: Session, error: OpentokError) {
            Log.e(TAG, "Session error - Code: ${error.errorCode}, Message: ${error.message}, Exception: ${error.exception}")
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
            Log.d(TAG, "Publisher stream created. Stream ID: ${stream.streamId}")
            sendEvent(mapOf("type" to "publisherStarted"))
        }

        override fun onStreamDestroyed(publisher: PublisherKit, stream: Stream) {
            Log.d(TAG, "Publisher stream destroyed. Stream ID: ${stream.streamId}")
            sendEvent(mapOf("type" to "publisherStopped"))
        }

        override fun onError(publisher: PublisherKit, error: OpentokError) {
            Log.e(TAG, "Publisher error - Code: ${error.errorCode}, Message: ${error.message}, Exception: ${error.exception}")
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
        Log.d(TAG, "Attempting to connect to session...")
        Log.d(TAG, "API Key: $apiKey")
        Log.d(TAG, "Session ID: $sessionId")
        Log.d(TAG, "Token (first 50 chars): ${token.take(50)}...")

        // Clean up any existing session/publisher before connecting
        if (session != null || publisher != null) {
            Log.d(TAG, "Cleaning up previous session before connecting...")
            cleanup()
        }

        try {
            session = Session.Builder(context, apiKey, sessionId).build().apply {
                setSessionListener(sessionListener)
                Log.d(TAG, "Session object created, calling connect()...")
                connect(token)
                Log.d(TAG, "connect() called successfully")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception during session connection: ${e.message}", e)
            throw e
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
        initialCameraPosition = cameraPosition
        publisher = Publisher.Builder(context).apply {
            name?.let { name(it) }
            audioTrack(publishAudio)
            videoTrack(publishVideo)
        }.build().apply {
            setPublisherListener(publisherListener)
            // Note: Vonage SDK starts with front camera by default
            // If back camera is requested, we'll need to cycle after publishing
        }
    }

    // Publish stream
    fun publish() {
        publisher?.let { pub ->
            session?.publish(pub)
            // If back camera was requested, cycle to it after publishing
            if (initialCameraPosition == "back") {
                pub.cycleCamera()
            }
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
        Log.d(TAG, "Subscribing to stream: $streamId")
        val stream = sessionStreams[streamId]
        if (stream == null) {
            Log.e(TAG, "Stream not found for ID: $streamId")
            return
        }

        val subscriber = Subscriber.Builder(context, stream).build().apply {
            setSubscriberListener(object : SubscriberKit.SubscriberListener {
                override fun onConnected(subscriber: SubscriberKit) {
                    Log.d(TAG, "Subscriber connected for stream: $streamId")
                    sendEvent(
                        mapOf(
                            "type" to "subscriberConnected",
                            "streamId" to streamId
                        )
                    )
                }

                override fun onDisconnected(subscriber: SubscriberKit) {
                    Log.d(TAG, "Subscriber disconnected for stream: $streamId")
                    sendEvent(
                        mapOf(
                            "type" to "subscriberDisconnected",
                            "streamId" to streamId
                        )
                    )
                }

                override fun onError(subscriber: SubscriberKit, error: OpentokError) {
                    Log.e(TAG, "Subscriber error for stream $streamId - Code: ${error.errorCode}, Message: ${error.message}")
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
        Log.d(TAG, "Subscriber created and subscribed for stream: $streamId")
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
        sessionStreams.clear()
        session = null
    }
}
