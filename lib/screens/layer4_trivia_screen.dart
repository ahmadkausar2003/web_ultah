import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/audio/audio_manager.dart';
import '../core/state/app_state.dart';
import '../core/theme/app_theme.dart';
import 'layer5_baking_screen.dart';

// Model Data Pertanyaan
class TriviaQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  TriviaQuestion(this.question, this.options, this.correctIndex);
}

class Layer4TriviaScreen extends StatefulWidget {
  const Layer4TriviaScreen({super.key});

  @override
  State<Layer4TriviaScreen> createState() => _Layer4TriviaScreenState();
}

class _Layer4TriviaScreenState extends State<Layer4TriviaScreen> {
  int _currentQuestionIndex = 0;
  int _selectedWrongIndex = -1;
  int _shakeTrigger = 0;
  bool _isCorrectAnswered = false;

  // SOAL PSIKOLOGI (Untuk Dewi)
  final List<TriviaQuestion> _dewiQuestions = [
    TriviaQuestion("Diagnosis paling tepat buat orang yang bales curhat panjang kita cuma pakai 'wkwk'?", ["Sindrom jari kaku", "Kekurangan empati kronis", "Bipolar ringan"], 1),
    TriviaQuestion("Terapi paling manjur buat menyembuhkan galau patah hati?", ["Checkout keranjang Shopee", "Meditasi di gunung", "Rebahan doang"], 0),
    TriviaQuestion("Kalau kamu telat ngampus, menurut Sigmund Freud itu salah siapa?", ["Dosennya kepagian", "Alam bawah sadar pengen rebahan", "Alarmnya kurang keras"], 1),
    TriviaQuestion("Alat tes psikologi apa yang paling ampuh buat ngetes kesabaran?", ["Tes Rorschach", "Tes IQ", "Disuruh nungguin temen dandan"], 2),
    TriviaQuestion("Cara elegan nolak diajak nongkrong pas lagi bokek?", ["Pura-pura kesurupan", "Gak ada duit woy!", "Lagi butuh me-time buat inner child-ku"], 2),
    TriviaQuestion("Kalau lagi banyak masalah selalu katakan kalimat", ["Ngatta Ngatta Deh", "Jancok", "All Izz Well"], 2),
  ];

  // SOAL KEDOKTERAN (Untuk Nabila)
  final List<TriviaQuestion> _nabilaQuestions = [
    TriviaQuestion("Resep dokter paling legendaris kalau ada pasien sakit ringan?", ["Amputasi", "Operasi plastik", "Paracetamol & Istirahat"], 2),
    TriviaQuestion("Apa yang lebih menegangkan buat mahasiswa kedokteran daripada masuk ruang operasi?", ["Ditanya kapan lulus / Ujian OSCE", "Disuntik vaksin", "Nonton film horor"], 0),
    TriviaQuestion("Organ tubuh apa yang kerjanya paling lembur pas lagi minggu ujian?", ["Jantung (deg-degan)", "Kantung Mata", "Hati (menahan tangis)"], 1),
    TriviaQuestion("Temen tiba-tiba sakit perut habis makan seblak level 10, tindakan pertamamu?", ["Tertawakan dulu baru kasih obat", "Langsung RJP", "Bawa ke UGD pake helikopter"], 0),
    TriviaQuestion("Suara apa yang bikin anak kedokteran langsung reflek tegang?", ["Suara alarm EKG monitor", "Suara notif pacar", "Suara tukang bakso"], 0),
    TriviaQuestion("Kalau lagi banyak masalah selalu katakan kalimat", ["Ngatta Ngatta Deh", "Jancok", "All Izz Well"], 2),
  ];

  Future<void> _checkAnswer(int index, int correctIndex, int totalQuestions) async {
    if (_isCorrectAnswered) {
      return;
    }

    if (index == correctIndex) {
      setState(() {
        _isCorrectAnswered = true;
        _selectedWrongIndex = -1;
      });

      try {
        await AudioManager().playSfx('correct.mp3');
      } catch (e) {
        debugPrint('Audio error: $e');
      }

      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) {
        return;
      }

      // Jika masih ada soal, lanjut ke soal berikutnya
      if (_currentQuestionIndex < totalQuestions - 1) {
        setState(() {
          _currentQuestionIndex++;
          _isCorrectAnswered = false; // Reset status untuk soal baru
        });
      } else {
        // Jika semua soal selesai, pindah ke layer 5
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Layer5BakingScreen()),
        );
      }
    } else {
      setState(() {
        _selectedWrongIndex = index;
        _shakeTrigger++;
      });

      try {
        await AudioManager().playSfx('wrong.mp3');
      } catch (e) {
        debugPrint('Audio error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final friendName = context.watch<AppState>().selectedFriendName;
    final isDewi = friendName.toLowerCase() == 'dewi';
    
    // Pilih daftar soal berdasarkan teman
    final List<TriviaQuestion> activeQuestions = isDewi ? _dewiQuestions : _nabilaQuestions;
    final currentQuestion = activeQuestions[_currentQuestionIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDewi 
              ? [const Color(0xFFD4FC79), const Color(0xFF96E6A1)] // Hijau kalem energik (Psikologi)
              : [const Color(0xFF89F7FE), const Color(0xFF66A6FF)], // Biru kalem energik (Kedokteran)
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Indikator Progress Soal
                    Text(
                      "Ujian Kesabaran: ${_currentQuestionIndex + 1} / ${activeQuestions.length}",
                      style: const TextStyle(
                        color: AppTheme.darkText,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Kotak Pertanyaan (Gunakan Key agar animasi me-reset tiap ganti soal)
                    ClipRRect(
                      key: ValueKey("question_$_currentQuestionIndex"),
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: Text(
                            currentQuestion.question,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppTheme.darkText,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 30),

                    // Opsi Jawaban
                    for (int i = 0; i < currentQuestion.options.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildOptionButton(
                          index: i,
                          text: currentQuestion.options[i],
                          correctIndex: currentQuestion.correctIndex,
                          totalQuestions: activeQuestions.length,
                        ),
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

  Widget _buildOptionButton({
    required int index,
    required String text,
    required int correctIndex,
    required int totalQuestions,
  }) {
    Color buttonColor = Colors.white;
    if (_isCorrectAnswered && index == correctIndex) {
      buttonColor = Colors.greenAccent;
    } else if (_selectedWrongIndex == index) {
      buttonColor = Colors.redAccent;
    }

    Widget button = ElevatedButton(
      onPressed: () => _checkAnswer(index, correctIndex, totalQuestions),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: AppTheme.darkText,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );

    // Kunci _currentQuestionIndex ditambahkan ke animasi agar me-reset saat soal berganti
    Widget animatedButton = button.animate(key: ValueKey("btn_${_currentQuestionIndex}_$index"))
                                  .fade(delay: (150 * index).ms).slideX(begin: 0.2);

    if (_selectedWrongIndex == index) {
      animatedButton = animatedButton.animate(key: ValueKey("shake_$_shakeTrigger")).shake(hz: 8, duration: 400.ms);
    }

    if (_isCorrectAnswered && index == correctIndex) {
      animatedButton = animatedButton.animate().scale(end: const Offset(1.05, 1.05), duration: 300.ms);
    }

    return animatedButton;
  }
}