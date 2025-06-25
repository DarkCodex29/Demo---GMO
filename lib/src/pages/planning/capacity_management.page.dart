import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class CapacityManagementPage extends StatefulWidget {
  const CapacityManagementPage({super.key});

  @override
  CapacityManagementPageState createState() => CapacityManagementPageState();
}

class CapacityManagementPageState extends State<CapacityManagementPage> {
  String searchQuery = '';
  List<Map<String, dynamic>> capacidades = [];
  List<Map<String, dynamic>> ordenesProgramadas = [];
  List<Map<String, dynamic>> filteredCapacidades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/capacidades.json');
      final List<dynamic> data = json.decode(response);
      
      if (data.isNotEmpty) {
        final datos = data[0]['datos'];
        setState(() {
          capacidades = (datos['capacidades'] as List).cast<Map<String, dynamic>>();
          ordenesProgramadas = (datos['ordenes_programadas'] as List).cast<Map<String, dynamic>>();
          filteredCapacidades = capacidades;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar datos de capacidades: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error al cargar datos: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterCapacidades(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredCapacidades = capacidades;
      } else {
        filteredCapacidades = capacidades.where((capacidad) {
          return capacidad.values.any((value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Gestión de Capacidades'),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      );
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: ResponsiveRowColumn(
          layout: ResponsiveRowColumnType.ROW,
          children: [
            const ResponsiveRowColumnItem(
              child: Icon(Icons.assessment, color: Colors.white),
            ),
            const ResponsiveRowColumnItem(
              child: SizedBox(width: 8),
            ),
            ResponsiveRowColumnItem(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Gestión de Capacidades',
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
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        elevation: 2,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notification_add, color: Colors.white),
            onPressed: _simulateCapacityAlert,
          ),
        ],
      ),
      body: ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.COLUMN,
        children: [
          // Barra de búsqueda responsiva
          ResponsiveRowColumnItem(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                ResponsiveValue<double>(
                  context,
                  conditionalValues: [
                    const Condition.smallerThan(name: TABLET, value: 12.0),
                    const Condition.largerThan(name: MOBILE, value: 16.0),
                  ],
                ).value,
                ResponsiveValue<double>(
                  context,
                  conditionalValues: [
                    const Condition.smallerThan(name: TABLET, value: 12.0),
                    const Condition.largerThan(name: MOBILE, value: 16.0),
                  ],
                ).value,
                ResponsiveValue<double>(
                  context,
                  conditionalValues: [
                    const Condition.smallerThan(name: TABLET, value: 12.0),
                    const Condition.largerThan(name: MOBILE, value: 16.0),
                  ],
                ).value,
                8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _filterCapacidades,
                style: TextStyle(
                  fontSize: ResponsiveValue<double>(
                    context,
                    conditionalValues: [
                      const Condition.smallerThan(name: TABLET, value: 14.0),
                      const Condition.largerThan(name: MOBILE, value: 16.0),
                    ],
                  ).value,
                ),
                decoration: InputDecoration(
                  hintText: isMobile 
                      ? 'Buscar capacidades...' 
                      : 'Buscar por puesto, centro o estado...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500], 
                    fontSize: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 13.0),
                        const Condition.largerThan(name: MOBILE, value: 15.0),
                      ],
                    ).value,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.orange.shade600, size: 24),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            _filterCapacidades('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 16.0),
                        const Condition.largerThan(name: MOBILE, value: 20.0),
                      ],
                    ).value,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          // Contenido principal
          ResponsiveRowColumnItem(
            child: Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveValue<double>(
                    context,
                    conditionalValues: [
                      const Condition.smallerThan(name: TABLET, value: 12.0),
                      const Condition.largerThan(name: MOBILE, value: 16.0),
                    ],
                  ).value,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    // Sección de Capacidades
                    _buildCapacidadCard(),
                    const SizedBox(height: 16),
                    
                    // Sección de Órdenes Programadas
                    _buildOrdenesCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacidadCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assessment, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Gestión de Capacidades',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido del card
          Padding(
            padding: const EdgeInsets.all(16),
            child: filteredCapacidades.isEmpty
                ? _buildEmptyState()
                : ResponsiveBreakpoints.of(context).isMobile
                    ? _buildMobileCapacityList()
                    : _buildDesktopCapacityTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay capacidades disponibles'
                : 'No se encontraron capacidades',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCapacityList() {
    return Column(
      children: filteredCapacidades.map((capacidad) => _buildCapacityCard(capacidad)).toList(),
    );
  }

  Widget _buildCapacityCard(Map<String, dynamic> capacidad) {
    final statusColor = _getStatusColor(capacidad['estado']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  capacidad['puestoTrabajo'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  capacidad['estado'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Centro', capacidad['centro']),
          _buildDetailRow('Semana', capacidad['semanaNro']),
          _buildDetailRow('Necesidad', capacidad['necesidad']),
          _buildDetailRow('Oferta', capacidad['oferta']),
          _buildDetailRow('Utilización', capacidad['utilizacion']),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCapacityTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Puesto de trabajo')),
          DataColumn(label: Text('Centro')),
          DataColumn(label: Text('Semana')),
          DataColumn(label: Text('Necesidad')),
          DataColumn(label: Text('Oferta')),
          DataColumn(label: Text('Utilización')),
          DataColumn(label: Text('Estado')),
        ],
        rows: filteredCapacidades.map((capacidad) {
          final statusColor = _getStatusColor(capacidad['estado']);
          return DataRow(
            cells: [
              DataCell(Text(capacidad['puestoTrabajo'])),
              DataCell(Text(capacidad['centro'])),
              DataCell(Text(capacidad['semanaNro'])),
              DataCell(Text(capacidad['necesidad'])),
              DataCell(Text(capacidad['oferta'])),
              DataCell(Text(capacidad['utilizacion'])),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    capacidad['estado'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Widget _buildOrdenesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.schedule, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Programa de Órdenes - Semana 20',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _generateProgram,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Generar programa',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido del card
          Padding(
            padding: const EdgeInsets.all(16),
            child: ordenesProgramadas.isEmpty
                ? _buildEmptyOrdersState()
                : ResponsiveBreakpoints.of(context).isMobile
                    ? _buildMobileOrdersList()
                    : _buildDesktopOrdersTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay órdenes programadas',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileOrdersList() {
    return Column(
      children: ordenesProgramadas.map((orden) => _buildOrderCard(orden)).toList(),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> orden) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orden: ${orden['orden']}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Operación', orden['operacion']),
          _buildDetailRow('Puesto de trabajo', orden['puestoTrabajo']),
          _buildDetailRow('Trabajo plan', orden['trabajoPlan']),
          if (orden.containsKey('fechaInicio'))
            _buildDetailRow('Fecha inicio', orden['fechaInicio']),
          if (orden.containsKey('fechaFin'))
            _buildDetailRow('Fecha fin', orden['fechaFin']),
        ],
      ),
    );
  }

  Widget _buildDesktopOrdersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Orden')),
          DataColumn(label: Text('Operación')),
          DataColumn(label: Text('Puesto de trabajo')),
          DataColumn(label: Text('Trabajo plan')),
          DataColumn(label: Text('Fecha inicio')),
          DataColumn(label: Text('Fecha fin')),
        ],
        rows: ordenesProgramadas.map((orden) {
          return DataRow(
            cells: [
              DataCell(Text(orden['orden'])),
              DataCell(Text(orden['operacion'])),
              DataCell(Text(orden['puestoTrabajo'])),
              DataCell(Text(orden['trabajoPlan'])),
              DataCell(Text(orden['fechaInicio'] ?? '-')),
              DataCell(Text(orden['fechaFin'] ?? '-')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'crítico':
        return Colors.red;
      case 'sobrecargado':
        return Colors.deepOrange;
      case 'normal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _simulateCapacityAlert() async {
    await NotificationService.showCapacityAlert(
      workCenter: 'PM_INST',
      message: 'El puesto está sobrecargado al 125%',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Notificación de capacidad enviada')),
            ],
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _generateProgram() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Programa de órdenes generado exitosamente')),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
} 