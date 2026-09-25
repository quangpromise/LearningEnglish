import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/tts/app_tts.dart';
import '../data/exercise_model.dart';
import '../data/rep_counter.dart';

/// "Dem rep bang camera": dat dien thoai de camera TRUOC nhin thay ca
/// nguoi, ML Kit Pose Detection (on-device) tinh goc khop (goi/khuyu/hong)
/// -> [RepCounter] dem rep, HLV dem to bang tieng Anh ("one, two...") va
/// nhac "Go a little lower!" khi rep chua du sau. Bam "Xong" tra ve so rep
/// de dien vao set dang ghi.
///
/// Chi 1 luong camera 1 luc (man do nhip tim dung camera sau rieng). Moi
/// loi (may khong ho tro, thieu quyen, ML Kit loi) -> hien thong bao, khong
/// crash; nguoi dung van nhap reps bang tay nhu cu.
class RepCameraScreen extends ConsumerStatefulWidget {
  const RepCameraScreen({
    super.key,
    required this.exercise,
    required this.pattern,
    required this.targetReps,
  });

  final Exercise exercise;
  final RepPattern pattern;
  final int targetReps;

  @override
  ConsumerState<RepCameraScreen> createState() => _RepCameraScreenState();
}

class _RepCameraScreenState extends ConsumerState<RepCameraScreen> {
  CameraController? _camera;
  CameraDescription? _description;
  PoseDetector? _detector;
  late final RepCounter _counter = RepCounter(widget.pattern);

  bool _busy = false;
  DateTime _lastFrame = DateTime.fromMillisecondsSinceEpoch(0);
  String? _errorKey;
  String? _cue;
  bool _personVisible = false;

  /// Ben co the dung de do (trai/phai) - chon theo do tin cay cua cac
  /// khop trong ~10 khung dau roi GIU CO DINH, tranh nhay ben moi khung.
  bool? _useLeft;
  double _leftScore = 0;
  double _rightScore = 0;
  int _sideSamples = 0;

  static const _frameInterval = Duration(milliseconds: 120);

