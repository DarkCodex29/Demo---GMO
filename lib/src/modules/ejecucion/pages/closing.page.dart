import 'package:flutter/material.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class ClosingPage extends StatelessWidget {
  const ClosingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentModule: 'ejecucion',
      customTitle: 'Cierre de órdenes',
      showBackButton: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.secondaryAquaGreen,
              ),
              const SizedBox(height: 16),
              Text(
                'Cierre de órdenes',
                style: AppTextStyles.heading4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Página en desarrollo para el cierre t�cnico de �rdenes de mantenimiento',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
