import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class FaultLogPage extends StatefulWidget {
  const FaultLogPage({super.key});

  @override
  FaultLogPageState createState() => FaultLogPageState();
}

class FaultLogPageState extends State<FaultLogPage> {
  List<Map<String, dynamic>> fallas = [];
  List<Map<String, dynamic>> filteredFallas = [];
  bool isLoading = true;
  String searchQuery = '';
  Timer? _debounceTimer;

  // Filtros
  String selectedSeveridad = 'Todas';
  String selectedTipo = 'Todos';
  String selectedEstado = 'Todos';
  String selectedEquipo = 'Todos';
  bool showFilters = false;

  Set<String> severidades = {'Todas'};
  Set<String> tipos = {'Todos'};
  Set<String> estados = {'Todos'};
  Set<String> equipos = {'Todos'};

  // Ordenamiento
  String sortColumn = '';
  bool sortAscending =
      false; // Por defecto descendente para mostrar más recientes primero

  // Paginación
  int currentPage = 0;
  int itemsPerPage = 15;
  int get totalPages => (filteredFallas.length / itemsPerPage).ceil();

  // Controladores
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFallas();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFallas() async {
    setState(() => isLoading = true);

    try {
      // Generar datos de fallas simulados ya que no tenemos un JSON específico
      final fallas = _generateFaultData();

      setState(() {
        this.fallas = fallas;
        filteredFallas = fallas;

        // Extraer valores únicos para filtros
        for (var falla in fallas) {
          severidades.add(falla['severidad']?.toString() ?? '');
          tipos.add(falla['tipo']?.toString() ?? '');
          estados.add(falla['estado']?.toString() ?? '');
          equipos.add(falla['equipo']?.toString() ?? '');
        }

        isLoading = false;
      });

      _checkCriticalFaults();
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error al cargar log de fallas: $e');
      _showErrorSnackBar('Error al cargar log de fallas: ${e.toString()}');
    }
  }

  List<Map<String, dynamic>> _generateFaultData() {
    final equipos = [
      'EQ-001',
      'EQ-005',
      'EQ-012',
      'EQ-018',
      'EQ-023',
      'EQ-029',
      'EQ-034'
    ];
    final tipos = [
      'Mecánica',
      'Eléctrica',
      'Hidráulica',
      'Neumática',
      'Control',
      'Software'
    ];
    final severidades = ['Crítica', 'Alta', 'Media', 'Baja'];
    final estados = ['Abierta', 'En Proceso', 'Resuelta', 'Cerrada'];

    final fallas = <Map<String, dynamic>>[];
    final now = DateTime.now();

    for (int i = 0; i < 89; i++) {
      final fechaFalla = now.subtract(Duration(days: i * 2, hours: i % 24));
      final fechaResolucion =
          i % 4 == 0 ? null : fechaFalla.add(Duration(hours: (i % 48) + 1));

      fallas.add({
        'id': 'FL-${(i + 1).toString().padLeft(4, '0')}',
        'fecha': fechaFalla.toIso8601String(),
        'equipo': equipos[i % equipos.length],
        'tipo': tipos[i % tipos.length],
        'severidad': severidades[i % severidades.length],
        'estado': estados[i % estados.length],
        'descripcion': _getDescripcionFalla(tipos[i % tipos.length], i),
        'reportadoPor': 'Operador ${(i % 5) + 1}',
        'fechaResolucion': fechaResolucion?.toIso8601String(),
        'tiempoResolucion': fechaResolucion != null
            ? '${fechaResolucion.difference(fechaFalla).inHours}h'
            : null,
        'costoEstimado': ((i + 1) * 150.0 + (i % 1000)),
      });
    }

    return fallas;
  }

