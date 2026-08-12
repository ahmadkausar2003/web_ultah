// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:screenshot/screenshot.dart';

import '../core/audio/audio_manager.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';

class Layer8DonationScreen extends StatefulWidget {
  const Layer8DonationScreen({super.key});

  @override
  State<Layer8DonationScreen> createState() => _Layer8DonationScreenState();
}

class _Layer8DonationScreenState extends State<Layer8DonationScreen> {
  bool _isCopied = false;
  final String _danaNumber = "082314118811";
  final ScreenshotController _screenshotController = ScreenshotController();

  final List<Map<String, dynamic>> _frames = [
    {"color": const Color(0xFFE8F5E9), "icon": "🧠", "textColor": Colors.black87},
    {"color": const Color(0xFFE3F2FD), "icon": "🩺", "textColor": Colors.black87},
    {"color": const Color(0xFFFFE4E1), "icon": "🌸", "textColor": Colors.black87},
    {"color": const Color(0xFF1E1E1E), "icon": "🖤", "textColor": Colors.white},
  ];

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _danaNumber));
    setState(() => _isCopied = true);
    try { await AudioManager().playSfx('correct.mp3'); } catch (e) {}
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  Future<void> _downloadPhotoStrip() async {
    try {
      await AudioManager().playSfx('click.mp3');
      final imageBytes = await _screenshotController.capture(delay: const Duration(milliseconds: 10));
      if (imageBytes != null) {
        final base64data = base64Encode(imageBytes);
        final a = html.AnchorElement(href: 'data:image/png;base64,$base64data');
        a.download = 'Photobooth_Ultah.png';
        a.click();
        a.remove();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Foto diunduh! Cek galeri kamu 🥳"), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("Gagal download: $e");
    }
  }

  Widget _buildKoreanPhotoboothStrip(List<Uint8List> images, Map<String, dynamic> frame, String friendName) {
    bool isGrid = images.length > 3;
    return Container(
      width: isGrid ? 320 : 180,
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 40),
      decoration: BoxDecoration(
        color: frame["color"],
        borderRadius: BorderRadius.circular(4), 
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isGrid)
            Wrap(
              spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
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
      width: isGrid ? (height * 1.1) : (height * 0.9),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.black87, width: 2), borderRadius: BorderRadius.circular(4)),
      child: ClipRRect(borderRadius: BorderRadius.circular(2), child: Image.memory(img, fit: BoxFit.cover)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final friendName = appState.selectedFriendName;
    final images = appState.photoboothImages;
    
    // Safety check jika _selectedFrame belum ter-set
    final frame = _frames[appState.selectedFrame < _frames.length ? appState.selectedFrame : 0];

    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE8F5E9), Color(0xFF81C784)]),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ==========================================
                    // EMOJI UANG TERBANG YANG DIKEMBALIKAN! 💸
                    // ==========================================
                    const Text(
                      "💸 🤑 💸",
                      style: TextStyle(fontSize: 60),
                    )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .slideY(begin: -0.15, end: 0.15, duration: 1200.ms, curve: Curves.easeInOutSine)
                    .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),

                    const SizedBox(height: 20),

                    Text("EITS, TUNGGU DULU!", style: Theme.of(context).textTheme.displayLarge?.copyWith(color: const Color(0xFF2E7D32), fontSize: 32)).animate().fade(),
                    const SizedBox(height: 10),
                    Text("Jangan lupa bawa pulang fotonya!", style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold, fontSize: 18)).animate().fade(delay: 300.ms),
                    const SizedBox(height: 30),

                    // Screenshot Wrapper untuk Download Foto
                    if (images.isNotEmpty)
                      Screenshot(
                        controller: _screenshotController,
                        child: _buildKoreanPhotoboothStrip(images, frame, friendName),
                      ).animate().scale(delay: 400.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 30),
                    
                    // Tombol Download
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _downloadPhotoStrip,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        icon: const Icon(Icons.download),
                        label: const Text("DOWNLOAD HASIL FOTO 📸", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ).animate().fade(delay: 600.ms).slideY(begin: 0.2),

                    const SizedBox(height: 40),

                    // Card Rekening DANA
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.greenAccent, width: 3)),
                      child: Column(
                        children: [
                          Text("Sebagai bentuk apresiasi web dan studio foto gratis ini di buat dengan keringat,air mata dan kurang tidur.. 😌\n\nKalau $friendName kebetulan kesurupan pengen transfer 100 ribu buat jajanin kawanmu ini, pintu rekeningku terbuka sangat lebar lho! 😂✌️", style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5), textAlign: TextAlign.center),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blueAccent, width: 2)),
                            child: Column(
                              children: [
                                const Text("Dompet DANA:", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(_danaNumber, style: const TextStyle(color: Color(0xFF0D47A1), fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(delay: 800.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 20),

                    // Tombol Salin
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _copyToClipboard,
                        style: ElevatedButton.styleFrom(backgroundColor: _isCopied ? Colors.green : Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        icon: Icon(_isCopied ? Icons.check_circle : Icons.copy),
                        label: Text(_isCopied ? "NOMOR DISALIN! 🤑" : "SALIN NOMOR DANA", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ).animate().fade(delay: 1000.ms).slideY(begin: 0.2),
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