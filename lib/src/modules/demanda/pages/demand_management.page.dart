import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class DemandManagementPage extends StatefulWidget {
  const DemandManagementPage({super.key});

  @override
  DemandManagementPageState createState() => DemandManagementPageState();
}

class DemandManagementPageState extends State<DemandManagementPage> {
  List<Map<String, dynamic>> demandas = [];
  List<Map<String, dynamic>> filteredDemandas = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDemandas();
  }

  Future<void> _loadDemandas() async {
    try {
      final String response = await rootBundle.loadString('assets/data/demandas.json');
      final data = await json.decode(response);
      setState(() {
        demandas = List<Map<String, dynamic>>.from(data['demandas'] ?? []);
        filteredDemandas = demandas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar datos de demandas: $e');
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
            backgroundColor: AppColors.neutralTextGray,
          ),
        );
      }
    }
  }

  void _filterDemandas(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredDemandas = demandas;
      } else {
        filteredDemandas = demandas.where((demanda) {
          return demanda.values.any((value) =>
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
        customTitle: 'Gestión de Demanda',
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
      customTitle: 'Gestión de Demanda',
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
                onChanged: _filterDemandas,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar demandas...'
                      : 'Buscar por título, síntoma o autor...',
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
                            _filterDemandas('');
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

            // Demandas list
            filteredDemandas.isEmpty
                ? _buildEmptyState()
                : (isTablet || !isMobile
                    ? _buildDesktopDemandasTable()
                    : _buildMobileDemandasList()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(bool isMobile, bool isTablet) {
    final stats = [
      {
        'title': 'Total Demandas',
        'value': demandas.length.toString(),
        'icon': Icons.assignment_outlined,
        'color': AppColors.primaryDarkTeal,
      },
      {
        'title': 'Ruido',
        'value': demandas.where((d) => d['sintoma'] == 'Ruido').length.toString(),
        'icon': Icons.volume_up,
        'color': AppColors.primaryMediumTeal,
      },
      {
        'title': 'Vibración',
        'value': demandas.where((d) => d['sintoma'] == 'Vibración').length.toString(),
        'icon': Icons.vibration,
        'color': AppColors.neutralTextGray,
      },
      {
        'title': 'Temperatura',
        'value': demandas.where((d) => d['sintoma']?.toLowerCase()?.contains('temperatura') ?? false).length.toString(),
        'icon': Icons.thermostat,
        'color': AppColors.primaryDarkTeal,
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
                ? 'No hay demandas disponibles'
                : 'No se encontraron demandas',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.neutralTextGray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDemandasList() {
    return Column(
      children: filteredDemandas.map((demanda) => 
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildDemandaCard(demanda),
        ),
      ).toList(),
    );
  }

  Widget _buildDemandaCard(Map<String, dynamic> demanda) {
    final sintoma = demanda['sintoma']?.toString() ?? '';
    final sintomaColor = _getSintomaColor(sintoma);

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
        onTap: () => _showDemandaDetails(demanda),
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
                      demanda['claseAviso'] ?? 'N/A',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryDarkTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (sintoma.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: sintomaColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSintomaIcon(sintoma),
                            size: 14,
                            color: sintomaColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            sintoma,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: sintomaColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                demanda['tituloAviso'] ?? 'Sin título',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                demanda['descripcionAviso'] ?? 'Sin descripción',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.neutralTextGray.withOpacity(0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      demanda['autor'] ?? 'Sin autor',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.neutralTextGray.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    demanda['fechaInicio'] ?? 'Sin fecha',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.neutralTextGray.withOpacity(0.7),
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

  Widget _buildDesktopDemandasTable() {
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
                  'Lista de Demandas',
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
                  DataColumn(label: Text('Clase')),
                  DataColumn(label: Text('Título')),
                  DataColumn(label: Text('Descripción')),
                  DataColumn(label: Text('Síntoma')),
                  DataColumn(label: Text('Autor')),
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Acciones')),
                ],
                rows: filteredDemandas.map((demanda) {
                  final sintoma = demanda['sintoma']?.toString() ?? '';
                  final sintomaColor = _getSintomaColor(sintoma);
                  
                  return DataRow(
                    cells: [
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDarkTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            demanda['claseAviso'] ?? '',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primaryDarkTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            demanda['tituloAviso'] ?? 'Sin título',
                            style: AppTextStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 250,
                          child: Text(
                            demanda['descripcionAviso'] ?? 'Sin descripción',
                            style: AppTextStyles.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(
                        sintoma.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: sintomaColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getSintomaIcon(sintoma),
                                      size: 14,
                                      color: sintomaColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      sintoma,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: sintomaColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Text('-'),
                      ),
                      DataCell(Text(demanda['autor'] ?? '', style: AppTextStyles.bodySmall)),
                      DataCell(Text(demanda['fechaInicio'] ?? '', style: AppTextStyles.bodySmall)),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.visibility_outlined),
                          color: AppColors.primaryDarkTeal,
                          iconSize: 20,
                          onPressed: () => _showDemandaDetails(demanda),
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

  Color _getSintomaColor(String sintoma) {
    switch (sintoma.toLowerCase()) {
      case 'ruido':
        return AppColors.secondaryGoldenYellow;
      case 'vibración':
        return AppColors.secondaryCoralRed;
      case 'fuga':
        return AppColors.secondaryBrightBlue;
      case 'temperatura alta':
      case 'temperatura':
        return AppColors.secondaryCoralRed;
      default:
        return AppColors.primaryMintGreen;
    }
  }

  IconData _getSintomaIcon(String sintoma) {
    switch (sintoma.toLowerCase()) {
      case 'ruido':
        return Icons.volume_up;
      case 'vibración':
        return Icons.vibration;
      case 'fuga':
        return Icons.water_drop;
      case 'temperatura alta':
      case 'temperatura':
        return Icons.thermostat;
      default:
        return Icons.warning_outlined;
    }
  }

  void _showDemandaDetails(Map<String, dynamic> demanda) {
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
                              'Demanda ${demanda['claseAviso'] ?? 'N/A'}',
                              style: AppTextStyles.heading6.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              demanda['fechaInicio'] ?? 'Sin fecha',
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
                          _buildDetailItem('Clase de Aviso', demanda['claseAviso']),
                          _buildDetailItem('Título', demanda['tituloAviso']),
                          _buildDetailItem('Descripción', demanda['descripcionAviso']),
                          _buildDetailItem('Fecha de Inicio', demanda['fechaInicio']),
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('Diagnóstico', [
                          _buildDetailItem('Síntoma', demanda['sintoma']),
                          _buildDetailItem('Causa', demanda['causa']),
                          _buildDetailItem('Tiempo de Reparación', demanda['tiempoReparacion']),
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('Información Técnica', [
                          _buildDetailItem('Equipo', demanda['equipo']),
                          _buildDetailItem('Denominación', demanda['denominacionEquipo']),
                          _buildDetailItem('Ubicación Técnica', demanda['ubicacionTecnica']),
                        ]),
                        const SizedBox(height: 20),
                        _buildDetailSection('Responsabilidad', [
                          _buildDetailItem('Autor', demanda['autor']),
                          _buildDetailItem('Centro Responsable', demanda['centroResponsable']),
                          _buildDetailItem('Puesto de Trabajo', demanda['puestoTrabajo']),
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
              value?.isNotEmpty == true ? value! : 'N/A',
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}