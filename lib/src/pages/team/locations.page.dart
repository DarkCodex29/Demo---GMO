import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';

class LocationsPage extends StatefulWidget {
  const LocationsPage({super.key});

  @override
  LocationsPageState createState() => LocationsPageState();
}

class LocationsPageState extends State<LocationsPage> {
  List<Map<String, dynamic>> ubicaciones = [];
  List<Map<String, dynamic>> filteredUbicaciones = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUbicaciones();
  }

  Future<void> _loadUbicaciones() async {
    try {
      final String response = await rootBundle.loadString('assets/data/locations.json');
      final data = await json.decode(response);
      setState(() {
        ubicaciones = (data['ubicaciones'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        filteredUbicaciones = ubicaciones;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar datos de ubicaciones: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline),
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

  void _filterUbicaciones(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredUbicaciones = ubicaciones;
      } else {
        filteredUbicaciones = ubicaciones.where((ubicacion) {
          return ubicacion.values.any((value) => 
              value.toString().toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        
        appBar: AppBar(
          title: const Text('Gestión de Ubicaciones'),
          
          
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
      );
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    
    return Scaffold(
      
      appBar: AppBar(
        title: Text(
          'Ubicaciones Técnicas',
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
        
        elevation: 2,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
                onChanged: _filterUbicaciones,
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
                      ? 'Buscar ubicaciones...' 
                      : 'Buscar por código, descripción o edificio...',
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
                  prefixIcon: const Icon(Icons.search, size: 24),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _filterUbicaciones('');
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

          // Lista de ubicaciones responsiva
          ResponsiveRowColumnItem(
            child: Expanded(
              child: filteredUbicaciones.isEmpty
                  ? _buildEmptyState()
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveValue<double>(
                          context,
                          conditionalValues: [
                            const Condition.smallerThan(name: TABLET, value: 12.0),
                            const Condition.largerThan(name: MOBILE, value: 16.0),
                          ],
                        ).value,
                      ),
                      child: isTablet || !isMobile
                          ? _buildDesktopUbicacionTable()
                          : _buildMobileUbicacionList(),
                    ),
            ),
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
            Icons.location_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay ubicaciones disponibles'
                : 'No se encontraron ubicaciones',
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

  Widget _buildMobileUbicacionList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filteredUbicaciones.length,
      itemBuilder: (context, index) {
        return _buildUbicacionCard(filteredUbicaciones[index]);
      },
    );
  }

  Widget _buildUbicacionCard(Map<String, dynamic> ubicacion) {
    final statusColor = _getStatusColor(ubicacion['general']['estado']);
    final categoriaColor = _getCategoriaColor(ubicacion['general']['categoria']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLocationDetails(ubicacion),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ResponsiveRowColumn(
            layout: ResponsiveRowColumnType.ROW,
            children: [
              // Ícono de la ubicación
              ResponsiveRowColumnItem(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getLocationIcon(ubicacion['general']['categoria']),
                    color: Colors.orange.shade700,
                    size: 20,
                  ),
                ),
              ),
              const ResponsiveRowColumnItem(
                child: SizedBox(width: 12),
              ),
              // Información principal
              ResponsiveRowColumnItem(
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ubicacion['ubicacion'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: categoriaColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ubicacion['general']['categoria'].toString().split(' ').first,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  ubicacion['general']['estado'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ubicacion['descripcion'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Edificio', ubicacion['emplazamiento']['edificio']),
                      _buildDetailRow('Piso', ubicacion['emplazamiento']['piso']),
                      _buildDetailRow('Centro', ubicacion['organizacion']['centro_costo']),
                      _buildDetailRow('Responsable', ubicacion['general']['responsable']),
                      if (ubicacion['equipos_asignados'] != null && ubicacion['equipos_asignados'].isNotEmpty)
                        _buildDetailRow('Equipos', '${ubicacion['equipos_asignados'].length} asignados'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopUbicacionTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        columnSpacing: ResponsiveValue<double>(
          context,
          conditionalValues: [
            const Condition.smallerThan(name: DESKTOP, value: 20.0),
            const Condition.largerThan(name: TABLET, value: 30.0),
          ],
        ).value,
        dataRowMaxHeight: 60,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
        columns: const [
          DataColumn(
            label: Text(
              'Ubicación Técnica',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Categoría',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Edificio',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Centro Costo',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Responsable',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Equipos',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Estado',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        rows: filteredUbicaciones.map((ubicacion) {
          final statusColor = _getStatusColor(ubicacion['general']['estado']);
          final categoriaColor = _getCategoriaColor(ubicacion['general']['categoria']);
          
          return DataRow(
            onSelectChanged: (selected) {
              if (selected == true) {
                _showLocationDetails(ubicacion);
              }
            },
            cells: [
              DataCell(
                Row(
                  children: [
                    Icon(
                      _getLocationIcon(ubicacion['general']['categoria']),
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ubicacion['ubicacion'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    ubicacion['descripcion'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: categoriaColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ubicacion['general']['categoria'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  ubicacion['emplazamiento']['edificio'],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  ubicacion['organizacion']['centro_costo'],
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              DataCell(
                Text(
                  ubicacion['general']['responsable'],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  ubicacion['equipos_asignados'] != null ? 
                    '${ubicacion['equipos_asignados'].length}' : '0',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ubicacion['general']['estado'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
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

  IconData _getLocationIcon(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'sala de equipos':
        return Icons.room_preferences;
      case 'área de proceso':
        return Icons.factory;
      case 'área de trabajo':
        return Icons.work;
      case 'área de almacén':
        return Icons.warehouse;
      default:
        return Icons.location_on;
    }
  }

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return Colors.green;
      case 'en mantenimiento':
        return Colors.orange;
      case 'inactivo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getCategoriaColor(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'sala de equipos':
        return Colors.blue;
      case 'área de proceso':
        return Colors.purple;
      case 'área de trabajo':
        return Colors.teal;
      case 'área de almacén':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  void _showLocationDetails(Map<String, dynamic> ubicacion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: ResponsiveValue<double>(
              context,
              conditionalValues: [
                const Condition.smallerThan(name: TABLET, value: 350.0),
                const Condition.largerThan(name: MOBILE, value: 600.0),
              ],
            ).value,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getLocationIcon(ubicacion['general']['categoria']),
                        color: Colors.orange.shade600,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ubicacion['ubicacion'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailSection('General', ubicacion['general']),
                  _buildDetailSection('Organización', ubicacion['organizacion']),
                  _buildDetailSection('Emplazamiento', ubicacion['emplazamiento']),
                  _buildDetailSection('Estructura', ubicacion['estructura']),
                  _buildDetailSection('Características', ubicacion['caracteristicas']),
                  if (ubicacion['equipos_asignados'] != null && ubicacion['equipos_asignados'].isNotEmpty)
                    _buildEquiposSection(ubicacion['equipos_asignados']),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.orange.shade700,
          ),
        ),
        const SizedBox(height: 8),
        ...data.entries.map((entry) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(
                  _formatFieldName(entry.key),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        )),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEquiposSection(List<dynamic> equipos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipos Asignados',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.orange.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: equipos.map((equipo) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              equipo.toString(),
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }
}
