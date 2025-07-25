import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';
import 'package:demo/src/modules/demanda/pages/demand_management.page.dart';
import 'package:demo/src/modules/demanda/pages/notification.page.dart';
import 'package:demo/src/modules/demanda/pages/warning.page.dart';

class DemandaMainPage extends StatelessWidget {
  const DemandaMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return MainLayout(
      currentModule: 'demanda',
      customTitle: 'Demanda',
      showBackButton: true,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondaryCoralRed.withOpacity(0.8),
                    AppColors.secondaryGoldenYellow.withOpacity(0.6),
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
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notification_important_outlined,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Demanda',
                              style: AppTextStyles.heading4.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Gestión de avisos y notificaciones',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Módulos de Demanda',
              style: AppTextStyles.heading5.copyWith(
                color: AppColors.neutralTextGray,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ResponsiveRowColumn(
                layout: isMobile
                    ? ResponsiveRowColumnType.COLUMN
                    : ResponsiveRowColumnType.ROW,
                rowSpacing: 16,
                rowCrossAxisAlignment: CrossAxisAlignment.start,
                children: _buildSectionCards(context, isMobile, isTablet),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ResponsiveRowColumnItem> _buildSectionCards(
      BuildContext context, bool isMobile, bool isTablet) {
    final sections = [
      {
        'title': 'Gestión de Demanda',
        'subtitle': 'Procesamiento de avisos y demandas',
        'icon': Icons.assignment_outlined,
        'color': AppColors.secondaryBrightBlue,
        'page': const DemandManagementPage(),
      },
      {
        'title': 'Notificaciones',
        'subtitle': 'Sistema de notificaciones y alertas',
        'icon': Icons.notifications_outlined,
        'color': AppColors.secondaryGoldenYellow,
        'page': const NotificationPage(),
      },
      {
        'title': 'Avisos',
        'subtitle': 'Gestión de avisos de mantenimiento',
        'icon': Icons.warning_outlined,
        'color': AppColors.secondaryCoralRed,
        'page': const AvisoPage(),
      },
    ];

    return sections.map((section) {
      return ResponsiveRowColumnItem(
        rowFlex: isMobile ? 1 : (isTablet ? 1 : 1),
        child: Container(
          margin: EdgeInsets.only(bottom: isMobile ? 16 : 0),
          child: _buildSectionCard(context, section, isMobile),
        ),
      );
    }).toList();
  }

  Widget _buildSectionCard(
      BuildContext context, Map<String, dynamic> section, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => section['page'],
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: isMobile ? 120 : 140,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.white,
                (section['color'] as Color).withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (section['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      section['icon'],
                      color: section['color'],
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.neutralTextGray.withOpacity(0.5),
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                section['title'],
                style: AppTextStyles.heading6.copyWith(
                  color: AppColors.neutralTextGray,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                section['subtitle'],
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutralTextGray.withOpacity(0.7),
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
}