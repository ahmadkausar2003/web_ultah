import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class AppState extends ChangeNotifier {
  String _selectedFriendName = '';
  String get selectedFriendName => _selectedFriendName;

  List<Uint8List> _photoboothImages = [];
  List<Uint8List> get photoboothImages => _photoboothImages;

  int _selectedFrame = 0;
  int get selectedFrame => _selectedFrame;

  // Memori baru untuk menyimpan HASIL AKHIR (sudah di-edit/zoom/geser)
  Uint8List? _finalPhotoboothStrip;
  Uint8List? get finalPhotoboothStrip => _finalPhotoboothStrip;

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

  void setFinalPhotoboothStrip(Uint8List image) {
    _finalPhotoboothStrip = image;
    notifyListeners();
  }
}