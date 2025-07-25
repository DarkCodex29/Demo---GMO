import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:convert';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';

class UbtPage extends StatefulWidget {
  const UbtPage({super.key});

  @override
  UbtPageState createState() => UbtPageState();
}

class UbtPageState extends State<UbtPage> {
  String searchQuery = '';
  List<Map<String, dynamic>> ubts = [];
  List<Map<String, dynamic>> filteredUbts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/ubts.json');
      final List<dynamic> data = json.decode(response);

      if (data.isNotEmpty) {
        final datos = data[0]['datos'];
        setState(() {
          ubts = (datos['ubts'] as List).cast<Map<String, dynamic>>();
          filteredUbts = ubts;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar datos de UBTs: $e');
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

  void _filterUbts(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredUbts = ubts;
      } else {
        filteredUbts = ubts.where((ubt) {
          return ubt.values.any((value) =>
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
        customTitle: 'UBTs',
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
      customTitle: 'UBTs',
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
                onChanged: _filterUbts,
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
                      ? 'Buscar UBTs...'
                      : 'Buscar por código, nombre o categoría...',
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
                            _filterUbts('');
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
                    // Sección de UBTs
                    _buildUbtsCard(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUbtsCard() {
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
                  child: const Icon(Icons.work_outline, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Unidades Básicas de Trabajo (UBTs)',
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
            child: filteredUbts.isEmpty
                ? _buildEmptyState()
                : ResponsiveBreakpoints.of(context).isMobile
                    ? _buildMobileUbtsList()
                    : _buildDesktopUbtsTable(),
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
            Icons.work_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay UBTs disponibles'
                : 'No se encontraron UBTs',
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

  Widget _buildMobileUbtsList() {
    return Column(
      children: filteredUbts.map((ubt) => _buildUbtItemCard(ubt)).toList(),
    );
  }

  Widget _buildUbtItemCard(Map<String, dynamic> ubt) {
    final statusColor = _getStatusColor(ubt['estado']);

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
                        ubt['codigo'],
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
                        ubt['nombre'],
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
                  ubt['estado'],
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
            ubt['descripcion'],
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Tiempo estimado', ubt['tiempoEstimado']),
          _buildDetailRow('Recursos', ubt['recursos']),
          _buildDetailRow('Categoría', ubt['categoria']),
          _buildDetailRow('Frecuencia', ubt['frecuencia']),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildDesktopUbtsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Código')),
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Descripción')),
          DataColumn(label: Text('Tiempo estimado')),
          DataColumn(label: Text('Recursos')),
          DataColumn(label: Text('Categoría')),
          DataColumn(label: Text('Frecuencia')),
          DataColumn(label: Text('Estado')),
        ],
        rows: filteredUbts.map((ubt) {
          final statusColor = _getStatusColor(ubt['estado']);
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
                    ubt['codigo'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              DataCell(Text(ubt['nombre'])),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    ubt['descripcion'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(Text(ubt['tiempoEstimado'])),
              DataCell(
                SizedBox(
                  width: 150,
                  child: Text(
                    ubt['recursos'],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ),
              DataCell(Text(ubt['categoria'])),
              DataCell(Text(ubt['frecuencia'])),
              DataCell(
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ubt['estado'],
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
      case 'en revisión':
        return AppColors.secondaryGoldenYellow;
      case 'inactivo':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
