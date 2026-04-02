import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class WebcamCaptureResult {
  const WebcamCaptureResult({
    required this.bytes,
    required this.fileName,
  });

  final Uint8List bytes;
  final String fileName;
}

class WebcamCaptureScreen extends StatefulWidget {
  const WebcamCaptureScreen({super.key});

  @override
  State<WebcamCaptureScreen> createState() => _WebcamCaptureScreenState();
}

class _WebcamCaptureScreenState extends State<WebcamCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initFuture;
  String? _error;
  String? _errorCode;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _initFuture = _setupCamera();
  }

  Future<void> _setupCamera() async {
    await _controller?.dispose();
    _controller = null;
    _error = null;
    _errorCode = null;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No webcam detected.');
      }

      final cameraCandidates = <CameraDescription>[
        ...cameras.where((c) => c.lensDirection == CameraLensDirection.front),
        ...cameras.where((c) => c.lensDirection == CameraLensDirection.back),
        ...cameras.where((c) => c.lensDirection == CameraLensDirection.external),
      ];
      if (cameraCandidates.isEmpty) {
        cameraCandidates.addAll(cameras);
      }

      final presets = <ResolutionPreset>[
        ResolutionPreset.medium,
        ResolutionPreset.low,
      ];

      Object? lastError;
      String? lastCode;

      for (final cam in cameraCandidates) {
        for (final preset in presets) {
          try {
            final controller = CameraController(
              cam,
              preset,
              enableAudio: false,
            );
            await controller.initialize();
            if (!mounted) {
              await controller.dispose();
              return;
            }
            setState(() {
              _controller = controller;
              _error = null;
              _errorCode = null;
            });
            return;
          } catch (e) {
            if (e is CameraException) {
              lastCode = e.code;
            }
            lastError = e;
          }
        }
      }

      throw CameraException(
        lastCode ?? 'cameraInitFailed',
        '$lastError',
      );
    } catch (e) {
      if (!mounted) return;
      final code = e is CameraException ? e.code : null;
      var message = 'Could not initialize webcam: $e';
      if (code == 'cameraNotReadable') {
        message =
            'Webcam is busy or blocked. Close other apps/tabs using the camera, allow browser camera permissions, then retry.';
      } else if (code == 'cameraPermission') {
        message = 'Camera permission denied. Allow camera access and retry.';
      }
      setState(() {
        _errorCode = code;
        _error = message;
      });
    }
  }

  void _retryCamera() {
    setState(() {
      _initFuture = _setupCamera();
    });
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }
    setState(() {
      _capturing = true;
    });
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      Navigator.of(context).pop(
        WebcamCaptureResult(
          bytes: bytes,
          fileName: file.name,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Capture failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _capturing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Take Photo'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (_error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _retryCamera,
                      child: const Text('Retry Webcam'),
                    ),
                    if (_errorCode == 'cameraNotReadable')
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Use File Picker Instead'),
                      ),
                  ],
                ),
              ),
            );
          }
          final controller = _controller;
          if (snapshot.connectionState != ConnectionState.done ||
              controller == null ||
              !controller.value.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: CameraPreview(controller),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: Center(
                  child: FloatingActionButton(
                    onPressed: _capture,
                    backgroundColor: Colors.white,
                    child: _capturing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
