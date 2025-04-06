import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({super.key});

  @override
  MaterialsPageState createState() => MaterialsPageState();
}

class MaterialsPageState extends State<MaterialsPage> {
  List<Map<String, dynamic>> equipos = [];
  List<Map<String, dynamic>> filteredMaterials = [];
  String selectedEquipo = '';
  String selectedCentro = '';
  String selectedUtilizacion = '';

  @override
  void initState() {
    super.initState();
    _loadEquipos();
  }

  Future<void> _loadEquipos() async {
    final String response =
        await rootBundle.loadString('assets/data/equipament.json');
    final data = await json.decode(response);

    setState(() {
      equipos = List<Map<String, dynamic>>.from(data['equipos']);
    });
  }

  void _filterMaterials() {
    setState(() {
      filteredMaterials = equipos.where((equipo) {
        final matchEquipo = equipo['equipo'] == selectedEquipo;
        final matchCentro = equipo['emplazamiento']['centro'] == selectedCentro;
        final matchUtilizacion =
            equipo['emplazamiento']['utilizacion'] == selectedUtilizacion;
        return matchEquipo &&
            matchCentro &&
            matchUtilizacion &&
            equipo.containsKey('materiales');
      }).toList();

      if (filteredMaterials.isEmpty) {
        _showNoMaterialsFoundModal();
      }
    });
  }

  void _showNoMaterialsFoundModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sin Resultados'),
          content: const Text(
              'No se encontraron materiales para el equipo seleccionado.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Materiales'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchForm(),
            const SizedBox(height: 16.0),
            Expanded(
              child: filteredMaterials.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron materiales',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredMaterials.length,
                      itemBuilder: (context, index) {
                        final equipo = filteredMaterials[index];
                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            tilePadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            expandedAlignment: Alignment.centerLeft,
                            title: Text(
                              'Equipo: ${equipo['equipo']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.orange,
                              ),
                            ),
                            subtitle: Text(
                              'Descripción: ${equipo['descripcion']} \nCentro: ${equipo['emplazamiento']['centro']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            children: List.generate(
                              equipo['materiales'].length,
                              (i) {
                                final material = equipo['materiales'][i];
                                return _buildExpandedMaterialTile(
                                  material['nombre_material'],
                                  material['codigo_material'],
                                  'Cantidad: ${material['cantidad']} ${material['unidad']}, Válido: ${material['valido_desde']} - ${material['valido_hasta']}',
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) {
            selectedEquipo = value;
          },
          decoration: InputDecoration(
            labelText: 'Equipo',
            labelStyle: const TextStyle(color: Colors.orange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          onChanged: (value) {
            selectedCentro = value;
          },
          decoration: InputDecoration(
            labelText: 'Centro',
            labelStyle: const TextStyle(color: Colors.orange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          onChanged: (value) {
            selectedUtilizacion = value;
          },
          decoration: InputDecoration(
            labelText: 'Utilización',
            labelStyle: const TextStyle(color: Colors.orange),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _filterMaterials,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Buscar',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedMaterialTile(
      String name, String code, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: const Icon(
            Icons.inventory_2,
            color: Colors.orange,
          ),
          title: Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.orange,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Código: $code'),
              Text('Descripción: $description'),
            ],
          ),
        ),
      ),
    );
  }
}
