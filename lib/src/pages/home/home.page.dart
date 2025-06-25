import 'package:demo/src/pages/auth/auth.page.dart';
import 'package:flutter/material.dart';
import 'package:demo/src/pages/maintenance/order.page.dart';
import 'package:demo/src/pages/maintenance/warning.page.dart';
import 'package:demo/src/pages/maintenance/create_order.page.dart';
import 'package:demo/src/pages/team/class.page.dart';
import 'package:demo/src/pages/team/locations.page.dart';
import 'package:demo/src/pages/team/job.page.dart';
import 'package:demo/src/pages/team/equipment.page.dart';
import 'package:demo/src/pages/team/materials.page.dart';
import 'package:demo/src/pages/planning/maintenance/cycle.page.dart';
import 'package:demo/src/pages/planning/maintenance/strategy.page.dart';
import 'package:demo/src/pages/planning/capacity_management.page.dart';
import 'package:demo/src/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    // Simular notificaciones del sistema después de 10 segundos
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
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar la sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Cerrar sesión',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');

      // Verificar si el contexto sigue siendo válido antes de usarlo
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Sistema GMO - Demo'),
        backgroundColor: Colors.orange,
        actions: [
          // Botón para toggle de notificaciones
          IconButton(
            icon: Icon(_notificationsEnabled ? Icons.notifications : Icons.notifications_off),
            onPressed: () {
              setState(() {
                _notificationsEnabled = !_notificationsEnabled;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _notificationsEnabled 
                      ? 'Notificaciones activadas' 
                      : 'Notificaciones desactivadas'
                  ),
                ),
              );
            },
          ),
          // Botón para simular notificación inmediata
          IconButton(
            icon: const Icon(Icons.notification_add),
            onPressed: () {
              NotificationService.showOrderNotification(
                orderNumber: "TEST-${DateTime.now().millisecondsSinceEpoch % 1000}",
                description: "Notificación de prueba",
                priority: "NORMAL",
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Banner de notificaciones
            if (_notificationsEnabled)
              Card(
                color: Colors.orange.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.notifications_active, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notificaciones del sistema activadas. Recibirás alertas en tiempo real.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 8),

            // Datos Maestros para Equipo
            ExpansionTile(
              leading: const Icon(Icons.engineering),
              title: const Text('Datos Maestros para Equipo'),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.list),
                  title: const Text('Clases'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClasesPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Ubicaciones Técnicas'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LocationsPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.work),
                  title: const Text('Puesto de trabajo'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JobPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.build),
                  title: const Text('Equipos'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EquipmentPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Lista de Materiales'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MaterialsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
            
            // Datos Maestros para Planificación
            ExpansionTile(
              leading: const Icon(Icons.timeline),
              title: const Text('Datos Maestros para Planificación'),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.stacked_line_chart),
                  title: const Text('Estrategias'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StrategyPage(),
                      ),
                    );
                  },
                ),
                // NUEVO: Gestión de Capacidades
                ListTile(
                  leading: const Icon(Icons.assessment),
                  title: const Text('Gestión de Capacidades'),
                  subtitle: const Text('Planificación y programación de recursos'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CapacityManagementPage(),
                      ),
                    );
                  },
                ),
                ExpansionTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Plan de Mantenimiento'),
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.repeat),
                      title: const Text('Ciclo Individual'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CyclePage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: const Text('Estrategia'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StrategyPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            
            // Mantenimiento Correctivo
            ExpansionTile(
              leading: const Icon(Icons.warning),
              title: const Text('Mantenimiento Correctivo'),
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.notification_important),
                  title: const Text('Aviso'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AvisoPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.build_circle),
                  title: const Text('Orden'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdenPage(),
                      ),
                    );
                  },
                ),
                // NUEVO: Crear Orden
                ListTile(
                  leading: const Icon(Icons.add_circle),
                  title: const Text('Crear Orden'),
                  subtitle: const Text('Crear nueva orden de mantenimiento'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateOrderPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sección de acciones rápidas
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acciones Rápidas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickAction(
                          context,
                          'Nueva Orden',
                          Icons.add_circle_outline,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateOrderPage(),
                            ),
                          ),
                        ),
                        _buildQuickAction(
                          context,
                          'Capacidades',
                          Icons.assessment,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CapacityManagementPage(),
                            ),
                          ),
                        ),
                        _buildQuickAction(
                          context,
                          'Equipos',
                          Icons.build,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EquipmentPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.orange, size: 32),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
