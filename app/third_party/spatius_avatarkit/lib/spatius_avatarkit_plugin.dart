import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'spatius_avatarkit_platform.dart';

final AvatarKitPlatform _platform = AvatarKitPlatform.instance;

/// Default deployment region request. `auto` lets the SDK pick the access
/// region at init via the bootstrap service; on failure it falls back to a
/// built-in default. Internal; subject to change.
const String kDefaultRegion = 'auto';

/// Default Opus bitrate (bits/sec) for the SDK-encoded uplink.
const int kDefaultOpusBitrate = 48000;

class Configuration {
  /// Deployment region (e.g. `us-west`). Defaults to [kDefaultRegion] (`auto`),
  /// which resolves the access region from the backend at init; pass an explicit
  /// value to skip resolution and use it directly.
  /// Not intended to be set by SDK users in normal use.
  final String region;
  final AudioFormat audioFormat;
  final DrivingServiceMode drivingServiceMode;
  final LogLevel logLevel;

  /// Render quality tier. Defaults to [RenderQuality.ultra].
  final RenderQuality renderQuality;

  const Configuration({
    this.region = kDefaultRegion,
    this.audioFormat = const AudioFormat(),
    this.drivingServiceMode = DrivingServiceMode.direct,
    this.logLevel = LogLevel.off,
    this.renderQuality = RenderQuality.ultra,
  });
}

/// Codec of the audio the host feeds into the SDK.
/// Mirrors native `AudioCodec` (iOS `.pcm`/`.opus`, Android `PCM`/`OPUS`).
enum AudioCodec {
  /// Raw PCM16, no compression (default).
  pcm,

  /// Ogg Opus. The SDK decodes it to PCM locally for playback and forwards the
  /// raw Ogg upstream unchanged (never re-encoded).
  opus;

  factory AudioCodec.fromName(String name) {
    final lower = name.toLowerCase();
    return AudioCodec.values.where((e) => e.name == lower).first;
  }
}

class AudioFormat {
  final int channelCount = 1;

  /// Audio sample rate in Hz. When [inputAudioFormat] is [AudioCodec.opus] the
  /// native SDK normalizes this to 48000 (the fixed Opus decode rate).
  final int sampleRate;

  /// Codec of the audio the host feeds via `send`. Defaults to [AudioCodec.pcm].
  final AudioCodec inputAudioFormat;

  /// Whether the SDK may Opus-encode the uplink. Only takes effect in
  /// [DrivingServiceMode.direct]. Defaults to `true` — the uplink drops to
  /// roughly an eighth of the bytes, which matters most on the mobile networks
  /// where playback stalls actually happen. Pass `false` to keep the raw PCM
  /// uplink (e.g. on low-end devices where the encode cost is not worth it).
  /// With PCM input, [sampleRate] must be one of 8000/16000/24000/48000;
  /// otherwise the native SDK falls back to PCM.
  final bool opusUplinkEnabled;

  /// Target Opus bitrate in bits/sec for the SDK-encoded uplink.
  final int opusBitrate;

  const AudioFormat({
    this.sampleRate = 16000,
    this.inputAudioFormat = AudioCodec.pcm,
    this.opusUplinkEnabled = true,
    this.opusBitrate = kDefaultOpusBitrate,
  });
}

enum DrivingServiceMode {
  direct,
  backend;

  factory DrivingServiceMode.fromName(String name) {
    final lower = name.toLowerCase();
    return DrivingServiceMode.values.where((e) => e.name == lower).first;
  }
}

/// Render quality tier. Mirrors native `RenderQuality`
/// (iOS `.standard/.high/.ultra`, Android `STANDARD/HIGH/ULTRA`).
/// Defaults to [ultra] (no quality loss).
enum RenderQuality {
  standard,
  high,
  ultra;

  factory RenderQuality.fromName(String name) {
    final lower = name.toLowerCase();
    return RenderQuality.values.where((e) => e.name == lower).first;
  }
}

