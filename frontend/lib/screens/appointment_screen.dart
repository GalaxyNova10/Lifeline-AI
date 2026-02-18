import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../theme/app_colors.dart';
import '../widgets/pulse_button.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'triage_screen.dart';
import 'dart:async';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  bool _isScanning = false;
  CameraController? _controller;
  bool _cameraInitialized = false;
  String _instructionText = "Center your face in the circle";
  String _buttonLabel = "Start Face Scan";
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception("No cameras found");

      // Select front camera or fallback
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // "Safe Mode": Force Low resolution on Web to ensure compatibility
      // Optimized for connectivity and hardware lock prevention
      final resolution = kIsWeb ? ResolutionPreset.low : ResolutionPreset.high;

      _controller = CameraController(
        camera,
        resolution,
        enableAudio: false, // Prevents audio permission crashes
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _cameraInitialized = true);
      }
    } catch (e) {
      debugPrint("Camera Error (Safe Mode): $e");
      // Do not block UI, just print error
      if (mounted) {
        setState(() {
          _cameraInitialized = false;
          _instructionText = "Camera unavailable (Safe Mode active)";
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _pulseController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _startFaceScan() {
    if (!_cameraInitialized) return;

    setState(() {
      _isScanning = true;
      _instructionText = "Calibrating... Keep still";
      _buttonLabel = "Scanning...";
    });

    _pulseController.repeat(reverse: true);

    // Start Camera Stream for rPPG
    if (_controller != null && _controller!.value.isInitialized) {
      int frameCount = 0;
      _controller!.startImageStream((CameraImage image) {
        frameCount++;
        if (frameCount % 3 != 0) return; // Throttle: Process every 3rd frame

        // In a real app, convert YUV420 to JPEG/RGB here.
        // For hackathon web demo, we might just send a "ping" or mock data
        // because raw camera bytes are huge and complex to encode in Dart web.
        // We'll trust the simulated WebSocket fallback we wrote in ApiService.
        
        // However, if we MUST send bytes:
        // final bytes = image.planes[0].bytes; 
        // final base64 = base64Encode(bytes);
        // channel?.sink.add("IMAGE,$base64"); 
      });
    }

    // Try WebSocket connection for real rPPG
    _tryWebSocketScan();
  }

  Future<void> _tryWebSocketScan() async {
    try {
      final channel = ApiService.connectHeartRateWS();
      if (channel != null) {
        // Listen for BPM data from server
        final subscription = channel.stream.listen(
          (data) {
            if (!mounted) return;
            final json = jsonDecode(data.toString());
            final bpm = json['bpm'];
            if (bpm != null) {
              setState(() => _instructionText = "♥ ${bpm.round()} BPM");
              context.read<UserProvider>().updateBpm(bpm.round());
            }
          },
          onError: (_) => _fallbackSimulatedScan(),
          onDone: () {},
        );

        // Run for 10 seconds then finish
        Timer(const Duration(seconds: 10), () {
          subscription.cancel();
          channel.sink.close();
          _finishScan();
        });
        return;
      }
    } catch (e) {
      debugPrint('WebSocket failed: $e');
    }

    // Fallback to simulated scan
    _fallbackSimulatedScan();
  }

  void _fallbackSimulatedScan() {
    // Original simulated scan behavior
    _scanTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _instructionText = "Detecting Pulse...");
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _instructionText = "♥ 84 BPM");
            context.read<UserProvider>().updateBpm(84);
          }
        });
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() => _instructionText = "♥ 86 BPM");
            context.read<UserProvider>().updateBpm(86);
          }
        });
        Future.delayed(const Duration(seconds: 6), () {
          if (mounted) {
            setState(() => _instructionText = "♥ 85 BPM");
            context.read<UserProvider>().updateBpm(85);
          }
        });
      }
    });

    Timer(const Duration(seconds: 10), () => _finishScan());
  }

  void _finishScan() {
    if (mounted) {
      _pulseController.stop();
      setState(() {
        _isScanning = false;
        _currentStep = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStep == 1) {
      return const TriageScreen();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "New Appointment",
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                "Step 1: Face rPPG Scan",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.neonCyan,
                ),
              ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // --- ZONE A: Camera Preview (Mirror) ---
                    Flexible(
                      flex: 4,
                      child: Center(
                        child: Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isScanning ? AppColors.neonGreen : Colors.white24,
                              width: _isScanning ? 4.0 : 2.0,
                            ),
                            boxShadow: _isScanning
                                ? [
                                    BoxShadow(
                                      color: AppColors.neonGreen.withValues(alpha: 0.4),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    )
                                  ]
                                : [],
                          ),
                          child: ClipOval(
                            child: Stack(
                              fit: StackFit.expand,
                              alignment: Alignment.center,
                              children: [
                                // Layer 1: Camera Feed (Forced Aspect Fill)
                                FittedBox(
                                  fit: BoxFit.cover,
                                  child: SizedBox(
                                    width: 100, // Arbitrary aspect ratio base
                                    height: 100,
                                    child: _cameraInitialized
                                        ? CameraPreview(_controller!)
                                        : Container(color: Colors.black),
                                  ),
                                ),

                                // Layer 2: Face Guide Overlay (Strictly Centered)
                                Center(
                                  child: IgnorePointer(
                                    child: AnimatedOpacity(
                                      duration: const Duration(milliseconds: 500),
                                      opacity: _isScanning ? 0.0 : 0.8,
                                      child: Icon(
                                        Icons.face_retouching_natural, 
                                        size: 140, // 50% of container is safer visually
                                        color: Colors.white.withValues(alpha: 0.5)
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // --- ZONE B: Instruction Text ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _instructionText,
                          key: ValueKey(_instructionText),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: _isScanning ? AppColors.neonGreen : Colors.white,
                            fontWeight: _isScanning ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                    // --- ZONE C: Start Button (Trigger) ---
                    Flexible(
                      flex: 2,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width - 48,
                            child: PulseButton(
                              label: _buttonLabel,
                              onPressed: _isScanning ? null : _startFaceScan,
                              color: _isScanning ? AppColors.neonGreen : AppColors.neonCyan,
                              icon: _isScanning ? Icons.favorite : Icons.camera_front,
                              size: 100,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
