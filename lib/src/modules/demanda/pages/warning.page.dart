import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class AvisoPage extends StatefulWidget {
  const AvisoPage({super.key});

  @override
  AvisoPageState createState() => AvisoPageState();
}

class AvisoPageState extends State<AvisoPage> {
  List<Map<String, dynamic>> avisos = [];
  List<Map<String, dynamic>> filteredAvisos = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAvisos();
  }

  Future<void> _loadAvisos() async {
    try {
      final String response = await rootBundle.loadString('assets/data/avisos.json');
      final data = await json.decode(response);
      setState(() {
        avisos = List<Map<String, dynamic>>.from(data['avisos']);
        filteredAvisos = avisos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar datos de avisos: $e');
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

  void _filterAvisos(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredAvisos = avisos;
      } else {
        filteredAvisos = avisos.where((aviso) {
          return aviso.values.any((value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MainLayout(
        currentModule: 'demanda',
        customTitle: 'Avisos',
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
      currentModule: 'demanda',
      customTitle: 'Avisos',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            Container(
              margin: const EdgeInsets.only(bottom: 8),
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
                onChanged: _filterAvisos,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar avisos...'
                      : 'Buscar por número, equipo o descripción...',
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
                            _filterAvisos('');
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

            const SizedBox(height: 16),

            // Statistics cards
            _buildStatisticsCards(isMobile, isTablet),

            const SizedBox(height: 16),

            // Avisos list
            filteredAvisos.isEmpty
                ? _buildEmptyState()
                : (isTablet || !isMobile
                    ? _buildDesktopAvisosTable()
                    : _buildMobileAvisosList()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(bool isMobile, bool isTablet) {
    final stats = [
      {
        'title': 'Total Avisos',
        'value': avisos.length.toString(),
        'icon': Icons.assignment_outlined,
        'color': AppColors.primaryDarkTeal,
      },
      {
        'title': 'Prioridad Alta',
        'value': avisos.where((a) => a['averiaParada']?['prioridad'] == 'Alta').length.toString(),
        'icon': Icons.priority_high,
        'color': AppColors.secondaryCoralRed,
      },
      {
        'title': 'En Proceso',
        'value': avisos.where((a) => a['statusMensaje'] == 'En proceso').length.toString(),
        'icon': Icons.pending_actions,
        'color': AppColors.secondaryGoldenYellow,
      },
      {
        'title': 'Completados',
        'value': avisos.where((a) => a['statusMensaje'] == 'Completado').length.toString(),
        'icon': Icons.check_circle_outline,
        'color': AppColors.secondaryAquaGreen,
      },
    ];

    return ResponsiveRowColumn(
      layout: isMobile ? ResponsiveRowColumnType.COLUMN : ResponsiveRowColumnType.ROW,
      rowSpacing: 16,
      children: stats.map((stat) {
        return ResponsiveRowColumnItem(
          rowFlex: 1,
          child: Container(
            margin: EdgeInsets.only(bottom: isMobile ? 8 : 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutralMediumBorder.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (stat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    stat['icon'] as IconData,
                    color: stat['color'] as Color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stat['title'] as String,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.neutralTextGray.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        stat['value'] as String,
                        style: AppTextStyles.heading5.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
            color: AppColors.neutralTextGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay avisos disponibles'
                : 'No se encontraron avisos',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.neutralTextGray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileAvisosList() {
    return Column(
      children: filteredAvisos.map((aviso) => 
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildAvisoCard(aviso),
        ),
      ).toList(),
    );
  }

  Widget _buildAvisoCard(Map<String, dynamic> aviso) {
    final prioridad = aviso['averiaParada']?['prioridad'] ?? 'Media';
    final priorityColor = _getPriorityColor(prioridad);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutralMediumBorder.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMediumBorder.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showAvisoDetails(aviso),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarkTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      aviso['nroAviso'] ?? '',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryDarkTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      prioridad,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.5),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                aviso['descripcion'] ?? 'Sin descripción',
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.build_outlined,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      aviso['equipo'] ?? 'Sin equipo',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.neutralTextGray.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      aviso['ubicacionTecnica'] ?? 'Sin ubicación',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.neutralTextGray.withOpacity(0.7),
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
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    aviso['fecha'] ?? 'Sin fecha',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.neutralTextGray.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(aviso['statusMensaje']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      aviso['statusMensaje'] ?? 'Sin estado',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _getStatusColor(aviso['statusMensaje']),
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildDesktopAvisosTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMediumBorder.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkTeal.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_outlined,
                  color: AppColors.primaryDarkTeal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lista de Avisos',
                  style: AppTextStyles.heading6.copyWith(
                    color: AppColors.primaryDarkTeal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Nro Aviso')),
                  DataColumn(label: Text('Descripción')),
                  DataColumn(label: Text('Equipo')),
                  DataColumn(label: Text('Ubicación')),
                  DataColumn(label: Text('Prioridad')),
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Estado')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: filteredAvisos.map((aviso) {
                  final prioridad = aviso['averiaParada']?['prioridad'] ?? 'Media';
                  final priorityColor = _getPriorityColor(prioridad);
                  
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          aviso['nroAviso'] ?? '',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            aviso['descripcion'] ?? 'Sin descripción',
                            style: AppTextStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(aviso['equipo'] ?? '', style: AppTextStyles.bodySmall)),
                      DataCell(Text(aviso['ubicacionTecnica'] ?? '', style: AppTextStyles.bodySmall)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            prioridad,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: priorityColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(Text(aviso['fecha'] ?? '', style: AppTextStyles.bodySmall)),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(aviso['statusMensaje']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            aviso['statusMensaje'] ?? '',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: _getStatusColor(aviso['statusMensaje']),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined),
                          color: AppColors.primaryDarkTeal,
                          iconSize: 20,
                          onPressed: () => _showAvisoDetails(aviso),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String prioridad) {
    switch (prioridad.toLowerCase()) {
      case 'alta':
        return AppColors.secondaryCoralRed;
      case 'media':
        return AppColors.secondaryGoldenYellow;
      case 'baja':
        return AppColors.secondaryAquaGreen;
      default:
        return AppColors.neutralTextGray;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completado':
        return AppColors.secondaryAquaGreen;
      case 'en proceso':
        return AppColors.primaryMediumTeal;
      case 'pendiente':
        return AppColors.secondaryGoldenYellow;
      default:
        return AppColors.neutralTextGray;
    }
  }

  void _showAvisoDetails(Map<String, dynamic> aviso) {
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
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryDarkTeal,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.assignment_outlined,
                        color: AppColors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aviso ${aviso['nroAviso']}',
                              style: AppTextStyles.heading6.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              aviso['fecha'] ?? 'Sin fecha',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailSection('Información General', [
                          _buildDetailItem('Número de Aviso', aviso['nroAviso']),
                          _buildDetailItem('Orden', aviso['orden']),
                          _buildDetailItem('Estado', aviso['statusMensaje']),
                          _buildDetailItem('Descripción', aviso['descripcion']),
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('Datos Técnicos', [
                          _buildDetailItem('Ubicación Técnica', aviso['ubicacionTecnica']),
                          _buildDetailItem('Equipo', aviso['equipo']),
                          _buildDetailItem('Puesto de Trabajo', aviso['datosEmplazamiento']?['puestoTrabajo']),
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('Avería/Parada', [
                          _buildDetailItem('Inicio Avería', aviso['averiaParada']?['inicioAveria']),
                          _buildDetailItem('Fin Avería', aviso['averiaParada']?['finAveria']),
                          _buildDetailItem('Duración', aviso['averiaParada']?['duracionParada']),
                          _buildDetailItem('Prioridad', aviso['averiaParada']?['prioridad']),
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('Emplazamiento', [
                          _buildDetailItem('Centro', aviso['datosEmplazamiento']?['ceEmplazamiento']),
                          _buildDetailItem('Emplazamiento', aviso['datosEmplazamiento']?['emplazamiento']),
                          _buildDetailItem('Área de Empresa', aviso['datosEmplazamiento']?['areaEmpresa']),
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('Información Adicional', [
                          _buildDetailItem('Autor', aviso['autor']),
                          _buildDetailItem('Fecha de Cierre', aviso['fechaCierre']),
                          _buildDetailItem('Fecha Ref', aviso['fechaRef']),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading6.copyWith(
            color: AppColors.primaryDarkTeal,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.neutralTextGray.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}