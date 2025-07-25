import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class CaracteristicsPage extends StatefulWidget {
  const CaracteristicsPage({super.key});

  @override
  CaracteristicsPageState createState() => CaracteristicsPageState();
}

class CaracteristicsPageState extends State<CaracteristicsPage> {
  List<Map<String, dynamic>> capacidades = [];
  List<Map<String, dynamic>> filteredCapacidades = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCapacidades();
  }

  Future<void> _loadCapacidades() async {
    try {
      final String response = await rootBundle.loadString('assets/data/capacidades.json');
      final List<dynamic> data = await json.decode(response);
      if (data.isNotEmpty && data[0]['datos'] != null && data[0]['datos']['capacidades'] != null) {
        setState(() {
          capacidades = List<Map<String, dynamic>>.from(data[0]['datos']['capacidades']);
          filteredCapacidades = capacidades;
          isLoading = false;
        });
      } else {
        setState(() {
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
                const Icon(Icons.error_outline, color: AppColors.white),
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
      return const MainLayout(
        currentModule: 'confiabilidad',
        customTitle: 'Características',
        showBackButton: true,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryDarkTeal,
          ),
        ),
      );
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return MainLayout(
      currentModule: 'confiabilidad',
      customTitle: 'Características',
      showBackButton: true,
      child: ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.COLUMN,
        children: [
          // Search bar
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
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neutralMediumBorder.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _filterCapacidades,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar capacidades...'
                      : 'Buscar por puesto de trabajo o centro...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutralTextGray.withOpacity(0.6),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primaryDarkTeal,
                    size: 24,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.neutralTextGray,
                          ),
                          onPressed: () {
                            _filterCapacidades('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          // Capacidades list
          ResponsiveRowColumnItem(
            child: Expanded(
              child: filteredCapacidades.isEmpty
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
                          ? _buildDesktopCapacidadesTable()
                          : _buildMobileCapacidadesList(),
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
            Icons.assessment_outlined,
            size: 64,
            color: AppColors.neutralTextGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay capacidades disponibles'
                : 'No se encontraron capacidades',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.neutralTextGray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCapacidadesList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filteredCapacidades.length,
      itemBuilder: (context, index) {
        return _buildCapacidadCard(filteredCapacidades[index]);
      },
    );
  }

  Widget _buildDesktopCapacidadesTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutralMediumBorder.withOpacity(0.3)),
        ),
        columnSpacing: ResponsiveValue<double>(
          context,
          conditionalValues: [
            const Condition.smallerThan(name: DESKTOP, value: 20.0),
            const Condition.largerThan(name: TABLET, value: 30.0),
          ],
        ).value,
        dataRowMaxHeight: 60,
        headingRowColor: WidgetStateProperty.all(AppColors.neutralLightBackground),
        columns: [
          DataColumn(
            label: Text(
              'Puesto',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Centro',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Semana',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Necesidad',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Oferta',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Utilización',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Estado',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
        ],
        rows: filteredCapacidades.map((capacidad) {
          return DataRow(
            onSelectChanged: (selected) {
              if (selected == true) {
                _showCapacidadDetails(capacidad);
              }
            },
            cells: [
              DataCell(
                Text(
                  capacidad['puestoTrabajo'] ?? 'N/A',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Text(
                  capacidad['centro'] ?? 'N/A',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  capacidad['semanaNro'] ?? 'N/A',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  capacidad['necesidad'] ?? 'N/A',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  capacidad['oferta'] ?? 'N/A',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  capacidad['utilizacion'] ?? 'N/A',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(capacidad['estado']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getEstadoColor(capacidad['estado']).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    capacidad['estado'] ?? 'N/A',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _getEstadoColor(capacidad['estado']),
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

  Widget _buildCapacidadCard(Map<String, dynamic> capacidad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutralMediumBorder.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMediumBorder.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showCapacidadDetails(capacidad),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ResponsiveRowColumn(
            layout: ResponsiveRowColumnType.ROW,
            children: [
              // Icon and indicator
              ResponsiveRowColumnItem(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getEstadoColor(capacidad['estado']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.assessment,
                    color: _getEstadoColor(capacidad['estado']),
                    size: 20,
                  ),
                ),
              ),
              const ResponsiveRowColumnItem(
                child: SizedBox(width: 12),
              ),
              // Information
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
                              capacidad['puestoTrabajo'] ?? 'Sin puesto',
                              style: AppTextStyles.heading6,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getEstadoColor(capacidad['estado']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getEstadoColor(capacidad['estado']).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              capacidad['estado'] ?? 'N/A',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _getEstadoColor(capacidad['estado']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Centro', capacidad['centro'] ?? 'N/A'),
                      _buildDetailRow('Semana', capacidad['semanaNro'] ?? 'N/A'),
                      _buildDetailRow('Necesidad', capacidad['necesidad'] ?? 'N/A'),
                      _buildDetailRow('Oferta', capacidad['oferta'] ?? 'N/A'),
                      _buildDetailRow('Utilización', capacidad['utilizacion'] ?? 'N/A'),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.neutralTextGray.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'crítico':
        return AppColors.secondaryCoralRed;
      case 'normal':
        return AppColors.primaryMintGreen;
      case 'advertencia':
        return AppColors.secondaryGoldenYellow;
      default:
        return AppColors.neutralTextGray;
    }
  }

  void _showCapacidadDetails(Map<String, dynamic> capacidad) {
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getEstadoColor(capacidad['estado']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.assessment,
                          color: _getEstadoColor(capacidad['estado']),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Capacidad: ${capacidad['puestoTrabajo'] ?? 'Sin puesto'}',
                          style: AppTextStyles.heading5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCapacidadSection('Información General', {
                    'puesto_trabajo': capacidad['puestoTrabajo'],
                    'centro': capacidad['centro'],
                    'semana_numero': capacidad['semanaNro'],
                    'estado': capacidad['estado'],
                  }),
                  _buildCapacidadSection('Capacidad y Utilización', {
                    'necesidad': capacidad['necesidad'],
                    'oferta': capacidad['oferta'],
                    'utilizacion': capacidad['utilizacion'],
                    'deficit': capacidad['deficit'],
                    'exceso': capacidad['exceso'],
                  }),
                  if (capacidad['descripcion'] != null) ...[
                    _buildCapacidadSection('Descripción', {
                      'descripcion': capacidad['descripcion'],
                    }),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCapacidadSection(String title, Map<String, dynamic> data) {
    // Filter out null values
    final filteredData = Map<String, dynamic>.from(data)
      ..removeWhere((key, value) => value == null);
    
    if (filteredData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading6.copyWith(
            color: AppColors.primaryDarkTeal,
          ),
        ),
        const SizedBox(height: 8),
        ...filteredData.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      _formatFieldName(entry.key),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.neutralTextGray.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value.toString(),
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
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
