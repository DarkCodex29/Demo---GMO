import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Familia de fuente corporativa
  static String get fontFamily => GoogleFonts.dmSans().fontFamily!;

  // Pesos de fuente
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;

  // Estilos de encabezados
  static TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.2,
  );

  static TextStyle heading2 = TextStyle(
    fontSize: 28,
    fontWeight: bold,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.3,
  );

  static TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: bold,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.3,
  );

  static TextStyle heading4 = TextStyle(
    fontSize: 20,
    fontWeight: bold,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.4,
  );

  static TextStyle heading5 = TextStyle(
    fontSize: 18,
    fontWeight: bold,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.4,
  );

  static TextStyle heading6 = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: bold,
    color: AppColors.neutralTextGray,
    height: 1.5,
  );

  // Estilos de texto de cuerpo
  static TextStyle bodyLarge = GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: regular,
    color: AppColors.neutralTextGray,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: regular,
    color: AppColors.neutralTextGray,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: regular,
    color: AppColors.neutralTextGray,
    height: 1.4,
  );

  // Estilos de etiquetas y subtítulos
  static TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.4,
  );

  static TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.3,
  );

  static TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.3,
  );

  static TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.3,
  );

  static TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // Estilos específicos para botones
  static TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.white,
    height: 1.25,
    letterSpacing: 0.1,
  );

  static TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.white,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.white,
    height: 1.3,
    letterSpacing: 0.5,
  );

  // Estilos para títulos de AppBar
  static TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.white,
    height: 1.2,
  );

  // Estilos para elementos de navegación
  static TextStyle navigationLabel = TextStyle(
    fontSize: 16,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.25,
  );

  static TextStyle navigationSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: AppColors.neutralTextGray,
    height: 1.3,
  );

  // Estilos para notificaciones
  static TextStyle notificationTitle = TextStyle(
    fontSize: 14,
    fontWeight: medium,
    fontFamily: fontFamily,
    color: AppColors.primaryDarkTeal,
    height: 1.3,
  );

  static TextStyle notificationBody = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    fontFamily: fontFamily,
    color: AppColors.primaryDarkTeal,
    height: 1.4,
  );

  // Métodos helper para crear variaciones de color
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