/// How playback behaves when animation frames can't keep up with audio.
/// Mirrors native `FrameStarvationMode`
/// (iOS `.audioIndependent/.strictSync`, Android `AUDIO_INDEPENDENT/STRICT_SYNC`).
/// Defaults to [audioIndependent] (previous behavior, no regression).
enum FrameStarvationMode {
  /// Audio keeps playing while animation catches up (previous behavior).
  audioIndependent,

  /// Audio pauses until frames arrive, keeping audio and animation strictly in
  /// sync. Pause/resume is reported via [AvatarController.onPlaybackStall].
  strictSync;

  factory FrameStarvationMode.fromName(String name) {
    final lower = name.toLowerCase();
    return FrameStarvationMode.values.where((e) => e.name == lower).first;
  }
}

enum LogLevel {
  off,
  error,
  warning,
  all;

  factory LogLevel.fromName(String name) {
    final lower = name.toLowerCase();
    return LogLevel.values.where((e) => e.name == lower).first;
  }
}

enum ConnectionState {
  disconnected,
  connecting,
  connected,
  failed;

  factory ConnectionState.fromName(String name) {
    return ConnectionState.values.where((e) => e.name == name).first;
  }
}

enum ConversationState {
  idle,
  paused,
  playing;

  static ConversationState? fromNameOrNull(String name) {
    return ConversationState.values.where((e) => e.name == name).firstOrNull;
  }

  factory ConversationState.fromName(String name) {
    final state = fromNameOrNull(name);
    if (state == null) {
      throw ArgumentError.value(name, 'name', 'Unknown conversation state');
    }
    return state;
  }
}

/// Animation type reported by `AvatarController.onAnimationState`.
/// Mirrors iOS / Android `AnimationType`.
enum AnimationType {
  idle,
  mono;

  static AnimationType? fromNameOrNull(String? name) {
    if (name == null) return null;
    return AnimationType.values.where((e) => e.name == name).firstOrNull;
  }
}

class Transform {
  static const identity = Transform();

  final double x;
  final double y;
  final double scale;

  const Transform({this.x = 0.0, this.y = 0.0, this.scale = 1.0});
}

enum AvatarError {
  appIDUnrecognized,
  avatarIDUnrecognized,
  avatarAssetMissing,
  sessionTokenInvalid,
  sessionTokenExpired,
  failedToFetchAvatarMetadata,
  invalidAvatarMetadata,
  failedToDownloadAvatarAssets,
  invalidAnimationData,
  insufficientBalance,
  sessionTimeout,
  concurrentLimitExceeded,
  incompatibleAvatarAsset,

  /// Audio handed to the SDK does not match `audioFormat.inputAudioFormat`.
  /// Raised for Opus input that is neither Ogg Opus nor a bare Opus packet
  /// (e.g. WebM or MP4, which the SDK does not demux), is stereo, or switches
  /// shape mid-conversation.
  invalidAudioInput,
  serverError;

  static AvatarError? fromNameOrNull(String name) {
    return AvatarError.values.where((e) => e.name == name).firstOrNull;
  }
}

class FrameRateInfo {
  final double productionFps;
  final double displayFps;
  final double stage1Ms;
  final double stage2Ms;
  final double renderMs;
  final double totalFrameMs;
  final double idleMs;
  final double cpuUsagePercent;
  final double frameP95Ms;
  final double frameP99Ms;
  final double jankRatio50Ms;

  /// Sliding-window average of real GPU render time (ms). Measured natively
  /// via Metal `gpuStartTime/gpuEndTime` on iOS and Vulkan `vkCmdWriteTimestamp`
  /// on Android. 0 before the first completed frame.
  final double avgGpuRenderMs;

