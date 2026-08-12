import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  Future<void> _startMission() async {
    try {
      await AudioManager().playSfx('click.mp3');
    } catch (e) {
      debugPrint('Audio belum ditemukan: $e');
    }

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Layer3BalloonScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final friendName = context.watch<AppState>().selectedFriendName;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF9A8B),
              Color(0xFFFF6A88),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Maskot Stres Berputar/Bergetar
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.softShadow,
                        border: Border.all(color: Colors.yellowAccent, width: 4),
                      ),
                      child: const Text(
                        "😱",
                        style: TextStyle(fontSize: 70),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .shake(hz: 6, duration: 600.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1)),
                    
                    const SizedBox(height: 30),

                    // Card Dialog Slengean
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: _TypewriterText(
                        text: "Woy $friendName! Gawat darurat! Kue ultah mu na bawa lari asta! Kalau tidak diselamatkan, si duta klarifikasi bakalan jadi monster kabulammats! Buruan tolongin!",
                      ),
                    ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 40),

                    // Tombol Semangat
                    ElevatedButton(
                      onPressed: _startMission,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellowAccent,
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                      ),
                      child: const Text("GAS, SELAMATKAN ASTA Duta Klarifikasi! 🚀"),
                    )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.08, 1.08),
                      duration: 600.ms,
                      curve: Curves.easeInOut,
                    ),
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

class _TypewriterText extends StatefulWidget {
  final String text;

  const _TypewriterText({required this.text});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      
      _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
        if (_currentIndex < widget.text.length) {
          setState(() {
            _displayedText += widget.text[_currentIndex];
            _currentIndex++;
          });
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            height: 1.5,
          ),
      textAlign: TextAlign.center,
    );
  }
}