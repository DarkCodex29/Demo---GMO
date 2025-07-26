import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class ExecutionPage extends StatefulWidget {
  const ExecutionPage({super.key});

  @override
  ExecutionPageState createState() => ExecutionPageState();
}

class ExecutionPageState extends State<ExecutionPage> {
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
            'progreso': _calculateProgress(orden),
            'prioridad':
                _getPriority(orden['Status del sistema']?.toString() ?? ''),
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

  double _calculateProgress(dynamic orden) {
    final status = orden['Status del sistema']?.toString() ?? '';
    if (status.contains('PREC')) return 1.0;
    if (status.contains('JBFI')) return 0.7;
    if (status.contains('NLIQ')) return 0.4;
    return 0.1;
  }

  String _getPriority(String status) {
    if (status.contains('PREC')) return 'Baja';
    if (status.contains('JBFI')) return 'Media';
    if (status.contains('NLIQ')) return 'Alta';
    return 'Media';
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
          (selectedStatus == 'En Progreso' &&
              orden['progreso'] < 1.0 &&
              orden['progreso'] > 0.0) ||
          (selectedStatus == 'Completadas' && orden['progreso'] == 1.0) ||
          (selectedStatus == 'Pendientes' && orden['progreso'] <= 0.1);

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return MainLayout(
      currentModule: 'ejecucion',
      customTitle: 'Ejecución de Trabajos',
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
                        prefixIcon: const Icon(
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
                        'En Progreso',
                        'Completadas',
                        'Pendientes'
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
                      : _buildExecutionList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final enProgreso =
        ordenes.where((o) => o['progreso'] < 1.0 && o['progreso'] > 0.0).length;
    final completadas = ordenes.where((o) => o['progreso'] == 1.0).length;
    final pendientes = ordenes.where((o) => o['progreso'] <= 0.1).length;

    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                'En Progreso', enProgreso, AppColors.primaryMediumTeal)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                'Completadas', completadas, AppColors.primaryMintGreen)),
        const SizedBox(width: 12),
        Expanded(
            child: _buildStatCard(
                'Pendientes', pendientes, AppColors.primaryDarkTeal)),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
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
            Icons.engineering_outlined,
            size: 64,
            color: AppColors.neutralTextGray,
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay trabajos en ejecución'
                : 'No se encontraron trabajos',
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.neutralTextGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionList() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 8,
      ),
      itemCount: filteredOrdenes.length,
      itemBuilder: (context, index) {
        final orden = filteredOrdenes[index];
        return _buildExecutionCard(orden);
      },
    );
  }

  Widget _buildExecutionCard(Map<String, dynamic> orden) {
    final progreso = orden['progreso'] as double;
    final prioridad = orden['prioridad'] as String;
    final priorityColor = _getPriorityColor(prioridad);

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
            // Header con orden y prioridad
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
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: priorityColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    prioridad,
                    style: AppTextStyles.caption.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Información del equipo
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

            // Ubicación
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

            // Barra de progreso
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progreso de Ejecución',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutralTextGray,
                      ),
                    ),
                    Text(
                      '${(progreso * 100).toInt()}%',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDarkTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progreso,
                  backgroundColor: AppColors.neutralLightBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progreso == 1.0
                        ? AppColors.primaryMintGreen
                        : AppColors.primaryDarkTeal,
                  ),
                  minHeight: 6,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showExecutionDetails(orden),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        progreso < 1.0 ? () => _updateProgress(orden) : null,
                    icon: Icon(
                      progreso == 1.0 ? Icons.check_circle : Icons.play_arrow,
                      size: 16,
                    ),
                    label: Text(
                      progreso == 1.0 ? 'Completado' : 'Actualizar',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: progreso == 1.0
                          ? AppColors.primaryMintGreen
                          : AppColors.primaryDarkTeal,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Alta':
        return AppColors.secondaryCoralRed;
      case 'Media':
        return AppColors.secondaryGoldenYellow;
      case 'Baja':
        return AppColors.primaryMintGreen;
      default:
        return AppColors.neutralTextGray;
    }
  }

  void _showExecutionDetails(Map<String, dynamic> orden) {
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
              'Detalles de Ejecución',
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
                  _buildDetailRow('Fecha', orden['fecha']),
                  _buildDetailRow('Hora Inicio', orden['horaInicioReal']),
                  _buildDetailRow('Hora Fin', orden['horaFinReal']),
                  _buildDetailRow('Estado', orden['statusMensaje']),
                  _buildDetailRow('Prioridad', orden['prioridad']),
                  _buildDetailRow('Progreso', '${(orden['progreso'] * 100).toInt()}%'),
                ],
              ),
            ),
          ],
        ),
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

  void _updateProgress(Map<String, dynamic> orden) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Actualizar Progreso',
          style: AppTextStyles.heading6.copyWith(
            color: AppColors.primaryDarkTeal,
          ),
        ),
        content: Text(
          '¿Desea marcar como completada la orden ${orden['nroOrden']}?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                orden['progreso'] = 1.0;
                _applyFilters();
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Orden ${orden['nroOrden']} marcada como completada'),
                  backgroundColor: AppColors.primaryMintGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDarkTeal,
            ),
            child: const Text('Completar'),
          ),
        ],
      ),
    );
  }
}
