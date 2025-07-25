import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:convert';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';

class InstructionPage extends StatefulWidget {
  const InstructionPage({super.key});

  @override
  InstructionPageState createState() => InstructionPageState();
}

class InstructionPageState extends State<InstructionPage> {
  String searchQuery = '';
  List<Map<String, dynamic>> instrucciones = [];
  List<Map<String, dynamic>> filteredInstrucciones = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/instrucciones_trabajo.json');
      final List<dynamic> data = json.decode(response);

      if (data.isNotEmpty) {
        final datos = data[0]['datos'];
        setState(() {
          instrucciones =
              (datos['instrucciones'] as List).cast<Map<String, dynamic>>();
          filteredInstrucciones = instrucciones;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar datos de instrucciones: $e');
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

  void _filterInstrucciones(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredInstrucciones = instrucciones;
      } else {
        filteredInstrucciones = instrucciones.where((instruccion) {
          return instruccion.values.any((value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MainLayout(
        currentModule: 'confiabilidad',
        customTitle: 'Instrucciones de Trabajo',
        showBackButton: true,
        child: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.secondaryGoldenYellow),
          ),
        ),
      );
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return MainLayout(
      currentModule: 'confiabilidad',
      customTitle: 'Instrucciones de Trabajo',
      showBackButton: true,
      child: ResponsiveRowColumn(
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
                onChanged: _filterInstrucciones,
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
                      ? 'Buscar instrucciones...'
                      : 'Buscar por código, título o categoría...',
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
                            _filterInstrucciones('');
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
                    // Sección de Instrucciones
                    _buildInstruccionesCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruccionesCard() {
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
            decoration: const BoxDecoration(
              color: AppColors.secondaryGoldenYellow,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryGoldenYellow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.assignment, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Instrucciones de Trabajo',
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
            child: filteredInstrucciones.isEmpty
                ? _buildEmptyState()
                : ResponsiveBreakpoints.of(context).isMobile
                    ? _buildMobileInstruccionesList()
                    : _buildDesktopInstruccionesTable(),
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
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay instrucciones disponibles'
                : 'No se encontraron instrucciones',
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

  Widget _buildMobileInstruccionesList() {
    return Column(
      children: filteredInstrucciones
          .map((instruccion) => _buildInstruccionItemCard(instruccion))
          .toList(),
    );
  }

  Widget _buildInstruccionItemCard(Map<String, dynamic> instruccion) {
    final statusColor = _getStatusColor(instruccion['estado']);

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
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        instruccion['codigo'],
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        instruccion['titulo'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  instruccion['estado'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            instruccion['descripcion'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Categoría', instruccion['categoria']),
          _buildDetailRow('Responsable', instruccion['responsable']),
          _buildDetailRow('Duración', instruccion['duracion']),
          _buildDetailRow('Frecuencia', instruccion['frecuencia']),
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

  Widget _buildDesktopInstruccionesTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Código')),
          DataColumn(label: Text('Título')),
          DataColumn(label: Text('Descripción')),
          DataColumn(label: Text('Categoría')),
          DataColumn(label: Text('Responsable')),
          DataColumn(label: Text('Duración')),
          DataColumn(label: Text('Frecuencia')),
          DataColumn(label: Text('Estado')),
        ],
        rows: filteredInstrucciones.map((instruccion) {
          final statusColor = _getStatusColor(instruccion['estado']);
          return DataRow(
            cells: [
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    instruccion['codigo'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(Text(instruccion['titulo'])),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    instruccion['descripcion'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(Text(instruccion['categoria'])),
              DataCell(Text(instruccion['responsable'])),
              DataCell(Text(instruccion['duracion'])),
              DataCell(Text(instruccion['frecuencia'])),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    instruccion['estado'],
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

  Color _getStatusColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'vigente':
        return Colors.green;
      case 'en revisión':
        return AppColors.secondaryGoldenYellow;
      case 'obsoleto':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
