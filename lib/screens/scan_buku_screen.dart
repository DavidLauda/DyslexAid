import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../services/ocr_service.dart';
import 'conversion_result_screen.dart';

class ScanBukuScreen extends StatefulWidget {
  const ScanBukuScreen({super.key});

  @override
  State<ScanBukuScreen> createState() => _ScanBukuScreenState();
}

class _ScanBukuScreenState extends State<ScanBukuScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _isFlashOn = false;
  
  Offset? _focusPoint;
  Timer? _focusTimer;
  
  final GlobalKey _previewKey = GlobalKey();
  
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  int _iconTurns = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _initCamera();
    
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (!mounted) return;
      int newTurns = _iconTurns;
      if (event.x > 6) {
        newTurns = 1;
      } else if (event.x < -6) {
        newTurns = -1;
      } else if (event.y > 6) {
        newTurns = 0;
      }
      
      if (newTurns != _iconTurns) {
        setState(() {
          _iconTurns = newTurns;
        });
      }
    });
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras[0],
          ResolutionPreset.max, // Ditingkatkan ke max agar teks kecil/jauh tetap tajam saat di-scan
          enableAudio: false,
        );
        await _controller!.initialize();
        // BUKA KUNCI orientasi gambar agar hasil foto (JPEG) selalu tegak (Upright) sesuai gravitasi!
        await _controller!.unlockCaptureOrientation();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    _focusTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    if (_controller == null || !_isCameraInitialized) return;
    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
        setState(() => _isFlashOn = false);
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
        setState(() => _isFlashOn = true);
      }
    } catch (e) {
      debugPrint("Error toggling flash: $e");
    }
  }

  void _onTapFocus(TapDownDetails details) async {
    if (_controller == null || !_isCameraInitialized) return;

    final RenderBox? renderBox = _previewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final offset = Offset(
      localPosition.dx / renderBox.size.width,
      localPosition.dy / renderBox.size.height,
    );

    if (offset.dx < 0 || offset.dx > 1 || offset.dy < 0 || offset.dy > 1) return;

    setState(() {
      _focusPoint = localPosition;
    });

    try {
      await _controller!.setFocusPoint(offset);
      await _controller!.setFocusMode(FocusMode.auto);
    } catch (e) {}

    _focusTimer?.cancel();
    _focusTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _focusPoint = null;
        });
      }
    });
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized || _controller == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile image = await _controller!.takePicture();
      
      final size = MediaQuery.of(context).size;
      
      double cutoutWidth = size.width - 64;
      double cutoutHeight = size.height * 0.6;
      
      // Kita hitung persentase crop berdasarkan orientasi fisik layar
      double shortEdgePercent = cutoutWidth / size.width;
      double longEdgePercent = cutoutHeight / size.height;

      final ocrService = OcrService();
      final text = await ocrService.extractText(
        image.path, 
        shortEdgePercent: shortEdgePercent, 
        longEdgePercent: longEdgePercent,
        deviceOrientation: _iconTurns,
      );
      ocrService.dispose();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConversionResultScreen(
              imagePath: image.path,
              recognizedText: text,
              initialRotation: -_iconTurns,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.teal)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapFocus,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        key: _previewKey,
                        child: CameraPreview(_controller!),
                      ),
                      if (_focusPoint != null)
                        Positioned(
                          left: _focusPoint!.dx - 30,
                          top: _focusPoint!.dy - 30,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.tealAccent, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _OverlayPainter(),
                ),
              ),
            ),

            Center(
              child: IgnorePointer(
                child: Container(
                  width: MediaQuery.of(context).size.width - 64,
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal, width: 3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: const Text(
                    'Arahkan kamera ke bukumu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.teal)
                  : GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
              ),
            ),

            Positioned(
              top: 50,
              left: 16,
              child: AnimatedRotation(
                turns: _iconTurns / 4.0,
                duration: const Duration(milliseconds: 300),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Positioned(
              top: 50,
              right: 16,
              child: AnimatedRotation(
                turns: _iconTurns / 4.0,
                duration: const Duration(milliseconds: 300),
                child: IconButton(
                  icon: Icon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _toggleFlash,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.7);
    
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    double cutoutWidth = size.width - 64;
    double cutoutHeight = size.height * 0.6;

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: cutoutWidth,
            height: cutoutHeight,
          ),
          const Radius.circular(16),
        ),
      );

    final overlayPath = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);
    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) {
    return false;
  }
}

