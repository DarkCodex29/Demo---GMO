import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/shared/widgets/fade_out_card.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';
import 'stock_report.page.dart';
import 'orders_report.page.dart';
import 'capacity_report.page.dart';
import 'equipment_report.page.dart';
import 'fault.log.page.dart';

class ReportsMainPage extends StatefulWidget {
  const ReportsMainPage({super.key});
  
  @override
  ReportsMainPageState createState() => ReportsMainPageState();
}

class ReportsMainPageState extends State<ReportsMainPage> {
  bool _showInfoCard = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return MainLayout(
      currentModule: 'seguimiento_control',
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
                      'Seguimiento y Control',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reportes, análisis y control de operaciones de mantenimiento',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Accede a reportes detallados, indicadores de gestión y análisis de rendimiento',
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
                  child: const Icon(
                    Icons.analytics_outlined,
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

  Widget _buildSectionsGrid(
      BuildContext context, bool isMobile, bool isTablet) {
    final sections = _getSections();

    if (isMobile) {
      // En móvil: 1 columna
      return Column(
        children: sections
            .map(
              (section) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildSectionCard(context, section, isMobile),
              ),
            )
            .toList(),
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

  Widget _buildSectionCard(
      BuildContext context, Map<String, dynamic> section, bool isMobile) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        'id': 'reporte_stock',
        'title': 'Reporte de Stock',
        'description': 'Inventario y disponibilidad de materiales y repuestos',
        'icon': Icons.inventory_2_outlined,
        'color': AppColors.primaryDarkTeal,
        'count': 342,
        'page': const StockReportPage(),
      },
      {
        'id': 'reporte_ordenes',
        'title': 'Reporte de Órdenes',
        'description': 'Estado y seguimiento de órdenes de mantenimiento',
        'icon': Icons.assignment_outlined,
        'color': AppColors.primaryMediumTeal,
        'count': 156,
        'page': const OrdersReportPage(),
      },
      {
        'id': 'reporte_capacidades',
        'title': 'Reporte de Capacidades',
        'description': 'Análisis de capacidad por centro de trabajo y recursos',
        'icon': Icons.analytics_outlined,
        'color': AppColors.primaryDarkTeal,
        'count': 28,
        'page': const CapacityReportPage(),
      },
      {
        'id': 'reporte_equipos',
        'title': 'Reporte de Equipos',
        'description':
            'Estado, ubicación y rendimiento de equipos industriales',
        'icon': Icons.precision_manufacturing_outlined,
        'color': AppColors.primaryMediumTeal,
        'count': 125,
        'page': const EquipmentReportPage(),
      },
      {
        'id': 'log_fallas',
        'title': 'Log de Fallas',
        'description':
            'Registro histórico de fallas y eventos críticos del sistema',
        'icon': Icons.bug_report_outlined,
        'color': AppColors.primaryDarkTeal,
        'count': 89,
        'page': const FaultLogPage(),
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