  const FrameRateInfo({
    required this.productionFps,
    required this.displayFps,
    required this.stage1Ms,
    required this.stage2Ms,
    required this.renderMs,
    required this.totalFrameMs,
    required this.idleMs,
    required this.cpuUsagePercent,
    required this.frameP95Ms,
    required this.frameP99Ms,
    required this.jankRatio50Ms,
    required this.avgGpuRenderMs,
  });

  factory FrameRateInfo.fromJson(Map<String, dynamic> json) {
    double asDouble(String key) {
      final value = json[key];
      if (value is num) return value.toDouble();
      return 0.0;
    }

    return FrameRateInfo(
      productionFps: asDouble('productionFps'),
      displayFps: asDouble('displayFps'),
      stage1Ms: asDouble('stage1Ms'),
      stage2Ms: asDouble('stage2Ms'),
      renderMs: asDouble('renderMs'),
      totalFrameMs: asDouble('totalFrameMs'),
      idleMs: asDouble('idleMs'),
      cpuUsagePercent: asDouble('cpuUsagePercent'),
      frameP95Ms: asDouble('frameP95Ms'),
      frameP99Ms: asDouble('frameP99Ms'),
      jankRatio50Ms: asDouble('jankRatio50Ms'),
      avgGpuRenderMs: asDouble('avgGpuRenderMs'),
    );
  }
}

abstract class AvatarSDK {
  static Future<String> appID() {
    return _platform.appID();
  }

  static Future<Configuration> configuration() {
    return _platform.configuration();
  }

  static Future<void> initialize(
      {required String appID, required Configuration configuration}) {
    return _platform.initialize(appID: appID, configuration: configuration);
  }

  static Future<String> sessionToken() {
    return _platform.sessionToken();
  }

  static Future<void> setSessionToken(String sessionToken) {
    return _platform.setSessionToken(sessionToken);
  }

  static Future<String> userID() {
    return _platform.userID();
  }

  static Future<void> setUserID(String userID) {
    return _platform.setUserID(userID);
  }

  static Future<String> version() {
    return _platform.version();
  }

  static Future<bool> isDeviceSupported() {
    return _platform.isDeviceSupported();
  }

  /// Run CPU + GPU micro-benchmarks and return their scores.
  ///
  /// Used by `isDeviceSupported()` internally; exposed for tests / diagnostics.
  /// Aligned with iOS / Android `AvatarSDK.deviceScore()`.
  static Future<DeviceScore> deviceScore() {
    return _platform.deviceScore();
  }

  /// Update the global render quality tier at runtime. Takes effect on the
  /// next rendered frame. Aligned with iOS / Android `setRenderQuality`.
  static Future<void> setRenderQuality(RenderQuality quality) {
    return _platform.setRenderQuality(quality);
  }

  /// Cap the internal render resolution height. When [enabled] and a view's
  /// drawable height exceeds [maxHeight], rendering is done at [maxHeight]
  /// (preserving aspect) to bound GPU/bandwidth cost. Aligned with iOS /
  /// Android `setRenderResolutionCap`.
  static Future<void> setRenderResolutionCap(
      {required bool enabled, int maxHeight = 1440}) {
    return _platform.setRenderResolutionCap(
        enabled: enabled, maxHeight: maxHeight);
  }

  // ========== Test-only SPI ==========
  // Aligned with iOS `@_spi(Internal)` / Android `*ForTesting` / Web
  // `*ForTesting`. Used only by host-mode integration tests to swap the
  // driving service mode at runtime and to slice raw protobuf animation
  // messages so a recorded fixture can be replayed in arbitrary chunks.
  // Do NOT call from production code.

  /// Flip the driving service mode without re-initializing the SDK.
  /// @internal Test-only SPI.
  static Future<void> setDrivingServiceModeForTesting(DrivingServiceMode mode) {
    return _platform.setDrivingServiceModeForTesting(mode);
  }

