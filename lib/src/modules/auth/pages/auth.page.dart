import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/shared.dart';
import 'package:demo/src/shared/widgets/animated_loading.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  Map<String, String> users = {};

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadRememberedUser();
  }

  Future<void> _loadRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberedUsername = prefs.getString('rememberedUsername');
    if (rememberedUsername != null) {
      _usernameController.text = rememberedUsername;
      setState(() {
        _rememberMe = true;
      });
    }
  }

  Future<void> _loadUsers() async {
    final String response =
        await rootBundle.loadString('assets/data/users.json');
    final data = await json.decode(response);
    debugPrint('Datos cargados: $data');
    setState(() {
      for (var user in data['users']) {
        users[user['usuario']] = user['contrasena'];
      }
    });
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simular tiempo de carga para mostrar la animación
    await Future.delayed(const Duration(seconds: 2));

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (users.containsKey(username) && users[username] == password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', username);

      if (_rememberMe) {
        await prefs.setString('rememberedUsername', username);
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ModernHomePage()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.white),
              SizedBox(width: 8),
              Text('Usuario o contraseña incorrectos'),
            ],
          ),
          backgroundColor: AppColors.secondaryCoralRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      backgroundColor: AppColors.neutralLightBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? double.infinity : (isTablet ? 400 : 450),
            ),
            margin: EdgeInsets.all(isMobile ? 16 : 24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 24 : 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo y título
                      _buildHeader(isMobile),
                      SizedBox(height: isMobile ? 24 : 32),

                      // Campos de entrada
                      _buildUsernameField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 8),

                      // Recordar usuario y olvidar contraseña
                      _buildOptionsRow(),
                      SizedBox(height: isMobile ? 24 : 32),

                      // Botón de login o loading
                      _buildLoginButton(),

                      // Credenciales de demo
                      const SizedBox(height: 24),
                      _buildDemoCredentials(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo_demo.png',
          width: isMobile ? 160 : 200,
          height: isMobile ? 160 : 200,
        ),
        Text(
          'Iniciar Sesión',
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.neutralTextGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      enabled: !_isLoading,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: 'Usuario',
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutralTextGray,
        ),
        prefixIcon: const Icon(
          Icons.person_outline,
          color: AppColors.primaryDarkTeal,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutralMediumBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutralMediumBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryDarkTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondaryCoralRed),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Por favor ingresa tu usuario';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      enabled: !_isLoading,
      obscureText: !_isPasswordVisible,
      style: AppTextStyles.bodyMedium,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.neutralTextGray,
        ),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.primaryDarkTeal,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.neutralTextGray,
          ),
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutralMediumBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.neutralMediumBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryDarkTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondaryCoralRed),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa tu contraseña';
        }
        return null;
      },
    );
  }

  Widget _buildOptionsRow() {
    return Column(
      children: [
        // Olvidar contraseña
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Función no disponible en el demo'),
                        backgroundColor: AppColors.primaryMediumTeal,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryDarkTeal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),

        // Recordar usuario
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: _isLoading
                  ? null
                  : (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
              activeColor: AppColors.primaryDarkTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text(
              'Recordar usuario',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.neutralTextGray,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDarkTeal,
          foregroundColor: AppColors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: AppColors.neutralTextGray.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Iniciar Sesión',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDemoCredentials() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkTeal.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryDarkTeal.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.primaryDarkTeal,
              ),
              const SizedBox(width: 6),
              Text(
                'Credenciales de Demostración',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primaryDarkTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Admin: admin / admin123\nUsuario: user1 / password1',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutralTextGray,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
