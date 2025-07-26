import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class EquipmentReportPage extends StatefulWidget {
  const EquipmentReportPage({super.key});

  @override
  EquipmentReportPageState createState() => EquipmentReportPageState();
}

class EquipmentReportPageState extends State<EquipmentReportPage> {
  List<Map<String, dynamic>> equipos = [];
  List<Map<String, dynamic>> filteredEquipos = [];
  bool isLoading = true;
  String searchQuery = '';
  Timer? _debounceTimer;

  // Filtros
  String selectedTipo = 'Todos';
  String selectedEstado = 'Todos';
  String selectedCriticidad = 'Todos';
  String selectedCentro = 'Todos';
  bool showFilters = false;

  Set<String> tipos = {'Todos'};
  Set<String> estados = {'Todos'};
  Set<String> criticidades = {'Todos'};
  Set<String> centros = {'Todos'};

  // Ordenamiento
  String sortColumn = '';
  bool sortAscending = true;

  // Paginación
  int currentPage = 0;
  int itemsPerPage = 10;
  int get totalPages => (filteredEquipos.length / itemsPerPage).ceil();

  // Controladores
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadEquipos();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadEquipos() async {
    setState(() => isLoading = true);

    try {
      final String response =
          await rootBundle.loadString('assets/data/equipament.json');
      final Map<String, dynamic> data = json.decode(response);

      setState(() {
        equipos = List<Map<String, dynamic>>.from(data['equipos']);
        filteredEquipos = equipos;

        // Extraer valores únicos para filtros
        for (var equipo in equipos) {
          tipos.add(equipo['general']['tipo_equipo']?.toString() ?? '');
          estados.add(equipo['general']['estado']?.toString() ?? '');
          criticidades.add(equipo['general']['criticidad']?.toString() ?? '');
          centros.add(equipo['organizacion']['centro_costo']?.toString() ?? '');
        }

        isLoading = false;
      });

      _checkCriticalEquipment();
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error al cargar equipos: $e');
      _showErrorSnackBar('Error al cargar equipos: ${e.toString()}');
    }
  }