  /// Swap the audio format without re-initializing the SDK. All other
  /// configuration fields are preserved. `inputAudioFormat` is otherwise fixed
  /// at initialize time, so the Opus cases have no other way to flip it.
  /// Same caller contract as [setDrivingServiceModeForTesting].
  /// @internal Test-only SPI.
  static Future<void> setAudioFormatForTesting(AudioFormat audioFormat) {
    return _platform.setAudioFormatForTesting(audioFormat);
  }

  /// Encode PCM16 (mono, little-endian) into ONE continuous Ogg Opus stream —
  /// headers, audio pages and the EOS page — as a host feeding a whole
  /// utterance in a single call would produce. Returns null if the encoder
  /// can't be created (unsupported sample rate / codec unavailable).
  /// @internal Test-only SPI.
  static Future<Uint8List?> encodeWholePcmToOggForTesting(
      Uint8List pcm, int sampleRate,
      {int? bitrate}) {
    return _platform.encodeWholePcmToOggForTesting(pcm, sampleRate,
        bitrate: bitrate);
  }

  /// Count keyframes in a raw protobuf `Message` payload (as captured via
  /// the native `onRawAnimationData` hook). Returns 0 on decode failure.
  /// @internal Test-only SPI.
  static Future<int> keyframeCount(Uint8List rawMessage) {
    return _platform.keyframeCount(rawMessage);
  }

  /// Slice a raw protobuf `Message` to a sub-range of its keyframes,
  /// preserving avatar_id and rewriting `end` only when the slice covers
  /// through the original last frame. Returns null on out-of-range or decode failure.
  /// @internal Test-only SPI.
  static Future<Uint8List?> sliceRawAnimationMessage(
      Uint8List rawMessage, int startFrame, int endFrame) {
    return _platform.sliceRawAnimationMessage(rawMessage, startFrame, endFrame);
  }
}

class DeviceScore {
  final int cpuScore;
  final int gpuScore;

  const DeviceScore({required this.cpuScore, required this.gpuScore});

  factory DeviceScore.fromJson(Map<String, dynamic> json) {
    int asInt(String key) {
      final v = json[key];
      if (v is num) return v.toInt();
      return 0;
    }

    return DeviceScore(cpuScore: asInt('cpuScore'), gpuScore: asInt('gpuScore'));
  }
}

class AvatarManager {
  static final AvatarManager shared = AvatarManager._init();

  AvatarManager._init();

  Future<Avatar> derive(String assetPath) {
    return _platform.derive(assetPath);
  }

  Future<Avatar?> retrieve({required String id}) {
    return _platform.retrieve(id: id);
  }

  Future<Avatar> load(
      {required String id, bool useCompressedModel = false, void Function(double progress)? onProgress}) {
    return _platform.load(id: id, useCompressedModel: useCompressedModel, onProgress: onProgress);
  }

  Future<void> cancelLoading({required String id}) {
    return _platform.cancelLoading(id: id);
  }

  Future<void> cancelAllLoading() {
    return _platform.cancelAllLoading();
  }

  Future<void> clear({required String id}) {
    return _platform.clear(id: id);
  }

  Future<void> clearAll() {
    return _platform.clearAll();
  }

  Future<int> getCacheSize({required String id}) {
    return _platform.getCacheSize(id: id);
  }

  Future<int> getAllCacheSize() {
    return _platform.getAllCacheSize();
  }
}

class Avatar {
  final String id;
  final bool isFromCache;
  final String assetPath;

  const Avatar(
      {required this.id, required this.isFromCache, required this.assetPath});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
        id: json['id'] as String,
        isFromCache: json['isFromCache'] as bool,
        assetPath: json['assetPath'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isFromCache': isFromCache,
      'assetPath': assetPath,
    };
  }
}

class AvatarWidget extends StatelessWidget {
  final Avatar avatar;
  final void Function(AvatarController controller) onPlatformViewCreated;

  const AvatarWidget({
    super.key,
    required this.avatar,
    required this.onPlatformViewCreated,
  });

