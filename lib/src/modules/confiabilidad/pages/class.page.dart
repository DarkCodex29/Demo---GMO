import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class ClasesPage extends StatefulWidget {
  const ClasesPage({super.key});

  @override
  ClasesPageState createState() => ClasesPageState();
}

class ClasesPageState extends State<ClasesPage> {
  List<Map<String, dynamic>> clases = [];
  List<Map<String, dynamic>> filteredClases = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadClases();
  }

  Future<void> _loadClases() async {
    try {
      final String response = await rootBundle.loadString('assets/data/class.json');
      final data = await json.decode(response);
      setState(() {
        clases = List<Map<String, dynamic>>.from(data['clases']);
        filteredClases = clases;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error al cargar datos de clases: $e');
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

  void _filterClases(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredClases = clases;
      } else {
        filteredClases = clases.where((clase) {
          return clase.values.any((value) =>
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
        customTitle: 'Clases',
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
      customTitle: 'Clases',
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
                onChanged: _filterClases,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar clases...'
                      : 'Buscar por clase, categoría o características...',
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
                            _filterClases('');
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

          // Classes list
          ResponsiveRowColumnItem(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: filteredClases.isEmpty
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
                          ? _buildDesktopClassGrid()
                          : _buildMobileClassList(),
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
            Icons.category_outlined,
            size: 64,
            color: AppColors.neutralTextGray.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isEmpty
                ? 'No hay clases disponibles'
                : 'No se encontraron clases',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.neutralTextGray.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileClassList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: filteredClases.length,
      itemBuilder: (context, index) {
        return _buildClassCard(filteredClases[index]);
      },
    );
  }

  Widget _buildDesktopClassGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: ResponsiveValue<double>(
          context,
          conditionalValues: [
            const Condition.smallerThan(name: DESKTOP, value: 400.0),
            const Condition.largerThan(name: TABLET, value: 500.0),
          ],
        ).value,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: filteredClases.length,
      itemBuilder: (context, index) {
        return _buildClassCard(filteredClases[index]);
      },
    );
  }

  Widget _buildClassCard(Map<String, dynamic> clase) {
    return Container(
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
        onTap: () => _showClassDetails(clase),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDarkTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.category,
                      color: AppColors.primaryDarkTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      clase['claseEquipo'] ?? 'Sin nombre',
                      style: AppTextStyles.heading6,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Categoría', clase['categoriaClase'] ?? 'N/A'),
              _buildDetailRow('Válido desde', clase['validoDe'] ?? 'N/A'),
              const SizedBox(height: 8),
              if (clase['caracteristicas'] != null && clase['caracteristicas'].isNotEmpty) ...[
                Text(
                  'Características:',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: (clase['caracteristicas'] as List)
                      .take(2)
                      .map((carac) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMintGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primaryMintGreen.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              carac.toString(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primaryMintGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ver detalles',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primaryDarkTeal,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryDarkTeal,
                    size: 16,
                  ),
                ],
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

  void _showClassDetails(Map<String, dynamic> clase) {
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
                          color: AppColors.primaryDarkTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.category,
                          color: AppColors.primaryDarkTeal,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Clase: ${clase['claseEquipo'] ?? 'Sin nombre'}',
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
                  _buildClassSection('Información General', {
                    'categoria_clase': clase['categoriaClase'],
                    'clase_equipo': clase['claseEquipo'],
                    'valido_desde': clase['validoDe'],
                  }),
                  if (clase['caracteristicas'] != null) ...[
                    _buildCharacteristicsSection(clase['caracteristicas']),
                  ],
                  if (clase['datosAdicionales'] != null) ...[
                    _buildClassSection('Datos Adicionales', clase['datosAdicionales']),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildClassSection(String title, Map<String, dynamic> data) {
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

  Widget _buildCharacteristicsSection(List<dynamic> characteristics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Características',
          style: AppTextStyles.heading6.copyWith(
            color: AppColors.primaryDarkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: characteristics.map((carac) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryMintGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryMintGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primaryMintGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      carac.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryMintGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )).toList(),
        ),
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
