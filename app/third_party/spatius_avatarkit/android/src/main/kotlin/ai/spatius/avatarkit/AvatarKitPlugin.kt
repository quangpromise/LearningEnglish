package ai.spatius.avatarkit

import ai.spatius.avatarkit.AudioFormat
import ai.spatius.avatarkit.Avatar
import ai.spatius.avatarkit.AvatarController
import ai.spatius.avatarkit.AvatarError
import ai.spatius.avatarkit.AvatarKitException
import ai.spatius.avatarkit.AvatarSDK
import ai.spatius.avatarkit.AvatarView
import ai.spatius.avatarkit.Configuration
import ai.spatius.avatarkit.DEFAULT_REGION
import ai.spatius.avatarkit.DrivingServiceMode
import ai.spatius.avatarkit.FrameStarvationMode
import ai.spatius.avatarkit.LogLevel
import ai.spatius.avatarkit.RenderQuality
import ai.spatius.avatarkit.Transform
import ai.spatius.avatarkit.assets.AssetMissingException
import ai.spatius.avatarkit.assets.AvatarManager
import ai.spatius.avatarkit.performance.FrameRateMonitor
import ai.spatius.avatarkit.player.AnimationPlayer
import android.content.Context
import android.os.SystemClock
import android.view.View
import androidx.annotation.NonNull
import io.flutter.FlutterInjector
import io.flutter.Log
import io.flutter.embedding.engine.loader.FlutterLoader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

private const val LOG_TAG = "AvatarKitPlugin"
private const val FRAME_RATE_EVENT_INTERVAL_MS = 250L

internal fun conversationStateToFlutterValue(state: AnimationPlayer.ConversationState): String {
    return when (state) {
        AnimationPlayer.ConversationState.Idle -> "idle"
        AnimationPlayer.ConversationState.Paused -> "paused"
        AnimationPlayer.ConversationState.Playing -> "playing"
    }
}

class AvatarKitPlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var context: Context
    private var eventSinks = mutableMapOf<String, EventChannel.EventSink>()
    private val scope = MainScope()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "AVATAR_KIT_METHOD_CHANNEL")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "AVATAR_KIT_EVENT_CHANNEL")
        eventChannel.setStreamHandler(this)

        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "AVATAR_VIEW",
            AvatarPlatformViewFactory(flutterPluginBinding.binaryMessenger)
        )
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "appID" -> result.success(AvatarSDK.appId)
            "configuration" -> {
                val config = AvatarSDK.config
                result.success(mapOf(
                    "region" to config.region,
                    "sampleRate" to config.audioFormat.sampleRate,
                    "inputAudioFormat" to config.audioFormat.inputAudioFormat.name.lowercase(),
                    "opusUplinkEnabled" to config.audioFormat.opusUplinkEnabled,
                    "opusBitrate" to config.audioFormat.opusBitrate,
                    "drivingServiceMode" to config.drivingServiceMode.name.lowercase(),
                    "logLevel" to config.logLevel.name.lowercase(),
                    "renderQuality" to config.renderQuality.name.lowercase()
                ))
            }
            "initialize" -> {
                val args = call.arguments as? Map<String, Any>
                if (args != null) {
                    val appID = args["appID"] as? String
                    val sampleRate = args["sampleRate"] as? Int ?: 16000
                    val inputAudioFormat = (args["inputAudioFormat"] as? String)
                        ?.let { AudioCodec.valueOf(it.uppercase()) } ?: AudioCodec.PCM
                    val opusUplinkEnabled = args["opusUplinkEnabled"] as? Boolean ?: false
                    val opusBitrate = args["opusBitrate"] as? Int ?: DEFAULT_OPUS_BITRATE
                    val region = (args["region"] as? String) ?: DEFAULT_REGION
                    val drivingServiceMode = args["drivingServiceMode"] as? String
                    val logLevel = args["logLevel"] as? String
                    val renderQuality = args["renderQuality"] as? String
                    val pluginVersion = args["pluginVersion"] as? String ?: ""

                    if (appID != null && drivingServiceMode != null && logLevel != null) {
                        val mode = DrivingServiceMode.valueOf(drivingServiceMode.uppercase())
                        val log = LogLevel.valueOf(logLevel.uppercase())
                        val quality = renderQuality?.let { RenderQuality.valueOf(it.uppercase()) }
                            ?: RenderQuality.ULTRA
                        val audioFormat = AudioFormat(
                            sampleRate = sampleRate,
                            opusBitrate = opusBitrate,
                            inputAudioFormat = inputAudioFormat,
                            opusUplinkEnabled = opusUplinkEnabled,
                        )
                        val config = Configuration(region, audioFormat, mode, log, quality)

                        AvatarSDK.inject(mapOf(
                            "sdk_package" to "spatius-flutter-sdk",
                            "sdk_version" to pluginVersion,
                        ))
                        AvatarSDK.initialize(context, appID, config)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Missing arguments", null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Arguments is null", null)
                }
            }
            "sessionToken" -> result.success(AvatarSDK.sessionToken)
            "setSessionToken" -> {
                val token = call.arguments as? String
                if (token != null) {
                    AvatarSDK.sessionToken = token
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Token is null", null)
                }
            }
            "userID" -> result.success(AvatarSDK.userId)
            "setUserID" -> {
                val userID = call.arguments as? String
                if (userID != null) {
                    AvatarSDK.userId = userID
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "UserID is null", null)
                }
            }
            "version" -> result.success(AvatarSDK.version)
            "setRenderQuality" -> {
                val quality = call.arguments as? String
                if (quality != null) {
                    AvatarSDK.setRenderQuality(RenderQuality.valueOf(quality.uppercase()))
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "quality is null", null)
                }
            }
            "setRenderResolutionCap" -> {
                val args = call.arguments as? Map<String, Any>
                val enabled = args?.get("enabled") as? Boolean
                val maxHeight = (args?.get("maxHeight") as? Number)?.toInt() ?: 1440
                if (enabled != null) {
                    AvatarSDK.setRenderResolutionCap(enabled, maxHeight)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "enabled is null", null)
                }
            }
            // ---- Test-only SPI (host-mode integration tests) ----
            "setDrivingServiceModeForTesting" -> {
                val mode = call.arguments as? String
                if (mode != null) {
                    AvatarSDK.setDrivingServiceModeForTesting(DrivingServiceMode.valueOf(mode.uppercase()))
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "mode is null", null)
                }
            }
            "setAudioFormatForTesting" -> {
                val args = call.arguments as? Map<String, Any>
                if (args != null) {
                    val codec = (args["inputAudioFormat"] as? String)
                        ?.let { AudioCodec.valueOf(it.uppercase()) } ?: AudioCodec.PCM
                    AvatarSDK.setAudioFormatForTesting(
                        AudioFormat(
                            sampleRate = args["sampleRate"] as? Int ?: 16000,
                            opusBitrate = args["opusBitrate"] as? Int ?: DEFAULT_OPUS_BITRATE,
                            inputAudioFormat = codec,
                            opusUplinkEnabled = args["opusUplinkEnabled"] as? Boolean ?: false,
                        )
                    )
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Arguments is null", null)
                }
            }
            "encodeWholePcmToOggForTesting" -> {
                val args = call.arguments as? Map<String, Any>
                val pcm = args?.get("pcm") as? ByteArray
                val sampleRate = args?.get("sampleRate") as? Int
                if (pcm != null && sampleRate != null) {
                    val bitrate = args["bitrate"] as? Int ?: DEFAULT_OPUS_BITRATE
                    result.success(AvatarSDK.encodeWholePcmToOggForTesting(pcm, sampleRate, bitrate))
                } else {
                    result.error("INVALID_ARGUMENTS", "pcm or sampleRate is null", null)
                }
            }
            "keyframeCount" -> {
                val raw = call.arguments as? ByteArray
                if (raw != null) {
                    result.success(AvatarSDK.keyframeCount(raw))
                } else {
                    result.error("INVALID_ARGUMENTS", "rawMessage is null", null)
                }
            }
            "sliceRawAnimationMessage" -> {
                val args = call.arguments as? Map<String, Any>
                val raw = args?.get("rawMessage") as? ByteArray
                val startFrame = (args?.get("startFrame") as? Number)?.toInt()
                val endFrame = (args?.get("endFrame") as? Number)?.toInt()
                if (raw != null && startFrame != null && endFrame != null) {
                    result.success(AvatarSDK.sliceRawAnimationMessage(raw, startFrame, endFrame))
                } else {
                    result.error("INVALID_ARGUMENTS", "missing rawMessage/startFrame/endFrame", null)
                }
            }
            "isDeviceSupported" -> {
                scope.launch {
                    result.success(AvatarSDK.isDeviceSupported())
                }
            }
            "deviceScore" -> {
                scope.launch {
                    val score = AvatarSDK.deviceScore()
                    result.success(mapOf(
                        "cpuScore" to score.cpuScore,
                        "gpuScore" to score.gpuScore,
                    ))
                }
            }
            "retrieve" -> {
                val id = call.arguments as? String
                if (id != null) {
                    val avatar = AvatarManager.retrieve(id)
                    if (avatar != null) {
                        result.success(mapOf("id" to avatar.id, "isFromCache" to avatar.isFromCache))
                    } else {
                        result.success(null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "ID is null", null)
                }
            }
            "derive" -> {
                val assetPath = call.arguments as? String
                if (assetPath != null) {
                    try {
                        val avatar = AvatarManager.derive(mapAssetPath(assetPath))
                        result.success(mapOf("id" to avatar.id, "isFromCache" to avatar.isFromCache, "assetPath" to assetPath))
                    } catch (e: AssetMissingException) {
                        result.error("ASSET_MISSING", e.message, e.filePath)
                    } catch (e: Exception) {
                        result.error("DERIVE_FAILED", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "assetPath is null", null)
                }
            }
            "load" -> {
                val args = call.arguments as? Map<String, Any>
                val id = args?.get("id") as? String
                val eventID = args?.get("eventID") as? String
                val useCompressedModel = args?.get("useCompressedModel") as? Boolean ?: false

                if (id != null && eventID != null) {
                    val sink = eventSinks[eventID]
                    scope.launch {
                        try {
                            val avatar = AvatarManager.load(id, useCompressedModel) { progress ->
                                when (progress) {
                                    is AvatarManager.LoadProgress.Downloading -> sink?.success(progress.progress.toDouble())
                                    is AvatarManager.LoadProgress.Completed -> sink?.success(1.0)
                                    is AvatarManager.LoadProgress.Failed -> sink?.error("Download failed", progress.error.toString(), null)
                                }
                            }
                            result.success(mapOf("id" to avatar.id, "isFromCache" to avatar.isFromCache))
                        } catch (e: AvatarKitException) {
                            result.error(avatarErrorCode(e.error), e.message, null)
                        } catch (e: Exception) {
                            result.error("OPERATION_FAILED", e.message, null)
                        }
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Missing id or eventID", null)
                }
            }
            "cancelLoading" -> {
                val id = call.arguments as? String
                if (id != null) {
                    AvatarManager.cancelLoading(id)
                } else {
                    result.error("INVALID_ARGUMENTS", "ID is null", null)
                }
            }
            "cancelAllLoading" -> {
                AvatarManager.cancelAllLoading()
            }
            "clear" -> {
                val id = call.arguments as? String
                if (id != null) {
                    scope.launch {
                        try {
                            AvatarManager.clear(id)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("OPERATION_FAILED", e.message, null)
                        }
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "ID is null", null)
                }
            }
            "clearAll" -> {
                scope.launch {
                     try {
                        AvatarManager.clearAll()
                        result.success(null)
                    } catch (e: Exception) {
                        result.error("OPERATION_FAILED", e.message, null)
                    }
                }
            }
            "getCacheSize" -> {
                val id = call.arguments as? String
                if (id != null) {
                    scope.launch {
                         try {
                            val size = AvatarManager.getCacheSize(id)
                            result.success(size)
                        } catch (e: Exception) {
                            result.error("OPERATION_FAILED", e.message, null)
                        }
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "ID is null", null)
                }
            }
            "getAllCacheSize" -> {
                scope.launch {
                     try {
                        val size = AvatarManager.getAllCacheSize()
                        result.success(size)
                    } catch (e: Exception) {
                        result.error("OPERATION_FAILED", e.message, null)
                    }
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        scope.cancel()
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        val eventID = arguments as? String
        if (eventID != null && events != null) {
            eventSinks[eventID] = events
        }
    }

    override fun onCancel(arguments: Any?) {
        val eventID = arguments as? String
        if (eventID != null) {
            eventSinks.remove(eventID)
        }
    }
}

class AvatarPlatformViewFactory(private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val arguments = args as? Map<String, Any>
        val id = arguments?.get("id") as? String
        val assetPath = arguments?.get("assetPath") as? String

        val avatar = if (!assetPath.isNullOrEmpty()) {
            try {
                AvatarManager.derive(mapAssetPath(assetPath))
            } catch (e: Exception) {
                null
            }
        } else if (!id.isNullOrEmpty()) {
            AvatarManager.retrieve(id)
        }  else {
            null
        }

        if (avatar != null) {
            Log.d(LOG_TAG, "Creating AvatarPlatformView with id: ${avatar.id}")
            return AvatarPlatformView(context, avatar, viewId, messenger)
        }
        Log.w(LOG_TAG, "Creating PlaceholderPlatformView")
        return PlaceholderPlatformView(context)
    }
}

class AvatarPlatformView(
    context: Context,
    private val avatar: Avatar,
    viewId: Int,
    messenger: BinaryMessenger
) : PlatformView, MethodCallHandler, EventChannel.StreamHandler {
    
    // Assuming AvatarView can be constructed with context and setAvatar or similar
    private val avatarView: AvatarView = AvatarView(context)
    private val methodChannel: MethodChannel = MethodChannel(messenger, "AVATAR_KIT_METHOD_CHANNEL_$viewId")
    private val eventChannel: EventChannel = EventChannel(messenger, "AVATAR_KIT_EVENT_CHANNEL_$viewId")
    private var eventSink: EventChannel.EventSink? = null
    private var lastFrameRateEventMs: Long = 0L
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    
    private val avatarController: AvatarController
        get() = avatarView.controller ?: error("Trying to access avatar controller before it has been initialized")

    init {
        avatarView.init(avatar, scope)
        
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
        setupCallbacks()
    }

    private fun setupCallbacks() {
        avatarController.onConnectionState = { state ->
             val value = when(state) {
                 AvatarController.ConnectionState.Disconnected -> "disconnected"
                 AvatarController.ConnectionState.Connecting -> "connecting"
                 AvatarController.ConnectionState.Connected -> "connected"
                 is AvatarController.ConnectionState.Failed -> "failed"
                 else -> "unknown"
             }
             val map = mutableMapOf("type" to "onConnectionState", "value" to value)
             if (state is AvatarController.ConnectionState.Failed) {
                 map["errorMessage"] = state.exception.message ?: ""
             }
             scope.launch { eventSink?.success(map) }
        }
        
        avatarController.onConversationState = { state ->
             val value = conversationStateToFlutterValue(state)
            scope.launch { eventSink?.success(mapOf("type" to "onConversationState", "value" to value)) }
        }

        avatarController.onError = { error ->
            scope.launch { eventSink?.success(mapOf("type" to "onError", "value" to avatarErrorCode(error))) }
        }

        avatarController.onAnimationState = { type ->
            scope.launch {
                eventSink?.success(mapOf("type" to "onAnimationState", "value" to type.name.lowercase()))
            }
        }

        avatarController.onPlaybackStall = { stalled ->
            scope.launch {
                eventSink?.success(mapOf("type" to "onPlaybackStall", "value" to stalled))
            }
        }

        avatarController.onFrameRateInfo = { info ->
            val nowMs = SystemClock.elapsedRealtime()
            if (nowMs - lastFrameRateEventMs >= FRAME_RATE_EVENT_INTERVAL_MS) {
                lastFrameRateEventMs = nowMs
                scope.launch {
                    eventSink?.success(
                        mapOf(
                            "type" to "onFrameRateInfo",
                            "value" to info.toFlutterMap()
                        )
                    )
                }
            }
        }

        avatarView.onFirstRendering = {
            scope.launch { eventSink?.success(mapOf("type" to "onFirstRendering")) }
        }
    }

    override fun getView(): View {
        return avatarView
    }

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        avatarController.onConnectionState = null
        avatarController.onConversationState = null
        avatarController.onError = null
        avatarController.onAnimationState = null
        avatarController.onPlaybackStall = null
        avatarController.onFrameRateInfo = null
        avatarView.onFirstRendering = null
        avatarView.dispose()
        eventSink = null
        scope.cancel()
    }
    
    override fun onMethodCall(call: MethodCall, result: Result) {
        when(call.method) {
            "start" -> {
                avatarController.start()
                result.success(null)
            }
            "send" -> {
                val args = call.arguments as? Map<String, Any>
                val audioData = args?.get("audioData") as? ByteArray
                val end = args?.get("end") as? Boolean ?: false
                if (audioData != null) {
                    scope.launch {
                        val conversationID = withContext(Dispatchers.IO) {
                            avatarController.send(audioData, end)
                        }
                        result.success(conversationID)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Missing audioData", null)
                }
            }
            "yieldAudioData" -> {
                val args = call.arguments as? Map<String, Any>
                val audioData = args?.get("audioData") as? ByteArray
                val end = args?.get("end") as? Boolean ?: false
                if (audioData != null) {
                    scope.launch {
                        val conversationID = withContext(Dispatchers.IO) {
                            avatarController.yieldAudioData(audioData, end)
                        }
                        result.success(conversationID)
                    }
                } else {
                    result.error("INVALID_ARGUMENTS", "Missing audioData", null)
                }
            }
            "yieldAnimations" -> {
                val args = call.arguments as? Map<String, Any>
                val animations = args?.get("animations") as? List<ByteArray>
                val conversationID = args?.get("conversationID") as? String
                if (animations != null && conversationID != null) {
                    val end = avatarController.yieldFramesData(animations, conversationID)
                    result.success(end)
                } else {
                    result.error("INVALID_ARGUMENTS", "Missing animations or conversationID", null)
                }
            }
            "pause" -> {
                avatarController.pause()
                result.success(null)
            }
            "resume" -> {
                avatarController.resume()
                result.success(null)
            }
            "interrupt" -> {
                avatarController.interrupt()
                result.success(null)
            }
            "close" -> {
                avatarController.close()
                result.success(null)
            }
            "pauseRendering" -> {
                avatarView.pauseRendering()
                result.success(null)
            }
            "resumeRendering" -> {
                avatarView.resumeRendering()
                result.success(null)
            }
            "exportBitmap" -> {
                val bitmap = avatarView.exportBitmap()
                if (bitmap != null) {
                    val stream = java.io.ByteArrayOutputStream()
                    bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
                    result.success(stream.toByteArray())
                } else {
                    result.success(null)
                }
            }
            "isRendering" -> {
                result.success(avatarView.isRenderingEnabled())
            }
            "volume" -> {
                result.success(avatarController.getVolume().toDouble())
            }
            "setVolume" -> {
                val volume = call.arguments as? Double
                if (volume != null) {
                    avatarController.setVolume(volume.toFloat())
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Missing volume", null)
                }
            }
            "setFrameStarvationMode" -> {
                // Dart sends the camelCase enum name; map explicitly to the Kotlin enum
                // (whose constants are SNAKE_CASE) rather than relying on a string transform.
                val native = when (call.arguments as? String) {
                    "audioIndependent" -> FrameStarvationMode.AUDIO_INDEPENDENT
                    "strictSync" -> FrameStarvationMode.STRICT_SYNC
                    else -> null
                }
                if (native != null) {
                    avatarController.frameStarvationMode = native
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Invalid frame starvation mode", null)
                }
            }
            "pointCount" -> {
                result.success(avatarController.pointCount)
            }
            "getAudioTime" -> {
                result.success(avatarController.getAudioTime())
            }
            "renderSize" -> {
                val size = avatarView.renderSize
                result.success(mapOf(
                    "width" to size.width,
                    "height" to size.height,
                ))
            }
            "getBoundingRect" -> {
                val rect = avatarView.getBoundingRect()
                if (rect != null) {
                    result.success(mapOf(
                        "left" to rect.left.toDouble(),
                        "top" to rect.top.toDouble(),
                        "right" to rect.right.toDouble(),
                        "bottom" to rect.bottom.toDouble(),
                    ))
                } else {
                    result.success(null)
                }
            }
            "contentTransform" -> {
                val transform = avatarView.avatarTransform
                result.success(mapOf(
                    "x" to transform.x.toDouble(),
                    "y" to transform.y.toDouble(),
                    "scale" to transform.scale.toDouble(),
                ))
            }
            "setContentTransform" -> {
                val args = call.arguments as? Map<String, Any>
                val x = args?.get("x") as? Double
                val y = args?.get("y") as? Double
                val scale = args?.get("scale") as? Double

                if (x != null && y != null && scale != null) {
                    avatarView.avatarTransform = Transform(x.toFloat(), y.toFloat(), scale.toFloat())
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Missing x, y, or scale", null)
                }
            }
            "frameRateMonitorEnabled" -> {
                result.success(avatarController.frameRateMonitorEnabled)
            }
            "setFrameRateMonitorEnabled" -> {
                val enabled = call.arguments as? Boolean
                if (enabled != null) {
                    avatarController.frameRateMonitorEnabled = enabled
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Missing enabled flag", null)
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}

class PlaceholderPlatformView(context: Context) : PlatformView {
    private val view = View(context)
    override fun getView(): View {
        return view
    }
    override fun dispose() {}
}

private fun mapAssetPath(assetPath: String): String {
    return FlutterInjector
        .instance()
        .flutterLoader()
        .getLookupKeyForAsset(assetPath)
}

private fun avatarErrorCode(error: AvatarError): String {
    return when (error) {
        is AvatarError.AppIDUnrecognized -> "appIDUnrecognized"
        is AvatarError.AvatarIDUnrecognized -> "avatarIDUnrecognized"
        is AvatarError.SessionTokenInvalid -> "sessionTokenInvalid"
        is AvatarError.SessionTokenExpired -> "sessionTokenExpired"
        is AvatarError.FailedToFetchAvatarMetadata -> "failedToFetchAvatarMetadata"
        is AvatarError.InvalidAvatarMetadata -> "invalidAvatarMetadata"
        is AvatarError.FailedToDownloadAvatarAssets -> "failedToDownloadAvatarAssets"
        is AvatarError.InvalidAnimationData -> "invalidAnimationData"
        is AvatarError.InsufficientBalance -> "insufficientBalance"
        is AvatarError.SessionTimeout -> "sessionTimeout"
        is AvatarError.ConcurrentLimitExceeded -> "concurrentLimitExceeded"
        is AvatarError.IncompatibleAvatarAsset -> "incompatibleAvatarAsset"
        is AvatarError.InvalidAudioInput -> "invalidAudioInput"
        is AvatarError.ServerError -> "serverError"
    }
}

private fun FrameRateMonitor.FrameRateInfo.toFlutterMap(): Map<String, Any> {
    // Aggregate real Vulkan GPU render time from per-frame samples.
    val gpuSamples = frames.map { it.gpuRenderMs }.filter { it > 0f }
    val avgGpu: Double = if (gpuSamples.isEmpty()) 0.0
    else gpuSamples.average()

    return mapOf(
        "productionFps" to fps.toDouble(),
        "displayFps" to presentationFps.toDouble(),
        "totalFrameMs" to averageFrameTimeMs.toDouble(),
        "cpuUsagePercent" to cpuUsagePercent,
        "frameP95Ms" to frameIntervalP95Ms.toDouble(),
        "frameP99Ms" to frameIntervalP99Ms.toDouble(),
        "jankRatio50Ms" to jankRatioPercent.toDouble(),
        "avgGpuRenderMs" to avgGpu
    )
}