  static const _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw StateError('no camera');
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _detector = PoseDetector(
        options: PoseDetectorOptions(model: PoseDetectionModel.base),
      );
      _description = front;
      setState(() => _camera = controller);
      await controller.startImageStream(_onFrame);
      AppTts.instance.speak(
        "Step back so I can see your whole body. Let's go!",
      );
    } catch (e) {
      debugPrint('RepCameraScreen start failed: $e');
      if (mounted) setState(() => _errorKey = 'rep_camera_unavailable');
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    final now = DateTime.now();
    if (_busy || now.difference(_lastFrame) < _frameInterval) return;
    _busy = true;
    _lastFrame = now;
    try {
      final input = _toInputImage(image);
      final detector = _detector;
      if (input == null || detector == null) return;
      final poses = await detector.processImage(input);
      if (!mounted) return;
      if (poses.isEmpty) {
        if (_personVisible) setState(() => _personVisible = false);
        return;
      }
      final angle = _angleFor(poses.first);
      if (angle == null) {
        if (_personVisible) setState(() => _personVisible = false);
        return;
      }
      final event = _counter.addAngle(angle);
      if (event == RepEvent.rep) {
        HapticFeedback.lightImpact();
        AppTts.instance.speak(repWord(_counter.reps));
        _cue = null;
      } else if (event == RepEvent.shallowRep) {
        AppTts.instance.speak(
          '${repWord(_counter.reps)}. ${widget.pattern.depthCue}',
        );
        _cue = widget.pattern.depthCue;
      }
      setState(() => _personVisible = true);
    } catch (e) {
      debugPrint('RepCameraScreen frame failed: $e');
    } finally {
      _busy = false;
    }
  }

  /// Chuyen CameraImage -> InputImage cua ML Kit (theo huong dan chinh thuc
  /// cua google_mlkit_commons: Android nv21 1 plane, iOS bgra8888).
  InputImage? _toInputImage(CameraImage image) {
    final camera = _camera;
    final description = _description;
    if (camera == null || description == null) return null;
    final sensor = description.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensor);
    } else {
      var compensation = _orientations[camera.value.deviceOrientation];
      if (compensation == null) return null;
      compensation = description.lensDirection == CameraLensDirection.front
          ? (sensor + compensation) % 360
          : (sensor - compensation + 360) % 360;
      rotation = InputImageRotationValue.fromRawValue(compensation);
    }
    if (rotation == null) return null;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Goc khop dang theo doi, hoac null neu cac khop can thiet khong du tin
  /// cay (nguoi ra khoi khung hinh).
  double? _angleFor(Pose pose) {
    final (a, b, c) = switch (widget.pattern.joint) {
      RepJoint.knee => ('Hip', 'Knee', 'Ankle'),
      RepJoint.elbow => ('Shoulder', 'Elbow', 'Wrist'),
      RepJoint.hip => ('Shoulder', 'Hip', 'Knee'),
    };
    PoseLandmark? lm(String side, String joint) =>
        pose.landmarks[_type('$side$joint')];

    List<PoseLandmark>? sideLandmarks(String side) {
      final pa = lm(side, a), pb = lm(side, b), pc = lm(side, c);
      if (pa == null || pb == null || pc == null) return null;
      return [pa, pb, pc];
    }

    final left = sideLandmarks('left');
    final right = sideLandmarks('right');
    double score(List<PoseLandmark>? l) =>
        l == null ? 0 : l.map((p) => p.likelihood).reduce((x, y) => x + y) / 3;

    if (_useLeft == null) {
      _leftScore += score(left);
      _rightScore += score(right);
      _sideSamples++;
      if (_sideSamples >= 10) _useLeft = _leftScore >= _rightScore;
    }
    final useLeft = _useLeft ?? score(left) >= score(right);
    final chosen = useLeft ? left : right;
    if (chosen == null || score(chosen) < 0.5) return null;
    return jointAngle(
      PosePoint(chosen[0].x, chosen[0].y),
      PosePoint(chosen[1].x, chosen[1].y),
      PosePoint(chosen[2].x, chosen[2].y),
    );
  }

  static PoseLandmarkType _type(String name) =>
      PoseLandmarkType.values.firstWhere((t) => t.name == name);

  void _reset() {
    setState(() {
      _counter.reset();
      _cue = null;
    });
  }

  void _done() => Navigator.of(context).pop(_counter.reps);

  @override
  void dispose() {
    final camera = _camera;
    _camera = null;
    if (camera != null) {
      camera
          .stopImageStream()
          .catchError((_) {})
          .whenComplete(() => camera.dispose());
    }
    _detector?.close();
    AppTts.instance.stopSpeaking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    final errorKey = _errorKey;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (camera != null && camera.value.isInitialized)
              Center(child: CameraPreview(camera))
            else if (errorKey == null)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.fitnessAccent,
                ),
              ),
            if (errorKey != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    ref.tr(errorKey),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body(size: 16),
                  ),
                ),
              ),
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.nameEn,
                    style: AppTextStyles.heading(size: 20),
                  ),
                  Text(
                    ref.tr(
                      _personVisible
                          ? 'rep_camera_tracking'
                          : 'rep_camera_step_back',
                    ),
                    style: AppTextStyles.body(
                      size: 13,
                      color: _personVisible
                          ? AppColors.wealthUp
                          : AppColors.amber,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                children: [
                  Text(
                    '${_counter.reps}/${widget.targetReps}',
                    style: AppTextStyles.heading(size: 72),
                  ),
                  if (_cue != null)
                    Text(
                      _cue!,
                      style: AppTextStyles.body(
                        size: 16,
                        weight: FontWeight.w800,
                        color: AppColors.amber,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: PillButton(
                          label: ref.tr('rep_camera_reset'),
                          accentColor: AppColors.fitnessAccent,
                          filled: false,
                          onTap: _reset,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: PillButton(
                          label: ref
                              .tr('rep_camera_done')
                              .replaceFirst('{reps}', '${_counter.reps}'),
                          accentColor: AppColors.fitnessAccent,
                          accentGradient: AppColors.fitnessAccentGradient,
                          onTap: _done,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
