import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  // Tema ala Korean Photobooth yang estetik
  final List<Map<String, dynamic>> _frames = [
    {"name": "Psikologi", "color": const Color(0xFFE8F5E9), "icon": "🧠", "textColor": Colors.black87},
    {"name": "Kedokteran", "color": const Color(0xFFE3F2FD), "icon": "🩺", "textColor": Colors.black87},
    {"name": "Pinky Cute", "color": const Color(0xFFFFE4E1), "icon": "🌸", "textColor": Colors.black87},
    {"name": "Dark Noir", "color": const Color(0xFF1E1E1E), "icon": "🖤", "textColor": Colors.white},
  ];

  Future<void> _continueToTrivia() async {
    Provider.of<AppState>(context, listen: false).setSelectedFrame(_selectedFrameIndex);
    try {
      await AudioManager().playSfx('correct.mp3');
    } catch (e) {}
    
    if (mounted) {
      // Gunakan pushReplacement agar tidak numpuk
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Layer4TriviaScreen()));
    }
  }

  // Desain Kertas Cetak Ala Photobooth
  Widget _buildKoreanPhotoboothStrip(List<Uint8List> images, Map<String, dynamic> frame, String friendName) {
    bool isGrid = images.length > 3; // Jika 6 foto, bentuknya grid (kotak lebar)
    
    return Container(
      width: isGrid ? 320 : 180,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 40),
      decoration: BoxDecoration(
        color: frame["color"],
        borderRadius: BorderRadius.circular(4), 
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(2, 4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isGrid)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: images.map((img) => _buildPhotoItem(img, 120, isGrid: true)).toList(),
            )
          else
            Column(
              children: images.map((img) => Padding(
                padding: const EdgeInsets.only(bottom: 12), 
                child: _buildPhotoItem(img, 150, isGrid: false),
              )).toList(),
            ),
          
          const SizedBox(height: 20),
          Text(
            "${frame["icon"]} $friendName's Day ${frame["icon"]}", 
            style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: isGrid ? 18 : 12, color: frame["textColor"]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoItem(Uint8List img, double height, {required bool isGrid}) {
    return Container(
      height: height,
      width: isGrid ? (height * 1.1) : (height * 0.9), // Rasio menyesuaikan bentuk
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.memory(img, fit: BoxFit.cover),
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
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text("Pilih Desain Frame Kamu!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)).animate().fade(),
                  
                  const SizedBox(height: 16),

                  // Carousel Pilihan Frame
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
                              border: Border.all(color: isSelected ? Colors.black87 : Colors.grey, width: 2),
                            ),
                            child: Text("${_frames[index]["icon"]} ${_frames[index]["name"]}", style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? _frames[index]["textColor"] : Colors.black54)),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Preview Foto (Korean Photobooth Style)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: images.isNotEmpty
                            ? _buildKoreanPhotoboothStrip(images, frame, friendName).animate(key: ValueKey(_selectedFrameIndex)).scale(duration: 300.ms)
                            : const Text("Belum ada foto nih!"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _continueToTrivia,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
                    child: const Text("CAKEP! LANJUT UJIAN 🏃‍♂️", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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