  void _checkCriticalEquipment() {
    final criticalItems = equipos.where((e) {
      return e['general']['estado'].toString().toLowerCase() ==
              'fuera de servicio' ||
          e['general']['criticidad'].toString().toLowerCase() == 'alta';
    }).length;

    if (criticalItems > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCriticalEquipmentAlert(criticalItems);
      });
    }
  }

  void _showCriticalEquipmentAlert(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.white, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$count equipos requieren atención crítica',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _filterByCriticalStatus();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(40, 28),
              ),
              child: Text(
                'VER',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.secondaryCoralRed,
        duration: const Duration(seconds: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _filterByCriticalStatus() {
    setState(() {
      selectedEstado = 'Fuera de servicio';
      _applyFilters();
    });
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchQuery = value;
        currentPage = 0;
      });
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      filteredEquipos = equipos.where((equipo) {
        final matchesSearch = searchQuery.isEmpty ||
            equipo['equipo']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            equipo['descripcion']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());

        final matchesTipo = selectedTipo == 'Todos' ||
            equipo['general']['tipo_equipo'].toString() == selectedTipo;

        final matchesEstado = selectedEstado == 'Todos' ||
            equipo['general']['estado'].toString() == selectedEstado;

        final matchesCriticidad = selectedCriticidad == 'Todos' ||
            equipo['general']['criticidad'].toString() == selectedCriticidad;

        final matchesCentro = selectedCentro == 'Todos' ||
            equipo['organizacion']['centro_costo'].toString() == selectedCentro;

        return matchesSearch &&
            matchesTipo &&
            matchesEstado &&
            matchesCriticidad &&
            matchesCentro;
      }).toList();

      _applySorting();
      currentPage = 0;
    });
  }

  void _applySorting() {
    if (sortColumn.isEmpty) return;

    filteredEquipos.sort((a, b) {
      dynamic aValue, bValue;

      switch (sortColumn) {
        case 'equipo':
          aValue = a['equipo'];
          bValue = b['equipo'];
          break;
        case 'tipo':
          aValue = a['general']['tipo_equipo'];
          bValue = b['general']['tipo_equipo'];
          break;
        case 'estado':
          aValue = a['general']['estado'];
          bValue = b['general']['estado'];
          break;
        case 'centro':
          aValue = a['organizacion']['centro_costo'];
          bValue = b['organizacion']['centro_costo'];
          break;
        default:
          return 0;
      }

      final comparison = aValue
          .toString()
          .toLowerCase()
          .compareTo(bValue.toString().toLowerCase());
      return sortAscending ? comparison : -comparison;
    });
  }

  void _sortBy(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
      _applySorting();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedTipo = 'Todos';
      selectedEstado = 'Todos';
      selectedCriticidad = 'Todos';
      selectedCentro = 'Todos';
      searchQuery = '';
      sortColumn = '';
      currentPage = 0;
      _searchController.clear();
      filteredEquipos = equipos;
    });
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.download, color: AppColors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              'Exportando equipos... (Funcionalidad pendiente)',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryDarkTeal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _refreshData() {
    _loadEquipos();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.refresh, color: AppColors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              'Datos actualizados',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.secondaryAquaGreen,
        duration: const Duration(seconds: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.white, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.secondaryCoralRed,
        duration: const Duration(seconds: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'operativo':
        return AppColors.primaryDarkTeal;
      case 'en mantenimiento':
        return AppColors.primaryMediumTeal;
      case 'fuera de servicio':
        return AppColors.secondaryCoralRed;
      default:
        return AppColors.neutralTextGray;
    }
  }

  Color _getCriticidadColor(String criticidad) {
    switch (criticidad.toLowerCase()) {
      case 'alta':
        return AppColors.secondaryCoralRed;
      case 'media':
        return AppColors.primaryMediumTeal;
      case 'baja':
        return AppColors.primaryDarkTeal;
      default:
        return AppColors.neutralTextGray;
    }
  }

  IconData _getEquipmentIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'máquina':
      case 'maquina':
        return Icons.precision_manufacturing;
      case 'motor':
        return Icons.electric_bolt;
      case 'válvula':
      case 'valvula':
        return Icons.water_drop;
      case 'compresor':
        return Icons.air;
      case 'secador':
        return Icons.dry;
      default:
        return Icons.build;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MainLayout(
        currentModule: 'seguimiento_control',
        customTitle: 'Reporte de Equipos',
        showBackButton: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryDarkTeal),
              SizedBox(height: 16),
              Text(
                'Cargando equipos...',
                style: TextStyle(color: AppColors.neutralTextGray),
              ),
            ],
          ),
        ),
      );
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return MainLayout(
      currentModule: 'seguimiento_control',
      customTitle: 'Reporte de Equipos',
      showBackButton: true,
      child: Column(
        children: [
          // Header con acciones rápidas
          _buildActionBar(isMobile),

          // Barra de búsqueda y filtros
          _buildSearchAndFilters(isMobile),

          // Estadísticas resumidas
          _buildEnhancedStats(isMobile),

          // Lista/tabla de equipos con paginación
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Expanded(
                    child: isTablet || !isMobile
                        ? _buildEnhancedDesktopTable()
                        : _buildEnhancedMobileList(),
                  ),
                  if (totalPages > 1) _buildPagination(isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(bool isMobile) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              const Icon(
                Icons.precision_manufacturing,
                color: AppColors.primaryDarkTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Gestión de Equipos',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primaryDarkTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (!isMobile) ...[
                IconButton(
                  onPressed: _refreshData,
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Actualizar datos',
                  color: AppColors.primaryDarkTeal,
                ),
                IconButton(
                  onPressed: _exportData,
                  icon: const Icon(Icons.download, size: 20),
                  tooltip: 'Exportar datos',
                  color: AppColors.primaryDarkTeal,
                ),
              ],
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppColors.primaryDarkTeal),
                onSelected: (value) {
                  switch (value) {
                    case 'refresh':
                      _refreshData();
                      break;
                    case 'export':
                      _exportData();
                      break;
                    case 'critical':
                      _filterByCriticalStatus();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 16),
                        SizedBox(width: 8),
                        Text('Actualizar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 16),
                        SizedBox(width: 8),
                        Text('Exportar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'critical',
                    child: Row(
                      children: [
                        Icon(Icons.warning,
                            size: 16, color: AppColors.secondaryCoralRed),
                        SizedBox(width: 8),
                        Text('Equipos Críticos'),
                      ],
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

  Widget _buildSearchAndFilters(bool isMobile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Búsqueda
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            'Buscar por código, descripción o ubicación...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.neutralTextGray.withOpacity(0.6),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.primaryDarkTeal,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.neutralTextGray,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                              color: AppColors.neutralMediumBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primaryDarkTeal,
                            width: 2,
                          ),
                        ),
                      ),
                      style: AppTextStyles.bodyMedium,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        showFilters = !showFilters;
                      });
                    },
                    icon: Icon(
                      showFilters ? Icons.filter_list_off : Icons.filter_list,
                      color: showFilters
                          ? AppColors.secondaryCoralRed
                          : AppColors.primaryDarkTeal,
                    ),
                    tooltip:
                        showFilters ? 'Ocultar filtros' : 'Mostrar filtros',
                  ),
                ],
              ),

              // Filtros colapsables
              if (showFilters) ...[
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Column(
                    children: [
                      if (isMobile)
                        _buildMobileFilters()
                      else
                        _buildDesktopFilters(),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.clear_all, size: 16),
                            label: const Text('Limpiar filtros'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.neutralLightBackground,
                              foregroundColor: AppColors.neutralTextGray,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${filteredEquipos.length} de ${equipos.length} equipos',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.neutralTextGray,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child:
                    _buildFilterDropdown('Tipo', selectedTipo, tipos, (value) {
              setState(() {
                selectedTipo = value!;
              });
              _applyFilters();
            })),
            const SizedBox(width: 8),
            Expanded(
                child: _buildFilterDropdown('Estado', selectedEstado, estados,
                    (value) {
              setState(() {
                selectedEstado = value!;
              });
              _applyFilters();
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _buildFilterDropdown(
                    'Criticidad', selectedCriticidad, criticidades, (value) {
              setState(() {
                selectedCriticidad = value!;
              });
              _applyFilters();
            })),
            const SizedBox(width: 8),
            Expanded(
                child: _buildFilterDropdown('Centro', selectedCentro, centros,
                    (value) {
              setState(() {
                selectedCentro = value!;
              });
              _applyFilters();
            })),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildFilterDropdown('Tipo Equipo', selectedTipo, tipos,
                    (value) {
              setState(() {
                selectedTipo = value!;
              });
              _applyFilters();
            })),
            const SizedBox(width: 12),
            Expanded(
                child: _buildFilterDropdown('Estado', selectedEstado, estados,
                    (value) {
              setState(() {
                selectedEstado = value!;
              });
              _applyFilters();
            })),
            const SizedBox(width: 12),
            Expanded(
                child: _buildFilterDropdown(
                    'Criticidad', selectedCriticidad, criticidades, (value) {
              setState(() {
                selectedCriticidad = value!;
              });
              _applyFilters();
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _buildFilterDropdown(
                    'Centro Costo', selectedCentro, centros, (value) {
              setState(() {
                selectedCentro = value!;
              });
              _applyFilters();
            })),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()), // Espacio vacío
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()), // Espacio vacío
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, String value, Set<String> items,
      Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.neutralMediumBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.primaryDarkTeal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      style: AppTextStyles.bodyMedium,
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: AppTextStyles.bodyMedium),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildEnhancedStats(bool isMobile) {
    final totalEquipos = filteredEquipos.length;
    final equiposOperativos = filteredEquipos
        .where((e) =>
            e['general']['estado'].toString().toLowerCase() == 'operativo')
        .length;
    final equiposCriticos = filteredEquipos
        .where((e) =>
            e['general']['criticidad'].toString().toLowerCase() == 'alta')
        .length;
    final equiposFueraServicio = filteredEquipos
        .where((e) =>
            e['general']['estado'].toString().toLowerCase() ==
            'fuera de servicio')
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: isMobile
          ? Row(
              children: [
                Expanded(
                  child: _buildCompactStatCard(
                    'Total: $totalEquipos',
                    Icons.precision_manufacturing,
                    AppColors.primaryDarkTeal,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactStatCard(
                    'Operativos: $equiposOperativos',
                    Icons.check_circle,
                    AppColors.primaryDarkTeal,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactStatCard(
                    'Críticos: $equiposCriticos',
                    Icons.error,
                    AppColors.secondaryCoralRed,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        'Total Equipos',
                        totalEquipos.toString(),
                        Icons.precision_manufacturing,
                        AppColors.primaryDarkTeal)),
                Expanded(
                    child: _buildStatCard(
                        'Operativos',
                        equiposOperativos.toString(),
                        Icons.check_circle,
                        AppColors.primaryDarkTeal)),
                Expanded(
                    child: _buildStatCard(
                        'Críticos',
                        equiposCriticos.toString(),
                        Icons.error,
                        AppColors.secondaryCoralRed)),
                Expanded(
                    child: _buildStatCard(
                        'Fuera de Servicio',
                        equiposFueraServicio.toString(),
                        Icons.cancel,
                        AppColors.secondaryCoralRed)),
              ],
            ),
    );
  }

  Widget _buildCompactStatCard(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading6.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.neutralTextGray,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMobileList() {
    if (filteredEquipos.isEmpty) {
      return _buildEmptyState();
    }

    final startIndex = currentPage * itemsPerPage;
    final endIndex =
        (startIndex + itemsPerPage).clamp(0, filteredEquipos.length);
    final paginatedItems = filteredEquipos.sublist(startIndex, endIndex);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8),
      itemCount: paginatedItems.length,
      itemBuilder: (context, index) {
        final equipo = paginatedItems[index];
        return _buildExpandableEquipmentCard(equipo);
      },
    );
  }

  Widget _buildExpandableEquipmentCard(Map<String, dynamic> equipo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralMediumBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralTextGray.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getEstadoColor(equipo['general']['estado']),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getEquipmentIcon(equipo['general']['tipo_equipo']),
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          equipo['equipo'],
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              equipo['descripcion'],
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.neutralTextGray,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(equipo['general']['estado']),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    equipo['general']['estado'],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCriticidadColor(equipo['general']['criticidad'])
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    equipo['general']['criticidad'],
                    style: AppTextStyles.labelSmall.copyWith(
                      color:
                          _getCriticidadColor(equipo['general']['criticidad']),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neutralLightBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                    'Tipo', equipo['general']['tipo_equipo'], Icons.category),
                _buildDetailRow('Centro Costo',
                    equipo['organizacion']['centro_costo'], Icons.business),
                _buildDetailRow(
                    'Ubicación',
                    equipo['emplazamiento']['ubicacion_tecnica'],
                    Icons.location_on),
                _buildDetailRow('Responsable',
                    equipo['organizacion']['responsable'], Icons.person),
                _buildDetailRow('Puesto Trabajo',
                    equipo['organizacion']['puesto_trabajo'], Icons.work),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.neutralTextGray),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall,
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedDesktopTable() {
    if (filteredEquipos.isEmpty) {
      return _buildEmptyState();
    }

    final startIndex = currentPage * itemsPerPage;
    final endIndex =
        (startIndex + itemsPerPage).clamp(0, filteredEquipos.length);
    final paginatedItems = filteredEquipos.sublist(startIndex, endIndex);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            AppColors.primaryDarkTeal.withOpacity(0.1),
          ),
          headingTextStyle: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryDarkTeal,
          ),
          dataTextStyle: AppTextStyles.bodyMedium,
          sortColumnIndex:
              sortColumn.isEmpty ? null : _getColumnIndex(sortColumn),
          sortAscending: sortAscending,
          columns: [
            DataColumn(
              label: const Text('Equipo'),
              onSort: (columnIndex, ascending) => _sortBy('equipo'),
            ),
            DataColumn(
              label: const Text('Tipo'),
              onSort: (columnIndex, ascending) => _sortBy('tipo'),
            ),
            DataColumn(
              label: const Text('Estado'),
              onSort: (columnIndex, ascending) => _sortBy('estado'),
            ),
            const DataColumn(label: Text('Criticidad')),
            DataColumn(
              label: const Text('Centro'),
              onSort: (columnIndex, ascending) => _sortBy('centro'),
            ),
            const DataColumn(label: Text('Descripción')),
            const DataColumn(label: Text('Ubicación')),
            const DataColumn(label: Text('Responsable')),
          ],
          rows: paginatedItems.map((equipo) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Icon(
                        _getEquipmentIcon(equipo['general']['tipo_equipo']),
                        color: AppColors.primaryDarkTeal,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        equipo['equipo'],
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(equipo['general']['tipo_equipo'])),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(equipo['general']['estado']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      equipo['general']['estado'],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color:
                          _getCriticidadColor(equipo['general']['criticidad']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      equipo['general']['criticidad'],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(equipo['organizacion']['centro_costo'])),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      equipo['descripcion'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(equipo['emplazamiento']['ubicacion_tecnica'])),
                DataCell(Text(equipo['organizacion']['responsable'])),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  int _getColumnIndex(String column) {
    switch (column) {
      case 'equipo':
        return 0;
      case 'tipo':
        return 1;
      case 'estado':
        return 2;
      case 'centro':
        return 4;
      default:
        return 0;
    }
  }

  Widget _buildPagination(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Página ${currentPage + 1} de $totalPages',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.neutralTextGray,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: currentPage > 0
                    ? () {
                        setState(() {
                          currentPage--;
                        });
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
                color: currentPage > 0
                    ? AppColors.primaryDarkTeal
                    : AppColors.neutralTextGray,
              ),
              IconButton(
                onPressed: currentPage < totalPages - 1
                    ? () {
                        setState(() {
                          currentPage++;
                        });
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
                color: currentPage < totalPages - 1
                    ? AppColors.primaryDarkTeal
                    : AppColors.neutralTextGray,
              ),
            ],
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
            Icons.precision_manufacturing_outlined,
            size: 64,
            color: AppColors.neutralTextGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty && !showFilters
                ? 'No hay equipos disponibles'
                : 'No se encontraron equipos',
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.neutralTextGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty && !showFilters
                ? 'Verifica la conexión de datos'
                : 'Intenta ajustar los filtros o términos de búsqueda',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.neutralTextGray.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (showFilters || searchQuery.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Limpiar filtros'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDarkTeal,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
