import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class StockReportPage extends StatefulWidget {
  const StockReportPage({super.key});

  @override
  StockReportPageState createState() => StockReportPageState();
}

class StockReportPageState extends State<StockReportPage> {
  List<Map<String, dynamic>> materials = [];
  List<Map<String, dynamic>> filteredMaterials = [];
  bool isLoading = true;
  String searchQuery = '';
  Timer? _debounceTimer;

  // Filtros
  String selectedCentro = 'Todos';
  String selectedAlmacen = 'Todos';
  String selectedTipoMaterial = 'Todos';
  String selectedClasificacion = 'Todos';
  String selectedStockStatus = 'Todos';
  bool showFilters = false;

  Set<String> centros = {'Todos'};
  Set<String> almacenes = {'Todos'};
  Set<String> tiposMaterial = {'Todos'};
  Set<String> clasificaciones = {'Todos'};

  // Ordenamiento
  String sortColumn = '';
  bool sortAscending = true;

  // Paginación
  int currentPage = 0;
  int itemsPerPage = 10;
  int get totalPages => (filteredMaterials.length / itemsPerPage).ceil();

  // Controladores
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    setState(() => isLoading = true);
    
    try {
      final String response = await rootBundle.loadString('assets/data/materials.json');
      final Map<String, dynamic> data = json.decode(response);
      
      setState(() {
        materials = List<Map<String, dynamic>>.from(data['materials']);
        filteredMaterials = materials;
        
        // Extraer valores únicos para filtros
        for (var material in materials) {
          centros.add(material['centro']?.toString() ?? '');
          almacenes.add(material['almacen']?.toString() ?? '');
          tiposMaterial.add(material['tipoMaterial']?.toString() ?? '');
          clasificaciones.add(material['clasificacion']?.toString() ?? '');
        }
        
        isLoading = false;
      });

      _checkCriticalStock();
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error al cargar materiales: $e');
      _showErrorSnackBar('Error al cargar materiales: ${e.toString()}');
    }
  }

  void _checkCriticalStock() {
    final criticalItems = materials.where((m) {
      final stockValue = int.tryParse(m['stockLibre'].toString().split(' ').first) ?? 0;
      return stockValue <= 5;
    }).length;

    if (criticalItems > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCriticalStockAlert(criticalItems);
      });
    }
  }

  void _showCriticalStockAlert(int count) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: AppColors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('⚠️ $count materiales con stock crítico (≤5 unidades)'),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _filterByCriticalStock();
              },
              child: const Text('VER', style: TextStyle(color: AppColors.white)),
            ),
          ],
        ),
        backgroundColor: AppColors.secondaryCoralRed,
        duration: const Duration(seconds: 8),
        action: SnackBarAction(
          label: 'CERRAR',
          textColor: AppColors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _filterByCriticalStock() {
    setState(() {
      selectedStockStatus = 'Crítico';
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
      filteredMaterials = materials.where((material) {
        final matchesSearch = searchQuery.isEmpty ||
            material['material'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
            material['descripcion'].toString().toLowerCase().contains(searchQuery.toLowerCase());
            
        final matchesCentro = selectedCentro == 'Todos' || 
            material['centro'].toString() == selectedCentro;
            
        final matchesAlmacen = selectedAlmacen == 'Todos' || 
            material['almacen'].toString() == selectedAlmacen;
            
        final matchesTipo = selectedTipoMaterial == 'Todos' || 
            material['tipoMaterial'].toString() == selectedTipoMaterial;
            
        final matchesClasificacion = selectedClasificacion == 'Todos' || 
            material['clasificacion'].toString() == selectedClasificacion;

        final stockValue = int.tryParse(material['stockLibre'].toString().split(' ').first) ?? 0;
        final matchesStockStatus = selectedStockStatus == 'Todos' ||
            (selectedStockStatus == 'Crítico' && stockValue <= 5) ||
            (selectedStockStatus == 'Bajo' && stockValue > 5 && stockValue <= 25) ||
            (selectedStockStatus == 'Normal' && stockValue > 25);

        return matchesSearch && matchesCentro && matchesAlmacen && 
               matchesTipo && matchesClasificacion && matchesStockStatus;
      }).toList();

      _applySorting();
      currentPage = 0;
    });
  }

  void _applySorting() {
    if (sortColumn.isEmpty) return;

    filteredMaterials.sort((a, b) {
      dynamic aValue = a[sortColumn];
      dynamic bValue = b[sortColumn];

      if (sortColumn == 'stockLibre') {
        aValue = int.tryParse(aValue.toString().split(' ').first) ?? 0;
        bValue = int.tryParse(bValue.toString().split(' ').first) ?? 0;
      } else if (sortColumn == 'precio') {
        aValue = double.tryParse(aValue?.toString() ?? '0') ?? 0;
        bValue = double.tryParse(bValue?.toString() ?? '0') ?? 0;
      }

      final comparison = aValue.toString().toLowerCase().compareTo(bValue.toString().toLowerCase());
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
      selectedCentro = 'Todos';
      selectedAlmacen = 'Todos';
      selectedTipoMaterial = 'Todos';
      selectedClasificacion = 'Todos';
      selectedStockStatus = 'Todos';
      searchQuery = '';
      sortColumn = '';
      currentPage = 0;
      _searchController.clear();
      filteredMaterials = materials;
    });
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.download, color: AppColors.white),
            SizedBox(width: 8),
            Text('Exportando datos... (Funcionalidad pendiente)'),
          ],
        ),
        backgroundColor: AppColors.primaryDarkTeal,
      ),
    );
  }

  void _refreshData() {
    _loadMaterials();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.refresh, color: AppColors.white),
            SizedBox(width: 8),
            Text('Datos actualizados'),
          ],
        ),
        backgroundColor: AppColors.secondaryAquaGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.secondaryCoralRed,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Color _getStockColor(String stockLibre) {
    final stockValue = int.tryParse(stockLibre.split(' ').first) ?? 0;
    if (stockValue <= 5) return AppColors.secondaryCoralRed;
    if (stockValue <= 25) return AppColors.primaryMediumTeal;
    return AppColors.primaryDarkTeal;
  }

  String _getStockStatus(String stockLibre) {
    final stockValue = int.tryParse(stockLibre.split(' ').first) ?? 0;
    if (stockValue <= 5) return 'Crítico';
    if (stockValue <= 25) return 'Bajo';
    return 'Normal';
  }

  Color _getClasificacionColor(String clasificacion) {
    switch (clasificacion.toUpperCase()) {
      case 'A': return AppColors.secondaryCoralRed;
      case 'B': return AppColors.primaryMediumTeal;
      case 'C': return AppColors.primaryDarkTeal;
      default: return AppColors.neutralTextGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MainLayout(
        currentModule: 'seguimiento_control',
        customTitle: 'Reporte de Stock',
        showBackButton: true,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primaryDarkTeal),
              SizedBox(height: 16),
              Text(
                'Cargando inventario...',
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
      customTitle: 'Reporte de Stock',
      showBackButton: true,
      child: Column(
        children: [
          // Header con acciones rápidas
          _buildActionBar(isMobile),

          // Barra de búsqueda y filtros
          _buildSearchAndFilters(isMobile),

          // Estadísticas resumidas mejoradas
          _buildEnhancedStats(isMobile),

          // Lista/tabla de materiales con paginación
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
              Icon(
                Icons.inventory_2,
                color: AppColors.primaryDarkTeal,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Gestión de Inventario',
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
                icon: const Icon(Icons.more_vert, color: AppColors.primaryDarkTeal),
                onSelected: (value) {
                  switch (value) {
                    case 'refresh':
                      _refreshData();
                      break;
                    case 'export':
                      _exportData();
                      break;
                    case 'critical':
                      _filterByCriticalStock();
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
                        Icon(Icons.warning, size: 16, color: AppColors.secondaryCoralRed),
                        SizedBox(width: 8),
                        Text('Stock Crítico'),
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
              // Búsqueda mejorada
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar por código, descripción o ubicación...',
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
                          borderSide: BorderSide(color: AppColors.neutralMediumBorder),
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
                      color: showFilters ? AppColors.secondaryCoralRed : AppColors.primaryDarkTeal,
                    ),
                    tooltip: showFilters ? 'Ocultar filtros' : 'Mostrar filtros',
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
                            '${filteredMaterials.length} de ${materials.length} materiales',
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
            Expanded(child: _buildFilterDropdown('Centro', selectedCentro, centros, (value) {
              setState(() { selectedCentro = value!; });
              _applyFilters();
            })),
            const SizedBox(width: 8),
            Expanded(child: _buildFilterDropdown('Almacén', selectedAlmacen, almacenes, (value) {
              setState(() { selectedAlmacen = value!; });
              _applyFilters();
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildFilterDropdown('Tipo', selectedTipoMaterial, tiposMaterial, (value) {
              setState(() { selectedTipoMaterial = value!; });
              _applyFilters();
            })),
            const SizedBox(width: 8),
            Expanded(child: _buildFilterDropdown('Clase', selectedClasificacion, clasificaciones, (value) {
              setState(() { selectedClasificacion = value!; });
              _applyFilters();
            })),
          ],
        ),
        const SizedBox(height: 8),
        _buildFilterDropdown('Estado Stock', selectedStockStatus, {'Todos', 'Crítico', 'Bajo', 'Normal'}, (value) {
          setState(() { selectedStockStatus = value!; });
          _applyFilters();
        }),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildFilterDropdown('Centro', selectedCentro, centros, (value) {
              setState(() { selectedCentro = value!; });
              _applyFilters();
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildFilterDropdown('Almacén', selectedAlmacen, almacenes, (value) {
              setState(() { selectedAlmacen = value!; });
              _applyFilters();
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildFilterDropdown('Tipo Material', selectedTipoMaterial, tiposMaterial, (value) {
              setState(() { selectedTipoMaterial = value!; });
              _applyFilters();
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildFilterDropdown('Clasificación', selectedClasificacion, clasificaciones, (value) {
              setState(() { selectedClasificacion = value!; });
              _applyFilters();
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildFilterDropdown('Estado Stock', selectedStockStatus, {'Todos', 'Crítico', 'Bajo', 'Normal'}, (value) {
              setState(() { selectedStockStatus = value!; });
              _applyFilters();
            })),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()), // Espacio vacío para alineación
          ],
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, String value, Set<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.neutralMediumBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryDarkTeal, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      style: AppTextStyles.bodyMedium,
      items: items.map((item) => DropdownMenuItem(
        value: item, 
        child: Text(item, style: AppTextStyles.bodyMedium),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildEnhancedStats(bool isMobile) {
    final totalMateriales = filteredMaterials.length;
    final stockCritico = filteredMaterials.where((m) {
      final stockValue = int.tryParse(m['stockLibre'].toString().split(' ').first) ?? 0;
      return stockValue <= 5;
    }).length;
    
    final stockBajo = filteredMaterials.where((m) {
      final stockValue = int.tryParse(m['stockLibre'].toString().split(' ').first) ?? 0;
      return stockValue > 5 && stockValue <= 25;
    }).length;
    
    final valorTotal = filteredMaterials.fold<double>(0, (sum, material) {
      final precio = double.tryParse(material['precio']?.toString() ?? '0') ?? 0;
      final stockValue = int.tryParse(material['stockLibre'].toString().split(' ').first) ?? 0;
      return sum + (precio * stockValue);
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: isMobile
          ? Row(
              children: [
                Expanded(
                  child: _buildCompactStatCard(
                    'Total: $totalMateriales',
                    Icons.inventory_2,
                    AppColors.primaryDarkTeal,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactStatCard(
                    'Crítico: $stockCritico',
                    Icons.error,
                    AppColors.secondaryCoralRed,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCompactStatCard(
                    'Bajo: $stockBajo',
                    Icons.warning,
                    AppColors.primaryMediumTeal,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Expanded(child: _buildStatCard('Total Materiales', totalMateriales.toString(), Icons.inventory_2, AppColors.primaryDarkTeal)),
                Expanded(child: _buildStatCard('Stock Crítico', stockCritico.toString(), Icons.error, AppColors.secondaryCoralRed)),
                Expanded(child: _buildStatCard('Stock Bajo', stockBajo.toString(), Icons.warning, AppColors.primaryMediumTeal)),
                Expanded(child: _buildStatCard('Valor Total', 'S/ ${valorTotal.toStringAsFixed(0)}', Icons.attach_money, AppColors.primaryDarkTeal)),
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
    if (filteredMaterials.isEmpty) {
      return _buildEmptyState();
    }

    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, filteredMaterials.length);
    final paginatedItems = filteredMaterials.sublist(startIndex, endIndex);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 8),
      itemCount: paginatedItems.length,
      itemBuilder: (context, index) {
        final material = paginatedItems[index];
        return _buildExpandableMaterialCard(material);
      },
    );
  }

  Widget _buildExpandableMaterialCard(Map<String, dynamic> material) {
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
            color: _getStockColor(material['stockLibre']),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.inventory_2,
            color: AppColors.white,
            size: 20,
          ),
        ),
        title: Text(
          material['material'],
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
              material['descripcion'],
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStockColor(material['stockLibre']),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    material['stockLibre'],
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStockColor(material['stockLibre']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStockStatus(material['stockLibre']),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _getStockColor(material['stockLibre']),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.neutralLightBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildDetailRow('Centro', material['centro'], Icons.business),
                _buildDetailRow('Almacén', material['almacen'], Icons.store),
                _buildDetailRow('Tipo Material', material['tipoMaterial'], Icons.category),
                _buildDetailRow('Ubicación', material['ubicacionStock'], Icons.location_on),
                _buildDetailRow('Precio Unitario', 'S/ ${material['precio']}', Icons.attach_money),
                Row(
                  children: [
                    const Icon(Icons.label, size: 16, color: AppColors.neutralTextGray),
                    const SizedBox(width: 8),
                    const Text('Clasificación: '),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getClasificacionColor(material['clasificacion']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Clase ${material['clasificacion']}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
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
    if (filteredMaterials.isEmpty) {
      return _buildEmptyState();
    }

    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, filteredMaterials.length);
    final paginatedItems = filteredMaterials.sublist(startIndex, endIndex);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          sortColumnIndex: sortColumn.isEmpty ? null : _getColumnIndex(sortColumn),
          sortAscending: sortAscending,
          columns: [
            DataColumn(
              label: const Text('Material'),
              onSort: (columnIndex, ascending) => _sortBy('material'),
            ),
            DataColumn(
              label: const Text('Centro'),
              onSort: (columnIndex, ascending) => _sortBy('centro'),
            ),
            DataColumn(
              label: const Text('Almacén'),
              onSort: (columnIndex, ascending) => _sortBy('almacen'),
            ),
            DataColumn(
              label: const Text('Stock'),
              onSort: (columnIndex, ascending) => _sortBy('stockLibre'),
              numeric: true,
            ),
            const DataColumn(label: Text('Estado')),
            const DataColumn(label: Text('Descripción')),
            const DataColumn(label: Text('Tipo')),
            const DataColumn(label: Text('Clase')),
            DataColumn(
              label: const Text('Precio'),
              onSort: (columnIndex, ascending) => _sortBy('precio'),
              numeric: true,
            ),
            const DataColumn(label: Text('Ubicación')),
          ],
          rows: paginatedItems.map((material) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    material['material'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(Text(material['centro'])),
                DataCell(Text(material['almacen'])),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStockColor(material['stockLibre']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      material['stockLibre'],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStockColor(material['stockLibre']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getStockStatus(material['stockLibre']),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _getStockColor(material['stockLibre']),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      material['descripcion'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.neutralLightBackground,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      material['tipoMaterial'],
                      style: AppTextStyles.labelSmall,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getClasificacionColor(material['clasificacion']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      material['clasificacion'],
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(Text('S/ ${material['precio']}')),
                DataCell(Text(material['ubicacionStock'])),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  int _getColumnIndex(String column) {
    switch (column) {
      case 'material': return 0;
      case 'centro': return 1;
      case 'almacen': return 2;
      case 'stockLibre': return 3;
      case 'precio': return 8;
      default: return 0;
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
                onPressed: currentPage > 0 ? () {
                  setState(() {
                    currentPage--;
                  });
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } : null,
                icon: const Icon(Icons.chevron_left),
                color: currentPage > 0 ? AppColors.primaryDarkTeal : AppColors.neutralTextGray,
              ),
              IconButton(
                onPressed: currentPage < totalPages - 1 ? () {
                  setState(() {
                    currentPage++;
                  });
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } : null,
                icon: const Icon(Icons.chevron_right),
                color: currentPage < totalPages - 1 ? AppColors.primaryDarkTeal : AppColors.neutralTextGray,
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
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.neutralTextGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty && !showFilters
                ? 'No hay materiales disponibles'
                : 'No se encontraron materiales',
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