# Changelog

All notable changes to this project will be documented in this file.

## [1.3.6] - 2026-09-01

Packaging fix only. The plugin's own API and both native SDKs are unchanged from
`1.3.5` (Android `1.3.4` / iOS `1.3.4`).

### Fixed

- The published package no longer contains the iOS `AvatarKit.xcframework`. It was
  bundled by mistake in `1.3.4` and `1.3.5`, which made those downloads roughly
  60 MB larger than necessary — the framework is fetched from its own release
  during `pod install`, so the copy inside the package was never used. The
  package is back to about 5 MB.

## [1.3.5] - 2026-08-31

Bridges the Android `1.3.4` and iOS `1.3.4` native SDKs. No changes to the plugin's own API.

### Changed

- Both native SDKs now send their diagnostics to a collection gateway instead of the storage backend directly, and no longer carry any credentials for that backend.
- Both native SDKs now check, one second after the first frame is reported as rendered, whether anything was actually drawn, and report a diagnostic when the view is completely blank.
- Updated the analytics dependency bundled by both native SDKs.

### Fixed

- End-to-end latency is now reported when the host application supplies the motion data, not only when the SDK connects to the driving service itself. Applies to both platforms.

## [1.3.4] - 2026-08-22

Bridges the Android `1.3.3` and iOS `1.3.3` native SDKs. No changes to the plugin's own API.

### Fixed

- **Fixed the SDK continuing to send audio under an already-finished conversation id in direct mode (Android).** After `send(audio, end: true)`, feeding new audio while that round had not started playing yet reused the same conversation id on the wire, so the driving service received new audio on a request it had already been told was over. A new round now always starts under a fresh id, whether or not the previous one had begun playing. iOS was not affected.
- The timestamp prefix on session and request ids is now generated in UTC on Android, matching the other platforms.
- Internal telemetry only, no change to public API or runtime behaviour: the connection identifier is now attached automatically to the diagnostic events and traces both native SDKs report; playback records additionally carry the rendering SDK's own version; loading and connection timings are now reported for failed attempts as well; and HTTP request duration buckets were widened to match the other platforms.

## [1.3.3] - 2026-08-08

Bridges the Android `1.3.2` and iOS `1.3.2` native SDKs. Rolls up everything from the 1.3.3 beta line.

### Known issues