  @override
  Widget build(BuildContext context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'AVATAR_VIEW',
          creationParams: avatar.toJson(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (viewID) =>
              onPlatformViewCreated(AvatarController._init(viewID: viewID)),
        );
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'AVATAR_VIEW',
          creationParams: avatar.toJson(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (viewID) =>
              onPlatformViewCreated(AvatarController._init(viewID: viewID)),
        );
      default:
        return Placeholder();
    }
  }
}

class AvatarController {
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  AvatarController._init({required int viewID})
      : _methodChannel = MethodChannel('AVATAR_KIT_METHOD_CHANNEL_$viewID'),
        _eventChannel = EventChannel('AVATAR_KIT_EVENT_CHANNEL_$viewID') {
    _eventChannel.receiveBroadcastStream().listen((event) {
      final map = Map<String, dynamic>.from(event);
      final type = map['type'] as String;
      final value = map['value'];
      switch (type) {
        case 'onFirstRendering':
          onFirstRendering?.call();
        case 'onConnectionState':
          onConnectionState?.call(
              ConnectionState.fromName(value), map['errorMessage'] as String?);
        case 'onConversationState':
          final stateName = value as String?;
          final state = stateName == null
              ? null
              : ConversationState.fromNameOrNull(stateName);
          if (state != null) {
            onConversationState?.call(state);
          } else {
            assert(false, 'Unexpected conversation state: $value');
          }
        case 'onError':
          final error = AvatarError.fromNameOrNull(value);
          if (error != null) {
            onError?.call(error);
          } else {
            assert(false, 'Unexpected avatar error: $value');
          }
        case 'onFrameRateInfo':
          final metrics = Map<String, dynamic>.from(value as Map);
          onFrameRateInfo?.call(FrameRateInfo.fromJson(metrics));
        case 'onAnimationState':
          final type = AnimationType.fromNameOrNull(value as String?);
          if (type != null) {
            onAnimationState?.call(type);
          } else {
            assert(false, 'Unexpected animation state: $value');
          }
        case 'onPlaybackStall':
          onPlaybackStall?.call(value as bool);
        default:
          assert(false, 'Unexpected event type: $type');
      }
    });
  }

  void Function()? onFirstRendering;

  void Function(ConnectionState state, String? errorMessage)? onConnectionState;

  void Function(ConversationState state)? onConversationState;

  void Function(AvatarError error)? onError;

  void Function(FrameRateInfo info)? onFrameRateInfo;

  /// Notified when the animation type changes (idle / mono / etc.).
  /// Native SDKs emit this on transitions; aligned with iOS / Android.
  void Function(AnimationType type)? onAnimationState;

  /// Notified when audio is paused/resumed due to frame starvation.
  /// `stalled == true` means audio paused waiting for frames; `false` means it
  /// resumed. Only fires under [FrameStarvationMode.strictSync].
  /// Aligned with iOS / Android `AvatarController.onPlaybackStall`.
  void Function(bool stalled)? onPlaybackStall;

  Future<void> start() async {
    return await _methodChannel.invokeMethod('start');
  }

  Future<String> send(Uint8List audioData, {bool end = false}) async {
    return await _methodChannel
        .invokeMethod('send', {'audioData': audioData, 'end': end});
  }

  /// Yields host-supplied audio in [DrivingServiceMode.backend].
  ///
  /// The audio format is taken from [Configuration.audioFormat] given at
  /// `initialize`; the per-call [audioFormat] override is deprecated and ignored.
  Future<String> yieldAudioData(Uint8List audioData,
      {bool end = false,
      @Deprecated(
          'Set the format via Configuration.audioFormat at initialize instead. '
          'This parameter is ignored and will be removed in a future release.')
      AudioFormat? audioFormat}) async {
    return await _methodChannel.invokeMethod('yieldAudioData', {
      'audioData': audioData,
      'end': end,
    });
  }

