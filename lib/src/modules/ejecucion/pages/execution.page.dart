import 'package:flutter/material.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class ExecutionPage extends StatelessWidget {
  const ExecutionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentModule: 'ejecucion',
      customTitle: 'Ejecución de Trabajos',
      showBackButton: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.engineering,
                size: 64,
                color: AppColors.primaryDarkTeal,
              ),
              const SizedBox(height: 16),
              Text(
                'Ejecución de Trabajos',
                style: AppTextStyles.heading4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'P�gina en desarrollo para la gestión de ejecución de trabajos de mantenimiento',
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
