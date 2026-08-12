import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  String _selectedFriendName = '';
  String get selectedFriendName => _selectedFriendName;

  // Memori untuk menyimpan hasil jepretan Photobooth
  List<Uint8List> _photoboothImages = [];
  List<Uint8List> get photoboothImages => _photoboothImages;

  // Memori untuk menyimpan tema frame yang dipilih
  int _selectedFrame = 0;
  int get selectedFrame => _selectedFrame;

  void setFriendName(String name) {
    _selectedFriendName = name;
    notifyListeners();
  }

  void setPhotoboothImages(List<Uint8List> images) {
    _photoboothImages = images;
    notifyListeners();
  }

  void setSelectedFrame(int index) {
    _selectedFrame = index;
    notifyListeners();
  }
}