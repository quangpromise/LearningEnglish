import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'spatius_avatarkit_channel.dart';
import 'spatius_avatarkit_plugin.dart';

/// The interface that platform-specific implementations of `spatius_avatarkit`
/// must implement.
///
/// Platform implementations should extend this class rather than implement it
/// as `AvatarKitPlatform`; extending ensures new methods added here won't break
/// existing implementations. The default instance is [AvatarKitChannel], which
/// bridges to the native Android/iOS AvatarKit SDKs over a method channel.
abstract class AvatarKitPlatform extends PlatformInterface {
  /// Constructs an [AvatarKitPlatform].
  AvatarKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static AvatarKitPlatform _instance = AvatarKitChannel();

  /// The default instance of [AvatarKitPlatform] to use.
  ///
  /// Defaults to [AvatarKitChannel].
  static AvatarKitPlatform get instance => _instance;

  /// Sets the platform-specific implementation to use.
  ///
  /// The [instance] is verified against a shared token to prevent third-party
  /// packages from providing an unverified implementation.
  static set instance(AvatarKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the app ID the SDK was initialized with.
  Future<String> appID() {
    throw UnimplementedError('appID() has not been implemented.');
  }

  /// Returns the current SDK [Configuration].
  Future<Configuration> configuration() {
    throw UnimplementedError('configuration() has not been implemented.');
  }

  /// Initializes the SDK with the given [appID] and [configuration].
  ///
  /// Must be called before loading avatars or starting a session.
  Future<void> initialize(
      {required String appID, required Configuration configuration}) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Returns the current session token.
  Future<String> sessionToken() {
    throw UnimplementedError('sessionToken() has not been implemented.');
  }

  /// Sets the session token used to authenticate driving/streaming requests.
  Future<void> setSessionToken(String sessionToken) {
    throw UnimplementedError('setSessionToken() has not been implemented.');
  }

  /// Returns the current user ID.
  Future<String> userID() {
    throw UnimplementedError('userID() has not been implemented.');
  }

  /// Sets the user ID reported with telemetry and driving requests.
  Future<void> setUserID(String userID) {
    throw UnimplementedError('setUserID() has not been implemented.');
  }

  /// Returns the SDK version string.
  Future<String> version() {
    throw UnimplementedError('version() has not been implemented.');
  }

  /// Whether the current device meets the minimum requirements for rendering.
  Future<bool> isDeviceSupported() {
    throw UnimplementedError('isDeviceSupported() has not been implemented.');
  }

  /// Returns a [DeviceScore] describing the device's rendering capability tier.
  Future<DeviceScore> deviceScore() {
    throw UnimplementedError('deviceScore() has not been implemented.');
  }

  /// Sets the render quality tier (e.g. ultra / high / standard).
  Future<void> setRenderQuality(RenderQuality quality) {
    throw UnimplementedError('setRenderQuality() has not been implemented.');
  }

  /// Caps the render resolution.
  ///
  /// When [enabled], the rendered output height is limited to [maxHeight]
  /// pixels to reduce GPU load on high-resolution displays.
  Future<void> setRenderResolutionCap(
      {required bool enabled, int maxHeight = 1440}) {
    throw UnimplementedError(
        'setRenderResolutionCap() has not been implemented.');
  }

  // ---- Test-only SPI (host-mode integration tests) ----

  /// Test-only: overrides the driving service mode. Not for production use.
  Future<void> setDrivingServiceModeForTesting(DrivingServiceMode mode) {
    throw UnimplementedError(
        'setDrivingServiceModeForTesting() has not been implemented.');
  }

  /// Test-only: overrides the audio format. Not for production use.
  Future<void> setAudioFormatForTesting(AudioFormat audioFormat) {
    throw UnimplementedError(
        'setAudioFormatForTesting() has not been implemented.');
  }

  /// Test-only: encodes PCM16 (mono, little-endian) into one continuous Ogg
  /// Opus stream. Returns null if the encoder can't be created.
  Future<Uint8List?> encodeWholePcmToOggForTesting(
      Uint8List pcm, int sampleRate,
      {int? bitrate}) {
    throw UnimplementedError(
        'encodeWholePcmToOggForTesting() has not been implemented.');
  }

  /// Test-only: returns the number of keyframes in a raw animation [rawMessage].
  Future<int> keyframeCount(Uint8List rawMessage) {
    throw UnimplementedError('keyframeCount() has not been implemented.');
  }

  /// Test-only: slices a raw animation message to the frame range
  /// [startFrame, endFrame).
  Future<Uint8List?> sliceRawAnimationMessage(
      Uint8List rawMessage, int startFrame, int endFrame) {
    throw UnimplementedError(
        'sliceRawAnimationMessage() has not been implemented.');
  }

  /// Derives an [Avatar] from a local asset directory at [assetPath].
  Future<Avatar> derive(String assetPath) {
    throw UnimplementedError('derive() has not been implemented.');
  }

  /// Retrieves a cached [Avatar] by [id], or `null` if not present on disk.
  Future<Avatar?> retrieve({required String id}) {
    throw UnimplementedError('retrieve() has not been implemented.');
  }

  /// Loads the [Avatar] with the given [id], downloading it if necessary.
  ///
  /// Set [useCompressedModel] to fetch the smaller compressed model. Loading
  /// progress is reported through [onProgress] in the range 0.0–1.0.
  Future<Avatar> load(
      {required String id,
      bool useCompressedModel = false,
      void Function(double progress)? onProgress}) {
    throw UnimplementedError('load() has not been implemented.');
  }

  /// Cancels an in-flight load for the avatar with the given [id].
  Future<void> cancelLoading({required String id}) {
    throw UnimplementedError('cancelLoading() has not been implemented.');
  }

  /// Cancels all in-flight avatar loads.
  Future<void> cancelAllLoading() {
    throw UnimplementedError('cancelAllLoading() has not been implemented.');
  }

  /// Removes the cached avatar with the given [id] from disk.
  Future<void> clear({required String id}) {
    throw UnimplementedError('clear() has not been implemented.');
  }

  /// Removes all cached avatars from disk.
  Future<void> clearAll() {
    throw UnimplementedError('clearAll() has not been implemented.');
  }

  /// Returns the on-disk cache size in bytes for the avatar with the given [id].
  Future<int> getCacheSize({required String id}) {
    throw UnimplementedError('getCacheSize() has not been implemented.');
  }

  /// Returns the total on-disk cache size in bytes across all avatars.
  Future<int> getAllCacheSize() {
    throw UnimplementedError('getAllCacheSize() has not been implemented.');
  }

  /// Pauses rendering and playback.
  Future<void> pause() {
    throw UnimplementedError('pause() has not been implemented.');
  }

  /// Resumes rendering and playback after a [pause].
  Future<void> resume() {
    throw UnimplementedError('resume() has not been implemented.');
  }
}
