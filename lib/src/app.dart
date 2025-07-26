import 'package:demo/src/modules/auth/auth.dart';
import 'package:demo/src/shared/shared.dart';
import 'package:demo/src/shared/widgets/animated_loading.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      // Mientras se carga el estado de la autenticación, muestra un indicador de carga
      return Scaffold(
        backgroundColor: AppColors.neutralLightBackground,
        body: const Center(
          child: CompanyAnimatedLoading(
            size: 80,
            text: 'Cargando...',
          ),
        ),
      );
    }

    // Redirige a la HomePage si el usuario está autenticado, o a la AuthPage si no lo está
    return isLoggedIn! ? const ModernHomePage() : const AuthPage();
  }
}
