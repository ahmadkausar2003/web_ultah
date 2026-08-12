import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/audio/audio_manager.dart';
import '../core/theme/app_theme.dart';
import 'layer7_surprise_screen.dart';

class Layer6DecorateScreen extends StatefulWidget {
  const Layer6DecorateScreen({super.key});

  @override
  State<Layer6DecorateScreen> createState() => _Layer6DecorateScreenState();
}

class _Layer6DecorateScreenState extends State<Layer6DecorateScreen> {
  bool _hasStrawberry = false;
  bool _hasChocolate = false;
  bool _hasCandle = false;
  bool _hasPetai = false; // Toping slengean

  // Tombol hanya aktif jika minimal 1 toping dipilih
  bool get _canProceed {
    return _hasStrawberry || _hasChocolate || _hasCandle || _hasPetai;
  }

  void _toggleDecoration(String type) {
    setState(() {
      if (type == 'strawberry') {
        _hasStrawberry = !_hasStrawberry;
      } else if (type == 'chocolate') {
        _hasChocolate = !_hasChocolate;
      } else if (type == 'candle') {
        _hasCandle = !_hasCandle;
      } else if (type == 'petai') {
        _hasPetai = !_hasPetai;
      }
    });

    try {
      AudioManager().playSfx('pop.mp3');
    } catch (e) {
      debugPrint('Audio belum ditemukan: $e');
    }
  }

  Future<void> _finishDecoration() async {
    if (!_canProceed) {
      return;
    }

    try {
      await AudioManager().playSfx('click.mp3');
    } catch (e) {
      debugPrint('Audio belum ditemukan: $e');
    }

    if (!mounted) {
      return;
    }

    // PERBAIKAN: Gunakan pushReplacement agar memori browser tidak penuh/macet
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Layer7SurpriseScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFFF8008),
              Color(0xFFFFC837),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Hias Kue Sesuai Selera Rusuhmu!",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            shadows: AppTheme.softShadow,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fade().slideY(begin: -0.5),

                    SizedBox(
                      height: 260,
                      width: 260,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Positioned(
                            bottom: 10,
                            child: Text("🎂", style: TextStyle(fontSize: 130)),
                          ).animate().scale(delay: 200.ms, curve: Curves.elasticOut),

                          if (_hasChocolate)
                            Positioned(
                              bottom: 10,
                              child: const Text("🍫🍫🍫", style: TextStyle(fontSize: 30))
                                  .animate()
                                  .fade()
                                  .scale(curve: Curves.elasticOut),
                            ),

                          if (_hasStrawberry)
                            Positioned(
                              bottom: 80,
                              child: const Text("🍓 🍓 🍓", style: TextStyle(fontSize: 30))
                                  .animate()
                                  .fade()
                                  .slideY(begin: -0.5),
                            ),

                          if (_hasPetai)
                            Positioned(
                              bottom: 50,
                              child: const Text("🫘 🫘", style: TextStyle(fontSize: 35))
                                  .animate()
                                  .fade()
                                  .shake(hz: 8),
                            ),

                          if (_hasCandle)
                            Positioned(
                              top: 10,
                              child: const Text("🔥🕯️🔥", style: TextStyle(fontSize: 45))
                                  .animate()
                                  .fade()
                                  .slideY(begin: -1.0),
                            ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildToggleButton("🍓", "Stroberi", _hasStrawberry, () => _toggleDecoration('strawberry')),
                          _buildToggleButton("🍫", "Cokelat", _hasChocolate, () => _toggleDecoration('chocolate')),
                          _buildToggleButton("🕯️", "Lilin", _hasCandle, () => _toggleDecoration('candle')),
                          _buildToggleButton("🫘", "Petai", _hasPetai, () => _toggleDecoration('petai')),
                        ],
                      ),
                    ).animate().fade(delay: 300.ms),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        // Tombol hanya bisa diklik kalau _canProceed bernilai true (ada hiasan yang dipilih)
                        onPressed: _canProceed ? _finishDecoration : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canProceed ? Colors.greenAccent : Colors.grey[400],
                          foregroundColor: Colors.black87,
                          elevation: _canProceed ? 5 : 0,
                        ),
                        child: Text(
                          _canProceed ? "BAWA KUE KE PESTA! 🥳" : "Pilih minimal 1 toping woy!",
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: _canProceed ? Colors.black87 : Colors.black54,
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleButton(String emoji, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.yellowAccent : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.darkText,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}