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
  final List<Uint8List> _capturedImages = [];
  bool _isCameraReady = false;
  bool _isTakingPhoto = false;
  int _photoCountGoal = 3;

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
      }
    } catch (e) {
      debugPrint('Error kamera: $e');
    }
  }

  Future<void> _takeManualPhoto() async {
    if (!_isCameraReady || _isTakingPhoto || _cameraController == null) return;
    if (_capturedImages.length >= _photoCountGoal) return; 

    setState(() => _isTakingPhoto = true);
    
    try { await AudioManager().playSfx('click.mp3'); } catch (e) {}

    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();
      
      try { await AudioManager().playSfx('pop.mp3'); } catch (e) {}

      setState(() {
        _capturedImages.add(bytes);
      });
    } catch (e) {
      debugPrint('Gagal jepret: $e');
    }
    
    setState(() => _isTakingPhoto = false);
  }

  void _retakeLast() {
    if (_capturedImages.isNotEmpty) {
      setState(() {
        _capturedImages.removeLast();
      });
      try { AudioManager().playSfx('click.mp3'); } catch (e) {}
    }
  }

  void _retakeAll() {
    setState(() {
      _capturedImages.clear();
    });
    try { AudioManager().playSfx('click.mp3'); } catch (e) {}
  }

  Future<void> _finishPhotobooth() async {
    if (_capturedImages.length < _photoCountGoal) return;

    if (mounted) {
      Provider.of<AppState>(context, listen: false).setPhotoboothImages(_capturedImages);
      
      final oldController = _cameraController;
      setState(() {
        _cameraController = null;
        _isCameraReady = false;
      });
      await oldController?.dispose();

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
    bool isDone = _capturedImages.length == _photoCountGoal;

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE0C3FC), Color(0xFF8EC5FC)]),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              // PERBAIKAN: SingleChildScrollView agar tidak overflow di HP
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Darurat Photobooth! 📸", style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.darkText, fontSize: 32)).animate().fade(),
                    const SizedBox(height: 5),
                    Text(
                      isDone ? "Bagus! Silakan lanjut ke Frame!" : "Foto ${_capturedImages.length} dari $_photoCountGoal", 
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDone ? Colors.green[800] : Colors.indigo)
                    ),
                    const SizedBox(height: 20),

                    Container(
                      height: 320,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: isDone ? Colors.greenAccent : Colors.white, width: 4),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _isCameraReady && _cameraController != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  CameraPreview(_cameraController!),
                                  if (_isTakingPhoto)
                                    Container(color: Colors.white).animate().fade(duration: 100.ms).then().fadeOut(duration: 200.ms),
                                  if (isDone)
                                    Container(
                                      color: Colors.black54,
                                      child: const Center(child: Icon(Icons.check_circle, color: Colors.greenAccent, size: 80)),
                                    ).animate().fade(),
                                ],
                              )
                            : const Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: _photoCountGoal,
                        itemBuilder: (context, index) {
                          bool hasImage = index < _capturedImages.length;
                          return Container(
                            width: 50,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: hasImage 
                                ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.memory(_capturedImages[index], fit: BoxFit.cover))
                                : const Center(child: Icon(Icons.photo_camera_back, color: Colors.black26, size: 20)),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (_capturedImages.isEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(label: const Text("3 Foto (Strip)"), selected: _photoCountGoal == 3, onSelected: (val) => setState(() => _photoCountGoal = 3)),
                          const SizedBox(width: 16),
                          ChoiceChip(label: const Text("6 Foto (Grid)"), selected: _photoCountGoal == 6, onSelected: (val) => setState(() => _photoCountGoal = 6)),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (!isDone) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_capturedImages.isNotEmpty)
                            IconButton(
                              onPressed: _retakeLast,
                              icon: const Icon(Icons.undo),
                              style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.redAccent, padding: const EdgeInsets.all(12)),
                            ).animate().scale(),
                          
                          if (_capturedImages.isNotEmpty) const SizedBox(width: 20),

                          ElevatedButton(
                            onPressed: _takeManualPhoto,
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryPink, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: const CircleBorder()),
                            child: const Icon(Icons.camera_alt, size: 40, color: Colors.white),
                          ).animate().scale(curve: Curves.elasticOut),
                        ],
                      ),
                    ] else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _retakeAll,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Ulang"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _finishPhotobooth,
                            icon: const Icon(Icons.check),
                            label: const Text("LANJUT!"),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                          ).animate().scale(curve: Curves.elasticOut),
                        ],
                      ),
                    ],
                    const SizedBox(height: 30), // Padding ekstra di bawah agar scroll lebih lega
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