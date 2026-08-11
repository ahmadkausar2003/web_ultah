import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/audio/audio_manager.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';
import 'layer6_decorate_screen.dart';

class Layer5BakingScreen extends StatefulWidget {
  const Layer5BakingScreen({super.key});

  @override
  State<Layer5BakingScreen> createState() => _Layer5BakingScreenState();
}

class _Layer5BakingScreenState extends State<Layer5BakingScreen> {
  double _progress = 0.0;
  int _clickCount = 0;
  bool _isNavigating = false;

  Future<void> _mixBatter() async {
    if (_progress >= 1.0 || _isNavigating) {
      return;
    }

    setState(() {
      _clickCount++;
      _progress += 0.08;
      if (_progress > 1.0) {
        _progress = 1.0;
      }
    });

    try {
      await AudioManager().playSfx('click.mp3');
    } catch (e) {
      debugPrint('Audio error: $e');
    }

    if (_progress >= 1.0 && !_isNavigating) {
      _isNavigating = true;

      try {
        await AudioManager().playSfx('correct.mp3');
      } catch (e) {
        debugPrint('Audio error: $e');
      }

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) {
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Layer6DecorateScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil nama dari state untuk membedakan tampilan
    final friendName = context.watch<AppState>().selectedFriendName;
    final isDewi = friendName.toLowerCase() == 'dewi';

    // Konfigurasi dinamis (Kalem tapi Energik)
    final List<Color> bgColors = isDewi 
        ? [const Color(0xFFFF9A9E), const Color(0xFFFECFEF)] // Pink kalem (Dewi)
        : [const Color(0xFFA1C4FD), const Color(0xFFC2E9FB)]; // Biru kalem (Nabila)
    
    final String title = isDewi ? "Dapur Psikologi" : "Apotek Kue";
    final String emojiCenter = isDewi ? "🥣" : "🧪";
    final String buttonText = isDewi ? "ADUK EMOSI!" : "RACIK RESEP!";

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgColors,
          ),
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
                    Text(
                      title,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppTheme.darkText,
                            shadows: AppTheme.softShadow,
                          ),
                    ).animate().fade().slideY(begin: -0.5),

                    const SizedBox(height: 12),
                    
                    Text(
                      "Spam klik buat bikin kue paling enak se-dunia!",
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 200.ms),

                    const SizedBox(height: 50),

                    // Mangkuk/Tabung Reaksi Bergetar
                    Container(
                      padding: const EdgeInsets.all(35),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Text(
                        emojiCenter,
                        style: const TextStyle(fontSize: 75),
                      ),
                    )
                    .animate(key: ValueKey(_clickCount))
                    .shake(hz: 8, duration: 250.ms, curve: Curves.easeInOut)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),

                    const SizedBox(height: 50),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        height: 28,
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: Colors.white.withOpacity(0.6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDewi ? Colors.pinkAccent : Colors.blueAccent
                          ),
                        ),
                      ),
                    ).animate().fade(delay: 300.ms),

                    const SizedBox(height: 12),

                    Text(
                      "${(_progress * 100).toInt()}%",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: AppTheme.darkText,
                          ),
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _mixBatter,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: isDewi ? Colors.pink : Colors.blue,
                        ),
                        child: Text(
                          buttonText,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ).animate().fade(delay: 400.ms).scale(curve: Curves.elasticOut),
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