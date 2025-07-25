import 'package:flutter/material.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';

class FaultLogPage extends StatelessWidget {
  const FaultLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainLayout(
      currentModule: 'seguimiento_control',
      customTitle: 'Log de Fallas',
      showBackButton: true,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.bug_report_outlined,
                size: 64,
                color: AppColors.secondaryCoralRed,
              ),
              SizedBox(height: 16),
              Text(
                'Log de Fallas',
                //style: AppTextStyles.heading4,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Página en desarrollo para el registro hist�rico de fallas y eventos críticos',
                //style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
