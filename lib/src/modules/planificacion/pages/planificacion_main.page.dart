import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/shared/widgets/fade_out_card.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';
import 'package:demo/src/modules/planificacion/pages/capacity_management.page.dart';
import 'package:demo/src/modules/planificacion/pages/create_order.page.dart';

class PlanificacionMainPage extends StatefulWidget {
  const PlanificacionMainPage({super.key});
  
  @override
  PlanificacionMainPageState createState() => PlanificacionMainPageState();
}

class PlanificacionMainPageState extends State<PlanificacionMainPage> {
  bool _showInfoCard = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return MainLayout(
      currentModule: 'planificacion',
      showBackButton: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section con efecto de desvanecimiento
            InfoCard(
              fadeDelay: const Duration(seconds: 2),
              fadeDuration: const Duration(milliseconds: 1500),
              onFadeComplete: () {
                setState(() {
                  _showInfoCard = false;
                });
              },
              child: _buildHeader(isMobile),
            ),
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
                      'Planificación',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestión de órdenes de trabajo y planificación de recursos',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Crea y gestiona órdenes de mantenimiento y administra la capacidad de recursos',
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
                    Icons.calendar_today_outlined,
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
        'id': 'gestion_capacidad',
        'title': 'Gestión de Capacidad',
        'description': 'Planificación y administración de recursos y capacidades de trabajo',
        'icon': Icons.assessment_outlined,
        'color': AppColors.primaryDarkTeal,
        'count': 28,
        'page': const CapacityManagementPage(),
      },
      {
        'id': 'crear_orden',
        'title': 'Crear Orden de Trabajo',
        'description': 'Creación y configuración de nuevas órdenes de mantenimiento',
        'icon': Icons.add_circle_outline,
        'color': AppColors.primaryMediumTeal,
        'count': 156,
        'page': const CreateOrderPage(),
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