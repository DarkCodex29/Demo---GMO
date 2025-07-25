import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class MaterialsPage extends StatefulWidget {
  const MaterialsPage({super.key});

  @override
  MaterialsPageState createState() => MaterialsPageState();
}

class MaterialsPageState extends State<MaterialsPage> {
  List<Map<String, dynamic>> materials = [];
  List<Map<String, dynamic>> filteredMaterials = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      final String response = await rootBundle.loadString('assets/data/materials.json');
      final data = await json.decode(response);
      setState(() {
        materials = List<Map<String, dynamic>>.from(data['materials']);
        filteredMaterials = materials;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar datos de materiales: $e');
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

  void _filterMaterials(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredMaterials = materials;
      } else {
        filteredMaterials = materials.where((material) {
          return material.values.any((value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MainLayout(
        currentModule: 'confiabilidad',
        customTitle: 'Materiales',
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
      currentModule: 'confiabilidad',
      customTitle: 'Materiales',
      showBackButton: true,
      child: ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.COLUMN,
        children: [
          // Search bar
          ResponsiveRowColumnItem(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                ResponsiveValue<double>(
                  context,
                  conditionalValues: [
                    const Condition.smallerThan(name: TABLET, value: 12.0),
                    const Condition.largerThan(name: MOBILE, value: 16.0),
                  ],
                ).value,
                ResponsiveValue<double>(
                  context,
                  conditionalValues: [
                    const Condition.smallerThan(name: TABLET, value: 12.0),
                    const Condition.largerThan(name: MOBILE, value: 16.0),
                  ],
                ).value,
                ResponsiveValue<double>(
                  context,
                  conditionalValues: [
                    const Condition.smallerThan(name: TABLET, value: 12.0),
                    const Condition.largerThan(name: MOBILE, value: 16.0),
                  ],
                ).value,
                8,
              ),
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
                onChanged: _filterMaterials,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar materiales...'
                      : 'Buscar por código, descripción, proveedor o tipo...',
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
                            _filterMaterials('');
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
          ),

          // Materials list
          ResponsiveRowColumnItem(
            child: Expanded(
              child: filteredMaterials.isEmpty
                  ? _buildEmptyState()
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveValue<double>(
                          context,
                          conditionalValues: [
                            const Condition.smallerThan(name: TABLET, value: 12.0),
                            const Condition.largerThan(name: MOBILE, value: 16.0),
                          ],
                        ).value,
                      ),
                      child: isTablet || !isMobile
                          ? _buildDesktopMaterialsTable()
                          : _buildMobileMaterialsList(),
                    ),
            ),
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
            searchQuery.isEmpty
                ? 'No hay materiales disponibles'
                : 'No se encontraron materiales',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.neutralTextGray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileMaterialsList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filteredMaterials.length,
      itemBuilder: (context, index) {
        return _buildMaterialCard(filteredMaterials[index]);
      },
    );
  }

  Widget _buildDesktopMaterialsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutralMediumBorder.withOpacity(0.3)),
        ),
        columnSpacing: ResponsiveValue<double>(
          context,
          conditionalValues: [
            const Condition.smallerThan(name: DESKTOP, value: 20.0),
            const Condition.largerThan(name: TABLET, value: 30.0),
          ],
        ).value,
        dataRowMaxHeight: 60,
        headingRowColor: WidgetStateProperty.all(AppColors.neutralLightBackground),
        columns: [
          DataColumn(
            label: Text(
              'Material',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Descripción',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Stock',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Precio',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Tipo',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
          DataColumn(
            label: Text(
              'Proveedor',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primaryDarkTeal,
              ),
            ),
          ),
        ],
        rows: filteredMaterials.map((material) {
          return DataRow(
            onSelectChanged: (selected) {
              if (selected == true) {
                _showMaterialDetails(material);
              }
            },
            cells: [
              DataCell(
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _getTypeColor(material['tipoMaterial']),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      material['material'] ?? 'N/A',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                SizedBox(
                  width: 200,
                  child: Text(
                    material['descripcion'] ?? 'N/A',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ),
              DataCell(
                Text(
                  material['stockLibre'] ?? 'N/A',
                  style: AppTextStyles.bodySmall,
                ),
              ),
              DataCell(
                Text(
                  '${material['precio'] ?? '0'} ${material['moneda'] ?? ''}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(material['tipoMaterial']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getTypeColor(material['tipoMaterial']).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    material['tipoMaterial'] ?? 'N/A',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: _getTypeColor(material['tipoMaterial']),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              DataCell(
                Text(
                  material['proveedor'] ?? 'N/A',
                  style: AppTextStyles.bodySmall,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutralMediumBorder.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMediumBorder.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showMaterialDetails(material),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ResponsiveRowColumn(
            layout: ResponsiveRowColumnType.ROW,
            children: [
              // Material icon and indicator
              ResponsiveRowColumnItem(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getTypeColor(material['tipoMaterial']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getMaterialIcon(material['tipoMaterial']),
                    color: _getTypeColor(material['tipoMaterial']),
                    size: 20,
                  ),
                ),
              ),
              const ResponsiveRowColumnItem(
                child: SizedBox(width: 12),
              ),
              // Material information
              ResponsiveRowColumnItem(
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              material['material'] ?? 'Sin código',
                              style: AppTextStyles.heading6,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(material['tipoMaterial']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getTypeColor(material['tipoMaterial']).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              material['tipoMaterial'] ?? 'N/A',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: _getTypeColor(material['tipoMaterial']),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        material['descripcion'] ?? 'Sin descripción',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.neutralTextGray.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('Stock', material['stockLibre'] ?? 'N/A'),
                      _buildDetailRow('Precio', '${material['precio'] ?? '0'} ${material['moneda'] ?? ''}'),
                      _buildDetailRow('Proveedor', material['proveedor'] ?? 'N/A'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.neutralTextGray.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String? type) {
    switch (type?.toUpperCase()) {
      case 'EQUIPO':
        return AppColors.primaryDarkTeal;
      case 'REPUESTO':
        return AppColors.secondaryBrightBlue;
      case 'CONSUMIBLE':
        return AppColors.primaryMintGreen;
      case 'HERRAMIENTA':
        return AppColors.secondaryGoldenYellow;
      default:
        return AppColors.neutralTextGray;
    }
  }

  IconData _getMaterialIcon(String? type) {
    switch (type?.toUpperCase()) {
      case 'EQUIPO':
        return Icons.precision_manufacturing;
      case 'REPUESTO':
        return Icons.build;
      case 'CONSUMIBLE':
        return Icons.inventory_2;
      case 'HERRAMIENTA':
        return Icons.handyman;
      default:
        return Icons.category;
    }
  }

  void _showMaterialDetails(Map<String, dynamic> material) {
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
                const Condition.largerThan(name: MOBILE, value: 500.0),
              ],
            ).value,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getTypeColor(material['tipoMaterial']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getMaterialIcon(material['tipoMaterial']),
                          color: _getTypeColor(material['tipoMaterial']),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Material ${material['material'] ?? 'Sin código'}',
                          style: AppTextStyles.heading5,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailSection('Información General', {
                    'codigo': material['material'],
                    'descripcion': material['descripcion'],
                    'tipo_material': material['tipoMaterial'],
                    'unidad_medida': material['unidadMedida'],
                    'clasificacion': material['clasificacion'],
                  }),
                  _buildDetailSection('Stock y Ubicación', {
                    'stock_libre': material['stockLibre'],
                    'centro': material['centro'],
                    'almacen': material['almacen'],
                    'ubicacion_stock': material['ubicacionStock'],
                    'utilizacion': material['utilizacion'],
                  }),
                  _buildDetailSection('Información Comercial', {
                    'precio': '${material['precio']} ${material['moneda']}',
                    'proveedor': material['proveedor'],
                    'fecha_ultima_entrada': material['fechaUltimaEntrada'],
                    'fecha_ultima_salida': material['fechaUltimaSalida'],
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.heading6.copyWith(
            color: AppColors.primaryDarkTeal,
          ),
        ),
        const SizedBox(height: 8),
        ...data.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      _formatFieldName(entry.key),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.neutralTextGray.withOpacity(0.7),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.value?.toString() ?? 'N/A',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatFieldName(String fieldName) {
    return fieldName
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : word)
        .join(' ');
  }
}
