import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class WorkloadPage extends StatefulWidget {
  const WorkloadPage({super.key});

  @override
  WorkloadPageState createState() => WorkloadPageState();
}

class WorkloadPageState extends State<WorkloadPage> {
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
      final List<dynamic> data = json.decode(response);
      
      if (data.isNotEmpty) {
        final datos = data[0]['datos'];
        setState(() {
          capacidades = (datos['capacidades'] as List).map((item) => Map<String, dynamic>.from(item as Map)).toList();
          filteredCapacidades = capacidades;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar capacidades: $e');
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
        currentModule: 'programacion',
        customTitle: 'Carga de Trabajo',
        showBackButton: true,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryMediumTeal,
          ),
        ),
      );
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return MainLayout(
      currentModule: 'programacion',
      customTitle: 'Carga de Trabajo',
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
                onChanged: _filterCapacidades,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar por puesto...'
                      : 'Buscar por puesto de trabajo o centro...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutralTextGray.withOpacity(0.6),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primaryMediumTeal,
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

            // Resumen de carga
            _buildWorkloadSummary(),
            const SizedBox(height: 16),

            // Lista de capacidades
            _buildCapacidadesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadSummary() {
    final normales = filteredCapacidades.where((c) => c['estado'] == 'Normal').length;
    final criticos = filteredCapacidades.where((c) => c['estado'] == 'Crítico' || c['estado'] == 'Sobrecargado').length;
    final utilizacionPromedio = _calculateAverageUtilization();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryMediumTeal.withOpacity(0.1),
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
                      '${filteredCapacidades.length}',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.primaryMediumTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Total Puestos',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primaryMediumTeal,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '$normales',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.primaryMintGreen,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Normales',
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
                      '$criticos',
                      style: AppTextStyles.heading4.copyWith(
                        color: AppColors.secondaryCoralRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Críticos',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.secondaryCoralRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.analytics,
                  color: AppColors.primaryDarkTeal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Utilización Promedio: $utilizacionPromedio%',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.primaryDarkTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAverageUtilization() {
    if (filteredCapacidades.isEmpty) return '0';
    
    double totalUtilization = 0;
    int validItems = 0;
    
    for (final capacidad in filteredCapacidades) {
      final utilizacion = capacidad['utilizacion']?.toString() ?? '';
      if (utilizacion.isNotEmpty) {
        final percentage = utilizacion.replaceAll('%', '');
        final value = double.tryParse(percentage);
        if (value != null) {
          totalUtilization += value;
          validItems++;
        }
      }
    }
    
    if (validItems == 0) return '0';
    return (totalUtilization / validItems).toStringAsFixed(1);
  }

  Widget _buildCapacidadesList() {
    if (filteredCapacidades.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics,
              size: 64,
              color: AppColors.neutralTextGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No hay datos de carga disponibles'
                  : 'No se encontraron resultados',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.neutralTextGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredCapacidades.map((capacidad) => 
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildCapacidadCard(capacidad),
        ),
      ).toList(),
    );
  }

  Widget _buildCapacidadCard(Map<String, dynamic> capacidad) {
    final estado = capacidad['estado'] ?? '';
    final estadoColor = _getEstadoColor(estado);
    final utilizacion = capacidad['utilizacion'] ?? '';
    final utilizacionValue = _getUtilizacionValue(utilizacion);
    
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    capacidad['puestoTrabajo'] ?? 'Sin nombre',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    estado,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: estadoColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Barra de utilización
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Utilización',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.neutralTextGray.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      utilizacion,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getUtilizacionColor(utilizacionValue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.neutralMediumBorder.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: (utilizacionValue / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getUtilizacionColor(utilizacionValue),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Información adicional
            Row(
              children: [
                Expanded(
                  child: _buildInfoColumn('Centro', capacidad['centro']),
                ),
                Expanded(
                  child: _buildInfoColumn('Semana', 'Semana ${capacidad['semanaNro']}'),
                ),
                Expanded(
                  child: _buildInfoColumn('Necesidad', capacidad['necesidad']),
                ),
                Expanded(
                  child: _buildInfoColumn('Oferta', capacidad['oferta']),
                ),
              ],
            ),
            
            // Mostrar déficit o exceso si existe
            if (capacidad.containsKey('deficit') || capacidad.containsKey('exceso')) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: capacidad.containsKey('deficit') 
                      ? AppColors.secondaryCoralRed.withOpacity(0.1)
                      : AppColors.primaryMintGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      capacidad.containsKey('deficit') 
                          ? Icons.trending_down
                          : Icons.trending_up,
                      size: 16,
                      color: capacidad.containsKey('deficit') 
                          ? AppColors.secondaryCoralRed
                          : AppColors.primaryMintGreen,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      capacidad.containsKey('deficit') 
                          ? 'Déficit: ${capacidad['deficit']}'
                          : 'Exceso: ${capacidad['exceso']}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: capacidad.containsKey('deficit') 
                            ? AppColors.secondaryCoralRed
                            : AppColors.primaryMintGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.neutralTextGray.withOpacity(0.7),
          ),
        ),
        Text(
          value ?? 'N/A',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'normal':
        return AppColors.primaryMintGreen;
      case 'crítico':
      case 'sobrecargado':
        return AppColors.secondaryCoralRed;
      default:
        return AppColors.neutralTextGray;
    }
  }

  double _getUtilizacionValue(String utilizacion) {
    final percentage = utilizacion.replaceAll('%', '');
    return double.tryParse(percentage) ?? 0;
  }

  Color _getUtilizacionColor(double value) {
    if (value >= 90) return AppColors.secondaryCoralRed;
    if (value >= 75) return AppColors.primaryMediumTeal;
    if (value >= 50) return AppColors.primaryMintGreen;
    return AppColors.primaryMintGreen;
  }
}