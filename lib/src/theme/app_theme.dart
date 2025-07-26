import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: AppColors.primarySwatch,
      primaryColor: AppColors.primaryDarkTeal,
      scaffoldBackgroundColor: AppColors.neutralLightBackground,

      // Color Scheme personalizado
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryDarkTeal,
        onPrimary: AppColors.white,
        secondary: AppColors.primaryMintGreen,
        onSecondary: AppColors.white,
        tertiary: AppColors.secondaryAquaGreen,
        onTertiary: AppColors.white,
        error: AppColors.secondaryCoralRed,
        onError: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.neutralTextGray,
        onSurfaceVariant: AppColors.neutralTextGray,
        outline: AppColors.neutralMediumBorder,
        surfaceContainerHighest: AppColors.neutralLightBackground,
      ),

      // Configuración de la fuente por defecto
      fontFamily: GoogleFonts.dmSans().fontFamily,

      // Tema de texto con DM Sans
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: AppTextStyles.heading1,
        displayMedium: AppTextStyles.heading2,
        displaySmall: AppTextStyles.heading3,
        headlineLarge: AppTextStyles.heading3,
        headlineMedium: AppTextStyles.heading4,
        headlineSmall: AppTextStyles.heading5,
        titleLarge: AppTextStyles.heading4,
        titleMedium: AppTextStyles.heading5,
        titleSmall: AppTextStyles.heading6,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryDarkTeal,
        foregroundColor: AppColors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        titleTextStyle: AppTextStyles.appBarTitle,
        iconTheme: const IconThemeData(color: AppColors.white),
        actionsIconTheme: const IconThemeData(color: AppColors.white),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black12,
        surfaceTintColor: AppColors.white,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkTeal,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          shadowColor: Colors.black26,
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryDarkTeal,
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDarkTeal,
          textStyle: AppTextStyles.buttonMedium,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: AppColors.primaryDarkTeal, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryMintGreen,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutralMediumBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutralMediumBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.primaryDarkTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.secondaryCoralRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.secondaryCoralRed, width: 2),
        ),
        labelStyle: AppTextStyles.labelMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutralTextGray.withOpacity(0.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.primaryDarkTeal.withOpacity(0.1),
        height: 65,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDarkTeal,
            );
          }
          return AppTextStyles.labelSmall.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: AppColors.neutralTextGray,
          );
        }),
      ),

      // ExpansionTile Theme
      expansionTileTheme: const ExpansionTileThemeData(
        backgroundColor: AppColors.transparent,
        collapsedBackgroundColor: AppColors.transparent,
        iconColor: AppColors.primaryDarkTeal,
        textColor: AppColors.neutralTextGray,
        collapsedTextColor: AppColors.neutralTextGray,
        collapsedIconColor: AppColors.primaryDarkTeal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      // ListTile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: AppTextStyles.navigationLabel,
        subtitleTextStyle: AppTextStyles.navigationSubtitle,
        iconColor: AppColors.primaryDarkTeal,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryDarkTeal,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        //margin: const EdgeInsets.all(16),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.neutralMediumBorder,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.primaryDarkTeal,
        size: 24,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryDarkTeal,
        linearTrackColor: AppColors.neutralMediumBorder,
        circularTrackColor: AppColors.neutralMediumBorder,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDarkTeal;
          }
          return AppColors.neutralMediumBorder;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryMintGreen;
          }
          return AppColors.neutralLightBackground;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDarkTeal;
          }
          return AppColors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.white),
        side: const BorderSide(color: AppColors.neutralMediumBorder, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryDarkTeal;
          }
          return AppColors.neutralMediumBorder;
        }),
      ),
    );
  }
}
