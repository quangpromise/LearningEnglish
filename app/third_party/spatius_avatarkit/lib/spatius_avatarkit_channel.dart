import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'spatius_avatarkit_platform.dart';
import 'spatius_avatarkit_plugin.dart';
import 'src/version.dart';

class AvatarKitChannel extends AvatarKitPlatform {
  final _methodChannel = const MethodChannel('AVATAR_KIT_METHOD_CHANNEL');
  final _eventChannel = const EventChannel('AVATAR_KIT_EVENT_CHANNEL');

  @override
  Future<String> appID() async {
    return await _methodChannel.invokeMethod('appID');
  }

  @override
  Future<Configuration> configuration() async {
    final result = await _methodChannel.invokeMethod('configuration');
    final sampleRate = (result['sampleRate'] as num?)?.toInt();
    final renderQuality = result['renderQuality'] as String?;
    final inputAudioFormat = result['inputAudioFormat'] as String?;
    final opusBitrate = (result['opusBitrate'] as num?)?.toInt();
    const defaults = AudioFormat();
    return Configuration(
      region: (result['region'] as String?) ?? kDefaultRegion,
      audioFormat: AudioFormat(
        sampleRate: sampleRate ?? defaults.sampleRate,
        inputAudioFormat: inputAudioFormat != null
            ? AudioCodec.fromName(inputAudioFormat)
            : defaults.inputAudioFormat,
        opusUplinkEnabled: (result['opusUplinkEnabled'] as bool?) ??
            defaults.opusUplinkEnabled,
        opusBitrate: opusBitrate ?? defaults.opusBitrate,
      ),
      drivingServiceMode:
          DrivingServiceMode.fromName(result['drivingServiceMode'] as String),
      logLevel: LogLevel.fromName(result['logLevel'] as String),
      renderQuality: renderQuality != null
          ? RenderQuality.fromName(renderQuality)
          : RenderQuality.ultra,
    );
  }

  @override
  Future<void> initialize(
      {required String appID, required Configuration configuration}) async {
    await _methodChannel.invokeMethod('initialize', {
      'appID': appID,
      'sampleRate': configuration.audioFormat.sampleRate,
      'inputAudioFormat': configuration.audioFormat.inputAudioFormat.name,
      'opusUplinkEnabled': configuration.audioFormat.opusUplinkEnabled,
      'opusBitrate': configuration.audioFormat.opusBitrate,
      'region': configuration.region,
      'drivingServiceMode': configuration.drivingServiceMode.name,
      'logLevel': configuration.logLevel.name,
      'renderQuality': configuration.renderQuality.name,
      'pluginVersion': kPluginVersion,
    });
  }

  @override
  Future<String> sessionToken() async {
    return await _methodChannel.invokeMethod('sessionToken');
  }

  @override
  Future<void> setSessionToken(String sessionToken) async {
    await _methodChannel.invokeMethod('setSessionToken', sessionToken);
  }

  @override
  Future<String> userID() async {
    return await _methodChannel.invokeMethod('userID');
  }

  @override
  Future<void> setUserID(String userID) async {
    await _methodChannel.invokeMethod('setUserID', userID);
  }

  @override
  Future<String> version() async {
    return await _methodChannel.invokeMethod('version');
  }

  @override
  Future<bool> isDeviceSupported() async {
    return await _methodChannel.invokeMethod('isDeviceSupported');
  }

  @override
  Future<DeviceScore> deviceScore() async {
    final result = await _methodChannel.invokeMethod('deviceScore');
    return DeviceScore.fromJson(Map<String, dynamic>.from(result as Map));
  }

  @override
  Future<void> setRenderQuality(RenderQuality quality) async {
    await _methodChannel.invokeMethod('setRenderQuality', quality.name);
  }

  @override
  Future<void> setRenderResolutionCap(
      {required bool enabled, int maxHeight = 1440}) async {
    await _methodChannel.invokeMethod('setRenderResolutionCap', {
      'enabled': enabled,
      'maxHeight': maxHeight,
    });
  }

  // ---- Test-only SPI ----

