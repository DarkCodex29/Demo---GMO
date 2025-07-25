import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'dart:convert';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';

class StrategiesPage extends StatefulWidget {
  const StrategiesPage({super.key});

  @override
  State<StrategiesPage> createState() => _StrategiesPageState();
}

class _StrategiesPageState extends State<StrategiesPage> {
  String searchQuery = '';
  List<Map<String, dynamic>> procesos = [];
  List<Map<String, dynamic>> filteredProcesos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProcesos();
  }

  Future<void> _loadProcesos() async {
    try {
      final String response = await rootBundle
          .loadString('assets/data/planificacion_mantenimiento.json');
      final List<dynamic> data = json.decode(response);

      setState(() {
        procesos = data.cast<Map<String, dynamic>>();
        filteredProcesos = procesos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error detallado al cargar procesos de planificación: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Error al cargar procesos de planificación: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: AppColors.neutralTextGray,
          ),
        );
      }
    }
  }

  void _filterProcesos(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredProcesos = procesos;
      } else {
        filteredProcesos = procesos.where((proceso) {
          final nombre = proceso['nombre']?.toString().toLowerCase() ?? '';
          final campos = (proceso['campos'] as List)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          final searchLower = query.toLowerCase();

          bool matchNombre = nombre.contains(searchLower);
          bool matchCampos = campos.any((campo) =>
              campo['campo']?.toString().toLowerCase().contains(searchLower) ==
                  true ||
              campo['valor']?.toString().toLowerCase().contains(searchLower) ==
                  true);

          return matchNombre || matchCampos;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MainLayout(
        currentModule: 'confiabilidad',
        customTitle: 'Estrategias de Mantenimiento',
        showBackButton: true,
        child: Center(
          child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(AppColors.primaryMediumTeal),
          ),
        ),
      );
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return MainLayout(
      currentModule: 'confiabilidad',
      customTitle: 'Estrategias de Mantenimiento',
      showBackButton: true,
      child: ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.COLUMN,
        children: [
          // Barra de búsqueda responsiva
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.neutralTextGray,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _filterProcesos,
                style: TextStyle(
                  fontSize: ResponsiveValue<double>(
                    context,
                    conditionalValues: [
                      const Condition.smallerThan(name: TABLET, value: 14.0),
                      const Condition.largerThan(name: MOBILE, value: 16.0),
                    ],
                  ).value,
                ),
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar procesos...'
                      : 'Buscar por proceso, campo o valor...',
                  hintStyle: TextStyle(
                    color: AppColors.neutralTextGray,
                    fontSize: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 13.0),
                        const Condition.largerThan(name: MOBILE, value: 15.0),
                      ],
                    ).value,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 24),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _filterProcesos('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 16.0),
                        const Condition.largerThan(name: MOBILE, value: 20.0),
                      ],
                    ).value,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ),

          // Lista de procesos responsiva
          ResponsiveRowColumnItem(
            child: Expanded(
              child: filteredProcesos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.stacked_line_chart_outlined,
                            size: 64,
                            color: AppColors.neutralTextGray,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            searchQuery.isEmpty
                                ? 'No hay procesos disponibles'
                                : 'No se encontraron procesos',
                            style: TextStyle(
                              fontSize: ResponsiveValue<double>(
                                context,
                                conditionalValues: [
                                  const Condition.smallerThan(
                                      name: TABLET, value: 16.0),
                                  const Condition.largerThan(
                                      name: MOBILE, value: 18.0),
                                ],
                              ).value,
                              color: AppColors.neutralTextGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildProcesosList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcesosList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveValue<double>(
          context,
          conditionalValues: [
            const Condition.smallerThan(name: TABLET, value: 12.0),
            const Condition.largerThan(name: MOBILE, value: 16.0),
          ],
        ).value,
        vertical: 8,
      ),
      itemCount: filteredProcesos.length,
      itemBuilder: (context, index) {
        final proceso = filteredProcesos[index];
        return _buildProcesoCard(proceso, index);
      },
    );
  }

  Widget _buildProcesoCard(Map<String, dynamic> proceso, int index) {
    final tipo = proceso['tipo']?.toString() ?? '';
    final isPrincipal = tipo == 'proceso_principal';
    final statusColor =
        isPrincipal ? AppColors.primaryMediumTeal : AppColors.primaryDarkTeal;
    final statusIcon = isPrincipal ? Icons.engineering : Icons.storage;

    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveValue<double>(
          context,
          conditionalValues: [
            const Condition.smallerThan(name: TABLET, value: 8.0),
            const Condition.largerThan(name: MOBILE, value: 10.0),
          ],
        ).value,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: AppColors.neutralTextGray,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.neutralTextGray, width: 0.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: AppColors.primaryMediumTeal,
            textColor: AppColors.primaryMediumTeal,
            collapsedTextColor: AppColors.neutralTextGray,
            collapsedIconColor: AppColors.primaryMediumTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(
            horizontal: ResponsiveValue<double>(
              context,
              conditionalValues: [
                const Condition.smallerThan(name: TABLET, value: 12.0),
                const Condition.largerThan(name: MOBILE, value: 16.0),
              ],
            ).value,
            vertical: 8,
          ),
          childrenPadding: EdgeInsets.only(
            bottom: ResponsiveValue<double>(
              context,
              conditionalValues: [
                const Condition.smallerThan(name: TABLET, value: 8.0),
                const Condition.largerThan(name: MOBILE, value: 12.0),
              ],
            ).value,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withOpacity(0.4), width: 1),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información principal compacta
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proceso['nombre'] ?? 'Sin nombre',
                      style: TextStyle(
                        fontSize: ResponsiveValue<double>(
                          context,
                          conditionalValues: [
                            const Condition.smallerThan(
                                name: TABLET, value: 14.0),
                            const Condition.largerThan(
                                name: MOBILE, value: 15.0),
                          ],
                        ).value,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutralTextGray,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.category, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isPrincipal
                                ? 'Proceso Principal'
                                : 'Datos Maestros',
                            style: TextStyle(
                              fontSize: ResponsiveValue<double>(
                                context,
                                conditionalValues: [
                                  const Condition.smallerThan(
                                      name: TABLET, value: 11.0),
                                  const Condition.largerThan(
                                      name: MOBILE, value: 12.0),
                                ],
                              ).value,
                              color: AppColors.neutralTextGray,
                              fontWeight: FontWeight.w400,
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

              // Badges a la derecha
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: statusColor.withOpacity(0.4), width: 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.table_chart,
                            size: 10,
                            color: statusColor,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${(proceso['campos'] as List).length} campos',
                            style: TextStyle(
                              fontSize: ResponsiveValue<double>(
                                context,
                                conditionalValues: [
                                  const Condition.smallerThan(
                                      name: TABLET, value: 9.0),
                                  const Condition.largerThan(
                                      name: MOBILE, value: 10.0),
                                ],
                              ).value,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            _buildProcesoDetails(proceso),
          ],
        ),
      ),
    );
  }

  Widget _buildProcesoDetails(Map<String, dynamic> proceso) {
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final campos = (proceso['campos'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveValue<double>(
          context,
          conditionalValues: [
            const Condition.smallerThan(name: TABLET, value: 12.0),
            const Condition.largerThan(name: MOBILE, value: 16.0),
          ],
        ).value,
      ),
      padding: EdgeInsets.all(
        ResponsiveValue<double>(
          context,
          conditionalValues: [
            const Condition.smallerThan(name: TABLET, value: 12.0),
            const Condition.largerThan(name: MOBILE, value: 16.0),
          ],
        ).value,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutralTextGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralTextGray),
      ),
      child: Column(
        children: [
          // Header de detalles
          ResponsiveRowColumn(
            layout: ResponsiveRowColumnType.ROW,
            children: [
              const ResponsiveRowColumnItem(
                child: Icon(Icons.info_outline, size: 20),
              ),
              const ResponsiveRowColumnItem(
                child: SizedBox(width: 8),
              ),
              ResponsiveRowColumnItem(
                child: Text(
                  'Campos del proceso',
                  style: TextStyle(
                    fontSize: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 13.0),
                        const Condition.largerThan(name: MOBILE, value: 14.0),
                      ],
                    ).value,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralTextGray,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
              height: ResponsiveValue<double>(
            context,
            conditionalValues: [
              const Condition.smallerThan(name: TABLET, value: 8.0),
              const Condition.largerThan(name: MOBILE, value: 12.0),
            ],
          ).value),

          // Tabla de campos responsive
          if (isDesktop || isTablet)
            _buildTableView(campos)
          else
            _buildListView(campos),
        ],
      ),
    );
  }

  Widget _buildTableView(List<Map<String, dynamic>> campos) {
    return Table(
      border: TableBorder.all(color: AppColors.neutralTextGray, width: 0.5),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
      },
      children: [
        _buildTableHeader(),
        ...campos.map((campo) => _buildTableRow(
            campo['campo']?.toString() ?? '',
            campo['valor']?.toString() ?? '',
            campo['referencia']?.toString() ?? '')),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: AppColors.neutralTextGray),
      children: [
        _buildTableCell('Campo', isHeader: true),
        _buildTableCell('Valor', isHeader: true),
        _buildTableCell('Referencia', isHeader: true),
      ],
    );
  }

  TableRow _buildTableRow(String campo, String valor, String referencia) {
    return TableRow(
      children: [
        _buildTableCell(campo),
        _buildTableCell(valor.isEmpty ? '(Sin especificar)' : valor),
        _buildTableCell(referencia.isEmpty ? '' : referencia),
      ],
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: ResponsiveValue<double>(
            context,
            conditionalValues: [
              const Condition.smallerThan(name: TABLET, value: 11.0),
              const Condition.largerThan(name: MOBILE, value: 12.0),
            ],
          ).value,
          fontWeight: isHeader ? FontWeight.w600 : FontWeight.w400,
          color: isHeader ? AppColors.neutralTextGray : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> campos) {
    return Column(
      children: campos
          .map((campo) => _buildDetailRow(
              campo['campo']?.toString() ?? '',
              campo['valor']?.toString() ?? '',
              campo['referencia']?.toString() ?? ''))
          .toList(),
    );
  }

  Widget _buildDetailRow(String label, String value, String referencia) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppColors.neutralTextGray, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 12.0),
                        const Condition.largerThan(name: MOBILE, value: 13.0),
                      ],
                    ).value,
                    fontWeight: FontWeight.w500,
                    color: AppColors.neutralTextGray,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value.isEmpty ? '(Sin especificar)' : value,
                  style: TextStyle(
                    fontSize: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 12.0),
                        const Condition.largerThan(name: MOBILE, value: 13.0),
                      ],
                    ).value,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          if (referencia.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.link, size: 12),
                const SizedBox(width: 4),
                Text(
                  'Ref: $referencia',
                  style: TextStyle(
                    fontSize: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 10.0),
                        const Condition.largerThan(name: MOBILE, value: 11.0),
                      ],
                    ).value,
                    color: AppColors.primaryMediumTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
