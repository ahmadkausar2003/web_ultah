import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  // Singleton Pattern
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() {
    return _instance;
  }

  AudioManager._internal();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _isMuted = false;

  /// Inisialisasi Audio Manager, set BGM agar looping
  Future<void> init() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Memutar Background Music (BGM)
  Future<void> playBgm(String assetPath) async {
    if (_isMuted) {
      return;
    }
    
    // PERBAIKAN: Menambahkan 'audio/' di depan nama file
    // Karena AssetSource secara otomatis sudah mencari di dalam folder 'assets/'
    await _bgmPlayer.play(AssetSource('audio/$assetPath'));
  }

  /// Mengganti BGM (Misal saat pindah ke Layer 7 / SurpriseScreen)
  Future<void> changeBgm(String assetPath) async {
    await _bgmPlayer.stop();
    
    if (_isMuted) {
      return;
    }
    
    // PERBAIKAN: Menambahkan 'audio/' di depan nama file
    await _bgmPlayer.play(AssetSource('audio/$assetPath'));
  }

  /// Menghentikan BGM secara paksa
  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  /// Memutar Sound Effects (SFX)
  Future<void> playSfx(String assetPath) async {
    if (_isMuted) {
      return;
    }
    
    final AudioPlayer sfxPlayer = AudioPlayer();
    
    // PERBAIKAN: Menambahkan 'audio/' di depan nama file
    await sfxPlayer.play(AssetSource('audio/$assetPath'));
    
    // Dispose player setelah SFX selesai diputar agar memory tidak bocor
    sfxPlayer.onPlayerComplete.listen((_) {
      sfxPlayer.dispose();
    });
  }

  /// Sinkronisasi status mute dari AppState
  void updateMuteStatus(bool isMuted) {
    _isMuted = isMuted;
    
    if (_isMuted) {
      _bgmPlayer.pause();
    } else {
      _bgmPlayer.resume();
    }
  }

  /// Membersihkan resource saat aplikasi ditutup
  void dispose() {
    _bgmPlayer.dispose();
  }
}