  Future<bool> yieldAnimations(List<Uint8List> animations,
      {required String conversationID}) async {
    final end = await _methodChannel.invokeMethod<bool>('yieldAnimations',
        {'animations': animations, 'conversationID': conversationID});
    return end ?? false;
  }

  Future<void> pause() async {
    return await _methodChannel.invokeMethod('pause');
  }

  Future<void> resume() async {
    return await _methodChannel.invokeMethod('resume');
  }

  Future<void> interrupt() async {
    return await _methodChannel.invokeMethod('interrupt');
  }

  Future<void> close() async {
    return await _methodChannel.invokeMethod('close');
  }

  Future<void> pauseRendering() async {
    return await _methodChannel.invokeMethod('pauseRendering');
  }

  Future<void> resumeRendering() async {
    return await _methodChannel.invokeMethod('resumeRendering');
  }

  /// Exports the current rendering frame as PNG image bytes.
  /// Returns null if not rendering or avatar is not initialized.
  Future<Uint8List?> exportBitmap() async {
    return await _methodChannel.invokeMethod<Uint8List>('exportBitmap');
  }

  Future<bool> isRendering() async {
    return await _methodChannel.invokeMethod('isRendering');
  }

  Future<double> volume() async {
    return await _methodChannel.invokeMethod('volume');
  }

  Future<void> setVolume(double volume) async {
    return await _methodChannel.invokeMethod('setVolume', volume);
  }

  /// Chooses how playback behaves when animation frames can't keep up with audio.
  /// Defaults to [FrameStarvationMode.audioIndependent] on the native side.
  /// In [FrameStarvationMode.strictSync], audio pause/resume due to frame
  /// starvation is reported via [onPlaybackStall].
  /// Aligned with iOS / Android `AvatarController.frameStarvationMode`.
  Future<void> setFrameStarvationMode(FrameStarvationMode mode) async {
    return await _methodChannel.invokeMethod(
        'setFrameStarvationMode', mode.name);
  }

  Future<int> pointCount() async {
    return await _methodChannel.invokeMethod('pointCount');
  }

  /// Playback time of the current audio session, in seconds.
  /// Resets to 0 on each new playback round. Returns 0 when not playing.
  Future<double> getAudioTime() async {
    return await _methodChannel.invokeMethod('getAudioTime');
  }

  /// Current Metal/Vulkan drawable size in pixels (post-DPR, after any
  /// `setRenderResolutionCap`). Aligned with iOS / Android `AvatarView.renderSize`.
  Future<Size> renderSize() async {
    final result = await _methodChannel.invokeMethod('renderSize');
    return Size(
      (result['width'] as num).toDouble(),
      (result['height'] as num).toDouble(),
    );
  }

  /// Bounding rect of the rendered avatar within the view, in pixels.
  /// Returns null when nothing is rendered yet. Aligned with iOS / Android
  /// `AvatarView.getBoundingRect`.
  Future<Rect?> getBoundingRect() async {
    final result = await _methodChannel.invokeMethod('getBoundingRect');
    if (result == null) return null;
    return Rect.fromLTRB(
      (result['left'] as num).toDouble(),
      (result['top'] as num).toDouble(),
      (result['right'] as num).toDouble(),
      (result['bottom'] as num).toDouble(),
    );
  }

  Future<Transform> contentTransform() async {
    final result = await _methodChannel.invokeMethod('contentTransform');
    return Transform(x: result['x'], y: result['y'], scale: result['scale']);
  }

  Future<void> setContentTransform(Transform transform) async {
    return await _methodChannel.invokeMethod('setContentTransform',
        {'x': transform.x, 'y': transform.y, 'scale': transform.scale});
  }

  Future<bool> frameRateMonitorEnabled() async {
    return await _methodChannel.invokeMethod('frameRateMonitorEnabled');
  }

  Future<void> setFrameRateMonitorEnabled(bool enabled) async {
    return await _methodChannel.invokeMethod(
        'setFrameRateMonitorEnabled', enabled);
  }
}
