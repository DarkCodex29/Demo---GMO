import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';
import 'package:demo/src/modules/confiabilidad/confiabilidad.dart';
import 'package:demo/src/modules/demanda/demanda.dart';
import 'package:demo/src/modules/planificacion/planificacion.dart';
import 'package:demo/src/modules/programacion/programacion.dart';
import 'package:demo/src/modules/ejecucion/ejecucion.dart';
import 'package:demo/src/modules/seguimiento_control/seguimiento_control.dart';
import 'package:demo/src/shared/widgets/floating_search.dart';
import 'package:demo/src/modules/auth/auth.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentModule;
  final String? customTitle;
  final VoidCallback? onMenuTap;
  final bool showBackButton;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentModule,
    this.customTitle,
    this.onMenuTap,
    this.showBackButton = false,
  });

  @override
  MainLayoutState createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  // final bool _isDrawerOpen = false; // Not used currently

  @override
  Widget build(BuildContext context) {
    // final isDesktop = ResponsiveBreakpoints.of(context).isDesktop; // Not used currently
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (isMobile) {
      return _buildMobileLayout();
    } else if (isTablet) {
      return _buildTabletLayout();
    } else {
      return _buildDesktopLayout();
    }
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar(true),
      drawer: _buildNavigationDrawer(),
      body: Stack(
        children: [
          widget.child,
          const FloatingSearch(),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationRail(extended: false),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(false),
                Expanded(
                  child: Stack(
                    children: [
                      widget.child,
                      const FloatingSearch(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationRail(extended: true),
          Expanded(
            child: Column(
              children: [
                _buildAppBar(false),
                Expanded(
                  child: Stack(
                    children: [
                      widget.child,
                      const FloatingSearch(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool showMenuButton) {
    return AppBar(
      automaticallyImplyLeading: showMenuButton && !widget.showBackButton,
      leading: widget.showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            )
          : (showMenuButton ? null : Container()),
      titleSpacing: showMenuButton ? 0 : 16,
      title: Text(
        widget.customTitle ?? _getModuleTitle(widget.currentModule),
        style: AppTextStyles.appBarTitle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  //padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryCoralRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: Text(
                    '3',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.white,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => _showNotifications(),
        ),
        /*
        PopupMenuButton<String>(
          icon: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.white.withOpacity(0.2),
            child: Text(
              'GM',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          onSelected: _handleProfileAction,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: _buildPopupMenuItem(
                Icons.person_outline,
                'Mi Perfil',
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: _buildPopupMenuItem(
                Icons.settings_outlined,
                'Configuración',
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: _buildPopupMenuItem(
                Icons.logout,
                'Cerrar Sesión',
                color: AppColors.secondaryCoralRed,
              ),
            ),
          ],
        ),*/
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPopupMenuItem(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? AppColors.neutralTextGray),
        const SizedBox(width: 12),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildNavigationRail({required bool extended}) {
    return NavigationRail(
      backgroundColor: AppColors.white,
      selectedIndex: _getSelectedIndex(),
      extended: extended,
      minExtendedWidth: 280,
      groupAlignment: 0.0,
      labelType: extended ? null : NavigationRailLabelType.selected,
      leading: extended
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarkTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.engineering,
                      color: AppColors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'GMO Demo',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDarkTeal,
                    ),
                  ),
                  Text(
                    'Gestión de Mantenimiento',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.neutralTextGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : null,
      destinations: _getNavigationDestinations(extended),
      onDestinationSelected: _onDestinationSelected,
    );
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 6),
            decoration: const BoxDecoration(
              color: AppColors.primaryDarkTeal,
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.engineering,
                    color: AppColors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'GMO Demo',
                  style: AppTextStyles.heading6.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Gestión de Mantenimiento Operacional',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 2),
              children: _getDrawerItems(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.neutralMediumBorder,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryDarkTeal.withOpacity(0.1),
                  child: Text(
                    'GM',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primaryDarkTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gianpierre Mio',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Administrador',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutralTextGray,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: _handleProfileAction,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: _buildPopupMenuItem(
                        Icons.person_outline,
                        'Mi Perfil',
                      ),
                    ),
                    PopupMenuItem(
                      value: 'settings',
                      child: _buildPopupMenuItem(
                        Icons.settings_outlined,
                        'Configuración',
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: _buildPopupMenuItem(
                        Icons.logout,
                        'Cerrar Sesión',
                        color: AppColors.secondaryCoralRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<NavigationRailDestination> _getNavigationDestinations(bool extended) {
    final modules = _getModules();
    return modules.map((module) {
      return NavigationRailDestination(
        icon: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: widget.currentModule == module['id']
                ? AppColors.primaryDarkTeal.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            module['icon'],
            color: widget.currentModule == module['id']
                ? AppColors.primaryDarkTeal
                : AppColors.neutralTextGray,
          ),
        ),
        selectedIcon: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.primaryDarkTeal,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            module['icon'],
            color: AppColors.white,
          ),
        ),
        label: Text(
          module['title'],
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: widget.currentModule == module['id']
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _getDrawerItems() {
    final modules = _getModules();
    return modules.map((module) {
      final isSelected = widget.currentModule == module['id'];
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDarkTeal.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(
            module['icon'],
            color: isSelected
                ? AppColors.primaryDarkTeal
                : AppColors.neutralTextGray,
          ),
          title: Text(
            module['title'],
            style: AppTextStyles.navigationLabel.copyWith(
              color: isSelected
                  ? AppColors.primaryDarkTeal
                  : AppColors.neutralTextGray,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          subtitle: Text(
            module['subtitle'],
            style: AppTextStyles.navigationSubtitle.copyWith(
              color: isSelected
                  ? AppColors.primaryDarkTeal.withOpacity(0.7)
                  : AppColors.neutralTextGray.withOpacity(0.7),
            ),
          ),
          onTap: () => _onModuleSelected(module['id']),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }).toList();
  }

  List<Map<String, dynamic>> _getModules() {
    return [
      {
        'id': 'home',
        'title': 'Dashboard',
        'subtitle': 'Vista general del sistema',
        'icon': Icons.dashboard_outlined,
      },
      {
        'id': 'confiabilidad',
        'title': 'Confiabilidad',
        'subtitle': 'Datos maestros y configuración',
        'icon': Icons.settings_outlined,
      },
      {
        'id': 'demanda',
        'title': 'Demanda',
        'subtitle': 'Gestión de avisos y notificaciones',
        'icon': Icons.notification_important_outlined,
      },
      {
        'id': 'planificacion',
        'title': 'Planificación',
        'subtitle': 'Órdenes y programación',
        'icon': Icons.calendar_today_outlined,
      },
      {
        'id': 'programacion',
        'title': 'Programación',
        'subtitle': 'Calendario y recursos',
        'icon': Icons.schedule_outlined,
      },
      {
        'id': 'ejecucion',
        'title': 'Ejecución',
        'subtitle': 'Trabajo de campo',
        'icon': Icons.engineering_outlined,
      },
      {
        'id': 'seguimiento_control',
        'title': 'Seguimiento y Control',
        'subtitle': 'Control y reportes',
        'icon': Icons.analytics_outlined,
      },
    ];
  }

  int _getSelectedIndex() {
    final modules = _getModules();
    return modules.indexWhere((module) => module['id'] == widget.currentModule);
  }

  IconData _getModuleIcon(String moduleId) {
    final module = _getModules().firstWhere(
      (m) => m['id'] == moduleId,
      orElse: () => _getModules().first,
    );
    return module['icon'];
  }

  String _getModuleTitle(String moduleId) {
    final module = _getModules().firstWhere(
      (m) => m['id'] == moduleId,
      orElse: () => _getModules().first,
    );
    return module['title'];
  }

  void _onDestinationSelected(int index) {
    final modules = _getModules();
    if (index < modules.length) {
      _onModuleSelected(modules[index]['id']);
    }
  }

  void _onModuleSelected(String moduleId) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(); // Close drawer if open
    }

    if (moduleId == 'home') {
      // Si selecciona Dashboard, volver al home
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Widget? targetPage = _getModulePage(moduleId);
      if (targetPage != null) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => targetPage),
        );
      }
    }
  }

  Widget? _getModulePage(String moduleId) {
    switch (moduleId) {
      case 'home':
        return null; // Ya estamos en home
      case 'confiabilidad':
        // Llevamos a la página principal del módulo Confiabilidad
        return const ConfiabilidadMainPage();
      case 'demanda':
        // Llevamos a la página principal del módulo Demanda
        return const DemandaMainPage();
      case 'planificacion':
        // Llevamos a la página principal del módulo Planificación
        return const PlanificacionMainPage();
      case 'programacion':
        // Llevamos a la página principal del módulo Programación
        return const ProgramacionMainPage();
      case 'ejecucion':
        // Llevamos a la página principal del módulo Ejecución
        return const EjecucionMainPage();
      case 'seguimiento_control':
        // Llevamos a reportes principales
        return const ReportsMainPage();
      default:
        return null;
    }
  }


  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.notifications,
              color: AppColors.primaryDarkTeal,
            ),
            SizedBox(width: 8),
            Text('Notificaciones'),
          ],
        ),
        content: SizedBox(
          width: 300,
          height: 350,
          child: Column(
            children: [
              _buildNotificationItem(
                'Nueva orden asignada',
                'Orden ZIA1-2024 requiere atención',
                Icons.assignment,
                AppColors.primaryDarkTeal,
                '5 min',
              ),
              _buildNotificationItem(
                'Equipo requiere mantenimiento',
                'Bomba 001 - Mantenimiento preventivo',
                Icons.engineering,
                AppColors.secondaryCoralRed,
                '15 min',
              ),
              _buildNotificationItem(
                'Capacidad al 85%',
                'Recursos PM_MECANICO necesitan programación',
                Icons.warning,
                AppColors.secondaryGoldenYellow,
                '30 min',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Ver todas'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
      String title, String subtitle, IconData icon, Color color, String time) {
    return ListTile(
      leading: Container(
        //padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        title,
        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall,
      ),
      trailing: Text(
        time,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.neutralTextGray.withOpacity(0.7),
        ),
      ),
      onTap: () => Navigator.of(context).pop(),
    );
  }

  void _handleProfileAction(String action) {
    switch (action) {
      case 'profile':
        _showProfile();
        break;
      case 'settings':
        _showSettings();
        break;
      case 'logout':
        _confirmLogout();
        break;
    }
  }

  void _showProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.person,
              color: AppColors.primaryDarkTeal,
            ),
            SizedBox(width: 8),
            Text('Mi Perfil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryDarkTeal.withOpacity(0.1),
                child: Text(
                  'GM',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryDarkTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              title: const Text('Gianpierre Mio'),
              subtitle: const Text('Administrador del Sistema'),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.email),
              title: Text('Email'),
              subtitle: Text('gianpierre.mio@empresa.com'),
            ),
            const ListTile(
              leading: Icon(Icons.badge),
              title: Text('Rol'),
              subtitle: Text('Administrador GMO'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.settings,
              color: AppColors.primaryDarkTeal,
            ),
            SizedBox(width: 8),
            Text('Configuración'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificaciones'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Modo oscuro'),
              trailing: Switch(
                value: false,
                onChanged: (value) {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Idioma'),
              subtitle: const Text('Español'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.logout,
              color: AppColors.secondaryCoralRed,
            ),
            SizedBox(width: 8),
            Text('Cerrar Sesión'),
          ],
        ),
        content: const Text('¿Estás seguro de que deseas cerrar la sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _performLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryCoralRed,
            ),
            child: const Text('Cerrar Sesión',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.remove('username');
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: AppColors.secondaryCoralRed,
          ),
        );
      }
    }
  }

  Widget _buildNavigationBar() {
    final modules = _getModules().where((module) => module['id'] != 'home').toList();
    final currentModuleIndex = modules.indexWhere((module) => module['id'] == widget.currentModule);
    
    return NavigationBar(
      selectedIndex: currentModuleIndex >= 0 ? currentModuleIndex : 0,
      onDestinationSelected: (index) {
        if (index < modules.length) {
          _onModuleSelected(modules[index]['id']);
        }
      },
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.primaryDarkTeal.withOpacity(0.1),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      height: 65,
      destinations: modules.take(5).map((module) {
        return NavigationDestination(
          icon: Icon(
            module['icon'],
            color: AppColors.neutralTextGray,
            size: 20,
          ),
          selectedIcon: Icon(
            module['icon'],
            color: AppColors.primaryDarkTeal,
            size: 20,
          ),
          label: module['title'],
        );
      }).toList(),
    );
  }
}

class GlobalSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: AppColors.neutralTextGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Buscar en GMO',
              style: AppTextStyles.heading6.copyWith(
                color: AppColors.neutralTextGray,
              ),
            ),
            Text(
              'Equipos, órdenes, avisos, materiales...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutralTextGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    // TODO: Implement actual search results
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.engineering),
          title: Text('Equipo ${query.toUpperCase()}'),
          subtitle: const Text('Bomba centrífuga - Ubicación: PLANTA-A'),
          onTap: () => close(context, query),
        ),
        ListTile(
          leading: const Icon(Icons.assignment),
          title: Text('Orden ZIA1-$query'),
          subtitle:
              const Text('Mantenimiento preventivo - Estado: Planificada'),
          onTap: () => close(context, query),
        ),
      ],
    );
  }
}
