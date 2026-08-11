import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/audio/audio_manager.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'screens/layer1_gate_screen.dart';

void main() async {
  // Wajib dipanggil sebelum inisialisasi hal lain yang bersifat asinkron
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Audio Manager
  await AudioManager().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const BirthdayQuestApp(),
    ),
  );
}

class BirthdayQuestApp extends StatelessWidget {
  const BirthdayQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Birthday Web Quest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      // Builder constraint telah dihapus agar UI bisa menyesuaikan (Universal)
      // untuk Desktop, Laptop, Tablet, dan Mobile secara penuh.
      home: const Layer1GateScreen(),
    );
  }
}