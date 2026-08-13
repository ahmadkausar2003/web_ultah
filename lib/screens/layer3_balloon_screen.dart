import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:screenshot/screenshot.dart';

import '../core/audio/audio_manager.dart';
import '../core/state/app_state.dart';
import 'layer4_trivia_screen.dart';

class Layer3BalloonScreen extends StatefulWidget {
  const Layer3BalloonScreen({super.key});

  @override
  State<Layer3BalloonScreen> createState() => _Layer3BalloonScreenState();
}

class _Layer3BalloonScreenState extends State<Layer3BalloonScreen> {
  int _selectedFrameIndex = 0;
  bool _isVertical = true; 
  bool _isProcessing = false; 
  
  final ScreenshotController _screenshotController = ScreenshotController();

  final List<Map<String, dynamic>> _frames = [
    {"name": "Beary Cute", "color": const Color(0xFFFDE4E4), "borderColor": const Color(0xFFFFB6C1), "icon": "🐻", "decor": "🐾", "float1": "🎀", "float2": "✨", "textColor": Colors.brown},
    {"name": "Dino Roar", "color": const Color(0xFFE8F5E9), "borderColor": const Color(0xFFA5D6A7), "icon": "🦖", "decor": "🌿", "float1": "🦕", "float2": "⭐", "textColor": Colors.green[900]},
    {"name": "Bunny Hop", "color": const Color(0xFFF3E5F5), "borderColor": const Color(0xFFCE93D8), "icon": "🐰", "decor": "🥕", "float1": "💖", "float2": "🌸", "textColor": Colors.purple[900]},
    {"name": "Alien Vibes", "color": const Color(0xFFE0F7FA), "borderColor": const Color(0xFF80DEEA), "icon": "👽", "decor": "🛸", "float1": "👾", "float2": "🪐", "textColor": Colors.teal[900]},
  ];

  Future<void> _continueToTrivia() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await AudioManager().playSfx('click.mp3');
      
      final imageBytes = await _screenshotController.capture(delay: const Duration(milliseconds: 150));
      