  String _getDescripcionFalla(String tipo, int index) {
    final descripciones = {
      'Mecánica': [
        'Desgaste excesivo en rodamientos principales',
        'Vibración anormal en eje motor',
        'Desalineación de correas transportadoras',
        'Sobrecalentamiento en caja reductora',
      ],
      'Eléctrica': [
        'Cortocircuito en panel de control',
        'Fallo en contactores principales',
        'Sobrecarga en motor trifásico',
        'Pérdida de fase en alimentación',
      ],
      'Hidráulica': [
        'Fuga en cilindro hidráulico principal',
        'Presión insuficiente en sistema',
        'Contaminación en aceite hidráulico',
        'Fallo en válvula direccional',
      ],
      'Neumática': [
        'Caída de presión en línea principal',
        'Fuga en actuador neumático',
        'Obstrucción en filtros de aire',
        'Mal funcionamiento de válvula solenoide',
      ],
      'Control': [
        'Error en PLC - fallo de comunicación',
        'Sensor de proximidad defectuoso',
        'Pérdida de señal en encoder',
        'Fallo en variador de frecuencia',
      ],
      'Software': [
        'Error de configuración en HMI',
        'Corrupción de base de datos',
        'Fallo en sistema SCADA',
        'Actualización de firmware fallida',
      ],
    };

    final lista = descripciones[tipo] ?? ['Falla no especificada'];
    return lista[index % lista.length];
  }

