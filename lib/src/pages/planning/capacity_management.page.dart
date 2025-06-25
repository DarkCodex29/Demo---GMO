import 'package:flutter/material.dart';
import 'package:demo/src/services/notification_service.dart';
import 'package:intl/intl.dart';

class CapacityManagementPage extends StatefulWidget {
  const CapacityManagementPage({super.key});

  @override
  CapacityManagementPageState createState() => CapacityManagementPageState();
}

class CapacityManagementPageState extends State<CapacityManagementPage> {
  // Datos de capacidad según las imágenes del proceso
  final List<Map<String, dynamic>> capacities = [
    {
      'puestoTrabajo': 'PM_MECANICO',
      'centro': '1000',
      'semanaNro': '20',
      'necesidad': '20h',
      'oferta': '15h',
      'utilizacion': '85%',
      'estado': 'Crítico'
    },
    {
      'puestoTrabajo': 'PM_ELEC',
      'centro': '1001',
      'semanaNro': '20',
      'necesidad': '15h',
      'oferta': '18h',
      'utilizacion': '83%',
      'estado': 'Normal'
    },
    {
      'puestoTrabajo': 'PM_INST',
      'centro': '1002',
      'semanaNro': '20',
      'necesidad': '25h',
      'oferta': '20h',
      'utilizacion': '125%',
      'estado': 'Sobrecargado'
    },
  ];

  // Órdenes programadas según la imagen
  final List<Map<String, dynamic>> scheduledOrders = [
    {
      'orden': '10000050',
      'operacion': '0010',
      'puestoTrabajo': 'PM_MECA',
      'trabajoPlan': '4h'
    },
    {
      'orden': '10000050',
      'operacion': '0020',
      'puestoTrabajo': 'PM_ELEC',
      'trabajoPlan': '5h'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Capacidades'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add),
            onPressed: _simulateCapacityAlert,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección de Capacidades
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GESTIÓN DE CAPACIDADES',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCapacityTable(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sección de Programación de Órdenes
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Crear programación de órdenes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _generateProgram,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: const Text(
                            'Generar programa',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildProgrammingForm(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Programa de Órdenes - Semana 20
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Programa de órdenes Semana 20',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(child: _buildOrdersSchedule()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapacityTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Puesto de trabajo')),
          DataColumn(label: Text('CENTRO')),
          DataColumn(label: Text('Semana nro')),
          DataColumn(label: Text('Necesidad')),
          DataColumn(label: Text('Oferta')),
          DataColumn(label: Text('Utilización')),
          DataColumn(label: Text('Estado')),
        ],
        rows: capacities.map((capacity) {
          Color statusColor = _getStatusColor(capacity['estado']);
          return DataRow(
            cells: [
              DataCell(Text(capacity['puestoTrabajo'])),
              DataCell(Text(capacity['centro'])),
              DataCell(Text(capacity['semanaNro'])),
              DataCell(Text(capacity['necesidad'])),
              DataCell(Text(capacity['oferta'])),
              DataCell(Text(capacity['utilizacion'])),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    capacity['estado'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgrammingForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Fecha inicio de programación',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: DateFormat('dd.MM.yyyy').format(DateTime.now()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Fecha fin de programación',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: DateFormat('dd.MM.yyyy').format(
                    DateTime.now().add(const Duration(days: 7)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrdersSchedule() {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Orden')),
          DataColumn(label: Text('Operación')),
          DataColumn(label: Text('Puesto de trabajo')),
          DataColumn(label: Text('Trabajo plan')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: scheduledOrders.map((order) {
          return DataRow(
            cells: [
              DataCell(Text(order['orden'])),
              DataCell(Text(order['operacion'])),
              DataCell(Text(order['puestoTrabajo'])),
              DataCell(Text(order['trabajoPlan'])),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => _editOrder(order),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications, color: Colors.blue),
                      onPressed: () => _notifyOrder(order),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado) {
      case 'Crítico':
        return Colors.red;
      case 'Sobrecargado':
        return Colors.red.shade800;
      case 'Normal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _generateProgram() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Programa Generado'),
        content: const Text(
          'Se ha generado el programa de órdenes para la Semana 20\n\n'
          '✓ 2 órdenes programadas\n'
          '✓ Capacidades balanceadas\n'
          '✓ Notificaciones enviadas',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    // Simular notificación de programa generado
    NotificationService.showOrderNotification(
      orderNumber: "PROGRAMA-S20",
      description: "Programa de órdenes Semana 20 generado",
      priority: "NORMAL",
    );
  }

  void _simulateCapacityAlert() {
    NotificationService.showCapacityAlert(
      workCenter: "PM_MECANICO",
      message: "Capacidad al 85% - Requiere ajuste de programación",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alerta de capacidad enviada'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _editOrder(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Orden ${order['orden']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Operación'),
              controller: TextEditingController(text: order['operacion']),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Puesto de trabajo'),
              controller: TextEditingController(text: order['puestoTrabajo']),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Trabajo planificado'),
              controller: TextEditingController(text: order['trabajoPlan']),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Orden actualizada')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _notifyOrder(Map<String, dynamic> order) {
    NotificationService.showOrderNotification(
      orderNumber: order['orden'],
      description: "Operación ${order['operacion']} programada",
      priority: "NORMAL",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notificación enviada para orden ${order['orden']}')),
    );
  }
} 