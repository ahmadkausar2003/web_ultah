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
  bool _isVertical = true; // Toggle Vertikal / Horizontal
  bool _isProcessing = false; // Loading saat mau screenshot
  
  final ScreenshotController _screenshotController = ScreenshotController();

  // Tema ala Korean Photobooth yang Super Cute dengan Karakter Gemas
  final List<Map<String, dynamic>> _frames = [
    {"name": "Beary Cute", "color": const Color(0xFFFFE4E1), "icon": "🐻", "decor": "🐾", "textColor": Colors.brown},
    {"name": "Dino Roar", "color": const Color(0xFFE8F5E9), "icon": "🦖", "decor": "🌿", "textColor": Colors.green[900]},
    {"name": "Bunny Hop", "color": const Color(0xFFF3E5F5), "icon": "🐰", "decor": "🥕", "textColor": Colors.purple[900]},
    {"name": "Alien Vibes", "color": const Color(0xFFE0F7FA), "icon": "👽", "decor": "🛸", "textColor": Colors.teal[900]},
  ];

  Future<void> _continueToTrivia() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await AudioManager().playSfx('click.mp3');
      
      // KEAJAIBAN TERJADI DI SINI:
      // Kita "foto" hasil jepretan yang sudah di-zoom & digeser ini
      final imageBytes = await _screenshotController.capture(delay: const Duration(milliseconds: 100));
      
      if (imageBytes != null && mounted) {
        Provider.of<AppState>(context, listen: false).setSelectedFrame(_selectedFrameIndex);
        Provider.of<AppState>(context, listen: false).setFinalPhotoboothStrip(imageBytes); // Simpan hasil akhir!
        
        await AudioManager().playSfx('correct.mp3');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Layer4TriviaScreen()));
      }
    } catch (e) {
      debugPrint('Error mengambil screenshot: $e');
      setState(() => _isProcessing = false);
    }
  }

  // Desain Kertas Cetak yang Canggih
  Widget _buildInteractivePhotobooth(List<Uint8List> images, Map<String, dynamic> frame, String friendName) {
    int totalPhotos = images.length;
    double photoSize = 130.0;
    
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 35),
      decoration: BoxDecoration(
        color: frame["color"],
        borderRadius: BorderRadius.circular(12), 
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Layout Dinamis Berdasarkan Toggle (Vertikal/Horizontal) & Jumlah Foto
              if (_isVertical) 
                Wrap(
                  spacing: 12, runSpacing: 12, 
                  alignment: WrapAlignment.center,
                  // Jika 6 foto = 2 kolom, Jika 3 foto = 1 kolom
                  children: images.map((img) => _buildZoomablePhoto(img, photoSize, photoSize * 0.8)).toList(),
                )
              else 
                Wrap(
                  spacing: 12, runSpacing: 12, 
                  alignment: WrapAlignment.center,
                  // Layout Horizontal (melebar)
                  children: images.map((img) => _buildZoomablePhoto(img, photoSize * 0.8, photoSize)).toList(),
                ),
              
              const SizedBox(height: 20),
              
              // Teks di bagian bawah frame
              Text(
                "${frame["decor"]} $friendName's Day ${frame["icon"]}", 
                style: TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, fontSize: 16, color: frame["textColor"]),
              ),
            ],
          ),

          // Dekorasi Menggemaskan di Pojok Kiri Atas
          Positioned(
            top: -25, left: -20,
            child: Text(frame["icon"], style: const TextStyle(fontSize: 40)),
          ),
          // Dekorasi di Pojok Kanan Bawah
          Positioned(
            bottom: -20, right: -15,
            child: Text(frame["decor"], style: const TextStyle(fontSize: 35)),
          ),
        ],
      ),
    );
  }

  // FITUR BARU: BISA DI-ZOOM & DI-GESER!
  Widget _buildZoomablePhoto(Uint8List img, double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black87, width: 3), borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        // InteractiveViewer memungkinkan Zoom dan Pan pakai jari/mouse!
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1.0, // Minimal ukuran asli
          maxScale: 4.0, // Bisa di-zoom sampai 4x
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
              constraints: const BoxConstraints(maxWidth: 800), // Diperlebar agar horizontal muat
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text("Edit & Pilih Frame Gemasmu!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)).animate().fade(),
                  const Text("(Cubir / Scroll untuk Zoom, Geser fotonya!)", style: TextStyle(fontSize: 12, color: Colors.black54)).animate().fade(),
                  
                  const SizedBox(height: 16),

                  // Toggle Orientasi (Vertikal / Horizontal)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Tegak (Vertikal)"),
                        selected: _isVertical,
                        onSelected: (val) => setState(() => _isVertical = true),
                        selectedColor: Colors.yellowAccent,
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text("Tidur (Horizontal)"),
                        selected: !_isVertical,
                        onSelected: (val) => setState(() => _isVertical = false),
                        selectedColor: Colors.yellowAccent,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Carousel Pilihan Karakter Frame
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

                  // PREVIEW STUDIO (Bisa di-zoom/pan)
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: images.isNotEmpty
                            ? Container(
                                // Sedikit margin agar box-shadow & ornamen tidak terpotong
                                padding: const EdgeInsets.all(20), 
                                child: Screenshot(
                                  controller: _screenshotController,
                                  // Kotak inilah yang akan difoto sistem
                                  child: Container(
                                    // Tambahkan warna dasar agar screenshot tidak transparan di background
                                    color: Colors.transparent, 
                                    child: _buildInteractivePhotobooth(images, frame, friendName)
                                  ),
                                ),
                              ).animate(key: ValueKey("$_selectedFrameIndex-$_isVertical")).scale(duration: 300.ms)
                            : const Text("Belum ada foto nih!"),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // Tombol Selesai
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