  void _checkCriticalFaults() {
    final criticalFaults = fallas.where((f) {
      return f['severidad'].toString().toLowerCase() == 'crítica' &&
          f['estado'].toString().toLowerCase() == 'abierta';
    }).length;

    if (criticalFaults > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCriticalFaultsAlert(criticalFaults);
      });
    }
  }

  void _showCriticalFaultsAlert(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.white, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$count fallas críticas sin resolver',
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
                _filterByCriticalFaults();
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

  void _filterByCriticalFaults() {
    setState(() {
      selectedSeveridad = 'Crítica';
      selectedEstado = 'Abierta';
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
      filteredFallas = fallas.where((falla) {
        final matchesSearch = searchQuery.isEmpty ||
            falla['id']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            falla['descripcion']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            falla['equipo']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());

        final matchesSeveridad = selectedSeveridad == 'Todas' ||
            falla['severidad'].toString() == selectedSeveridad;

        final matchesTipo =
            selectedTipo == 'Todos' || falla['tipo'].toString() == selectedTipo;

        final matchesEstado = selectedEstado == 'Todos' ||
            falla['estado'].toString() == selectedEstado;

        final matchesEquipo = selectedEquipo == 'Todos' ||
            falla['equipo'].toString() == selectedEquipo;

        return matchesSearch &&
            matchesSeveridad &&
            matchesTipo &&
            matchesEstado &&
            matchesEquipo;
      }).toList();

      _applySorting();
      currentPage = 0;
    });
  }

  void _applySorting() {
    if (sortColumn.isEmpty) {
      // Ordenamiento por defecto: más recientes primero
      filteredFallas.sort((a, b) {
        final dateA = DateTime.parse(a['fecha']);
        final dateB = DateTime.parse(b['fecha']);
        return dateB.compareTo(dateA);
      });
      return;
    }

    filteredFallas.sort((a, b) {
      dynamic aValue, bValue;

      switch (sortColumn) {
        case 'fecha':
          aValue = DateTime.parse(a['fecha']);
          bValue = DateTime.parse(b['fecha']);
          break;
        case 'id':
          aValue = a['id'];
          bValue = b['id'];
          break;
        case 'equipo':
          aValue = a['equipo'];
          bValue = b['equipo'];
          break;
        case 'severidad':
          aValue = a['severidad'];
          bValue = b['severidad'];
          break;
        default:
          return 0;
      }

      final comparison = aValue is DateTime
          ? aValue.compareTo(bValue)
          : aValue
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
        sortAscending =
            column == 'fecha' ? false : true; // Fechas descendente por defecto
      }
      _applySorting();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedSeveridad = 'Todas';
      selectedTipo = 'Todos';
      selectedEstado = 'Todos';
      selectedEquipo = 'Todos';
      searchQuery = '';
      sortColumn = '';
      currentPage = 0;
      _searchController.clear();
      filteredFallas = fallas;
      _applySorting(); // Aplicar orden por defecto
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
              'Exportando log de fallas... (Funcionalidad pendiente)',
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
    _loadFallas();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.refresh, color: AppColors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              'Log actualizado',
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

  Color _getSeveridadColor(String severidad) {
    switch (severidad.toLowerCase()) {
      case 'crítica':
        return AppColors.secondaryCoralRed;
      case 'alta':
        return Colors.orange;
      case 'media':
        return AppColors.primaryMediumTeal;
      case 'baja':
        return AppColors.primaryDarkTeal;
      default:
        return AppColors.neutralTextGray;
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'abierta':
        return AppColors.secondaryCoralRed;
      case 'en proceso':
        return Colors.orange;
      case 'resuelta':
        return AppColors.primaryMediumTeal;
      case 'cerrada':
        return AppColors.primaryDarkTeal;
      default:
        return AppColors.neutralTextGray;
    }
  }

  IconData _getTipoIcon(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'mecánica':
        return Icons.build;
      case 'eléctrica':
        return Icons.electrical_services;
      case 'hidráulica':
        return Icons.water_drop;
      case 'neumática':
        return Icons.air;
      case 'control':
        return Icons.developer_board;
      case 'software':
        return Icons.computer;
      default:
        return Icons.bug_report;
    }
  }

  String _formatDateTime(String isoString) {
    final date = DateTime.parse(isoString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } else if (difference.inDays > 0) {
      return 'Hace ${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours}h';
    } else {
      return 'Hace ${difference.inMinutes}min';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MainLayout(
        currentModule: 'seguimiento_control',
        customTitle: 'Log de Fallas',
        showBackButton: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryDarkTeal),
              SizedBox(height: 16),
              Text(
                'Cargando log de fallas...',
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
      customTitle: 'Log de Fallas',
      showBackButton: true,
      child: Column(
        children: [
          // Header con acciones rápidas
          _buildActionBar(isMobile),

          // Barra de búsqueda y filtros
          _buildSearchAndFilters(isMobile),

          // Estadísticas resumidas
          _buildEnhancedStats(isMobile),

          // Lista/tabla de fallas con paginación
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
                Icons.bug_report,
                color: AppColors.primaryDarkTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Registro de Fallas',
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
                  tooltip: 'Actualizar log',
                  color: AppColors.primaryDarkTeal,
                ),
                IconButton(
                  onPressed: _exportData,
                  icon: const Icon(Icons.download, size: 20),
                  tooltip: 'Exportar log',
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
                      _filterByCriticalFaults();
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
                        Text('Fallas Críticas'),
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
                        hintText: 'Buscar por ID, descripción o equipo...',
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
                            '${filteredFallas.length} de ${fallas.length} fallas',
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
                child: _buildFilterDropdown(
                    'Severidad', selectedSeveridad, severidades, (value) {
              setState(() {
                selectedSeveridad = value!;
              });
              _applyFilters();
            })),
            const SizedBox(width: 8),
            Expanded(
                child:
                    _buildFilterDropdown('Tipo', selectedTipo, tipos, (value) {
              setState(() {
                selectedTipo = value!;
              });
              _applyFilters();
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _buildFilterDropdown('Estado', selectedEstado, estados,
                    (value) {
              setState(() {
                selectedEstado = value!;
              });
              _applyFilters();
            })),
            const SizedBox(width: 8),
            Expanded(
                child: _buildFilterDropdown('Equipo', selectedEquipo, equipos,
                    (value) {
              setState(() {
                selectedEquipo = value!;
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
                child: _buildFilterDropdown(
                    'Severidad', selectedSeveridad, severidades, (value) {
              setState(() {
                selectedSeveridad = value!;
              });
              _applyFilters();
            })),
            const SizedBox(width: 12),
            Expanded(
                child: _buildFilterDropdown('Tipo Falla', selectedTipo, tipos,
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
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: _buildFilterDropdown('Equipo', selectedEquipo, equipos,
                    (value) {
              setState(() {
                selectedEquipo = value!;
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
    final totalFallas = filteredFallas.length;
    final fallasCriticas = filteredFallas
        .where((f) => f['severidad'].toString().toLowerCase() == 'crítica')
        .length;
    final fallasAbiertas = filteredFallas
        .where((f) => f['estado'].toString().toLowerCase() == 'abierta')
        .length;
    final fallasResueltas = filteredFallas
        .where((f) => f['estado'].toString().toLowerCase() == 'resuelta')
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: isMobile
          ? Row(
              children: [
                Expanded(
                  child: _buildCompactStatCard(
                    'Total: $totalFallas',
                    Icons.bug_report,
                    AppColors.primaryDarkTeal,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactStatCard(
                    'Críticas: $fallasCriticas',
                    Icons.error,
                    AppColors.secondaryCoralRed,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactStatCard(
                    'Abiertas: $fallasAbiertas',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        'Total Fallas',
                        totalFallas.toString(),
                        Icons.bug_report,
                        AppColors.primaryDarkTeal)),
                Expanded(
                    child: _buildStatCard('Críticas', fallasCriticas.toString(),
                        Icons.error, AppColors.secondaryCoralRed)),
                Expanded(
                    child: _buildStatCard('Abiertas', fallasAbiertas.toString(),
                        Icons.warning, Colors.orange)),
                Expanded(
                    child: _buildStatCard(
                        'Resueltas',
                        fallasResueltas.toString(),
                        Icons.check_circle,
                        AppColors.primaryDarkTeal)),
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
    if (filteredFallas.isEmpty) {
      return _buildEmptyState();
    }

    final startIndex = currentPage * itemsPerPage;
    final endIndex =
        (startIndex + itemsPerPage).clamp(0, filteredFallas.length);
    final paginatedItems = filteredFallas.sublist(startIndex, endIndex);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8),
      itemCount: paginatedItems.length,
      itemBuilder: (context, index) {
        final falla = paginatedItems[index];
        return _buildExpandableFaultCard(falla);
      },
    );
  }

  Widget _buildExpandableFaultCard(Map<String, dynamic> falla) {
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
            color: _getSeveridadColor(falla['severidad']),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTipoIcon(falla['tipo']),
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          falla['id'],
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
              falla['descripcion'],
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
                    color: _getSeveridadColor(falla['severidad']),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    falla['severidad'],
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
                    color: _getEstadoColor(falla['estado']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    falla['estado'],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _getEstadoColor(falla['estado']),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(falla['fecha']),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.neutralTextGray,
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
                    'Equipo', falla['equipo'], Icons.precision_manufacturing),
                _buildDetailRow('Tipo', falla['tipo'], Icons.category),
                _buildDetailRow(
                    'Reportado por', falla['reportadoPor'], Icons.person),
                if (falla['tiempoResolucion'] != null)
                  _buildDetailRow('Tiempo resolución',
                      falla['tiempoResolucion'], Icons.schedule),
                _buildDetailRow(
                    'Costo estimado',
                    'S/ ${falla['costoEstimado'].toStringAsFixed(0)}',
                    Icons.attach_money),
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
    if (filteredFallas.isEmpty) {
      return _buildEmptyState();
    }

    final startIndex = currentPage * itemsPerPage;
    final endIndex =
        (startIndex + itemsPerPage).clamp(0, filteredFallas.length);
    final paginatedItems = filteredFallas.sublist(startIndex, endIndex);

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
              label: const Text('Fecha'),
              onSort: (columnIndex, ascending) => _sortBy('fecha'),
            ),
            DataColumn(
              label: const Text('ID'),
              onSort: (columnIndex, ascending) => _sortBy('id'),
            ),
            DataColumn(
              label: const Text('Equipo'),
              onSort: (columnIndex, ascending) => _sortBy('equipo'),
            ),
            const DataColumn(label: Text('Tipo')),
            DataColumn(
              label: const Text('Severidad'),
              onSort: (columnIndex, ascending) => _sortBy('severidad'),
            ),
            const DataColumn(label: Text('Estado')),
            const DataColumn(label: Text('Descripción')),
            const DataColumn(label: Text('Reportado por')),
            const DataColumn(label: Text('Tiempo Res.')),
          ],
          rows: paginatedItems.map((falla) {
            return DataRow(
              cells: [
                DataCell(Text(_formatDateTime(falla['fecha']))),
                DataCell(
                  Text(
                    falla['id'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    children: [
                      Icon(
                        _getTipoIcon(falla['tipo']),
                        color: AppColors.primaryDarkTeal,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(falla['equipo']),
                    ],
                  ),
                ),
                DataCell(Text(falla['tipo'])),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSeveridadColor(falla['severidad']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      falla['severidad'],
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
                      color: _getEstadoColor(falla['estado']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      falla['estado'],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 250,
                    child: Text(
                      falla['descripcion'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(falla['reportadoPor'])),
                DataCell(Text(falla['tiempoResolucion'] ?? '-')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  int _getColumnIndex(String column) {
    switch (column) {
      case 'fecha':
        return 0;
      case 'id':
        return 1;
      case 'equipo':
        return 2;
      case 'severidad':
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
            Icons.bug_report_outlined,
            size: 64,
            color: AppColors.neutralTextGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty && !showFilters
                ? 'No hay fallas registradas'
                : 'No se encontraron fallas',
            style: AppTextStyles.heading6.copyWith(
              color: AppColors.neutralTextGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isEmpty && !showFilters
                ? 'El sistema está funcionando correctamente'
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
