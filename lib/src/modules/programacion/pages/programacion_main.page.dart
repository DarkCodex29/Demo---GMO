import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/modules/programacion/pages/calendar.page.dart';
import 'package:demo/src/modules/programacion/pages/scheduling.page.dart';
import 'package:demo/src/modules/programacion/pages/resources.page.dart';
import 'package:demo/src/modules/programacion/pages/workload.page.dart';

class ProgramacionMainPage extends StatelessWidget {
  const ProgramacionMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return MainLayout(
      currentModule: 'programacion',
      showBackButton: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeader(isMobile),
            SizedBox(height: isMobile ? 20 : 32),

            // Sections grid
            _buildSectionsGrid(context, isMobile, isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Programación',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestión de calendario y programación de recursos',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Planifica, programa y optimiza el uso de recursos y calendario de mantenimiento',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.schedule_outlined,
                    size: 48,
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionsGrid(BuildContext context, bool isMobile, bool isTablet) {
    final sections = _getSections();
    
    if (isMobile) {
      // En móvil: 1 columna
      return Column(
        children: sections.map((section) => 
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: _buildSectionCard(context, section, isMobile),
          ),
        ).toList(),
      );
    } else if (isTablet) {
      // En tablet: 2 columnas
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
        ),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          return _buildSectionCard(context, sections[index], isMobile);
        },
      );
    } else {
      // En desktop: 3 columnas
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.1,
        ),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          return _buildSectionCard(context, sections[index], isMobile);
        },
      );
    }
  }

  List<Map<String, dynamic>> _getSections() {
    return [
      {
        'title': 'Calendario de Mantenimiento',
        'subtitle': 'Vista calendario y planificación temporal',
        'icon': Icons.calendar_month,
        'color': AppColors.primaryDarkTeal,
        'page': const CalendarPage(),
      },
      {
        'title': 'Programación de Recursos',
        'subtitle': 'Asignación y gestión de recursos',
        'icon': Icons.schedule_send,
        'color': AppColors.primaryMediumTeal,
        'page': const SchedulingPage(),
      },
      {
        'title': 'Recursos Disponibles',
        'subtitle': 'Gestión de personal y equipamiento',
        'icon': Icons.group_work,
        'color': AppColors.primaryDarkTeal,
        'page': const ResourcesPage(),
      },
      {
        'title': 'Carga de Trabajo',
        'subtitle': 'Análisis de capacidad y distribución',
        'icon': Icons.analytics,
        'color': AppColors.primaryMediumTeal,
        'page': const WorkloadPage(),
      },
    ];
  }

  Widget _buildSectionCard(BuildContext context, Map<String, dynamic> section, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _navigateToSection(context, section),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon and title row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isMobile ? 12 : 14),
                    decoration: BoxDecoration(
                      color: (section['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      section['icon'] as IconData,
                      color: section['color'] as Color,
                      size: isMobile ? 24 : 28,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.5),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 20),
              
              // Title and subtitle
              Text(
                section['title'] as String,
                style: AppTextStyles.heading6.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 4 : 6),
              Text(
                section['subtitle'] as String,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutralTextGray.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToSection(BuildContext context, Map<String, dynamic> section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => section['page'] as Widget,
      ),
    );
  }
}