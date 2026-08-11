import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  Future<void> _copyToClipboard() async {
    // Fungsi bawaan Flutter untuk meng-copy teks
    await Clipboard.setData(ClipboardData(text: _danaNumber));
    
    setState(() {
      _isCopied = true;
    });

    try {
      await AudioManager().playSfx('correct.mp3'); // Bunyi "Ting!"
    } catch (e) {
      debugPrint('Audio error: $e');
    }

    // Kembalikan teks tombol setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendName = context.watch<AppState>().selectedFriendName;

    return Scaffold(
      body: Container(
        // Agar gradien background tetap memenuhi layar penuh walau di-scroll
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE8F5E9), // Hijau sangat pudar
              Color(0xFF81C784), // Hijau DANA
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              // PERBAIKAN: Menambahkan SingleChildScrollView agar bisa di-scroll di layar kecil
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoticon Uang Melayang
                    const Text(
                      "💸 🤑 💸",
                      style: TextStyle(fontSize: 60),
                    )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .slideY(begin: -0.1, end: 0.1, duration: 1000.ms)
                    .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),

                    const SizedBox(height: 20),

                    Text(
                      "EITS, TUNGGU DULU!",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontSize: 32,
                            shadows: AppTheme.softShadow,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fade().slideY(begin: -0.5),
                    
                    const SizedBox(height: 10),

                    Text(
                      "Peluk jauhnya udah diterima, TAPI...",
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 300.ms),

                    const SizedBox(height: 40),

                    // Card Pesan Kocak
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: AppTheme.softShadow,
                        border: Border.all(color: Colors.greenAccent, width: 3),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Sebagai bentuk apresiasi karena web ini dibuat dengan keringat, air mata, dan kurang tidur... 😌\n\nKalau $friendName kebetulan lagi banyak duit, abis menang arisan, atau tiba-tiba kesurupan pengen transfer 100 ribu buat jajanin kawanmu ini, pintu rekeningku terbuka sangat lebar lho! 😂✌️",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: AppTheme.darkText,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Kotak Nomor DANA
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blueAccent, width: 2),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Dompet DANA:",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _danaNumber,
                                  style: const TextStyle(
                                    color: Color(0xFF0D47A1),
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ).animate().shake(hz: 3, delay: 800.ms, duration: 1000.ms),
                        ],
                      ),
                    ).animate().scale(delay: 500.ms, curve: Curves.elasticOut, duration: 800.ms),

                    const SizedBox(height: 40),

                    // Tombol Copy Number
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _copyToClipboard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCopied ? Colors.green : Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: _isCopied ? 0 : 5,
                        ),
                        icon: Icon(_isCopied ? Icons.check_circle : Icons.copy, size: 24),
                        label: Text(
                          _isCopied ? "NOMOR DISALIN! DITUNGGU! 🤑" : "SALIN NOMOR DANA",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ).animate().fade(delay: 1000.ms).slideY(begin: 0.2),

                    const SizedBox(height: 20),
                    
                    const Text(
                      "*Bercanda doang (tapi kalau beneran ditransfer alhamdulillah wkwk)",
                      style: TextStyle(
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fade(delay: 1500.ms),
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