import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palet Warna Pastel Sesuai PRD
  static const Color primaryPink = Color(0xFFFFB6C1); // Pastel Pink
  static const Color babyBlue = Color(0xFFAEC6CF);    // Baby Blue
  static const Color mintGreen = Color(0xFF98FF98);   // Mint
  static const Color creamWhite = Color(0xFFFFFDD0);  // Background
  static const Color darkText = Color(0xFF2C3E50);    // Teks elegan

  // Styling Shadows Premium (Soft)
  static final List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 15,
      spreadRadius: 2,
      offset: const Offset(0, 5),
    ),
  ];

  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: creamWhite,
      primaryColor: primaryPink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        secondary: babyBlue,
        tertiary: mintGreen,
      ),
      
      // Menggunakan Fredoka One untuk Header/Judul (Bubbly look)
      // Menggunakan Nunito untuk Body Text (Keterbacaan)
      textTheme: TextTheme(
        displayLarge: GoogleFonts.fredoka(
          color: darkText,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.fredoka(
          color: darkText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: GoogleFonts.nunito(
          color: darkText,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.nunito(
          color: darkText,
          fontSize: 14,
        ),
      ),
      
      // PERBAIKAN: Menggunakan CardThemeData untuk Flutter versi terbaru
      cardTheme: CardThemeData(
        elevation: 0, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.white,
      ),
      
      // Styling ElevatedButton Premium (Bubbly)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.fredoka(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}