import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  EquipmentPageState createState() => EquipmentPageState();
}

class EquipmentPageState extends State<EquipmentPage> {
  List<Map<String, dynamic>> equipos = [];
  List<Map<String, dynamic>> filteredEquipos = [];
  bool isLoading = true;
  String searchQuery = '';
  Map<String, dynamic>? selectedEquipment;

  @override
  void initState() {
    super.initState();
    _loadEquipos();
  }

  Future<void> _loadEquipos() async {
    try {
      final String response = await rootBundle.loadString('assets/data/equipament.json');
      final data = await json.decode(response);
      setState(() {
        equipos = (data['equipos'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        filteredEquipos = equipos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar datos de equipos: $e');
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

  void _filterEquipos(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredEquipos = equipos;
      } else {
        filteredEquipos = equipos.where((equipo) {
          return equipo.values.any((value) => 
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
          title: const Text('Gestión de Equipos'),
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
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Gestión de Equipos',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                onChanged: _filterEquipos,
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
                      ? 'Buscar equipos...' 
                      : 'Buscar por código, descripción o ubicación...',
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
                            _filterEquipos('');
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

          // Lista de equipos responsiva
          ResponsiveRowColumnItem(
            child: Expanded(
              child: filteredEquipos.isEmpty
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
                          ? _buildDesktopEquipoTable()
                          : _buildMobileEquipoList(),
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
            Icons.precision_manufacturing_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay equipos disponibles'
                : 'No se encontraron equipos',
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

  Widget _buildMobileEquipoList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filteredEquipos.length,
      itemBuilder: (context, index) {
        return _buildEquipoCard(filteredEquipos[index]);
      },
    );
  }

  Widget _buildEquipoCard(Map<String, dynamic> equipo) {
    final statusColor = _getStatusColor(equipo['general']['estado']);
    final criticidadColor = _getCriticidadColor(equipo['general']['criticidad']);
    
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
        onTap: () => _showEquipmentDetails(equipo),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ResponsiveRowColumn(
            layout: ResponsiveRowColumnType.ROW,
            children: [
              // Ícono del equipo
              ResponsiveRowColumnItem(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getEquipmentIcon(equipo['general']['tipo_equipo']),
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
                               equipo['equipo'],
                               style: const TextStyle(
                                 fontSize: 15,
                                 fontWeight: FontWeight.w600,
                                 color: Colors.black87,
                               ),
                             ),
                           ),
                           Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                 decoration: BoxDecoration(
                                   color: criticidadColor,
                                   borderRadius: BorderRadius.circular(4),
                                 ),
                                 child: Text(
                                   equipo['general']['criticidad'],
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
                                   equipo['general']['estado'],
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
                         equipo['descripcion'],
                         style: TextStyle(
                           fontSize: 12,
                           color: Colors.grey[700],
                           fontStyle: FontStyle.italic,
                         ),
                       ),
                       const SizedBox(height: 8),
                       _buildDetailRow('Tipo', equipo['general']['tipo_equipo']),
                       _buildDetailRow('Ubicación', equipo['emplazamiento']['ubicacion_tecnica']),
                       _buildDetailRow('Centro', equipo['organizacion']['centro_costo']),
                       _buildDetailRow('Responsable', equipo['organizacion']['responsable']),
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

  Widget _buildDesktopEquipoTable() {
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
              'Equipo',
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
              'Tipo',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Ubicación Técnica',
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
              'Estado',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          DataColumn(
            label: Text(
              'Criticidad',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
        rows: filteredEquipos.map((equipo) {
          final statusColor = _getStatusColor(equipo['general']['estado']);
          final criticidadColor = _getCriticidadColor(equipo['general']['criticidad']);
          
          return DataRow(
            onSelectChanged: (selected) {
              if (selected == true) {
                _showEquipmentDetails(equipo);
              }
            },
            cells: [
              DataCell(
                Row(
                  children: [
                    Icon(
                      _getEquipmentIcon(equipo['general']['tipo_equipo']),
                      color: Colors.orange.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      equipo['equipo'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    equipo['descripcion'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              DataCell(
                Text(
                  equipo['general']['tipo_equipo'],
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                Text(
                  equipo['emplazamiento']['ubicacion_tecnica'],
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              DataCell(
                Text(
                  equipo['organizacion']['centro_costo'],
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              DataCell(
                Text(
                  equipo['organizacion']['responsable'],
                  style: const TextStyle(fontSize: 12),
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
                    equipo['general']['estado'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: criticidadColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    equipo['general']['criticidad'],
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

  IconData _getEquipmentIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'máquina':
      case 'maquina':
        return Icons.precision_manufacturing;
      case 'motor':
        return Icons.electric_bolt;
      case 'válvula':
      case 'valvula':
        return Icons.water_drop;
      case 'compresor':
        return Icons.air;
      case 'secador':
        return Icons.dry;
      default:
        return Icons.build;
    }
  }

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'operativo':
        return Colors.green;
      case 'en mantenimiento':
        return Colors.orange;
      case 'fuera de servicio':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getCriticidadColor(String criticidad) {
    switch (criticidad.toLowerCase()) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showEquipmentDetails(Map<String, dynamic> equipo) {
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
                const Condition.largerThan(name: MOBILE, value: 500.0),
              ],
            ).value,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _getEquipmentIcon(equipo['general']['tipo_equipo']),
                      color: Colors.orange.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Equipo ${equipo['equipo']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
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
                _buildDetailSection('General', equipo['general']),
                _buildDetailSection('Emplazamiento', equipo['emplazamiento']),
                _buildDetailSection('Organización', equipo['organizacion']),
                _buildDetailSection('Estructura', equipo['estructura']),
                _buildDetailSection('Garantías', equipo['garantias']),
              ],
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
