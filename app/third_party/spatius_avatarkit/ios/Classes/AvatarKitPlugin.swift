@_spi(Internal) import AvatarKit
import Flutter
import UIKit

@MainActor public class AvatarKitPlugin: NSObject, @preconcurrency FlutterPlugin, @preconcurrency FlutterStreamHandler {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()
        let methodChannel = FlutterMethodChannel(name: "AVATAR_KIT_METHOD_CHANNEL", binaryMessenger: messenger)
        let eventChannel = FlutterEventChannel(name: "AVATAR_KIT_EVENT_CHANNEL", binaryMessenger: messenger)
        let platformViewFactory = AvatarPlatformViewFactory(messenger: messenger, registrar: registrar)
        let avatarKitPlugin = AvatarKitPlugin(registrar: registrar)
        registrar.addMethodCallDelegate(avatarKitPlugin, channel: methodChannel)
        eventChannel.setStreamHandler(avatarKitPlugin)
        registrar.register(platformViewFactory, withId: "AVATAR_VIEW")
    }

    private weak var registrar: FlutterPluginRegistrar?

    private var eventSinks: [String: FlutterEventSink] = [:]

    private init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        super.init()
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "appID":
            result(AvatarSDK.appID)
        case "configuration":
            let configuration = AvatarSDK.configuration
            let region = configuration.region
            let drivingServiceMode = configuration.drivingServiceMode.rawValue
            let logLevel = configuration.logLevel.rawValue
            result([
                "region": region,
                "sampleRate": configuration.audioFormat.sampleRate,
                "inputAudioFormat": configuration.audioFormat.inputAudioFormat.rawValue,
                "opusUplinkEnabled": configuration.audioFormat.opusUplinkEnabled,
                "opusBitrate": configuration.audioFormat.opusBitrate,
                "drivingServiceMode": drivingServiceMode,
                "logLevel": logLevel,
                "renderQuality": renderQualityToName(configuration.renderQuality),
            ])
        case "initialize":
            if let args = call.arguments as? [String: Any],
               let appID = args["appID"] as? String,
               let sampleRate = args["sampleRate"] as? Int,
               let drivingServiceMode = DrivingServiceMode(rawValue: args["drivingServiceMode"] as? String ?? ""),
               let logLevel = LogLevel(rawValue: args["logLevel"] as? String ?? "")
            {
                let region = (args["region"] as? String) ?? DEFAULT_REGION
                let pluginVersion = (args["pluginVersion"] as? String) ?? ""
                AvatarSDK.inject([
                    "sdk_package": "spatius-flutter-sdk",
                    "sdk_version": pluginVersion,
                ])
                let renderQuality = renderQualityFromName(args["renderQuality"] as? String)
                let inputAudioFormat = AudioCodec(rawValue: (args["inputAudioFormat"] as? String) ?? "") ?? .pcm
                let opusBitrate = (args["opusBitrate"] as? Int) ?? kDefaultOpusBitrate
                let opusUplinkEnabled = (args["opusUplinkEnabled"] as? Bool) ?? false
                let configuration = Configuration(
                    region: region,
                    audioFormat: AudioFormat(
                        sampleRate: sampleRate,
                        inputAudioFormat: inputAudioFormat,
                        opusBitrate: opusBitrate,
                        opusUplinkEnabled: opusUplinkEnabled
                    ),
                    drivingServiceMode: drivingServiceMode,
                    logLevel: logLevel,
                    renderQuality: renderQuality
                )
                AvatarSDK.initialize(appID: appID, configuration: configuration)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "sessionToken":
            result(AvatarSDK.sessionToken)
        case "setSessionToken":
            if let sessionToken = call.arguments as? String {
                AvatarSDK.sessionToken = sessionToken
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "userID":
            result(AvatarSDK.userID)
        case "setUserID":
            if let userID = call.arguments as? String {
                AvatarSDK.userID = userID
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "version":
            result(AvatarSDK.version)
        case "setRenderQuality":
            if let name = call.arguments as? String {
                AvatarSDK.setRenderQuality(renderQualityFromName(name))
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "quality is null", details: nil))
            }
        case "setRenderResolutionCap":
            if let args = call.arguments as? [String: Any],
               let enabled = args["enabled"] as? Bool {
                let maxHeight = (args["maxHeight"] as? Int) ?? 1440
                AvatarSDK.setRenderResolutionCap(enabled: enabled, maxHeight: maxHeight)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "enabled is null", details: nil))
            }
        // ---- Test-only SPI (host-mode integration tests) ----
        case "setDrivingServiceModeForTesting":
            if let mode = call.arguments as? String,
               let m = DrivingServiceMode(rawValue: mode) {
                AvatarSDK.setDrivingServiceModeForTesting(m)
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "mode is invalid", details: nil))
            }
        case "setAudioFormatForTesting":
            if let args = call.arguments as? [String: Any],
               let sampleRate = args["sampleRate"] as? Int {
                let codec = AudioCodec(rawValue: (args["inputAudioFormat"] as? String) ?? "") ?? .pcm
                AvatarSDK.setAudioFormatForTesting(
                    AudioFormat(
                        sampleRate: sampleRate,
                        inputAudioFormat: codec,
                        opusBitrate: (args["opusBitrate"] as? Int) ?? kDefaultOpusBitrate,
                        opusUplinkEnabled: (args["opusUplinkEnabled"] as? Bool) ?? false
                    )
                )
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "audioFormat is invalid", details: nil))
            }
        case "encodeWholePcmToOggForTesting":
            if let args = call.arguments as? [String: Any],
               let pcm = (args["pcm"] as? FlutterStandardTypedData)?.data,
               let sampleRate = args["sampleRate"] as? Int {
                let bitrate = (args["bitrate"] as? Int) ?? kDefaultOpusBitrate
                let ogg = AvatarSDK.encodeWholePcmToOggForTesting(pcm, sampleRate: sampleRate, bitrate: bitrate)
                result(ogg.map { FlutterStandardTypedData(bytes: $0) })
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "pcm or sampleRate is null", details: nil))
            }
        case "keyframeCount":
            if let raw = (call.arguments as? FlutterStandardTypedData)?.data {
                result(AvatarSDK.keyframeCount(inRawAnimationMessage: raw))
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "rawMessage is null", details: nil))
            }
        case "sliceRawAnimationMessage":
            if let args = call.arguments as? [String: Any],
               let raw = (args["rawMessage"] as? FlutterStandardTypedData)?.data,
               let startFrame = args["startFrame"] as? Int,
               let endFrame = args["endFrame"] as? Int {
                let sliced = AvatarSDK.sliceRawAnimationMessage(raw, startFrame: startFrame, endFrame: endFrame)
                result(sliced.map { FlutterStandardTypedData(bytes: $0) })
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "missing rawMessage/startFrame/endFrame", details: nil))
            }
        case "isDeviceSupported":
            Task(priority: .userInitiated) {
                result(await AvatarSDK.isDeviceSupported())
            }
        case "deviceScore":
            Task(priority: .userInitiated) {
                let score = await AvatarSDK.deviceScore()
                result(["cpuScore": score.cpuScore, "gpuScore": score.gpuScore])
            }
        case "derive":
            if var assetPath = call.arguments as? String {
                Task(priority: .userInitiated) {
                    do {
                        guard let registrar = self.registrar else {
                            result(FlutterError(code: "OPERATION_FAILED", message: "FlutterPluginRegistrar not available", details: nil))
                            return
                        }
                        assetPath = assetPath.hasSuffix("/") ? String(assetPath.dropLast()) : assetPath
                        let key = registrar.lookupKey(forAsset: assetPath)
                        guard let path = Bundle.main.path(forResource: key, ofType: nil) else {
                            result(FlutterError(code: avatarErrorCode(.avatarAssetMissing), message: nil, details: nil))
                            return
                        }
                        let avatar = try AvatarManager.shared.derive(assetPath: path)
                        result(["id": avatar.id, "isFromCache": avatar.isFromCache, "assetPath": assetPath])
                    } catch {
                        if let error = error as? AvatarError {
                            result(FlutterError(code: avatarErrorCode(error), message: nil, details: nil))
                        } else {
                            result(FlutterError(code: "OPERATION_FAILED", message: error.localizedDescription, details: nil))
                        }
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "retrieve":
            Task(priority: .userInitiated) {
                if let id = call.arguments as? String {
                    if let avatar = AvatarManager.shared.retrieve(id: id) {
                        result(["id": avatar.id, "isFromCache": avatar.isFromCache])
                    } else {
                        result(nil)
                    }
                 } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
                }
            }
        case "load":
            if let args = call.arguments as? [String: Any],
               let id = args["id"] as? String,
               let eventID = args["eventID"] as? String
            {
                let useCompressedModel = args["useCompressedModel"] as? Bool ?? false
                let sink = eventSinks[eventID]
                Task(priority: .userInitiated) {
                    do {
                        let avatar = try await AvatarManager.shared.load(id: id, useCompressedModel: useCompressedModel) { sink?($0.fractionCompleted) }
                        result(["id": avatar.id, "isFromCache": avatar.isFromCache])
                    } catch {
                        if let error = error as? AvatarError {
                            result(FlutterError(code: avatarErrorCode(error), message: nil, details: nil))
                        } else {
                            result(FlutterError(code: "OPERATION_FAILED", message: error.localizedDescription, details: nil))
                        }
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "cancelLoading":
            if let id = call.arguments as? String {
                Task(priority: .userInitiated) {
                    await AvatarManager.shared.cancelLoading(id: id)
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "cancelAllLoading":
            Task(priority: .userInitiated) {
                await AvatarManager.shared.cancelAllLoading()
            }
        case "clear":
            if let id = call.arguments as? String {
                Task(priority: .userInitiated) {
                    do {
                        try AvatarManager.shared.clear(id: id)
                        result(nil)
                    } catch {
                        result(FlutterError(code: "OPERATION_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "clearAll":
            Task(priority: .userInitiated) {
                do {
                    try AvatarManager.shared.clearAll()
                    result(nil)
                } catch {
                    result(FlutterError(code: "OPERATION_FAILED", message: error.localizedDescription, details: nil))
                }
            }
        case "getCacheSize":
            if let id = call.arguments as? String {
                Task(priority: .userInitiated) {
                    do {
                        let size = try AvatarManager.shared.getCacheSize(id: id)
                        result(size)
                    } catch {
                        result(FlutterError(code: "OPERATION_FAILED", message: error.localizedDescription, details: nil))
                    }
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "getAllCacheSize":
            Task(priority: .userInitiated) {
                do {
                    let size = try AvatarManager.shared.getAllCacheSize()
                    result(size)
                } catch {
                    result(FlutterError(code: "OPERATION_FAILED", message: error.localizedDescription, details: nil))
                }
            }
        default:
            result(FlutterError(code: "UNIMPLEMENTED", message: "Unimplemented method: \(call.method)", details: nil))
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink sink: @escaping FlutterEventSink) -> FlutterError? {
        if let eventID = arguments as? String {
            eventSinks[eventID] = sink
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        if let eventID = arguments as? String {
            eventSinks[eventID] = nil
        }
        return nil
    }
}

@MainActor class AvatarPlatformViewFactory: NSObject, @preconcurrency FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private weak var registrar: FlutterPluginRegistrar?
    
    init(messenger: FlutterBinaryMessenger, registrar: FlutterPluginRegistrar) {
        self.messenger = messenger
        self.registrar = registrar
        super.init()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewID: Int64, arguments args: Any?) -> FlutterPlatformView {
        guard let arguments = args as? [String: Any], 
              let id = arguments["id"] as? String, 
              var assetPath = arguments["assetPath"] as? String 
        else {
            debugPrint("⚠️ Failed to create AvatarPlatformView: INVALID_ARGUMENTS")
            return PlaceholderPlatformView(frame: frame)
        }

        if !assetPath.isEmpty {
            do {
                guard let registrar = self.registrar else {
                    debugPrint("⚠️ Failed to create AvatarPlatformView: Registrar not available")
                    return PlaceholderPlatformView(frame: frame)
                }
                assetPath = assetPath.hasSuffix("/") ? String(assetPath.dropLast()) : assetPath
                let key = registrar.lookupKey(forAsset: assetPath)
                guard let path = Bundle.main.path(forResource: key, ofType: nil) else {
                    debugPrint("⚠️ Failed to create AvatarPlatformView: Asset not found at path: \(assetPath)")
                    return PlaceholderPlatformView(frame: frame)
                }
                let avatar = try AvatarManager.shared.derive(assetPath: path)
                return AvatarPlatformView(avatar: avatar, frame: frame, viewID: viewID, messenger: messenger)
            } catch {
                debugPrint("⚠️ Failed to create AvatarPlatformView: \(error.localizedDescription)")
                return PlaceholderPlatformView(frame: frame)
            }
        } else if let avatar = AvatarManager.shared.retrieve(id: id) {
            return AvatarPlatformView(avatar: avatar, frame: frame, viewID: viewID, messenger: messenger)
        } else {
            debugPrint("⚠️ Failed to create AvatarPlatformView: Avatar not found")
            return PlaceholderPlatformView(frame: frame)
        }        
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

@MainActor class AvatarPlatformView: NSObject, @preconcurrency FlutterPlatformView {
    fileprivate var eventSink: FlutterEventSink?
    private let avatarView: AvatarView
    private let methodChannel: FlutterMethodChannel
    private let eventChannel: FlutterEventChannel
    private let streamHandler: WeakStreamHandler

    init(avatar: Avatar, frame: CGRect, viewID: Int64, messenger: FlutterBinaryMessenger) {
        avatarView = AvatarView(avatar: avatar)
        methodChannel = FlutterMethodChannel(name: "AVATAR_KIT_METHOD_CHANNEL_\(viewID)", binaryMessenger: messenger)
        eventChannel = FlutterEventChannel(name: "AVATAR_KIT_EVENT_CHANNEL_\(viewID)", binaryMessenger: messenger)
        streamHandler = WeakStreamHandler()
        super.init()
        streamHandler.owner = self
        avatarView.frame = frame
        methodChannel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call, result: result)
        }
        eventChannel.setStreamHandler(streamHandler)
        setupCallbacks()
    }

    isolated deinit {
        methodChannel.setMethodCallHandler(nil)
        eventChannel.setStreamHandler(nil)
    }

    private func setupCallbacks() {
        avatarView.onFirstRendering = { [weak self] in
            self?.eventSink?(["type": "onFirstRendering"])
        }
        avatarController.onConnectionState = { [weak self] state in
            switch state {
            case .disconnected:
                self?.eventSink?(["type": "onConnectionState", "value": "disconnected"])
            case .connecting:
                self?.eventSink?(["type": "onConnectionState", "value": "connecting"])
            case .connected:
                self?.eventSink?(["type": "onConnectionState", "value": "connected"])
            case .failed(let error):
                var errorMessage = error.localizedDescription
                let nsError = error as NSError
                errorMessage += " [\(nsError.domain):\(nsError.code)]"

                if let avatarError = error as? AvatarError {
                    errorMessage += " [\(avatarErrorCode(avatarError))]"
                }

                if let failingURL = nsError.userInfo[NSURLErrorFailingURLStringErrorKey] as? String {
                    errorMessage += " [url:\(failingURL)]"
                }

                self?.eventSink?([
                    "type": "onConnectionState",
                    "value": "failed",
                    "errorMessage": errorMessage,
                ])
            @unknown default:
                assertionFailure() 
            }
        }
        avatarController.onConversationState = { [weak self] state in
            switch state {
            case .idle:
                self?.eventSink?(["type": "onConversationState", "value": "idle"])
            case .paused:
                self?.eventSink?(["type": "onConversationState", "value": "paused"])
            case .playing:
                self?.eventSink?(["type": "onConversationState", "value": "playing"])
            @unknown default:
                assertionFailure()
            }
        }
        avatarController.onError = { [weak self] error in
            self?.eventSink?(["type": "onError", "value": avatarErrorCode(error)])
        }
        avatarController.onAnimationState = { [weak self] type in
            self?.eventSink?(["type": "onAnimationState", "value": type.rawValue])
        }
        avatarController.onPlaybackStall = { [weak self] stalled in
            self?.eventSink?(["type": "onPlaybackStall", "value": stalled])
        }
        avatarController.onFrameRateInfo = { [weak self] info in
            guard let self = self else { return }
            // Throttle to ~10 events/s to match Android.
            let nowMs = CACurrentMediaTime() * 1000
            if nowMs - self.lastFrameRateEventMs < 100 { return }
            self.lastFrameRateEventMs = nowMs

            // Aggregate real Metal GPU render time from per-frame samples.
            let gpuSamples = info.frames.map { $0.gpuRenderMs }.filter { $0 > 0 }
            let avgGpu: Float = gpuSamples.isEmpty
                ? 0
                : gpuSamples.reduce(0, +) / Float(gpuSamples.count)

            self.eventSink?([
                "type": "onFrameRateInfo",
                "value": [
                    "productionFps": Double(info.fps),
                    "displayFps": Double(info.presentationFps),
                    "totalFrameMs": Double(info.averageFrameTimeMs),
                    "cpuUsagePercent": info.cpuUsagePercent,
                    "frameP95Ms": Double(info.frameIntervalP95Ms),
                    "frameP99Ms": Double(info.frameIntervalP99Ms),
                    "jankRatio50Ms": Double(info.jankRatioPercent),
                    "avgGpuRenderMs": Double(avgGpu),
                ],
            ])
        }
    }

    private var lastFrameRateEventMs: Double = 0

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "start":
            avatarController.start()
            result(nil)
        case "send":
            if let args = call.arguments as? [String: Any],
               let audio = args["audioData"] as? FlutterStandardTypedData,
               let end = args["end"] as? Bool
            {
                let conversationID = avatarController.send(audio.data, end: end)
                result(conversationID)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "yieldAudioData":
            if let args = call.arguments as? [String: Any],
               let audio = args["audioData"] as? FlutterStandardTypedData,
               let end = args["end"] as? Bool
            {
                // The audio format comes from Configuration.audioFormat at
                // initialize; there is no per-call override any more.
                result(avatarController.yieldAudioData(audio.data, end: end))
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "yieldAnimations":
            if let args = call.arguments as? [String: Any],
               let animations = args["animations"] as? [FlutterStandardTypedData],
               let conversationID = args["conversationID"] as? String
            {
                let end = avatarController.yieldFramesData(animations.map { $0.data }, conversationID: conversationID)
                result(end)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "pause":
            avatarController.pause()
            result(nil)
        case "resume":
            avatarController.resume()
            result(nil)
        case "interrupt":
            avatarController.interrupt()
            result(nil)
        case "close":
            avatarController.close()
            result(nil)
        case "pauseRendering":
            avatarView.pauseRendering()
            result(nil)
        case "resumeRendering":
            avatarView.resumeRendering()
            result(nil)
        case "exportBitmap":
            if let image = avatarView.exportBitmap(),
               let data = image.pngData() {
                result(FlutterStandardTypedData(bytes: data))
            } else {
                result(nil)
            }
        case "isRendering":
            // iOS 1.0.0: AvatarController.isRendering became internal — use the view-side getter instead.
            result(avatarView.isRenderingEnabled())
        case "volume":
            result(Double(avatarController.getVolume()))
        case "setVolume":
            if let volume = call.arguments as? Double {
                avatarController.setVolume(Float(volume))
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "setFrameStarvationMode":
            if let name = call.arguments as? String,
               let mode = FrameStarvationMode(rawValue: name) {
                avatarController.frameStarvationMode = mode
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid frame starvation mode", details: nil))
            }
        case "pointCount":
            result(avatarController.pointCount)
        case "getAudioTime":
            result(avatarController.getAudioTime())
        case "renderSize":
            let size = avatarView.renderSize
            result(["width": Double(size.width), "height": Double(size.height)])
        case "getBoundingRect":
            if let rect = avatarView.getBoundingRect() {
                result([
                    "left": Double(rect.minX),
                    "top": Double(rect.minY),
                    "right": Double(rect.maxX),
                    "bottom": Double(rect.maxY),
                ])
            } else {
                result(nil)
            }
        case "contentTransform":
            let transform = avatarView.avatarTransform
            result(["x": Double(transform.x), "y": Double(transform.y), "scale": Double(transform.scale)])
        case "setContentTransform":
            if let args = call.arguments as? [String: Any],
               let x = args["x"] as? Double,
               let y = args["y"] as? Double,
               let scale = args["scale"] as? Double
            {
                avatarView.avatarTransform = Transform(x: Float(x), y: Float(y), scale: Float(scale))
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        case "frameRateMonitorEnabled":
            result(avatarController.frameRateMonitorEnabled)
        case "setFrameRateMonitorEnabled":
            if let enabled = call.arguments as? Bool {
                avatarController.frameRateMonitorEnabled = enabled
                result(nil)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: nil, details: nil))
            }
        default:
            result(FlutterError(code: "UNIMPLEMENTED", message: "Unimplemented method: \(call.method)", details: nil))
        }
    }
    
    private var avatarController: AvatarController { avatarView.controller }

    func view() -> UIView { avatarView }
}

@MainActor private class WeakStreamHandler: NSObject, @preconcurrency FlutterStreamHandler {
    weak var owner: AvatarPlatformView?

    func onListen(withArguments arguments: Any?, eventSink sink: @escaping FlutterEventSink) -> FlutterError? {
        owner?.eventSink = sink
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        owner?.eventSink = nil
        return nil
    }
}

@MainActor class PlaceholderPlatformView: NSObject, @preconcurrency FlutterPlatformView {
    private let placeholderView: UIView

    init(frame: CGRect) {
        placeholderView = UIView(frame: frame)
        placeholderView.backgroundColor = .clear
        super.init()
    }

    func view() -> UIView { placeholderView }
}

/// Map a Flutter render-quality name to the native enum. Unknown / nil → .ultra.
private func renderQualityFromName(_ name: String?) -> RenderQuality {
    switch name {
    case "standard": return .standard
    case "high": return .high
    default: return .ultra
    }
}

private func renderQualityToName(_ quality: RenderQuality) -> String {
    switch quality {
    case .standard: return "standard"
    case .high: return "high"
    case .ultra: return "ultra"
    @unknown default: return "ultra"
    }
}

private func avatarErrorCode(_ error: AvatarError) -> String {
    switch error {
    case .appIDUnrecognized:
        return "appIDUnrecognized"
    case .avatarIDUnrecognized:
        return "avatarIDUnrecognized"
    case .avatarAssetMissing:
        return "avatarAssetMissing"
    case .sessionTokenInvalid:
        return "sessionTokenInvalid"
    case .sessionTokenExpired:
        return "sessionTokenExpired"
    case .failedToFetchAvatarMetadata:
        return "failedToFetchAvatarMetadata"
    case .invalidAvatarMetadata:
        return "invalidAvatarMetadata"
    case .failedToDownloadAvatarAssets:
        return "failedToDownloadAvatarAssets"
    case .invalidAnimationData:
        return "invalidAnimationData"
    case .insufficientBalance:
        return "insufficientBalance"
    case .sessionTimeout:
        return "sessionTimeout"
    case .concurrentLimitExceeded:
        return "concurrentLimitExceeded"
    case .incompatibleAvatarAsset:
        return "incompatibleAvatarAsset"
    case .invalidAudioInput:
        return "invalidAudioInput"
    case .serverError:
        return "serverError"
    @unknown default:
        return "serverError"
    }
}
