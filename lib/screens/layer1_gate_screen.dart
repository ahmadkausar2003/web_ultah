import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/audio/audio_manager.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';
import 'layer2_mission_screen.dart';

class Layer1GateScreen extends StatefulWidget {
  const Layer1GateScreen({super.key});

  @override
  State<Layer1GateScreen> createState() => _Layer1GateScreenState();
}

class _Layer1GateScreenState extends State<Layer1GateScreen> {
  // Fungsi untuk menampilkan Pop-up Password
  void _showPasswordDialog(BuildContext context, String name, String correctPassword) {
    final TextEditingController passwordController = TextEditingController();
    String errorMessage = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                "Masukkan Password 🔐",
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.darkText,
                      fontSize: 22,
                    ),
                textAlign: TextAlign.center,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Buktikan kalau kamu beneran $name!",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Ketik di sini...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      errorText: errorMessage.isNotEmpty ? errorMessage : null,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Tutup dialog jika batal
                  },
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text.toLowerCase().trim() == correctPassword) {
                      Navigator.pop(context); // Tutup dialog jika benar
                      await _proceedToMission(name);
                    } else {
                      setStateDialog(() {
                        errorMessage = "Password salah woy!";
                      });
                      try {
                        await AudioManager().playSfx('wrong.mp3');
                      } catch (e) {
                        debugPrint('Audio error: $e');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Masuk"),
                ),
              ],
            ).animate().scale(curve: Curves.easeOutBack, duration: 400.ms);
          },
        );
      },
    );
  }

  Future<void> _proceedToMission(String name) async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setFriendName(name);

    try {
      await AudioManager().playSfx('correct.mp3');
      await AudioManager().playBgm('bgm_main.mp3');
    } catch (e) {
      debugPrint('Audio belum ditemukan: $e');
    }

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Layer2MissionScreen(),
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
              Color(0xFFE0C3FC), // Lavender Lembut (Kalem)
              Color(0xFFFFC3A0), // Peach (Energik)
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
                    Text(
                      "silahkan di pilih dan untuk paswordnya tolong chat admin uca_sindoro",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            shadows: AppTheme.softShadow,
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fade(duration: 500.ms).slideY(begin: -0.2),
                    
                    const SizedBox(height: 40),

                    // Opsi Dewi (Psikologi)
                    _buildCharacterCard(
                      context: context,
                      name: "Dewi",
                      subtitle: "Duta Melankolis",
                      icon: "💃🏻",
                      color: const Color(0xFFB9A0E0),
                      onTap: () => _showPasswordDialog(context, "Dewi", "boboiboy"),
                    ).animate().fade(delay: 300.ms).slideX(begin: -0.3),

                    const SizedBox(height: 20),

                    // Opsi Nabila (Kedokteran)
                    _buildCharacterCard(
                      context: context,
                      name: "Nabila",
                      subtitle: "Duta Cari Kesibukan",
                      icon: "💃🏻",
                      color: const Color(0xFF88D49E),
                      onTap: () => _showPasswordDialog(context, "Nabila", "all is well"),
                    ).animate().fade(delay: 500.ms).slideX(begin: 0.3),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterCard({
    required BuildContext context,
    required String name,
    required String subtitle,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                boxShadow: AppTheme.softShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Text(icon, style: const TextStyle(fontSize: 32)),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}