- On some Android devices (Huawei and Mediatek/Mali GPUs are the ones reported), tearing down and rebuilding the avatar view in quick succession can abort the app with `java.lang.IllegalStateException: Image is already closed`. This is a Flutter engine bug in how platform views hand images to the rasterizer ([flutter/flutter#175267](https://github.com/flutter/flutter/issues/175267)), not something this plugin can guard against — it affects any plugin that renders through a platform view. The engine fix ([flutter/flutter#185125](https://github.com/flutter/flutter/pull/185125), merged 2026-04-29) makes the failure non-fatal, but has not landed in a stable release yet; it is expected in the 3.47 line. Until then, avoid mounting and unmounting `AvatarWidget` in a tight loop.

### Added

- Opus audio support. `AudioFormat.inputAudioFormat` (`AudioCodec.pcm` default, or `AudioCodec.opus`) declares the format the host feeds into the SDK via `send`/`yieldAudioData`; `opus` input is decoded back to PCM16 for local rendering and forwarded upstream as-is in direct mode. `AudioFormat.opusBitrate` tunes the target bitrate. Only effective in direct mode.
- `AvatarError.invalidAudioInput` is now reported when audio handed to the SDK does not match `AudioFormat.inputAudioFormat` — for example Opus input that is neither Ogg Opus nor a bare Opus packet, is stereo, or changes shape mid-conversation.

### Changed

- **The direct-mode uplink now compresses audio to Opus by default** (`AudioFormat.opusUplinkEnabled`, previously off). It cuts the upload to roughly 1/8 at the cost of client-side encoding, which matters most on the mobile networks where stalls actually happen. Pass `opusUplinkEnabled: false` to keep the raw PCM uplink. Unchanged for host mode (no uplink) and for `opus` input (already compressed). If the configured `sampleRate` is not one of 8000/16000/24000/48000, the SDK logs a warning and falls back to a raw PCM uplink.
- `Configuration.region` now defaults to automatic selection (`kDefaultRegion` is `'auto'`): when left unset, the SDK picks the closest serving region at initialization, and reuses the cached choice on later launches. Passing an explicit `region` continues to force that region, unchanged. If automatic selection can't be reached, the SDK falls back to a default region and continues initializing.
- `initialize` with a missing `appID` now fails fast, surfacing missing configuration immediately during local development. The accompanying message points to https://app.spatius.ai/ to obtain an app ID.

### Deprecated

- The per-call `audioFormat` parameter of `AvatarController.yieldAudioData` is deprecated and now ignored; the audio format comes from `Configuration.audioFormat` passed to `initialize`. It will be removed in a future release.

## [1.3.3-beta.1] - 2026-07-31

Bridges the Android `1.3.2-beta.1` and iOS `1.3.1-beta.1` native SDKs.

### Added

- Opus audio support. `AudioFormat.inputAudioFormat` (`AudioCodec.pcm` default, or `AudioCodec.opus`) declares the format the host feeds into the SDK via `send`/`yieldAudioData`; `opus` input is decoded back to PCM16 for local rendering and forwarded upstream as-is in direct mode. `AudioFormat.opusUplinkEnabled` (default `false`) opts the direct-mode uplink into Opus compression (roughly 1/8 the upload, at the cost of client-side encoding), and `AudioFormat.opusBitrate` tunes the target bitrate. Only effective in direct mode.
- `AvatarError.invalidAudioInput` is now reported when audio handed to the SDK does not match `AudioFormat.inputAudioFormat` — for example Opus input that is neither Ogg Opus nor a bare Opus packet, is stereo, or changes shape mid-conversation.

### Changed

- `Configuration.region` now defaults to automatic selection (`kDefaultRegion` is `'auto'`): when left unset, the SDK picks the closest serving region at initialization. Passing an explicit `region` continues to force that region, unchanged. If automatic selection can't be reached, the SDK falls back to a default region and continues initializing.
- When `opusUplinkEnabled` is `true` but the configured `sampleRate` is not Opus-compatible (8000/16000/24000/48000), `initialize` logs a warning and automatically falls back to a raw PCM uplink instead of silently failing.
- `initialize` with a missing `appID` now fails fast, surfacing missing configuration immediately during local development. The accompanying message points to https://app.spatius.ai/ to obtain an app ID.

### Deprecated

- The per-call `audioFormat` parameter of `AvatarController.yieldAudioData` is deprecated and now ignored; the audio format comes from `Configuration.audioFormat` passed to `initialize`. It will be removed in a future release.

## [1.3.2] - 2026-07-13

Bridges the Android 1.3.1 native SDK. No Dart API changes.

### Fixed

- On Android, native libraries are now aligned to a 16 KB memory page size, ensuring compatibility with 16 KB page-size devices and meeting Google Play's upload requirement (effective Nov 1, 2025) for apps targeting Android 15+.

## [1.3.1] - 2026-07-05

Documentation-only release. No code or native dependency changes since 1.3.0.

### Changed

- Cleaned up the package README shown on pub.dev and fixed the documentation link.

## [1.3.0] - 2026-07-05

Bridges the v1.3.0 native SDKs. No breaking Dart API changes.

### Changed

- Native dependencies bumped to v1.3.0
  (Android `ai.spatius:avatarkit:1.3.0`, iOS xcframework v1.3.0).

### Added

- Avatars are now automatically classified as body-fixation or non-body-fixation
  and loaded on the matching path, driven by the asset's compatibility flags
  (handled by the native SDKs).
- Loading an avatar whose asset requires a newer SDK now fails fast with an
  incompatible-asset error instead of rendering incorrectly, prompting an SDK
  upgrade.

## [1.2.0] - 2026-06-28

First stable 1.2 release. No Dart API changes since `1.2.0-beta.1`; this release
bumps the native SDKs to v1.2.0 for playback and asset-loading reliability fixes.

### Changed

- Native dependencies bumped to v1.2.0
  (Android `ai.spatius:avatarkit:1.2.0`, iOS xcframework v1.2.0).

### Fixed

- Fixed a crash that could occur when audio playback was interrupted by the
  system (e.g. an incoming phone call). Such interruptions are now handled
  gracefully instead of crashing the app.
- Fixed local avatar assets with absent or null optional fields (such as
  `transform`) being wrongly rejected when derived. Such assets now load
  correctly.

## [1.2.0-beta.1] - 2026-06-20

Aligns the public API with native iOS / Android SDK v1.2.0-beta.1.

### Added

- `FrameStarvationMode` enum (`audioIndependent` / `strictSync`) and
  `AvatarController.setFrameStarvationMode(FrameStarvationMode mode)` — choose how
  playback behaves when animation frames can't keep up with audio.
  `audioIndependent` (default) keeps audio playing while animation catches up;
  `strictSync` pauses audio until frames arrive, keeping audio and animation
  strictly in sync.
- `AvatarController.onPlaybackStall` — `void Function(bool stalled)?` callback that
  fires when audio is paused/resumed due to frame starvation (only in `strictSync`).
- `AvatarError.incompatibleAvatarAsset` — thrown when a local asset is in an
  unsupported (legacy) format.

### Changed

- Native dependencies bumped to v1.2.0-beta.1
  (Android `ai.spatius:avatarkit:1.2.0-beta.1`, iOS xcframework v1.2.0-beta.1).

## [1.1.0-beta.1] - 2026-06-09

Aligns the public API with native iOS / Android SDK v1.1.0-beta.2.

### Added

- `RenderQuality` enum (`standard` / `high` / `ultra`) and
  `Configuration({RenderQuality renderQuality = RenderQuality.ultra})` to set
  render quality at initialization.
- `AvatarSDK.setRenderQuality(RenderQuality quality)` — change render quality at runtime.
- `AvatarSDK.setRenderResolutionCap({required bool enabled, int maxHeight = 1440})` —
  cap internal render resolution height to bound GPU/bandwidth cost.
- `AvatarController.renderSize()` → `Size` — current drawable size in pixels.
- `AvatarController.getBoundingRect()` → `Rect?` — rendered avatar bounds.
- `AvatarError.invalidAvatarMetadata` and `AvatarError.invalidAnimationData`.

### Changed

- Native dependencies bumped to v1.1.0-beta.2
  (Android `ai.spatius:avatarkit:1.1.0-beta.2`, iOS xcframework v1.1.0-beta.1).

### Breaking

- `DrivingServiceMode` values renamed: `sdk` → `direct`, `host` → `backend`.
  Update `Configuration(drivingServiceMode: ...)` call sites accordingly.

## [1.0.0] - 2026-05-20

First stable release.

- Flutter plugin bridging native AvatarKit (Android `ai.spatius:avatarkit:1.0.0`, iOS xcframework v1.0.0).
- Public API: `AvatarSDK`, `AvatarManager`, `AvatarWidget`, `AvatarController`.
- Real-time avatar rendering with audio-driven and host-driven modes.
- See [README.md](README.md) for installation and usage.

Pre-1.0 beta history archived at [docs/history/CHANGELOG-pre-1.0.md](docs/history/CHANGELOG-pre-1.0.md).
