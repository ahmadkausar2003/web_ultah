import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String _selectedFriendName = '';
  bool _isAudioMuted = false;

  // Getter
  String get selectedFriendName => _selectedFriendName;
  bool get isAudioMuted => _isAudioMuted;

  // Setter untuk nama teman (Dipanggil di Layer 1)
  void setFriendName(String name) {
    _selectedFriendName = name;
    notifyListeners();
  }

  // Toggle untuk mematikan/menyalakan semua suara
  void toggleAudio() {
    _isAudioMuted = !_isAudioMuted;
    notifyListeners();
  }
}