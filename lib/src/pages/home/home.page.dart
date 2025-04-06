import 'package:demo/src/pages/auth/auth.page.dart';
import 'package:flutter/material.dart';
import 'package:demo/src/pages/maintenance/order.page.dart';
import 'package:demo/src/pages/maintenance/warning.page.dart';
import 'package:demo/src/pages/team/class.page.dart';
import 'package:demo/src/pages/team/locations.page.dart';
import 'package:demo/src/pages/team/job.page.dart';
import 'package:demo/src/pages/team/equipment.page.dart';
import 'package:demo/src/pages/team/materials.page.dart';
import 'package:demo/src/pages/planning/maintenance/cycle.page.dart';
import 'package:demo/src/pages/planning/maintenance/strategy.page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        title: const Text('Equipo/U.T'),
        backgroundColor: Colors.orange,
        actions: [
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
                /*
                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('Características'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CaracteristicsPage(),
                      ),
                    );
                  },
                ),*/
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
                ExpansionTile(
                  leading: const Icon(Icons.map),
                  title: const Text('Hoja de Ruta'),
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.devices),
                      title: const Text('Equipo'),
                      onTap: () {
                        /*
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamPage(),
                          ),
                        );
                        */
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_city),
                      title: const Text('UBT'),
                      onTap: () {
                        /*
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UbtPage(),
                          ),
                        );
                        */
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.description),
                      title: const Text('Instrucción'),
                      onTap: () {
                        /*
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InstructionPage(),
                          ),
                        );
                        */
                      },
                    ),
                  ],
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
                    ListTile(
                      leading: const Icon(Icons.view_list),
                      title: const Text('Múltiple'),
                      onTap: () {},
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
                ListTile(
                  leading: const Icon(Icons.done),
                  title: const Text('Ejecución'),
                  onTap: () {
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExecutionPage(),
                      ),
                    );
                    */
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notificación'),
                  onTap: () {
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationPage(),
                      ),
                    );
                    */
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.error),
                  title: const Text('Registro de falla'),
                  onTap: () {
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FaultLogPage(),
                      ),
                    );*/
                  },
                ),
                /*
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('Cierre'),
                  onTap: () {
                    /*
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClosingPage(),
                      ),
                    );
                    */
                  },
                ),
                */
              ],
            ),
          ],
        ),
      ),
    );
  }
}
