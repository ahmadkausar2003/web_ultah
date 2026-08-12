import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';

import '../core/audio/audio_manager.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';
import 'layer8_donation_screen.dart'; 

class Layer7SurpriseScreen extends StatefulWidget {
  const Layer7SurpriseScreen({super.key});

  @override
  State<Layer7SurpriseScreen> createState() => _Layer7SurpriseScreenState();
}

class _Layer7SurpriseScreenState extends State<Layer7SurpriseScreen> {
  late ConfettiController _confettiController;
  late ConfettiController _heartConfettiController;
  
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _heartConfettiController = ConfettiController(duration: const Duration(seconds: 3));
    _startSurpriseSequence();
  }

  Future<void> _startSurpriseSequence() async {
    final friendName = Provider.of<AppState>(context, listen: false).selectedFriendName;
    final folderName = friendName.toLowerCase();

    await AudioManager().stopBgm();
    
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) {
      return;
    }

    setState(() {
      _isDark = false;
    });

    _confettiController.play();
    _startAutoScroll();

    try {
      await AudioManager().playSfx('$folderName/voice_$folderName.mp3');
    } catch (e) {
      debugPrint('Voice note belum ditemukan: $e');
    }
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.offset;
        
        if (currentScroll < maxScroll) {
          _scrollController.jumpTo(currentScroll + 1.0);
        } else {
          _scrollController.jumpTo(0.0);
        }
      }
    });
  }

  Future<void> _triggerVirtualHug() async {
    try {
      await AudioManager().playSfx('pop.mp3');
    } catch (e) {
      debugPrint('Audio tidak ditemukan: $e');
    }
    
    _heartConfettiController.play();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Layer8DonationScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _heartConfettiController.dispose();
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Path _drawHeart(Size size) {
    double width = size.width;
    double height = size.height;
    Path path = Path();
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.25 * width, height * 0.6, 0.5 * width, height);
    path.cubicTo(1.25 * width, height * 0.6, 0.8 * width, height * 0.1, 0.5 * width, height * 0.35);
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final friendName = context.watch<AppState>().selectedFriendName;
    final String folderName = friendName.toLowerCase(); 
    final bool isDewi = folderName == 'dewi';

    // Teks Ucapan yang Berbeda untuk Dewi (Psikologi) dan Nabila (Kedokteran)
    final String greetingText = isDewi
        ? "Selamat ulang tahun, Dewi ! 🥳\n\nYang kalau badmood mendadak langsung berubah jadi reog! Kurang-kurangin dong pasang muka ketatnya, mending sekarang fokus cari jati diri yang baru. Ingat, mantan hanyalah masa lalu yang perlu di-format ulang seperti laptop lemot. Yuk, buka lembaran baru, siapa tahu jati dirimu yang baru ini ketemunya sama jodoh yang lebih ganteng dan spek dewa! Nikmati pestanya, ya!"
        : "Selamat ulang tahun, Nabila! 🎉\n\nYang sabar yah setiap minggu harus menahan diri biar tidak malpraktik gara-gara ketemu musuh bebuyutan berwujud mantan di divisi rumah sakit yang sama. Kerjaan koas sudah bikin tensi naik, ditambah lihat muka mantan pasti bikin pengen nyuntik dia pakai infus kosong kan? Semoga di usia baru ini kamu makin jago jaga imun dan iman. Biar si mantan menyesal seumur hidup setiap kali melihat pesonamu yang makin menyala di lorong RS. Semangat koasnya Nikmati pestanya, ya!";

    return Scaffold(
      backgroundColor: _isDark ? Colors.black : Colors.transparent,
      body: Stack(
        children: [
          if (!_isDark)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFF9A9E), 
                      Color(0xFFFECFEF), 
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

          SafeArea(
            child: Center(
              child: _isDark
                  ? const Text(
                      "Siap-siap ya...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontStyle: FontStyle.italic,
                      ),
                    ).animate().fade(duration: 800.ms)
                  : ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          const SizedBox(height: 10),
                          
                          Text(
                            "HAPPY BIRTHDAY",
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 34,
                                  shadows: AppTheme.softShadow,
                                ),
                            textAlign: TextAlign.center,
                          ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
                          
                          Text(
                            friendName.toUpperCase(),
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: AppTheme.darkText,
                                  fontSize: 52,
                                  shadows: AppTheme.softShadow,
                                ),
                            textAlign: TextAlign.center,
                          ).animate().scale(delay: 200.ms, curve: Curves.elasticOut, duration: 800.ms),

                          const SizedBox(height: 30),

                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 10, 
                              itemBuilder: (context, index) {
                                int photoIndex = (index % 4) + 1; 
                                String assetPath = 'assets/images/$folderName/foto$photoIndex.jpg';
                                
                                return Container(
                                  width: 140,
                                  margin: const EdgeInsets.only(right: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: AppTheme.softShadow,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      assetPath,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Text(
                                            "Taruh foto di\n$assetPath",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ).animate().fade(delay: 600.ms).slideX(begin: 0.2),
                          ),

                          const SizedBox(height: 30),

                          // Teks Ucapan Dinamis Sesuai Karakter
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: AppTheme.softShadow,
                            ),
                            child: Text(
                              greetingText,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    height: 1.5,
                                    color: AppTheme.darkText,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ).animate().fade(delay: 800.ms).slideY(begin: 0.2),

                          const SizedBox(height: 30),

                          ElevatedButton(
                            onPressed: _triggerVirtualHug,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryPink,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: const Text("KIRIM PELUK JAUH! 🤗", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ).animate().fade(delay: 1000.ms).scale(),
                          
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 6,
              minBlastForce: 3,
              emissionFrequency: 0.08,
              numberOfParticles: 60,
              gravity: 0.15,
              colors: const [Colors.white, Colors.pink, Colors.purple, Colors.lightBlue],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: ConfettiWidget(
              confettiController: _heartConfettiController,
              blastDirection: -pi / 2,
              maxBlastForce: 12,
              minBlastForce: 6,
              emissionFrequency: 0.12,
              numberOfParticles: 25,
              gravity: 0.1,
              createParticlePath: _drawHeart,
              colors: const [Colors.redAccent, Colors.pinkAccent],
            ),
          ),
        ],
      ),
    );
  }
}