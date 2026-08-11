import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/audio/audio_manager.dart';
import '../core/theme/app_theme.dart';
import 'layer4_trivia_screen.dart';

class Layer3BalloonScreen extends StatefulWidget {
  const Layer3BalloonScreen({super.key});

  @override
  State<Layer3BalloonScreen> createState() => _Layer3BalloonScreenState();
}

class _Layer3BalloonScreenState extends State<Layer3BalloonScreen> {
  final List<bool> _isPopped = List.generate(5, (_) => false);
  int _poppedCount = 0;

  final List<Alignment> _balloonPositions = [
    const Alignment(-0.7, -0.5),
    const Alignment(0.7, -0.3),
    const Alignment(0.1, 0.1),
    const Alignment(-0.6, 0.4),
    const Alignment(0.6, 0.6),
  ];

  final List<Color> _balloonColors = [
    Colors.yellowAccent,
    Colors.cyanAccent,
    Colors.pinkAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
  ];

  Future<void> _popBalloon(int index) async {
    if (_isPopped[index]) {
      return;
    }

    setState(() {
      _isPopped[index] = true;
      _poppedCount++;
    });

    try {
      await AudioManager().playSfx('pop.mp3');
    } catch (e) {
      debugPrint('Audio belum ditemukan: $e');
    }
  }

  Future<void> _nextScreen() async {
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
        builder: (context) => const Layer4TriviaScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF654EA3),
              Color(0xFFEAAFC8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Stack(
                children: [
                  Positioned(
                    top: 30,
                    left: 20,
                    right: 20,
                    child: Column(
                      children: [
                        Text(
                          "Pecahkan Semua Balon Rusuh!",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.white,
                                shadows: AppTheme.softShadow,
                              ),
                          textAlign: TextAlign.center,
                        ).animate().fade().slideY(begin: -0.5),
                        const SizedBox(height: 8),
                        Text(
                          "Sisa Balon: ${5 - _poppedCount}",
                          style: const TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  for (int i = 0; i < 5; i++)
                    Align(
                      alignment: _balloonPositions[i],
                      child: _isPopped[i]
                          ? const SizedBox.shrink()
                          : _buildBalloon(i),
                    ),

                  if (_poppedCount == 5)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: ElevatedButton(
                          onPressed: _nextScreen,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black87,
                          ),
                          child: const Text("MANTAP! LANJUT JALAN 🏃‍♂️"),
                        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalloon(int index) {
    return GestureDetector(
      onTap: () => _popBalloon(index),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          width: 90,
          height: 110,
          decoration: BoxDecoration(
            color: _balloonColors[index],
            borderRadius: const BorderRadius.all(Radius.elliptical(45, 55)),
            boxShadow: [
              BoxShadow(
                color: _balloonColors[index].withOpacity(0.8),
                blurRadius: 20,
                spreadRadius: 4,
                offset: const Offset(0, 5),
              )
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Center(
            child: Text(
              "💥",
              style: TextStyle(fontSize: 35),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .slideY(
          begin: -0.1,
          end: 0.1,
          duration: (600 + (index * 150)).ms,
          curve: Curves.easeInOut,
        )
        .rotate(
          begin: -0.05,
          end: 0.05,
          duration: 800.ms,
          curve: Curves.easeInOut,
        )
        .animate()
        .scale(delay: (100 * index).ms, duration: 400.ms, curve: Curves.elasticOut),
      ),
    );
  }
}