  @override
  Future<void> setDrivingServiceModeForTesting(DrivingServiceMode mode) async {
    await _methodChannel.invokeMethod(
        'setDrivingServiceModeForTesting', mode.name);
  }

  @override
  Future<void> setAudioFormatForTesting(AudioFormat audioFormat) async {
    await _methodChannel.invokeMethod('setAudioFormatForTesting', {
      'sampleRate': audioFormat.sampleRate,
      'inputAudioFormat': audioFormat.inputAudioFormat.name,
      'opusUplinkEnabled': audioFormat.opusUplinkEnabled,
      'opusBitrate': audioFormat.opusBitrate,
    });
  }

  @override
  Future<Uint8List?> encodeWholePcmToOggForTesting(
      Uint8List pcm, int sampleRate,
      {int? bitrate}) async {
    return await _methodChannel
        .invokeMethod<Uint8List>('encodeWholePcmToOggForTesting', {
      'pcm': pcm,
      'sampleRate': sampleRate,
      if (bitrate != null) 'bitrate': bitrate,
    });
  }

  @override
  Future<int> keyframeCount(Uint8List rawMessage) async {
    final result =
        await _methodChannel.invokeMethod('keyframeCount', rawMessage);
    return (result as num?)?.toInt() ?? 0;
  }

  @override
  Future<Uint8List?> sliceRawAnimationMessage(
      Uint8List rawMessage, int startFrame, int endFrame) async {
    final result =
        await _methodChannel.invokeMethod('sliceRawAnimationMessage', {
      'rawMessage': rawMessage,
      'startFrame': startFrame,
      'endFrame': endFrame,
    });
    return result as Uint8List?;
  }

  @override
  Future<Avatar> derive(String assetPath) async {
    final result = await _methodChannel.invokeMethod('derive', assetPath);
    return Avatar.fromJson(Map<String, dynamic>.from(result));
  }

  @override
  Future<Avatar?> retrieve({required String id}) async {
    final result = await _methodChannel.invokeMethod('retrieve', id);
    return result != null
        ? Avatar.fromJson(Map<String, dynamic>.from(result))
        : null;
  }

  @override
  Future<Avatar> load(
      {required String id,
      bool useCompressedModel = false,
      void Function(double progress)? onProgress}) async {
    final random = Random().nextInt(1000000000);
    final eventID = '${id}_${DateTime.now().millisecondsSinceEpoch}_$random';
    StreamSubscription? subscription;
    if (onProgress != null) {
      subscription =
          _eventChannel.receiveBroadcastStream(eventID).listen((progress) {
        onProgress(progress as double);
      });
    }
    try {
      final result = await _methodChannel.invokeMethod('load', {
        'id': id,
        'eventID': eventID,
        'useCompressedModel': useCompressedModel
      });
      return Avatar.fromJson(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      final error = AvatarError.fromNameOrNull(e.code);
      if (error != null) {
        throw error;
      } else {
        rethrow;
      }
    } finally {
      try {
        if (subscription != null) {
          await subscription.cancel();
        }
      } catch (_) {
        // ignore cancel errors
      }
    }
  }

  @override
  Future<void> cancelLoading({required String id}) async {
    await _methodChannel.invokeMethod('cancelLoading', id);
  }

  @override
  Future<void> cancelAllLoading() async {
    await _methodChannel.invokeMethod('cancelAllLoading');
  }

  @override
  Future<void> clear({required String id}) async {
    await _methodChannel.invokeMethod('clear', id);
  }

  @override
  Future<void> clearAll() async {
    await _methodChannel.invokeMethod('clearAll');
  }

  @override
  Future<int> getCacheSize({required String id}) async {
    return await _methodChannel.invokeMethod('getCacheSize', id);
  }

  @override
  Future<int> getAllCacheSize() async {
    return await _methodChannel.invokeMethod('getAllCacheSize');
  }

  @override
  Future<void> pause() async {
    await _methodChannel.invokeMethod('pause');
  }

  @override
  Future<void> resume() async {
    await _methodChannel.invokeMethod('resume');
  }
}
