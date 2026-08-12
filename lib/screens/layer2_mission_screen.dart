import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/audio/audio_manager.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';
import 'layer3_balloon_screen.dart'; 

class Layer2MissionScreen extends StatefulWidget {
  const Layer2MissionScreen({super.key});

  @override
  State<Layer2MissionScreen> createState() => _Layer2MissionScreenState();
}

class _Layer2MissionScreenState extends State<Layer2MissionScreen> {
  CameraController? _cameraController;
  List<Uint8List> _capturedImages = [];
  bool _isCameraReady = false;
  bool _isCapturing = false;
  int _photoCountGoal = 3;
  int _countdown = 3;
  String _statusText = "Siap-siap pasang muka paling cakep!";

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final frontCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first);

        _cameraController = CameraController(frontCamera, ResolutionPreset.medium, enableAudio: false);
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraReady = true;
          });
        }
      } else {
        setState(() => _statusText = "Yah, kameranya gak ketemu :(");
      }
    } catch (e) {
      setState(() => _statusText = "Beri izin akses kamera di browser kamu ya!");
      debugPrint('Error kamera: $e');
    }
  }

  Future<void> _startPhotobooth() async {
    if (_isCapturing || !_isCameraReady || _cameraController == null) return;
    
    setState(() {
      _isCapturing = true;
      _capturedImages.clear();
    });

    for (int i = 0; i < _photoCountGoal; i++) {
      for (int c = 3; c > 0; c--) {
        if (!mounted) return;
        setState(() {
          _countdown = c;
          _statusText = "Gaya ke-${i + 1}... $c";
        });
        try { await AudioManager().playSfx('click.mp3'); } catch (e) {}
        await Future.delayed(const Duration(seconds: 1));
      }

      if (!mounted) return;
      setState(() => _statusText = "CEKREK! 📸");
      try { await AudioManager().playSfx('pop.mp3'); } catch (e) {}
      
      try {
        final xFile = await _cameraController!.takePicture();
        final bytes = await xFile.readAsBytes();
        _capturedImages.add(bytes);
      } catch (e) {
        debugPrint('Gagal jepret: $e');
      }
      
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (mounted) {
      // Simpan foto ke state memori
      Provider.of<AppState>(context, listen: false).setPhotoboothImages(_capturedImages);
      
      // PERBAIKAN: Matikan hardware kamera sebelum pindah layar
      final oldController = _cameraController;
      setState(() {
        _cameraController = null;
        _isCameraReady = false;
      });
      await oldController?.dispose();

      // PERBAIKAN: Gunakan pushReplacement agar tidak menumpuk
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const Layer3BalloonScreen())
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)]),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Darurat Photobooth! 📸", style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.darkText)).animate().fade(),
                    const SizedBox(height: 10),
                    Text(_statusText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)).animate().fade(),
                    
                    const SizedBox(height: 30),

                    Container(
                      height: 350,
                      width: 280,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _isCameraReady && _cameraController != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  CameraPreview(_cameraController!),
                                  if (_isCapturing && _statusText.contains("..."))
                                    Center(
                                      child: Text("$_countdown", style: const TextStyle(fontSize: 120, color: Colors.white, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black, blurRadius: 10)]))
                                          .animate(key: ValueKey(_countdown)).scale(curve: Curves.elasticOut, duration: 500.ms),
                                    ),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 30),

                    if (!_isCapturing && _isCameraReady) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text("3 Foto (Strip)"),
                            selected: _photoCountGoal == 3,
                            onSelected: (val) => setState(() => _photoCountGoal = 3),
                          ),
                          const SizedBox(width: 16),
                          ChoiceChip(
                            label: const Text("6 Foto (Grid)"),
                            selected: _photoCountGoal == 6,
                            onSelected: (val) => setState(() => _photoCountGoal = 6),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _startPhotobooth,
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                        child: const Text("MULAI FOTO! 🚀", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ).animate().scale(curve: Curves.elasticOut),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}