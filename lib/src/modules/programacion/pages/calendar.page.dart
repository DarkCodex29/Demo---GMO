import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  List<Map<String, dynamic>> ordenes = [];
  List<Map<String, dynamic>> filteredOrdenes = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOrdenes();
  }

  Future<void> _loadOrdenes() async {
    try {
      final String response = await rootBundle.loadString('assets/data/ordenes.json');
      final data = json.decode(response);
      setState(() {
        ordenes = List<Map<String, dynamic>>.from(data['ordenes']);
        filteredOrdenes = ordenes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error al cargar órdenes: $e');
    }
  }

  void _filterOrdenes(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredOrdenes = ordenes;
      } else {
        filteredOrdenes = ordenes.where((orden) {
          return orden.values.any((value) =>
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
        customTitle: 'Calendario de Mantenimiento',
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
      currentModule: 'programacion',
      customTitle: 'Calendario de Mantenimiento',
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
                onChanged: _filterOrdenes,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar órdenes...'
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
                            _filterOrdenes('');
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

            // Vista de calendario/lista
            _buildCalendarView(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarView(bool isMobile) {
    if (filteredOrdenes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month,
              size: 64,
              color: AppColors.neutralTextGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No hay órdenes programadas'
                  : 'No se encontraron órdenes',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.neutralTextGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header con estadísticas
        _buildStatsHeader(),
        const SizedBox(height: 16),
        
        // Lista de órdenes organizadas por fecha
        ..._buildOrdersByDate(),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final today = DateTime.now();
    final thisWeek = filteredOrdenes.where((orden) {
      final fechaInicio = orden['fechas']?['inicioReal'] ?? '';
      if (fechaInicio.isEmpty) return false;
      try {
        final parts = fechaInicio.split('.');
        final orderDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0])
        );
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return orderDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
               orderDate.isBefore(weekEnd.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutralMediumBorder.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${filteredOrdenes.length}',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.primaryDarkTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Total Órdenes',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.neutralTextGray,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.neutralMediumBorder.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$thisWeek',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.primaryMediumTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Esta Semana',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.neutralTextGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrdersByDate() {
    // Agrupar órdenes por fecha
    final ordenesGrouped = <String, List<Map<String, dynamic>>>{};
    
    for (final orden in filteredOrdenes) {
      final fecha = orden['fechas']?['inicioReal'] ?? orden['fecha'] ?? 'Sin fecha';
      if (ordenesGrouped[fecha] == null) {
        ordenesGrouped[fecha] = [];
      }
      ordenesGrouped[fecha]!.add(orden);
    }

    // Convertir a lista de widgets
    final List<Widget> widgets = [];
    
    ordenesGrouped.forEach((fecha, ordenesList) {
      widgets.add(_buildDateSection(fecha, ordenesList));
      widgets.add(const SizedBox(height: 16));
    });

    return widgets;
  }

  Widget _buildDateSection(String fecha, List<Map<String, dynamic>> ordenes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.neutralLightBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.primaryDarkTeal,
              ),
              const SizedBox(width: 8),
              Text(
                fecha,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.neutralTextGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryDarkTeal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${ordenes.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ...ordenes.map((orden) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: _buildOrdenCard(orden),
        )),
      ],
    );
  }

  Widget _buildOrdenCard(Map<String, dynamic> orden) {
    final claseOrden = orden['claseOrden'] ?? '';
    final priority = _getPriorityFromClase(claseOrden);
    
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    orden['nroOrden'] ?? '',
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
                    color: priority['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    priority['label'],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: priority['color'],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${orden['fechas']?['horaInicioReal'] ?? ''}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.neutralTextGray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              orden['textoBrave'] ?? 'Sin descripción',
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
                    '${orden['equipo'] ?? ''} - ${orden['denominacionEquipo'] ?? ''}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.neutralTextGray.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getPriorityFromClase(String claseOrden) {
    switch (claseOrden.toUpperCase()) {
      case 'ZIA1':
        return {
          'label': 'Emergencia',
          'color': AppColors.secondaryCoralRed,
        };
      case 'ZPM1':
        return {
          'label': 'Preventivo',
          'color': AppColors.secondaryAquaGreen,
        };
      case 'ZPM2':
        return {
          'label': 'Predictivo',
          'color': AppColors.primaryMediumTeal,
        };
      default:
        return {
          'label': 'Normal',
          'color': AppColors.neutralTextGray,
        };
    }
  }
}