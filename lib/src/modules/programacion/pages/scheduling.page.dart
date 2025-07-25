import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class SchedulingPage extends StatefulWidget {
  const SchedulingPage({super.key});

  @override
  SchedulingPageState createState() => SchedulingPageState();
}

class SchedulingPageState extends State<SchedulingPage> {
  List<Map<String, dynamic>> equipos = [];
  List<Map<String, dynamic>> filteredEquipos = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEquipos();
  }

  Future<void> _loadEquipos() async {
    try {
      final String response = await rootBundle.loadString('assets/data/equipos_trabajo.json');
      final List<dynamic> data = json.decode(response);
      if (data.isNotEmpty) {
        final equiposData = data[0]['datos']['equipos'];
        setState(() {
          equipos = List<Map<String, dynamic>>.from(equiposData);
          filteredEquipos = equipos;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar equipos: $e');
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
      return const MainLayout(
        currentModule: 'programacion',
        customTitle: 'Programación de Recursos',
        showBackButton: true,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryMintGreen,
          ),
        ),
      );
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return MainLayout(
      currentModule: 'programacion',
      customTitle: 'Programación de Recursos',
      showBackButton: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                onChanged: _filterEquipos,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar equipos...'
                      : 'Buscar por nombre, líder o especialidad...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutralTextGray.withOpacity(0.6),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primaryMintGreen,
                    size: 24,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.neutralTextGray,
                          ),
                          onPressed: () {
                            _filterEquipos('');
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

            // Estadísticas
            _buildStatsHeader(),
            const SizedBox(height: 16),

            // Lista de equipos
            _buildEquiposList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader() {
    final activos = filteredEquipos.where((e) => e['estado'] == 'Activo').length;
    final turnoManana = filteredEquipos.where((e) => e['turno'] == 'Mañana').length;
    final turnoTarde = filteredEquipos.where((e) => e['turno'] == 'Tarde').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryMintGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${filteredEquipos.length}',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.primaryMintGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Total Equipos',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryMintGreen,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$activos',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.secondaryAquaGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Activos',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondaryAquaGreen,
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
                  children: [
                    Text(
                      '$turnoManana',
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.secondaryBrightBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Turno Mañana',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondaryBrightBlue,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$turnoTarde',
                      style: AppTextStyles.heading5.copyWith(
                        color: AppColors.secondaryGoldenYellow,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Turno Tarde',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.secondaryGoldenYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEquiposList() {
    if (filteredEquipos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 64,
              color: AppColors.neutralTextGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No hay equipos disponibles'
                  : 'No se encontraron equipos',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.neutralTextGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredEquipos.map((equipo) => 
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildEquipoCard(equipo),
        ),
      ).toList(),
    );
  }

  Widget _buildEquipoCard(Map<String, dynamic> equipo) {
    final especialidad = equipo['especialidad'] ?? '';
    final especialidadColor = _getEspecialidadColor(especialidad);
    final estadoColor = _getEstadoColor(equipo['estado']);
    
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
        onTap: () => _showEquipoDetails(equipo),
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
                      color: AppColors.primaryMintGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      equipo['id'] ?? '',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primaryMintGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      equipo['estado'] ?? '',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: estadoColor,
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
                equipo['nombre'] ?? 'Sin nombre',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
                  Text(
                    'Líder: ${equipo['lider'] ?? 'Sin asignar'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutralTextGray.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.groups_outlined,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${equipo['miembros'] ?? '0'} miembros',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutralTextGray.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Turno ${equipo['turno'] ?? 'No definido'}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutralTextGray.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: especialidadColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  especialidad,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: especialidadColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getEspecialidadColor(String especialidad) {
    switch (especialidad.toLowerCase()) {
      case 'mantenimiento mecánico':
        return AppColors.primaryDarkTeal;
      case 'mantenimiento eléctrico':
        return AppColors.secondaryBrightBlue;
      case 'instrumentación':
        return AppColors.secondaryGoldenYellow;
      case 'soldadura':
        return AppColors.secondaryCoralRed;
      default:
        return AppColors.neutralTextGray;
    }
  }

  Color _getEstadoColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'activo':
        return AppColors.secondaryAquaGreen;
      case 'inactivo':
        return AppColors.secondaryCoralRed;
      case 'mantenimiento':
        return AppColors.secondaryGoldenYellow;
      default:
        return AppColors.neutralTextGray;
    }
  }

  void _showEquipoDetails(Map<String, dynamic> equipo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 400,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryMintGreen,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.groups,
                        color: AppColors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              equipo['nombre'] ?? '',
                              style: AppTextStyles.heading6.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              equipo['id'] ?? '',
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
                        _buildDetailItem('Líder', equipo['lider']),
                        _buildDetailItem('Miembros', equipo['miembros']),
                        _buildDetailItem('Especialidad', equipo['especialidad']),
                        _buildDetailItem('Turno', equipo['turno']),
                        _buildDetailItem('Estado', equipo['estado']),
                        _buildDetailItem('Ubicación', equipo['ubicacion']),
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

  Widget _buildDetailItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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
