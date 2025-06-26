import 'package:demo/src/pages/auth/auth.page.dart';
import 'package:flutter/material.dart';
import 'package:demo/src/pages/maintenance/order.page.dart';
import 'package:demo/src/pages/maintenance/warning.page.dart';
import 'package:demo/src/pages/maintenance/create_order.page.dart';
import 'package:demo/src/pages/maintenance/demand_management.page.dart';
import 'package:demo/src/pages/team/class.page.dart';
import 'package:demo/src/pages/team/locations.page.dart';
import 'package:demo/src/pages/team/job.page.dart';
import 'package:demo/src/pages/team/equipment.page.dart';
import 'package:demo/src/pages/team/materials.page.dart';
import 'package:demo/src/pages/planning/maintenance/cycle.page.dart';
import 'package:demo/src/pages/planning/strategies.page.dart';
import 'package:demo/src/pages/planning/capacity_management.page.dart';
import 'package:demo/src/pages/planning/roadmap_main.page.dart';
import 'package:demo/src/pages/reports/reports_main.page.dart';
import 'package:demo/src/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _startNotificationSimulation();
  }

  void _startNotificationSimulation() {
    if (_notificationsEnabled) {
      Future.delayed(const Duration(seconds: 10), () {
        NotificationService.showOrderNotification(
          orderNumber: "ZIA1-${DateTime.now().millisecondsSinceEpoch % 1000}",
          description: "Nueva orden de mantenimiento asignada",
          priority: "ALTA",
        );
      });

      Future.delayed(const Duration(seconds: 30), () {
        NotificationService.showCapacityAlert(
          workCenter: "PM_MECANICO",
          message: "Capacidad al 85% - Requiere programación",
        );
      });

      Future.delayed(const Duration(minutes: 1), () {
        NotificationService.showFailureAlert(
          equipmentCode: "2000914",
          failureDescription: "Bomba con ruido anormal detectado",
          urgency: "ALTA",
        );
      });
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.orange),
              SizedBox(width: 8),
              Text('Cerrar sesión'),
            ],
          ),
          content: const Text(
            '¿Estás seguro de que deseas cerrar la sesión?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar', 
                style: TextStyle(color: Colors.grey, fontSize: 16)
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cerrar sesión', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar ResponsiveBreakpoints para obtener información del dispositivo
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Sistema GMO - Demo',
          style: TextStyle(
            fontSize: ResponsiveValue<double>(
              context,
              conditionalValues: [
                const Condition.smallerThan(name: TABLET, value: 18.0),
                const Condition.largerThan(name: MOBILE, value: 20.0),
              ],
            ).value,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 2,
        centerTitle: false,
        actions: [
          // Botones responsivos
          if (isDesktop || isTablet) ..._buildFullActions(),
          if (isMobile) ..._buildCompactActions(),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          ResponsiveValue<double>(
            context,
            conditionalValues: [
              const Condition.smallerThan(name: TABLET, value: 8.0),
              const Condition.largerThan(name: MOBILE, value: 16.0),
            ],
          ).value,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Banner de notificaciones mejorado y responsivo
            if (_notificationsEnabled) _buildNotificationBanner(),

            SizedBox(height: ResponsiveValue<double>(
              context,
              conditionalValues: [
                const Condition.smallerThan(name: TABLET, value: 8.0),
                const Condition.largerThan(name: MOBILE, value: 16.0),
              ],
            ).value),

            // Secciones principales con diseño responsive
            if (isDesktop) 
              _buildDesktopLayout()
            else if (isTablet)
              _buildTabletLayout()
            else
              _buildMobileLayout(),

            SizedBox(height: ResponsiveValue<double>(
                      context,
              conditionalValues: [
                const Condition.smallerThan(name: TABLET, value: 12.0),
                const Condition.largerThan(name: MOBILE, value: 24.0),
              ],
            ).value),

            // Acciones rápidas eliminadas según solicitud del usuario
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBanner() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        bottom: ResponsiveValue<double>(
                      context,
          conditionalValues: [
            const Condition.smallerThan(name: TABLET, value: 8.0),
            const Condition.largerThan(name: MOBILE, value: 16.0),
          ],
        ).value,
      ),
      padding: EdgeInsets.all(
        ResponsiveValue<double>(
                      context,
          conditionalValues: [
            const Condition.smallerThan(name: TABLET, value: 8.0),
            const Condition.largerThan(name: MOBILE, value: 16.0),
          ],
        ).value,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.ROW,
        children: [
          const ResponsiveRowColumnItem(
            child: Icon(Icons.notifications_active, color: Colors.orange, size: 24),
          ),
          ResponsiveRowColumnItem(
            child: SizedBox(width: ResponsiveValue<double>(
                      context,
              conditionalValues: [
                const Condition.smallerThan(name: TABLET, value: 6.0),
                const Condition.largerThan(name: MOBILE, value: 12.0),
              ],
            ).value),
          ),
          ResponsiveRowColumnItem(
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notificaciones Activas',
                    style: TextStyle(
                      fontSize: ResponsiveValue<double>(
                      context,
                        conditionalValues: [
                          const Condition.smallerThan(name: TABLET, value: 12.0),
                          const Condition.largerThan(name: MOBILE, value: 14.0),
                        ],
                      ).value,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recibirás alertas de mantenimiento en tiempo real',
                    style: TextStyle(
                      fontSize: ResponsiveValue<double>(
                          context,
                        conditionalValues: [
                          const Condition.smallerThan(name: TABLET, value: 10.0),
                          const Condition.largerThan(name: MOBILE, value: 12.0),
                        ],
                      ).value,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Layout para Desktop
  Widget _buildDesktopLayout() {
    return ResponsiveRowColumn(
      layout: ResponsiveRowColumnType.ROW,
      rowCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveRowColumnItem(
          rowFlex: 1,
          child: Column(
            children: [
              _buildExpansionSection(
                icon: Icons.engineering,
                title: 'Datos Maestros para Equipo',
                children: _buildEquipmentMenuItems(),
              ),
              const SizedBox(height: 12),
              _buildExpansionSection(
                icon: Icons.timeline,
                title: 'Datos Maestros para Planificación',
                children: _buildPlanningMenuItems(),
                    ),
                  ],
                ),
        ),
        const ResponsiveRowColumnItem(
          child: SizedBox(width: 16),
        ),
        ResponsiveRowColumnItem(
          rowFlex: 1,
          child: Column(
            children: [
              _buildExpansionSection(
                icon: Icons.warning,
                title: 'Mantenimiento Correctivo',
                children: _buildMaintenanceMenuItems(),
              ),
              const SizedBox(height: 12),
              _buildExpansionSection(
                icon: Icons.assessment,
                title: 'Reportes y Análisis',
                children: _buildReportsMenuItems(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Layout para Tablet
  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildExpansionSection(
          icon: Icons.engineering,
          title: 'Datos Maestros para Equipo',
          children: _buildEquipmentMenuItems(),
        ),
        const SizedBox(height: 12),
        ResponsiveRowColumn(
          layout: ResponsiveRowColumnType.ROW,
          rowCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveRowColumnItem(
              rowFlex: 1,
              child: _buildExpansionSection(
                icon: Icons.timeline,
                title: 'Datos Maestros para Planificación',
                children: _buildPlanningMenuItems(),
              ),
            ),
            const ResponsiveRowColumnItem(
              child: SizedBox(width: 12),
            ),
            ResponsiveRowColumnItem(
              rowFlex: 1,
              child: _buildExpansionSection(
                icon: Icons.warning,
                title: 'Mantenimiento Correctivo',
                children: _buildMaintenanceMenuItems(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildExpansionSection(
          icon: Icons.assessment,
          title: 'Reportes y Análisis',
          children: _buildReportsMenuItems(),
        ),
      ],
    );
  }

  // Layout para Mobile
  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildExpansionSection(
          icon: Icons.engineering,
          title: 'Datos Maestros para Equipo',
          children: _buildEquipmentMenuItems(),
        ),
        const SizedBox(height: 12),
        _buildExpansionSection(
          icon: Icons.timeline,
          title: 'Datos Maestros para Planificación',
          children: _buildPlanningMenuItems(),
        ),
        const SizedBox(height: 12),
        _buildExpansionSection(
          icon: Icons.warning,
          title: 'Mantenimiento Correctivo',
          children: _buildMaintenanceMenuItems(),
        ),
        const SizedBox(height: 12),
        _buildExpansionSection(
          icon: Icons.assessment,
          title: 'Reportes y Análisis',
          children: _buildReportsMenuItems(),
        ),
      ],
    );
  }

  List<Widget> _buildEquipmentMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.category,
        title: 'Clases',
        subtitle: 'Clasificación de equipos y componentes',
        onTap: () => _navigateTo(context, const ClasesPage()),
      ),
      _buildMenuItem(
        icon: Icons.location_on,
        title: 'Ubicaciones Técnicas',
        subtitle: 'Estructura jerárquica de ubicaciones',
        onTap: () => _navigateTo(context, const LocationsPage()),
      ),
      _buildMenuItem(
        icon: Icons.work,
        title: 'Puesto de Trabajo',
        subtitle: 'Centros de trabajo y responsabilidades',
        onTap: () => _navigateTo(context, const JobPage()),
      ),
      _buildMenuItem(
        icon: Icons.build,
        title: 'Equipos',
        subtitle: 'Registro maestro de equipos',
        onTap: () => _navigateTo(context, const EquipmentPage()),
      ),
      _buildMenuItem(
        icon: Icons.inventory,
        title: 'Lista de Materiales',
        subtitle: 'Catálogo de materiales y repuestos',
        onTap: () => _navigateTo(context, const MaterialsPage()),
      ),
    ];
  }

  List<Widget> _buildPlanningMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.stacked_line_chart,
        title: 'Estrategias',
        subtitle: 'Estrategias de mantenimiento preventivo',
        onTap: () => _navigateTo(context, const StrategiesPage()),
      ),
      _buildMenuItem(
        icon: Icons.assessment,
        title: 'Gestión de Capacidades',
        subtitle: 'Planificación y programación de recursos',
        onTap: () => _navigateTo(context, const CapacityManagementPage()),
      ),
      _buildMenuItem(
        icon: Icons.route,
        title: 'Hoja de Ruta',
        subtitle: 'Gestión de hojas de ruta y equipos de trabajo',
        onTap: () => _navigateTo(context, const RoadmapMainPage()),
      ),
      _buildSubExpansionTile(
        icon: Icons.calendar_today,
        title: 'Plan de Mantenimiento',
        children: [
          _buildMenuItem(
            icon: Icons.repeat,
            title: 'Ciclo Individual',
            subtitle: 'Programación de ciclos de mantenimiento',
            onTap: () => _navigateTo(context, const CyclePage()),
            isSubItem: true,
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMaintenanceMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.notification_important,
        title: 'Aviso',
        subtitle: 'Registro y seguimiento de avisos',
        onTap: () => _navigateTo(context, const AvisoPage()),
      ),
      _buildMenuItem(
        icon: Icons.build_circle,
        title: 'Orden',
        subtitle: 'Gestión de órdenes de trabajo',
        onTap: () => _navigateTo(context, const OrdenPage()),
      ),
      _buildMenuItem(
        icon: Icons.add_circle,
        title: 'Crear Orden',
        subtitle: 'Crear nueva orden de mantenimiento',
        onTap: () => _navigateTo(context, const CreateOrderPage()),
      ),
      _buildMenuItem(
        icon: Icons.report_problem,
        title: 'Gestión de Demandas',
        subtitle: 'Procesar avisos y demandas de mantenimiento',
        onTap: () => _navigateTo(context, const DemandManagementPage()),
      ),
    ];
  }

  List<Widget> _buildReportsMenuItems() {
    return [
      _buildMenuItem(
        icon: Icons.analytics,
        title: 'Centro de Reportes',
        subtitle: 'Acceso a todos los reportes del sistema',
        onTap: () => _navigateTo(context, const ReportsMainPage()),
      ),
    ];
  }

  List<Widget> _buildFullActions() {
    return [
      Tooltip(
        message: _notificationsEnabled ? 'Desactivar notificaciones' : 'Activar notificaciones',
        child: IconButton(
          icon: Icon(
            _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
            color: Colors.white,
          ),
          onPressed: _toggleNotifications,
        ),
      ),
      Tooltip(
        message: 'Enviar notificación de prueba',
        child: IconButton(
          icon: const Icon(Icons.notification_add, color: Colors.white),
          onPressed: _sendTestNotification,
        ),
      ),
      Tooltip(
        message: 'Cerrar sesión',
        child: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => _confirmLogout(context),
        ),
      ),
      const SizedBox(width: 8),
    ];
  }

  List<Widget> _buildCompactActions() {
    return [
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white),
        offset: const Offset(0, 45),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
        onSelected: (value) {
          switch (value) {
            case 'notifications':
              _toggleNotifications();
              break;
            case 'test':
              _sendTestNotification();
              break;
            case 'logout':
              _confirmLogout(context);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'notifications',
            child: _buildPopupMenuItem(
              icon: _notificationsEnabled ? Icons.notifications_off : Icons.notifications_active,
              text: _notificationsEnabled ? 'Desactivar' : 'Activar',
              iconColor: _notificationsEnabled ? Colors.grey[600]! : Colors.orange,
            ),
          ),
          PopupMenuItem(
            value: 'test',
            child: _buildPopupMenuItem(
              icon: Icons.notification_add,
              text: 'Probar',
              iconColor: Colors.blue,
            ),
          ),
          PopupMenuItem(
            value: 'logout',
            child: _buildPopupMenuItem(
              icon: Icons.logout,
              text: 'Cerrar sesión',
              iconColor: Colors.red,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildPopupMenuItem({
    required IconData icon,
    required String text,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications() {
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _notificationsEnabled ? Icons.check_circle : Icons.cancel,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              _notificationsEnabled 
                ? 'Notificaciones activadas' 
                : 'Notificaciones desactivadas',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        backgroundColor: _notificationsEnabled ? Colors.green : Colors.grey[600],
      ),
    );
  }

  void _sendTestNotification() {
    NotificationService.showOrderNotification(
      orderNumber: "TEST-${DateTime.now().millisecondsSinceEpoch % 1000}",
      description: "Notificación de prueba",
      priority: "NORMAL",
    );
  }

  Widget _buildExpansionSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: Colors.orange,
            textColor: Colors.orange,
            collapsedTextColor: Colors.black87,
            collapsedIconColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        child: ExpansionTile(
          leading: Icon(icon, color: Colors.orange, size: 24),
          title: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveValue<double>(
                      context,
                conditionalValues: [
                  const Condition.smallerThan(name: TABLET, value: 13.0),
                  const Condition.largerThan(name: MOBILE, value: 16.0),
                ],
              ).value,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          tilePadding: EdgeInsets.symmetric(
            horizontal: ResponsiveValue<double>(
                      context,
              conditionalValues: [
                const Condition.smallerThan(name: TABLET, value: 8.0),
                const Condition.largerThan(name: MOBILE, value: 16.0),
              ],
            ).value,
            vertical: 4,
          ),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          children: children,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSubItem = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isSubItem ? 
          ResponsiveValue<double>(
            context,
            conditionalValues: [
              const Condition.smallerThan(name: TABLET, value: 16.0),
              const Condition.largerThan(name: MOBILE, value: 24.0),
            ],
          ).value : 
          ResponsiveValue<double>(
            context,
            conditionalValues: [
              const Condition.smallerThan(name: TABLET, value: 4.0),
              const Condition.largerThan(name: MOBILE, value: 8.0),
            ],
          ).value,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon, 
            color: Colors.orange, 
            size: isSubItem ? 20 : 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveValue<double>(
                      context,
              conditionalValues: [
                Condition.smallerThan(name: TABLET, value: isSubItem ? 12.0 : 13.0),
                Condition.largerThan(name: MOBILE, value: isSubItem ? 14.0 : 15.0),
              ],
            ).value,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: ResponsiveValue<double>(
              context,
              conditionalValues: [
                Condition.smallerThan(name: TABLET, value: isSubItem ? 9.0 : 10.0),
                Condition.largerThan(name: MOBILE, value: isSubItem ? 11.0 : 12.0),
              ],
            ).value,
            color: Colors.grey[600],
          ),
          maxLines: ResponsiveBreakpoints.of(context).isDesktop ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveValue<double>(
            context,
            conditionalValues: [
              const Condition.smallerThan(name: TABLET, value: 8.0),
              const Condition.largerThan(name: MOBILE, value: 12.0),
            ],
          ).value,
          vertical: 4,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSubExpansionTile({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: Colors.orange,
            textColor: Colors.orange,
            collapsedTextColor: Colors.black87,
            collapsedIconColor: Colors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.orange, size: 22),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveValue<double>(
                context,
                conditionalValues: [
                  const Condition.smallerThan(name: TABLET, value: 14.0),
                  const Condition.largerThan(name: MOBILE, value: 15.0),
                ],
              ).value,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          children: children,
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
