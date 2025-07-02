import 'package:flutter/material.dart';
import 'package:demo/src/services/notification_service.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  CreateOrderPageState createState() => CreateOrderPageState();
}

class CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores según los campos del proceso real
  final TextEditingController _claseOrdenController = TextEditingController();
  final TextEditingController _prioridadController = TextEditingController();
  final TextEditingController _equipoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _operacionController = TextEditingController();
  final TextEditingController _centroCostoController = TextEditingController();
  final TextEditingController _cantidadPersonasController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  final TextEditingController _componentesController = TextEditingController();
  final TextEditingController _trabajoPlanController = TextEditingController();
  final TextEditingController _centroController = TextEditingController();
  final TextEditingController _almacenController = TextEditingController();
  final TextEditingController _tipoMaterialController = TextEditingController();
  final TextEditingController _ubicacionTecnicaController = TextEditingController();

  // Datos para dropdowns
  final List<String> clasesOrden = ['ZPM1', 'ZPM2', 'ZIA1', 'ZM23', 'ZM24', 'ZM25'];
  final List<String> prioridades = ['1 URGENTE', '2 PRIORITARIO', '3 NORMAL', '4 BAJO'];
  final List<String> tiposPlan = ['Plan preventivo', 'Plan correctivo', 'Mantenimiento de 500 km'];

  String? selectedClaseOrden;
  String? selectedPrioridad;
  String? selectedTipoPlan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Órdenes de Mantenimiento'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveOrder,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información General
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Información General de la Orden',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Clase de orden',
                                border: OutlineInputBorder(),
                              ),
                              value: selectedClaseOrden,
                              items: clasesOrden.map((clase) {
                                return DropdownMenuItem(
                                  value: clase,
                                  child: Text(clase),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedClaseOrden = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Seleccione una clase de orden';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
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
                              validator: (value) {
                                if (value == null) {
                                  return 'Seleccione una prioridad';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _equipoController,
                        decoration: const InputDecoration(
                          labelText: 'Equipo',
                          border: OutlineInputBorder(),
                          hintText: 'Ej: 10000001',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el código del equipo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descripcionController,
                        decoration: const InputDecoration(
                          labelText: 'Descripción de la orden',
                          border: OutlineInputBorder(),
                          hintText: 'Describa el trabajo a realizar',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese una descripción';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Tipo de plan',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedTipoPlan,
                        items: tiposPlan.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTipoPlan = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Operaciones
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detalles de Operación',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _operacionController,
                              decoration: const InputDecoration(
                                labelText: 'Operación',
                                border: OutlineInputBorder(),
                                hintText: 'Ej: 0010',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _centroCostoController,
                              decoration: const InputDecoration(
                                labelText: 'Centro de costo',
                                border: OutlineInputBorder(),
                                hintText: 'Ej: 10000001',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cantidadPersonasController,
                              decoration: const InputDecoration(
                                labelText: 'Cantidad de personas',
                                border: OutlineInputBorder(),
                                hintText: 'Ej: 2',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _duracionController,
                              decoration: const InputDecoration(
                                labelText: 'Duración',
                                border: OutlineInputBorder(),
                                hintText: 'Ej: 2h',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _trabajoPlanController,
                        decoration: const InputDecoration(
                          labelText: 'Trabajo plan',
                          border: OutlineInputBorder(),
                          hintText: 'Descripción del trabajo planificado',
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Materiales
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Materiales y Recursos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _centroController,
                              decoration: const InputDecoration(
                                labelText: 'Centro',
                                border: OutlineInputBorder(),
                                hintText: 'Ej: 1001',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _almacenController,
                              decoration: const InputDecoration(
                                labelText: 'Almacén',
                                border: OutlineInputBorder(),
                                hintText: 'Ej: 2001',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _componentesController,
                        decoration: const InputDecoration(
                          labelText: 'Componentes',
                          border: OutlineInputBorder(),
                          hintText: 'Lista de componentes necesarios',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ubicacionTecnicaController,
                        decoration: const InputDecoration(
                          labelText: 'Ubicación técnica',
                          border: OutlineInputBorder(),
                          hintText: 'Ej: PERU-CHI-PCBN-RA-',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveDraft,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Guardar Borrador'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveOrder,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Crear Orden'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Borrador guardado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveOrder() {
    if (_formKey.currentState!.validate()) {
      // Generar número de orden
      final orderNumber = 'ZIA1-${DateTime.now().millisecondsSinceEpoch % 10000}';
      
      // Mostrar confirmación
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Orden Creada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Número de orden: $orderNumber'),
              Text('Clase: ${selectedClaseOrden ?? 'N/A'}'),
              Text('Prioridad: ${selectedPrioridad ?? 'N/A'}'),
              Text('Equipo: ${_equipoController.text}'),
              const SizedBox(height: 16),
              const Text(
                '✓ Orden creada exitosamente\n'
                '✓ Notificaciones enviadas\n'
                '✓ Programación actualizada',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Volver a la página anterior
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _createAnotherOrder();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Crear Otra', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      // Enviar notificación
      NotificationService.showOrderNotification(
        orderNumber: orderNumber,
        description: _descripcionController.text,
        priority: selectedPrioridad ?? 'NORMAL',
      );
    }
  }

  void _createAnotherOrder() {
    // Limpiar formulario para nueva orden
    setState(() {
      _claseOrdenController.clear();
      _equipoController.clear();
      _descripcionController.clear();
      _operacionController.clear();
      _centroCostoController.clear();
      _cantidadPersonasController.clear();
      _duracionController.clear();
      _componentesController.clear();
      _trabajoPlanController.clear();
      _centroController.clear();
      _almacenController.clear();
      _ubicacionTecnicaController.clear();
      
      selectedClaseOrden = null;
      selectedPrioridad = null;
      selectedTipoPlan = null;
    });
  }

  @override
  void dispose() {
    _claseOrdenController.dispose();
    _prioridadController.dispose();
    _equipoController.dispose();
    _descripcionController.dispose();
    _operacionController.dispose();
    _centroCostoController.dispose();
    _cantidadPersonasController.dispose();
    _duracionController.dispose();
    _componentesController.dispose();
    _trabajoPlanController.dispose();
    _centroController.dispose();
    _almacenController.dispose();
    _tipoMaterialController.dispose();
    _ubicacionTecnicaController.dispose();
    super.dispose();
  }
} 