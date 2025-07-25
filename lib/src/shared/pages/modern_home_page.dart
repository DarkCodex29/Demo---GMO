import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/core/core.dart';

class ModernHomePage extends StatefulWidget {
  const ModernHomePage({super.key});

  @override
  ModernHomePageState createState() => ModernHomePageState();
}

class ModernHomePageState extends State<ModernHomePage> {
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final stats = await DataService.instance.getDashboardStats();
      if (mounted) {
        setState(() {
          _dashboardStats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentModule: 'home',
      child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section
          _buildWelcomeSection(),
          SizedBox(height: isMobile ? 20 : 32),

          // KPI Cards section
          _buildKPISection(),
          SizedBox(height: isMobile ? 20 : 32),

          // Recent activity and quick actions
          if (!isMobile) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildRecentActivity()),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildQuickActions()),
              ],
            ),
          ] else ...[
            _buildRecentActivity(),
            const SizedBox(height: 20),
            _buildQuickActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

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
                      '¡Buen día, Gianpierre!',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dashboard de Gestión de Mantenimiento Operacional',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      DateTime.now().toString().split(' ')[0],
                      style: AppTextStyles.labelMedium.copyWith(
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
                    Icons.engineering,
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

  Widget _buildKPISection() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final stats = _dashboardStats ?? {};

    final kpis = [
      {
        'title': 'Órdenes Activas',
        'value': '${stats['activeOrders'] ?? 0}',
        'subtitle': '${stats['activeOrders'] != null && stats['activeOrders'] > 0 ? '+3 vs ayer' : 'Sin datos'}',
        'icon': Icons.assignment,
        'color': AppColors.primaryDarkTeal,
        'trend': 'up',
      },
      {
        'title': 'Avisos Pendientes',
        'value': '${stats['pendingNotifications'] ?? 0}',
        'subtitle': '${stats['pendingNotifications'] != null && stats['pendingNotifications'] > 0 ? 'Requieren atención' : 'Todo al día'}',
        'icon': Icons.notification_important,
        'color': AppColors.secondaryCoralRed,
        'trend': stats['pendingNotifications'] != null && stats['pendingNotifications'] > 5 ? 'up' : 'down',
      },
      {
        'title': 'Equipos Operativos',
        'value': '${stats['operationalEquipment'] ?? 0}',
        'subtitle': '${stats['availability'] ?? 0}% disponible',
        'icon': Icons.precision_manufacturing,
        'color': AppColors.success,
        'trend': 'stable',
      },
      {
        'title': 'Eficiencia',
        'value': '${stats['efficiency'] ?? 0}%',
        'subtitle': '+2.1% vs mes anterior',
        'icon': Icons.trending_up,
        'color': AppColors.secondaryBrightBlue,
        'trend': 'up',
      },
    ];

    if (isMobile) {
      // En móvil: 2 columnas, 2 filas
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  title: kpis[0]['title'] as String,
                  value: kpis[0]['value'] as String,
                  subtitle: kpis[0]['subtitle'] as String,
                  icon: kpis[0]['icon'] as IconData,
                  color: kpis[0]['color'] as Color,
                  trend: kpis[0]['trend'] as String,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKPICard(
                  title: kpis[1]['title'] as String,
                  value: kpis[1]['value'] as String,
                  subtitle: kpis[1]['subtitle'] as String,
                  icon: kpis[1]['icon'] as IconData,
                  color: kpis[1]['color'] as Color,
                  trend: kpis[1]['trend'] as String,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildKPICard(
                  title: kpis[2]['title'] as String,
                  value: kpis[2]['value'] as String,
                  subtitle: kpis[2]['subtitle'] as String,
                  icon: kpis[2]['icon'] as IconData,
                  color: kpis[2]['color'] as Color,
                  trend: kpis[2]['trend'] as String,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKPICard(
                  title: kpis[3]['title'] as String,
                  value: kpis[3]['value'] as String,
                  subtitle: kpis[3]['subtitle'] as String,
                  icon: kpis[3]['icon'] as IconData,
                  color: kpis[3]['color'] as Color,
                  trend: kpis[3]['trend'] as String,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      // En tablet/desktop: 4 columnas en fila
      return Row(
        children: kpis.asMap().entries.map((entry) {
          final kpi = entry.value;
          final isLast = entry.key == kpis.length - 1;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: isLast ? 0 : 16),
              child: _buildKPICard(
                title: kpi['title'] as String,
                value: kpi['value'] as String,
                subtitle: kpi['subtitle'] as String,
                icon: kpi['icon'] as IconData,
                color: kpi['color'] as Color,
                trend: kpi['trend'] as String,
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String trend,
  }) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header compacto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 8 : 10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isMobile ? 18 : 22,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: trend == 'up' 
                        ? AppColors.success.withOpacity(0.1)
                        : trend == 'down' 
                            ? AppColors.secondaryCoralRed.withOpacity(0.1)
                            : AppColors.neutralTextGray.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    trend == 'up' 
                        ? Icons.trending_up 
                        : trend == 'down' 
                            ? Icons.trending_down 
                            : Icons.trending_flat,
                    color: trend == 'up' 
                        ? AppColors.success 
                        : trend == 'down' 
                            ? AppColors.secondaryCoralRed 
                            : AppColors.neutralTextGray,
                    size: isMobile ? 14 : 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            
            // Valor principal
            Text(
              value,
              style: AppTextStyles.heading3.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: isMobile ? 20 : 24,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            
            // Título
            Text(
              title,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: isMobile ? 12 : 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 6 : 8),
            
            // Subtítulo optimizado
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 6 : 8, 
                vertical: isMobile ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.neutralLightBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutralTextGray.withOpacity(0.9),
                  fontSize: isMobile ? 9 : 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRecentActivity() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Actividad Reciente',
                  style: AppTextStyles.heading6.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Ver todo',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primaryDarkTeal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._getRecentActivities().map((activity) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildActivityItem(activity),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (activity['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            activity['icon'] as IconData,
            color: activity['color'] as Color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                activity['title'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                activity['subtitle'] as String,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutralTextGray.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        Text(
          activity['time'] as String,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.neutralTextGray.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Acciones Rápidas',
              style: AppTextStyles.heading6.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ..._getQuickActions().map((action) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildQuickActionItem(action),
              ),
            ).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(Map<String, dynamic> action) {
    return InkWell(
      onTap: () => _handleQuickAction(action['id'] as String),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.neutralMediumBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              action['icon'] as IconData,
              color: action['color'] as Color,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                action['title'] as String,
                style: AppTextStyles.bodyMedium,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.neutralTextGray.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getRecentActivities() {
    return [
      {
        'title': 'Orden ZIA1-2024 completada',
        'subtitle': 'Mantenimiento preventivo - Bomba 001',
        'time': '2h',
        'icon': Icons.check_circle,
        'color': AppColors.success,
      },
      {
        'title': 'Nuevo aviso creado',
        'subtitle': 'Falla eléctrica - Prioridad Alta',
        'time': '4h',
        'icon': Icons.warning,
        'color': AppColors.secondaryCoralRed,
      },
      {
        'title': 'Plan programado',
        'subtitle': 'Mantenimiento semanal equipos críticos',
        'time': '6h',
        'icon': Icons.schedule,
        'color': AppColors.secondaryBrightBlue,
      },
    ];
  }

  List<Map<String, dynamic>> _getQuickActions() {
    return [
      {
        'id': 'create_order',
        'title': 'Crear Orden',
        'icon': Icons.add_circle_outline,
        'color': AppColors.primaryDarkTeal,
      },
      {
        'id': 'new_notification',
        'title': 'Nuevo Aviso',
        'icon': Icons.notification_add,
        'color': AppColors.secondaryCoralRed,
      },
      {
        'id': 'view_calendar',
        'title': 'Ver Calendario',
        'icon': Icons.calendar_today,
        'color': AppColors.primaryMintGreen,
      },
      {
        'id': 'reports',
        'title': 'Reportes',
        'icon': Icons.assessment,
        'color': AppColors.secondaryBrightBlue,
      },
    ];
  }


  void _handleQuickAction(String actionId) {
    // TODO: Implement quick actions
    print('Quick action: $actionId');
  }
}