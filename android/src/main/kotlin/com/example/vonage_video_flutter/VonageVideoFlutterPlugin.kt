package com.example.vonage_video_flutter

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformViewRegistry

class VonageVideoFlutterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var sessionManager: VonageSessionManager
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        // Initialize method channel
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "vonage_video_flutter")
        methodChannel.setMethodCallHandler(this)

        // Initialize event channel
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "vonage_video_flutter/events")
        sessionManager = VonageSessionManager(context)
        eventChannel.setStreamHandler(sessionManager)

        // Register platform views
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "vonage_video_flutter/publisher_view",
            VonagePublisherViewFactory(sessionManager, StandardMessageCodec.INSTANCE)
        )

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "vonage_video_flutter/subscriber_view",
            VonageSubscriberViewFactory(sessionManager, StandardMessageCodec.INSTANCE)
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "connect" -> {
                val apiKey = call.argument<String>("apiKey")
                val sessionId = call.argument<String>("sessionId")
                val token = call.argument<String>("token")

                if (apiKey != null && sessionId != null && token != null) {
                    sessionManager.connect(apiKey, sessionId, token)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGS", "Missing required arguments", null)
                }
            }
            "disconnect" -> {
                sessionManager.disconnect()
                result.success(null)
            }
            "sendSignal" -> {
                val type = call.argument<String>("type")
                val data = call.argument<String?>("data")
                val connectionId = call.argument<String?>("connectionId")

                if (type != null) {
                    sessionManager.sendSignal(type, data, connectionId)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGS", "Missing type argument", null)
                }
            }
            "initPublisher" -> {
                val name = call.argument<String?>("name")
                val publishAudio = call.argument<Boolean>("publishAudio") ?: true
                val publishVideo = call.argument<Boolean>("publishVideo") ?: true
                val cameraPosition = call.argument<String>("cameraPosition") ?: "front"

                sessionManager.initPublisher(name, publishAudio, publishVideo, cameraPosition)
                result.success(null)
            }
            "publish" -> {
                sessionManager.publish()
                result.success(null)
            }
            "unpublish" -> {
                sessionManager.unpublish()
                result.success(null)
            }
            "setPublishAudio" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                sessionManager.setPublishAudio(enabled)
                result.success(null)
            }
            "setPublishVideo" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                sessionManager.setPublishVideo(enabled)
                result.success(null)
            }
            "switchCamera" -> {
                sessionManager.switchCamera()
                result.success(null)
            }
            "subscribe" -> {
                val streamId = call.argument<String>("streamId")
                if (streamId != null) {
                    sessionManager.subscribe(streamId)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGS", "Missing streamId", null)
                }
            }
            "unsubscribe" -> {
                val streamId = call.argument<String>("streamId")
                if (streamId != null) {
                    sessionManager.unsubscribe(streamId)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGS", "Missing streamId", null)
                }
            }
            "setSubscribeToAudio" -> {
                val streamId = call.argument<String>("streamId")
                val enabled = call.argument<Boolean>("enabled") ?: false
                if (streamId != null) {
                    sessionManager.setSubscribeToAudio(streamId, enabled)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGS", "Missing streamId", null)
                }
            }
            "setSubscribeToVideo" -> {
                val streamId = call.argument<String>("streamId")
                val enabled = call.argument<Boolean>("enabled") ?: false
                if (streamId != null) {
                    sessionManager.setSubscribeToVideo(streamId, enabled)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGS", "Missing streamId", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        sessionManager.cleanup()
    }
}
