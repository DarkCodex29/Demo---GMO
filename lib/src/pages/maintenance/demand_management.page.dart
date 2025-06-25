import 'package:flutter/material.dart';
import 'package:demo/src/services/notification_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

class DemandManagementPage extends StatefulWidget {
  const DemandManagementPage({super.key});

  @override
  DemandManagementPageState createState() => DemandManagementPageState();
}

class DemandManagementPageState extends State<DemandManagementPage> {
  List<Map<String, dynamic>> demandas = [];
  Map<String, dynamic>? selectedDemanda;
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _claseAvisoController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _sintomaController = TextEditingController();
  final TextEditingController _causaController = TextEditingController();
  final TextEditingController _tiempoReparacionController = TextEditingController();
  
  final List<String> clasesAviso = ['m1', 'm2', 'm3', 'm4'];
  final List<String> prioridades = ['BAJA', 'MEDIA', 'ALTA', 'CRITICA'];
  final List<String> sintomas = ['Ruido', 'Fuga', 'Vibración', 'Temperatura alta', 'Otros'];
  
  String? selectedClaseAviso;
  String? selectedPrioridad;
  String? selectedSintoma;

  @override
  void initState() {
    super.initState();
    _loadDemandas();
    _autorController.text = 'usuario_actual'; // Simulamos usuario logueado
  }

  Future<void> _loadDemandas() async {
    try {
      final String response = await rootBundle.loadString('assets/data/demandas.json');
      final data = await json.decode(response);
      setState(() {
        demandas = List<Map<String, dynamic>>.from(data['demandas']);
      });
    } catch (e) {
      // Si no existe el archivo, usar datos predeterminados
      demandas = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Demandas'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDemandDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del proceso DEMANDA como en la imagen
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PROCESO DE DEMANDA',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),

            // Resumen de estadísticas
            Row(
              children: [
                Expanded(child: _buildStatCard('Total', demandas.length.toString(), Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Pendientes', 
                  demandas.where((d) => d['status'] == 'PENDIENTE').length.toString(), 
                  Colors.orange)),
                const SizedBox(width: 8),
                Expanded(child: _buildStatCard('Críticas', 
                  demandas.where((d) => d['prioridad'] == 'CRITICA').length.toString(), 
                  Colors.red)),
              ],
            ),

            const SizedBox(height: 16),

            // Lista de demandas
            Expanded(
              child: demandas.isEmpty 
                ? _buildEmptyState()
                : _buildDemandsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDemandDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay demandas registradas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para crear una nueva demanda',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandsList() {
    return ListView.builder(
      itemCount: demandas.length,
      itemBuilder: (context, index) {
        final demanda = demandas[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getPriorityColor(demanda['prioridad']),
              child: Text(
                demanda['claseAviso'].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            title: Text(
              demanda['tituloAviso'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${demanda['equipo']} - ${demanda['sintoma']}'),
                Text(
                  'Creado: ${demanda['fechaCreacion']} por ${demanda['autor']}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(demanda['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    demanda['status'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  demanda['prioridad'],
                  style: TextStyle(
                    fontSize: 10,
                    color: _getPriorityColor(demanda['prioridad']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            onTap: () => _showDemandDetails(demanda),
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String prioridad) {
    switch (prioridad) {
      case 'CRITICA':
        return Colors.red;
      case 'ALTA':
        return Colors.orange;
      case 'MEDIA':
        return Colors.yellow[700]!;
      case 'BAJA':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDIENTE':
        return Colors.orange;
      case 'EN_PROCESO':
        return Colors.blue;
      case 'ASIGNADO':
        return Colors.purple;
      case 'PLANIFICADO':
        return Colors.indigo;
      case 'COMPLETADO':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showCreateDemandDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Demanda'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Clase de aviso',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedClaseAviso,
                    items: clasesAviso.map((clase) {
                      return DropdownMenuItem(
                        value: clase,
                        child: Text(clase),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClaseAviso = value;
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione una clase' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título de aviso',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => 
                      value == null || value.isEmpty ? 'Ingrese un título' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción del aviso',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => 
                      value == null || value.isEmpty ? 'Ingrese una descripción' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Síntoma',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedSintoma,
                    items: sintomas.map((sintoma) {
                      return DropdownMenuItem(
                        value: sintoma,
                        child: Text(sintoma),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSintoma = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _causaController,
                    decoration: const InputDecoration(
                      labelText: 'Causa',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedPrioridad,
                    items: prioridades.map((prioridad) {
                      return DropdownMenuItem(
                        value: prioridad,
                        child: Text(prioridad),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPrioridad = value;
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione una prioridad' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tiempoReparacionController,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo de reparación',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: 4h, 2h',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _createDemand,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Crear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _createDemand() {
    if (_formKey.currentState!.validate()) {
      final newDemand = {
        'id': 'DEM-${DateTime.now().millisecondsSinceEpoch % 10000}',
        'claseAviso': selectedClaseAviso!,
        'tituloAviso': _tituloController.text,
        'descripcionAviso': _descripcionController.text,
        'fechaInicio': DateFormat('dd.MM.yyyy').format(DateTime.now()),
        'autor': _autorController.text,
        'sintoma': selectedSintoma ?? '',
        'causa': _causaController.text,
        'tiempoReparacion': _tiempoReparacionController.text,
        'prioridad': selectedPrioridad!,
        'status': 'PENDIENTE',
        'fechaCreacion': DateFormat('dd.MM.yyyy').format(DateTime.now()),
        'horaCreacion': DateFormat('HH:mm:ss').format(DateTime.now()),
      };

      setState(() {
        demandas.insert(0, newDemand);
      });

      Navigator.pop(context);
      _clearForm();

      // Enviar notificación
      NotificationService.showFailureAlert(
        equipmentCode: 'NUEVO',
        failureDescription: _tituloController.text,
        urgency: selectedPrioridad!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demanda creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _clearForm() {
    _tituloController.clear();
    _descripcionController.clear();
    _sintomaController.clear();
    _causaController.clear();
    _tiempoReparacionController.clear();
    
    setState(() {
      selectedClaseAviso = null;
      selectedPrioridad = null;
      selectedSintoma = null;
    });
  }

  void _showDemandDetails(Map<String, dynamic> demanda) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Demanda ${demanda['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Clase de aviso:', demanda['claseAviso']),
              _buildDetailRow('Título:', demanda['tituloAviso']),
              _buildDetailRow('Descripción:', demanda['descripcionAviso']),
              _buildDetailRow('Síntoma:', demanda['sintoma']),
              _buildDetailRow('Causa:', demanda['causa'] ?? 'No especificada'),
              _buildDetailRow('Tiempo reparación:', demanda['tiempoReparacion'] ?? 'No estimado'),
              _buildDetailRow('Prioridad:', demanda['prioridad']),
              _buildDetailRow('Estado:', demanda['status']),
              _buildDetailRow('Autor:', demanda['autor']),
              _buildDetailRow('Fecha creación:', 
                '${demanda['fechaCreacion']} ${demanda['horaCreacion']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              // Aquí se podría navegar a crear orden
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Funcionalidad: Crear orden desde demanda')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Crear Orden', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _autorController.dispose();
    _sintomaController.dispose();
    _causaController.dispose();
    _tiempoReparacionController.dispose();
    super.dispose();
  }
} 