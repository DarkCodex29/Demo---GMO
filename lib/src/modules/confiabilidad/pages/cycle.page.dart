import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:convert';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';

class CyclePage extends StatefulWidget {
  const CyclePage({super.key});

  @override
  CyclePageState createState() => CyclePageState();
}

class CyclePageState extends State<CyclePage> {
  String searchQuery = '';
  List<Map<String, dynamic>> ciclos = [];
  List<Map<String, dynamic>> filteredCiclos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/ciclos_mantenimiento.json');
      final List<dynamic> data = json.decode(response);

      if (data.isNotEmpty) {
        final datos = data[0]['datos'];
        setState(() {
          ciclos = (datos['ciclos'] as List).cast<Map<String, dynamic>>();
          filteredCiclos = ciclos;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar datos de ciclos: $e');
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
            backgroundColor: AppColors.secondaryCoralRed,
          ),
        );
      }
    }
  }

  void _filterCiclos(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredCiclos = ciclos;
      } else {
        filteredCiclos = ciclos.where((ciclo) {
          return ciclo.values.any((value) =>
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
        customTitle: 'Ciclos de Mantenimiento',
        showBackButton: true,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryDarkTeal,
          ),
        ),
      );
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return MainLayout(
      currentModule: 'confiabilidad',
      customTitle: 'Ciclos de Mantenimiento',
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
                onChanged: _filterCiclos,
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
                      ? 'Buscar ciclos...'
                      : 'Buscar por tipo, estado o responsable...',
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
                            _filterCiclos('');
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
                    // Sección de Ciclos
                    _buildCiclosCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCiclosCard() {
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
          filteredCiclos.isEmpty
              ? _buildEmptyState()
              : ResponsiveBreakpoints.of(context).isMobile
                  ? _buildMobileCiclosList()
                  : _buildDesktopCiclosTable(),
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
            Icons.refresh_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay ciclos disponibles'
                : 'No se encontraron ciclos',
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

  Widget _buildMobileCiclosList() {
    return Column(
      children:
          filteredCiclos.map((ciclo) => _buildCicloItemCard(ciclo)).toList(),
    );
  }

  Widget _buildCicloItemCard(Map<String, dynamic> ciclo) {
    final statusColor = _getStatusColor(ciclo['estado']);

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
                  ciclo['tipo'],
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
                  ciclo['estado'],
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
          Text(
            ciclo['descripcion'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Duración', ciclo['duracion']),
          _buildDetailRow('Última ejecución', ciclo['ultimaEjecucion']),
          _buildDetailRow('Próxima ejecución', ciclo['proximaEjecucion']),
          _buildDetailRow('Frecuencia', ciclo['frecuencia']),
          _buildDetailRow('Responsable', ciclo['responsable']),
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
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopCiclosTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Tipo')),
          DataColumn(label: Text('Descripción')),
          DataColumn(label: Text('Duración')),
          DataColumn(label: Text('Última ejecución')),
          DataColumn(label: Text('Próxima ejecución')),
          DataColumn(label: Text('Frecuencia')),
          DataColumn(label: Text('Responsable')),
          DataColumn(label: Text('Estado')),
        ],
        rows: filteredCiclos.map((ciclo) {
          final statusColor = _getStatusColor(ciclo['estado']);
          return DataRow(
            cells: [
              DataCell(Text(ciclo['tipo'])),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    ciclo['descripcion'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(Text(ciclo['duracion'])),
              DataCell(Text(ciclo['ultimaEjecucion'])),
              DataCell(Text(ciclo['proximaEjecucion'])),
              DataCell(Text(ciclo['frecuencia'])),
              DataCell(Text(ciclo['responsable'])),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ciclo['estado'],
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
      case 'activo':
        return Colors.green;
      case 'en progreso':
        return Colors.blue;
      case 'programado':
        return AppColors.secondaryGoldenYellow;
      case 'inactivo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
