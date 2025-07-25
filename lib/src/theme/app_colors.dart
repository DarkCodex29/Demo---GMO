import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Paleta de Colores Corporativa
  // Colores Primarios
  static const Color primaryDarkTeal = Color(0xFF055658);
  static const Color primaryMediumTeal = Color(0xFF056769);
  static const Color primaryMintGreen = Color(0xFF5AA97F);
  static const Color primaryLightGreen = Color(0xFFAEEA94);

  // Colores Secundarios
  static const Color secondaryAquaGreen = Color(0xFF59D19A);
  static const Color secondaryCoralRed = Color(0xFFEA5050);
  static const Color secondaryBrightBlue = Color(0xFF2A77E8);
  static const Color secondaryGoldenYellow = Color(0xFFFFD96E);

  // Colores Neutros
  static const Color neutralTextGray = Color(0xFF4E6478);
  static const Color neutralLightBackground = Color(0xFFF3F4F6);
  static const Color neutralMediumBorder = Color(0xFFC1C7D0);

  // Colores adicionales para estados
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Variaciones de intensidad para gradientes y hover states
  static Color primaryDarkTealLight = primaryDarkTeal.withOpacity(0.1);
  static Color primaryMediumTealLight = primaryMediumTeal.withOpacity(0.1);
  static Color primaryMintGreenLight = primaryMintGreen.withOpacity(0.1);

  // Colores de estado basados en la paleta secundaria
  static const Color success = secondaryAquaGreen;
  static const Color error = secondaryCoralRed;
  static const Color info = secondaryBrightBlue;
  static const Color warning = secondaryGoldenYellow;

  // Material Color Swatch basado en el teal principal
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF055658,
    <int, Color>{
      50: Color(0xFFE0F2F2),
      100: Color(0xFFB3DFDF),
      200: Color(0xFF80CACA),
      300: Color(0xFF4DB5B5),
      400: Color(0xFF26A5A5),
      500: Color(0xFF055658),
      600: Color(0xFF044E50),
      700: Color(0xFF044347),
      800: Color(0xFF03393D),
      900: Color(0xFF022A2D),
    },
  );
}
