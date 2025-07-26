import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class ClosingPage extends StatefulWidget {
  const ClosingPage({super.key});

  @override
  ClosingPageState createState() => ClosingPageState();
}

class ClosingPageState extends State<ClosingPage> {
  List<Map<String, dynamic>> ordenes = [];
  List<Map<String, dynamic>> filteredOrdenes = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedStatus = 'Todas';

  @override
  void initState() {
    super.initState();
    _loadOrdenes();
  }

  Future<void> _loadOrdenes() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/ordenes_pm.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        ordenes = data.map<Map<String, dynamic>>((orden) {
          return {
            'nroOrden': orden['Equipo']?.toString() ?? 'N/A',
            'fecha': _formatDateFromSAP(
                orden['Fecha inicio real']?.toString() ?? ''),
            'fechaFin': _formatDateFromSAP(
                orden['Fecha real de fin de la orden']?.toString() ?? ''),
            'textoBrave': orden['Texto breve']?.toString() ?? '',
            'statusMensaje': orden['Status del sistema']?.toString() ?? '',
            'equipo': orden['Equipo']?.toString() ?? '',
            'denominacionEquipo':
                orden['Denominación de objeto técnico']?.toString() ?? '',
            'ubicacionTecnica': orden['Ubicación técnica']?.toString() ?? '',
            'denominacionUbicacion':
                orden['Denominación de la ubicación técnica']?.toString() ?? '',
            'horaInicioReal': orden['Hora inicio real']?.toString() ?? '',
            'horaFinReal': orden['Fin real (hora)']?.toString() ?? '',
            'costePlan': orden['Suma de costes plan']?.toString() ?? '0',
            'costeReal': orden['Costes tot.reales']?.toString() ?? '0',
            'statusCierre': _getClosingStatus(orden),
            'requiereCierre': _requiresClosing(orden),
          };
        }).toList();
        filteredOrdenes = ordenes;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error al cargar órdenes: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar órdenes: ${e.toString()}'),
            backgroundColor: AppColors.secondaryCoralRed,
          ),
        );
      }
    }
  }

  String _formatDateFromSAP(String sapDate) {
    if (sapDate.isEmpty || sapDate == 'null') return '';
    try {
      String dateOnly = sapDate.trim().split(' ')[0];
      List<String> parts = dateOnly.split('-');
      if (parts.length == 3 && parts[0].length == 4) {
        return '${parts[2].padLeft(2, '0')}.${parts[1].padLeft(2, '0')}.${parts[0]}';
      }
    } catch (e) {
      debugPrint('Error parsing date: $sapDate');
    }
    return '';
  }

  String _getClosingStatus(dynamic orden) {
    final status = orden['Status del sistema']?.toString() ?? '';
    final fechaFin = orden['Fecha real de fin de la orden']?.toString() ?? '';

    if (status.contains('PREC') && fechaFin.isNotEmpty) return 'Cerrada';
    if (status.contains('JBFI') && fechaFin.isNotEmpty) {
      return 'Lista para Cierre';
    }
    if (status.contains('NLIQ')) return 'En Ejecución';
    return 'Pendiente';
  }

  bool _requiresClosing(dynamic orden) {
    final status = orden['Status del sistema']?.toString() ?? '';
    return status.contains('JBFI') ||
        (status.contains('PREC') &&
            orden['Fecha real de fin de la orden']?.toString().isEmpty == true);
  }

  void _filterOrdenes(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters();
    });
  }

  void _filterByStatus(String status) {
    setState(() {
      selectedStatus = status;
      _applyFilters();
    });
  }

  void _applyFilters() {
    filteredOrdenes = ordenes.where((orden) {
      final matchesSearch = searchQuery.isEmpty ||
          orden['nroOrden']
                  ?.toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ==
              true ||
          orden['textoBrave']
                  ?.toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ==
              true ||
          orden['equipo']
                  ?.toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ==
              true;

      final matchesStatus = selectedStatus == 'Todas' ||
          (selectedStatus == 'Pendientes Cierre' &&
              orden['requiereCierre'] == true) ||
          (selectedStatus == 'Cerradas' &&
              orden['statusCierre'] == 'Cerrada') ||
          (selectedStatus == 'En Ejecución' &&
              orden['statusCierre'] == 'En Ejecución');

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return MainLayout(
      currentModule: 'ejecucion',
      customTitle: 'Cierre de Órdenes',
      showBackButton: true,
      child: ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.COLUMN,
        children: [
          // Barra de búsqueda y filtros
          ResponsiveRowColumnItem(
            child: Container(
              margin: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                children: [
                  // Barra de búsqueda
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.neutralTextGray.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: _filterOrdenes,
                      decoration: InputDecoration(
                        hintText: 'Buscar por orden, descripción, equipo...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.primaryDarkTeal,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _filterOrdenes(''),
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
                  const SizedBox(height: 16),

                  // Filtros de estado
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'Todas',
                        'Pendientes Cierre',
                        'Cerradas',
                        'En Ejecución'
                      ]
                          .map((status) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(status),
                                  selected: selectedStatus == status,
                                  onSelected: (_) => _filterByStatus(status),
                                  selectedColor: AppColors.primaryDarkTeal
                                      .withOpacity(0.2),
                                  checkmarkColor: AppColors.primaryDarkTeal,
                                  labelStyle: TextStyle(
                                    color: selectedStatus == status
                                        ? AppColors.primaryDarkTeal
                                        : AppColors.neutralTextGray,
                                    fontWeight: selectedStatus == status
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),

                  // Resumen de estadísticas
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                ],
              ),
            ),
          ),

          // Lista de órdenes
          ResponsiveRowColumnItem(
            child: Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrdenes.isEmpty
                      ? _buildEmptyState()
                      : _buildClosingList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final pendientes = ordenes.where((o) => o['requiereCierre'] == true).length;
    final cerradas =
        ordenes.where((o) => o['statusCierre'] == 'Cerrada').length;
    final enEjecucion =
        ordenes.where((o) => o['statusCierre'] == 'En Ejecución').length;

    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                'Pendientes', pendientes, AppColors.secondaryGoldenYellow)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                'Cerradas', cerradas, AppColors.primaryMintGreen)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                'En Ejecución', enEjecucion, AppColors.primaryMediumTeal)),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: AppTextStyles.heading5.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
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
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.neutralTextGray,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay órdenes para cerrar'
                : 'No se encontraron órdenes',
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.neutralTextGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingList() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 8,
      ),
      itemCount: filteredOrdenes.length,
      itemBuilder: (context, index) {
        final orden = filteredOrdenes[index];
        return _buildClosingCard(orden);
      },
    );
  }

  Widget _buildClosingCard(Map<String, dynamic> orden) {
    final statusCierre = orden['statusCierre'] as String;
    final requiereCierre = orden['requiereCierre'] as bool;
    final statusColor = _getStatusColor(statusCierre);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralTextGray.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.neutralMediumBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con orden y estado
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Orden: ${orden['nroOrden']}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.primaryDarkTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        orden['textoBrave'] ?? 'Sin descripción',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutralTextGray,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(statusCierre),
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusCierre,
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Información del equipo y ubicación
            Row(
              children: [
                const Icon(Icons.settings,
                    size: 16, color: AppColors.neutralTextGray),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Equipo: ${orden['equipo']} - ${orden['denominacionEquipo']}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutralTextGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.neutralTextGray),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    orden['denominacionUbicacion'] ?? 'Sin ubicación',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.neutralTextGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Fechas y costos
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neutralLightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha Inicio',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutralTextGray,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              orden['fecha'] ?? 'N/A',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.neutralTextGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha Fin',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutralTextGray,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              orden['fechaFin']?.isNotEmpty == true
                                  ? orden['fechaFin']
                                  : 'Pendiente',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.neutralTextGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Costo Planificado',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutralTextGray,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'S/ ${_formatCost(orden['costePlan'])}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.neutralTextGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Costo Real',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w500,
                                color: AppColors.neutralTextGray,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'S/ ${_formatCost(orden['costeReal'])}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.neutralTextGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showClosingDetails(orden),
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: Text(
                      'Ver Detalles',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryDarkTeal,
                      side: const BorderSide(color: AppColors.primaryDarkTeal),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: requiereCierre && statusCierre != 'Cerrada'
                        ? () => _closeOrder(orden)
                        : null,
                    icon: Icon(
                      statusCierre == 'Cerrada'
                          ? Icons.check_circle
                          : Icons.close,
                      size: 16,
                    ),
                    label: Text(
                      statusCierre == 'Cerrada' ? 'Cerrada' : 'Cerrar Orden',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusCierre == 'Cerrada'
                          ? AppColors.primaryMintGreen
                          : requiereCierre
                              ? AppColors.primaryDarkTeal
                              : AppColors.neutralTextGray,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCost(dynamic cost) {
    if (cost == null || cost.toString().isEmpty || cost.toString() == '0') {
      return '0.00';
    }
    try {
      final double value = double.parse(cost.toString());
      return value.toStringAsFixed(2);
    } catch (e) {
      return '0.00';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Cerrada':
        return AppColors.primaryMintGreen;
      case 'Lista para Cierre':
        return AppColors.secondaryGoldenYellow;
      case 'En Ejecución':
        return AppColors.primaryMediumTeal;
      case 'Pendiente':
        return AppColors.neutralTextGray;
      default:
        return AppColors.neutralTextGray;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Cerrada':
        return Icons.check_circle;
      case 'Lista para Cierre':
        return Icons.pending_actions;
      case 'En Ejecución':
        return Icons.engineering;
      case 'Pendiente':
        return Icons.schedule;
      default:
        return Icons.help_outline;
    }
  }

  void _showClosingDetails(Map<String, dynamic> orden) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.neutralMediumBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Título
            Text(
              'Detalles de Cierre',
              style: AppTextStyles.heading5.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow('Número de Orden', orden['nroOrden']),
                  _buildDetailRow('Descripción', orden['textoBrave']),
                  _buildDetailRow('Equipo', '${orden['equipo']} - ${orden['denominacionEquipo']}'),
                  _buildDetailRow('Ubicación', orden['denominacionUbicacion']),
                  _buildDetailRow('Estado de Cierre', orden['statusCierre']),
                  _buildDetailRow('Fecha Inicio', orden['fecha']),
                  _buildDetailRow('Fecha Fin', orden['fechaFin']?.isNotEmpty == true ? orden['fechaFin'] : 'Pendiente'),
                  _buildDetailRow('Hora Inicio', orden['horaInicioReal']),
                  _buildDetailRow('Hora Fin', orden['horaFinReal']),
                  _buildDetailRow('Costo Planificado', 'S/ ${_formatCost(orden['costePlan'])}'),
                  _buildDetailRow('Costo Real', 'S/ ${_formatCost(orden['costeReal'])}'),
                  _buildDetailRow('Requiere Cierre', orden['requiereCierre'] ? 'Sí' : 'No'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClosingDetailsSheet(
      Map<String, dynamic> orden, ScrollController scrollController) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutralMediumBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Título
          Text(
            'Detalles de Cierre',
            style: AppTextStyles.heading5.copyWith(
              color: AppColors.primaryDarkTeal,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                _buildDetailRow('Número de Orden', orden['nroOrden']),
                _buildDetailRow('Descripción', orden['textoBrave']),
                _buildDetailRow('Equipo',
                    '${orden['equipo']} - ${orden['denominacionEquipo']}'),
                _buildDetailRow('Ubicación', orden['denominacionUbicacion']),
                _buildDetailRow('Estado de Cierre', orden['statusCierre']),
                _buildDetailRow('Fecha Inicio', orden['fecha']),
                _buildDetailRow(
                    'Fecha Fin',
                    orden['fechaFin']?.isNotEmpty == true
                        ? orden['fechaFin']
                        : 'Pendiente'),
                _buildDetailRow('Hora Inicio', orden['horaInicioReal']),
                _buildDetailRow('Hora Fin', orden['horaFinReal']),
                _buildDetailRow('Costo Planificado',
                    'S/ ${_formatCost(orden['costePlan'])}'),
                _buildDetailRow(
                    'Costo Real', 'S/ ${_formatCost(orden['costeReal'])}'),
                _buildDetailRow(
                    'Requiere Cierre', orden['requiereCierre'] ? 'Sí' : 'No'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: AppColors.neutralLightBackground)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.neutralTextGray,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value?.toString() ?? 'N/A',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutralTextGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _closeOrder(Map<String, dynamic> orden) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cerrar Orden',
          style: AppTextStyles.heading6.copyWith(
            color: AppColors.primaryDarkTeal,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¿Está seguro que desea cerrar la orden ${orden['nroOrden']}?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neutralLightBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen:',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutralTextGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Orden: ${orden['nroOrden']}',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '• Equipo: ${orden['equipo']}',
                    style: AppTextStyles.bodySmall,
                  ),
                  Text(
                    '• Estado actual: ${orden['statusCierre']}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                orden['statusCierre'] = 'Cerrada';
                orden['requiereCierre'] = false;
                orden['fechaFin'] = DateTime.now().toString().substring(0, 10);
                _applyFilters();
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Orden ${orden['nroOrden']} cerrada correctamente'),
                  backgroundColor: AppColors.primaryMintGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkTeal,
            ),
            child: const Text('Cerrar Orden'),
          ),
        ],
      ),
    );
  }
}
