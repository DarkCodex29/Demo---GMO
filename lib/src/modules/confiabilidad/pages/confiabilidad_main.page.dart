import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/modules/confiabilidad/pages/equipment.page.dart';
import 'package:demo/src/modules/confiabilidad/pages/locations.page.dart';
import 'package:demo/src/modules/confiabilidad/pages/class.page.dart';
import 'package:demo/src/modules/confiabilidad/pages/characteristics.page.dart';
import 'package:demo/src/modules/confiabilidad/pages/materials.page.dart';
import 'package:demo/src/modules/confiabilidad/pages/job.page.dart';
import 'package:demo/src/modules/confiabilidad/pages/strategies.page.dart';
import 'package:demo/src/modules/confiabilidad/pages/cycle.page.dart';
import 'package:demo/src/modules/confiabilidad/pages/roadmap_main.page.dart';

class ConfiabilidadMainPage extends StatelessWidget {
  const ConfiabilidadMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return MainLayout(
      currentModule: 'confiabilidad',
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
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDarkTeal,
            AppColors.primaryMediumTeal,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                      'Confiabilidad',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestión de datos maestros y configuración del sistema',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Administra equipos, ubicaciones, materiales y estrategias de mantenimiento',
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
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.settings_outlined,
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
              
              // Title
              Text(
                section['title'] as String,
                style: AppTextStyles.heading6.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 16 : 18,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Description
              Text(
                section['description'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neutralTextGray.withOpacity(0.8),
                  fontSize: isMobile ? 13 : 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Count badge if available
              if (section['count'] != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neutralLightBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${section['count']} registros',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.neutralTextGray,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSections() {
    return [
      {
        'id': 'equipos',
        'title': 'Equipos',
        'description': 'Catálogo maestro de equipos industriales y sus especificaciones técnicas',
        'icon': Icons.precision_manufacturing,
        'color': AppColors.primaryDarkTeal,
        'count': 125,
        'page': const EquipmentPage(),
      },
      {
        'id': 'ubicaciones',
        'title': 'Ubicaciones Técnicas',
        'description': 'Jerarquía de ubicaciones y estructura organizacional de planta',
        'icon': Icons.location_on_outlined,
        'color': AppColors.primaryMintGreen,
        'count': 89,
        'page': const LocationsPage(),
      },
      {
        'id': 'clases',
        'title': 'Clases',
        'description': 'Clasificación y categorización de equipos por tipos y características',
        'icon': Icons.category_outlined,
        'color': AppColors.secondaryBrightBlue,
        'count': 24,
        'page': const ClasesPage(),
      },
      {
        'id': 'caracteristicas',
        'title': 'Características',
        'description': 'Atributos técnicos y parámetros operacionales de equipos',
        'icon': Icons.tune,
        'color': AppColors.secondaryGoldenYellow,
        'count': 156,
        'page': const CaracteristicsPage(),
      },
      {
        'id': 'materiales',
        'title': 'Materiales',
        'description': 'Inventario de repuestos, consumibles y materiales de mantenimiento',
        'icon': Icons.inventory_2_outlined,
        'color': AppColors.primaryMediumTeal,
        'count': 342,
        'page': const MaterialsPage(),
      },
      {
        'id': 'puestos_trabajo',
        'title': 'Puestos de Trabajo',
        'description': 'Centros de trabajo y responsabilidades del personal técnico',
        'icon': Icons.work_outline,
        'color': AppColors.secondaryAquaGreen,
        'count': 18,
        'page': const JobPage(),
      },
      {
        'id': 'estrategias',
        'title': 'Estrategias de Mantenimiento',
        'description': 'Planes y metodologías para el mantenimiento preventivo y correctivo',
        'icon': Icons.psychology_outlined,
        'color': AppColors.secondaryCoralRed,
        'count': 15,
        'page': const StrategiesPage(),
      },
      {
        'id': 'ciclos',
        'title': 'Ciclos de Mantenimiento',
        'description': 'Programación temporal y frecuencias de mantenimiento',
        'icon': Icons.refresh,
        'color': AppColors.primaryLightGreen,
        'count': 32,
        'page': const CyclePage(),
      },
      {
        'id': 'hojas_ruta',
        'title': 'Hojas de Ruta',
        'description': 'Procedimientos detallados y secuencias de trabajo operacional',
        'icon': Icons.route_outlined,
        'color': AppColors.neutralTextGray,
        'count': 28,
        'page': const RoadmapMainPage(),
      },
    ];
  }

  void _navigateToSection(BuildContext context, Map<String, dynamic> section) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => section['page'] as Widget,
      ),
    );
  }
}