      if (imageBytes != null && mounted) {
        Provider.of<AppState>(context, listen: false).setSelectedFrame(_selectedFrameIndex);
        Provider.of<AppState>(context, listen: false).setFinalPhotoboothStrip(imageBytes); 
        
        await AudioManager().playSfx('correct.mp3');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Layer4TriviaScreen()));
      }
    } catch (e) {
      debugPrint('Error mengambil screenshot: $e');
      setState(() => _isProcessing = false);
    }
  }

  // ==========================================
  // PERBAIKAN GRID: ANTI-OVERFLOW & 100% SIMETRIS
  // ==========================================
  Widget _buildInteractivePhotobooth(List<Uint8List> images, Map<String, dynamic> frame, String friendName) {
    bool isSixPhotos = images.length > 3;

    double photoWidth = _isVertical ? 150.0 : 120.0;
    double photoHeight = _isVertical ? 110.0 : 150.0;
    double spacing = 14.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bingkai Utama - HAPUS Lebar Kaku (width) agar otomatis membungkus isi
        Container(
          padding: const EdgeInsets.only(top: 35, left: 24, right: 24, bottom: 25),
          decoration: BoxDecoration(
            color: frame["color"],
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: frame["borderColor"], width: 6), 
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(3, 6))]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Penting agar tinggi dan lebar pas
            children: [
              Text(
                "✨ Bestie Photobooth ✨",
                style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 12, color: frame["textColor"]?.withOpacity(0.7)),
              ),
              const SizedBox(height: 12),

              // RAKITAN FOTO (Menggunakan Wrap agar tidak ada jarak lebih di ujung)
              if (_isVertical)
                isSixPhotos
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildColumnPhotos(images.sublist(0, 3), photoWidth, photoHeight, frame, spacing),
                          SizedBox(width: spacing),
                          _buildColumnPhotos(images.sublist(3, 6), photoWidth, photoHeight, frame, spacing),
                        ],
                      )
                    : _buildColumnPhotos(images, photoWidth, photoHeight, frame, spacing)
              else
                isSixPhotos
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildRowPhotos(images.sublist(0, 3), photoWidth, photoHeight, frame, spacing),
                          SizedBox(height: spacing),
                          _buildRowPhotos(images.sublist(3, 6), photoWidth, photoHeight, frame, spacing),
                        ],
                      )
                    : _buildRowPhotos(images, photoWidth, photoHeight, frame, spacing),

              const SizedBox(height: 20),
              
              // FOOTER STUDIO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: frame["borderColor"].withOpacity(0.5), width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(frame["decor"], style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        Text(
                          "$friendName's Day", 
                          style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.w900, fontSize: 18, color: frame["textColor"]),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(18, (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.0),
                            width: index % 5 == 0 ? 3 : 1.5,
                            height: 14,
                            color: frame["textColor"].withOpacity(0.8),
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Text(frame["icon"], style: const TextStyle(fontSize: 24)),
                  ],
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: -15, left: -10,
          child: Transform.rotate(angle: -0.2, child: Text(frame["float1"], style: const TextStyle(fontSize: 35))),
        ),
        
        Positioned(
          bottom: -15, right: -10,
          child: Transform.rotate(angle: 0.2, child: Text(frame["float2"], style: const TextStyle(fontSize: 35))),
        ),

        Positioned(
          top: -12,
          left: 0, 
          right: 0,
          child: Align(
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -0.08,
                  child: Container(
                    width: 100, height: 30,
                    decoration: BoxDecoration(
                      color: frame["borderColor"].withOpacity(0.4),
                      border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2))],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: 0.05,
                  child: Container(
                    width: 100, height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Menggunakan Wrap agar spacing otomatis dan presisi tanpa overflow
  Widget _buildColumnPhotos(List<Uint8List> imgs, double w, double h, Map<String, dynamic> frame, double spacing) {
    return Wrap(
      direction: Axis.vertical,
      spacing: spacing,
      children: imgs.map((img) => _buildZoomablePhoto(img, w, h, frame)).toList(),
    );
  }

  // Menggunakan Wrap untuk susunan Horizontal
  Widget _buildRowPhotos(List<Uint8List> imgs, double w, double h, Map<String, dynamic> frame, double spacing) {
    return Wrap(
      spacing: spacing,
      children: imgs.map((img) => _buildZoomablePhoto(img, w, h, frame)).toList(),
    );
  }

  Widget _buildZoomablePhoto(Uint8List img, double w, double h, Map<String, dynamic> frame) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white, 
        border: Border.all(color: frame["borderColor"], width: 4), 
        borderRadius: BorderRadius.circular(12) 
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1.0, 
          maxScale: 4.0, 
          child: Image.memory(img, fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final images = appState.photoboothImages;
    final friendName = appState.selectedFriendName;
    final frame = _frames[_selectedFrameIndex];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFffecd2), Color(0xFFfcb69f)]),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800), 
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text("Edit & Pilih Frame Gemasmu!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.brown), textAlign: TextAlign.center).animate().fade(),
                  const Text("(Geser dan Cubit foto untuk mengatur posisinya!)", style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold), textAlign: TextAlign.center).animate().fade(),
                  
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Tegak (Vertikal)"),
                        selected: _isVertical,
                        onSelected: (val) {
                          setState(() => _isVertical = true);
                          AudioManager().playSfx('click.mp3');
                        },
                        selectedColor: Colors.yellowAccent,
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text("Tidur (Horizontal)"),
                        selected: !_isVertical,
                        onSelected: (val) {
                          setState(() => _isVertical = false);
                          AudioManager().playSfx('click.mp3');
                        },
                        selectedColor: Colors.yellowAccent,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _frames.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedFrameIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedFrameIndex = index);
                            AudioManager().playSfx('click.mp3');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? _frames[index]["color"] : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? _frames[index]["borderColor"] : Colors.grey, width: 3),
                            ),
                            child: Text("${_frames[index]["icon"]} ${_frames[index]["name"]}", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? _frames[index]["textColor"] : Colors.black54)),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: Center(
                      child: images.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), 
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Screenshot(
                                  controller: _screenshotController,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10), 
                                    color: Colors.transparent, 
                                    child: _buildInteractivePhotobooth(images, frame, friendName)
                                  ),
                                ),
                              ),
                            ).animate(key: ValueKey("$_selectedFrameIndex-$_isVertical")).scale(duration: 300.ms, curve: Curves.easeOutBack)
                          : const Text("Belum ada foto nih!"),
                    ),
                  ),

                  const SizedBox(height: 10),
                  
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _continueToTrivia,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                    child: _isProcessing 
                      ? const CircularProgressIndicator(color: Colors.black87)
                      : const Text("FOTO UDAH PAS! LANJUT 🏃‍♂️", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ).animate().slideY(begin: 0.5),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}