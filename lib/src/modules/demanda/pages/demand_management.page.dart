import 'package:flutter/material.dart';
import 'package:demo/src/core/services/notification_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';

class DemandManagementPage extends StatefulWidget {
  const DemandManagementPage({super.key});

  @override
  DemandManagementPageState createState() => DemandManagementPageState();
}

class DemandManagementPageState extends State<DemandManagementPage> {
  List<dynamic> demandas = [];
  List<dynamic> filteredDemandas = [];
  bool isLoading = true;
  String searchQuery = '';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _claseAvisoController = TextEditingController();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _autorController = TextEditingController();
  final TextEditingController _sintomaController = TextEditingController();
  final TextEditingController _causaController = TextEditingController();
  final TextEditingController _tiempoReparacionController =
      TextEditingController();

  final List<String> clasesAviso = ['m1', 'm2', 'm3', 'm4'];
  final List<String> prioridades = ['BAJA', 'MEDIA', 'ALTA', 'CRITICA'];
  final List<String> sintomas = [
    'Ruido',
    'Fuga',
    'Vibración',
    'Temperatura alta',
    'Otros'
  ];

  String? selectedClaseAviso;
  String? selectedPrioridad;
  String? selectedSintoma;

  @override
  void initState() {
    super.initState();
    _loadDemandas();
    _autorController.text = 'usuario_actual';
  }

  Future<void> _loadDemandas() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/demandas.json');
      final data = json.decode(response);
      setState(() {
        demandas = data['demandas'] ?? [];
        filteredDemandas = demandas;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error al cargar datos: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
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
          final titulo = demanda['tituloAviso']?.toString().toLowerCase() ?? '';
          final descripcion =
              demanda['descripcionAviso']?.toString().toLowerCase() ?? '';
          final claseAviso =
              demanda['claseAviso']?.toString().toLowerCase() ?? '';
          final autor = demanda['autor']?.toString().toLowerCase() ?? '';
          final sintoma = demanda['sintoma']?.toString().toLowerCase() ?? '';

          final searchLower = query.toLowerCase();

          return titulo.contains(searchLower) ||
              descripcion.contains(searchLower) ||
              claseAviso.contains(searchLower) ||
              autor.contains(searchLower) ||
              sintoma.contains(searchLower);
        }).toList();
      }
    });
  }

  String _formatValue(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return '(Sin especificar)';
    }
    return value.toString();
  }

  Color _getPriorityColor(String? sintoma) {
    if (sintoma == null || sintoma.trim().isEmpty) return Colors.grey;

    switch (sintoma.toLowerCase()) {
      case 'ruido':
        return Colors.orange;
      case 'vibración':
        return Colors.red;
      case 'temperatura':
        return Colors.deepOrange;
      case 'fuga':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  IconData _getPriorityIcon(String? sintoma) {
    if (sintoma == null || sintoma.trim().isEmpty) return Icons.help_outline;

    switch (sintoma.toLowerCase()) {
      case 'ruido':
        return Icons.volume_up;
      case 'vibración':
        return Icons.vibration;
      case 'temperatura':
        return Icons.thermostat;
      case 'fuga':
        return Icons.water_drop;
      default:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return MainLayout(
      currentModule: 'demanda',
      customTitle: 'Gestión de Demandas',
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
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _filterDemandas,
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
                      ? 'Buscar demandas...'
                      : 'Buscar por título, descripción, clase, autor...',
                  hintStyle: TextStyle(
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
                          onPressed: () => _filterDemandas(''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 12.0),
                        const Condition.largerThan(name: MOBILE, value: 16.0),
                      ],
                    ).value,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Badge de resultados responsivo
          if (searchQuery.isNotEmpty)
            ResponsiveRowColumnItem(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveValue<double>(
                    context,
                    conditionalValues: [
                      const Condition.smallerThan(name: TABLET, value: 12.0),
                      const Condition.largerThan(name: MOBILE, value: 16.0),
                    ],
                  ).value,
                  vertical: 4,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: ResponsiveRowColumn(
                  layout: ResponsiveRowColumnType.ROW,
                  rowMainAxisSize: MainAxisSize.min,
                  children: [
                    ResponsiveRowColumnItem(
                      child: Icon(Icons.filter_list,
                          color: Colors.orange.shade700, size: 18),
                    ),
                    const ResponsiveRowColumnItem(
                      child: SizedBox(width: 6),
                    ),
                    ResponsiveRowColumnItem(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${filteredDemandas.length} resultado${filteredDemandas.length != 1 ? 's' : ''} encontrado${filteredDemandas.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: ResponsiveValue<double>(
                              context,
                              conditionalValues: [
                                const Condition.smallerThan(
                                    name: TABLET, value: 11.0),
                                const Condition.largerThan(
                                    name: MOBILE, value: 13.0),
                              ],
                            ).value,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Lista de demandas responsiva
          ResponsiveRowColumnItem(
            child: Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          SizedBox(
                              height: ResponsiveValue<double>(
                            context,
                            conditionalValues: [
                              const Condition.smallerThan(
                                  name: TABLET, value: 12.0),
                              const Condition.largerThan(
                                  name: MOBILE, value: 16.0),
                            ],
                          ).value),
                          Text(
                            'Cargando demandas...',
                            style: TextStyle(
                              fontSize: ResponsiveValue<double>(
                                context,
                                conditionalValues: [
                                  const Condition.smallerThan(
                                      name: TABLET, value: 14.0),
                                  const Condition.largerThan(
                                      name: MOBILE, value: 16.0),
                                ],
                              ).value,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : filteredDemandas.isEmpty
                      ? _buildEmptyState()
                      : _buildDemandsList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          ResponsiveValue<double>(
            context,
            conditionalValues: [
              const Condition.smallerThan(name: TABLET, value: 16.0),
              const Condition.largerThan(name: MOBILE, value: 24.0),
            ],
          ).value,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2,
              size: ResponsiveValue<double>(
                context,
                conditionalValues: [
                  const Condition.smallerThan(name: TABLET, value: 64.0),
                  const Condition.largerThan(name: MOBILE, value: 80.0),
                ],
              ).value,
              color: Colors.grey[400],
            ),
            SizedBox(
                height: ResponsiveValue<double>(
              context,
              conditionalValues: [
                const Condition.smallerThan(name: TABLET, value: 12.0),
                const Condition.largerThan(name: MOBILE, value: 16.0),
              ],
            ).value),
            Text(
              searchQuery.isNotEmpty
                  ? 'No se encontraron resultados'
                  : 'No hay demandas disponibles',
              style: TextStyle(
                fontSize: ResponsiveValue<double>(
                  context,
                  conditionalValues: [
                    const Condition.smallerThan(name: TABLET, value: 16.0),
                    const Condition.largerThan(name: MOBILE, value: 18.0),
                  ],
                ).value,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
                height: ResponsiveValue<double>(
              context,
              conditionalValues: [
                const Condition.smallerThan(name: TABLET, value: 6.0),
                const Condition.largerThan(name: MOBILE, value: 8.0),
              ],
            ).value),
            Text(
              searchQuery.isNotEmpty
                  ? 'Intenta con otros términos de búsqueda'
                  : 'Las demandas aparecerán aquí cuando estén disponibles',
              style: TextStyle(
                fontSize: ResponsiveValue<double>(
                  context,
                  conditionalValues: [
                    const Condition.smallerThan(name: TABLET, value: 12.0),
                    const Condition.largerThan(name: MOBILE, value: 14.0),
                  ],
                ).value,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (searchQuery.isNotEmpty) ...[
              SizedBox(
                  height: ResponsiveValue<double>(
                context,
                conditionalValues: [
                  const Condition.smallerThan(name: TABLET, value: 12.0),
                  const Condition.largerThan(name: MOBILE, value: 16.0),
                ],
              ).value),
              ElevatedButton.icon(
                onPressed: () => _filterDemandas(''),
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar búsqueda'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDemandsList() {
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
      itemCount: filteredDemandas.length,
      itemBuilder: (context, index) {
        final demanda = filteredDemandas[index];
        return _buildDemandCard(demanda, index);
      },
    );
  }

  Widget _buildDemandCard(Map<String, dynamic> demanda, int index) {
    final sintoma = demanda['sintoma']?.toString() ?? '';
    final priorityColor = _getPriorityColor(sintoma);
    final priorityIcon = _getPriorityIcon(sintoma);
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: const ExpansionTileThemeData(
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
              color: priorityColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: priorityColor.withOpacity(0.4), width: 1),
            ),
            child: Icon(
              priorityIcon,
              color: priorityColor,
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
                      _formatValue(demanda['tituloAviso']),
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
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatValue(demanda['autor']),
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
                              color: Colors.grey[600],
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

              // Badges y fecha a la derecha
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Badges horizontales compactos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.orange.shade300, width: 0.5),
                          ),
                          child: Text(
                            _formatValue(demanda['claseAviso']),
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
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: priorityColor.withOpacity(0.4),
                                width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.medical_services,
                                size: 10,
                                color: priorityColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                sintoma.isNotEmpty
                                    ? sintoma.substring(0,
                                        sintoma.length > 4 ? 4 : sintoma.length)
                                    : 'N/A',
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
                                  color: priorityColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Fecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.calendar_today, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          _formatValue(demanda['fechaInicio']),
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
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          children: [
            _buildDemandDetails(demanda),
          ],
        ),
      ),
    );
  }

  Widget _buildDemandDetails(Map<String, dynamic> demanda) {
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
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
                  'Detalles de la Demanda',
                  style: TextStyle(
                    fontSize: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 13.0),
                        const Condition.largerThan(name: MOBILE, value: 14.0),
                      ],
                    ).value,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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

          // Tabla de detalles responsive
          if (isDesktop || isTablet)
            _buildTableView(demanda)
          else
            _buildColumnView(demanda),
        ],
      ),
    );
  }

  Widget _buildTableView(Map<String, dynamic> demanda) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(2),
      },
      children: [
        _buildTableRow('Clase de Aviso:', demanda['claseAviso']),
        _buildTableRow('Título:', demanda['tituloAviso']),
        _buildTableRow('Descripción:', demanda['descripcionAviso']),
        _buildTableRow('Fecha de Inicio:', demanda['fechaInicio']),
        _buildTableRow('Autor:', demanda['autor']),
        _buildTableRow('Síntoma:', demanda['sintoma']),
        _buildTableRow('Causa:', demanda['causa']),
        _buildTableRow('Tiempo de Reparación:', demanda['tiempoReparacion']),
      ],
    );
  }

  Widget _buildColumnView(Map<String, dynamic> demanda) {
    return Column(
      children: [
        _buildDetailRow('Clase de Aviso', demanda['claseAviso']),
        _buildDetailRow('Título', demanda['tituloAviso']),
        _buildDetailRow('Descripción', demanda['descripcionAviso']),
        _buildDetailRow('Fecha de Inicio', demanda['fechaInicio']),
        _buildDetailRow('Autor', demanda['autor']),
        _buildDetailRow('Síntoma', demanda['sintoma']),
        _buildDetailRow('Causa', demanda['causa']),
        _buildDetailRow('Tiempo de Reparación', demanda['tiempoReparacion']),
      ],
    );
  }

  TableRow _buildTableRow(String field, dynamic value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            field,
            style: TextStyle(
              fontSize: ResponsiveValue<double>(
                context,
                conditionalValues: [
                  const Condition.smallerThan(name: TABLET, value: 12.0),
                  const Condition.largerThan(name: MOBILE, value: 13.0),
                ],
              ).value,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            _formatValue(value),
            style: TextStyle(
              fontSize: ResponsiveValue<double>(
                context,
                conditionalValues: [
                  const Condition.smallerThan(name: TABLET, value: 12.0),
                  const Condition.largerThan(name: MOBILE, value: 13.0),
                ],
              ).value,
              color: value == null || value.toString().trim().isEmpty
                  ? Colors.grey[500]
                  : Colors.black87,
              fontWeight: FontWeight.w400,
              fontStyle: value == null || value.toString().trim().isEmpty
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String field, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.ROW,
        rowCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveRowColumnItem(
            rowFlex: 2,
            child: Text(
              '$field:',
              style: TextStyle(
                fontSize: ResponsiveValue<double>(
                  context,
                  conditionalValues: [
                    const Condition.smallerThan(name: TABLET, value: 12.0),
                    const Condition.largerThan(name: MOBILE, value: 13.0),
                  ],
                ).value,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          ResponsiveRowColumnItem(
            rowFlex: 3,
            child: Text(
              _formatValue(value),
              style: TextStyle(
                fontSize: ResponsiveValue<double>(
                  context,
                  conditionalValues: [
                    const Condition.smallerThan(name: TABLET, value: 12.0),
                    const Condition.largerThan(name: MOBILE, value: 13.0),
                  ],
                ).value,
                color: value == null || value.toString().trim().isEmpty
                    ? Colors.grey[500]
                    : Colors.black87,
                fontWeight: FontWeight.w400,
                fontStyle: value == null || value.toString().trim().isEmpty
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDemandDialog() {
    // Limpiar controladores
    _claseAvisoController.clear();
    _tituloController.clear();
    _descripcionController.clear();
    _sintomaController.clear();
    _causaController.clear();
    _tiempoReparacionController.clear();
    selectedClaseAviso = null;
    selectedPrioridad = null;
    selectedSintoma = null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Demanda'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Clase de aviso',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedClaseAviso,
                    items: clasesAviso.map((clase) {
                      return DropdownMenuItem(
                        value: clase,
                        child: Text(clase),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedClaseAviso = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Seleccione una clase' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título de aviso',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese un título'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción del aviso',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingrese una descripción'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Síntoma',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedSintoma,
                    items: sintomas.map((sintoma) {
                      return DropdownMenuItem(
                        value: sintoma,
                        child: Text(sintoma),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSintoma = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _causaController,
                    decoration: const InputDecoration(
                      labelText: 'Causa (opcional)',
                      border: OutlineInputBorder(),
                      hintText: 'Dejar vacío si no se conoce',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Prioridad',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedPrioridad,
                    items: prioridades.map((prioridad) {
                      return DropdownMenuItem(
                        value: prioridad,
                        child: Text(prioridad),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedPrioridad = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Seleccione una prioridad' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tiempoReparacionController,
                    decoration: const InputDecoration(
                      labelText: 'Tiempo de reparación (opcional)',
                      border: OutlineInputBorder(),
                      hintText: 'Ej: 4h, 2h - Dejar vacío si no se conoce',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _createDemand,
            style: ElevatedButton.styleFrom(),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _createDemand() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final newDemand = {
        'id': 'DEM-${now.millisecondsSinceEpoch.toString().substring(8)}',
        'claseAviso': selectedClaseAviso,
        'tituloAviso': _tituloController.text,
        'descripcionAviso': _descripcionController.text,
        'fechaInicio': DateFormat('dd.MM.yyyy').format(now),
        'autor': _autorController.text.isEmpty
            ? 'usuario_actual'
            : _autorController.text,
        'sintoma': selectedSintoma ?? '',
        'causa': _causaController.text.isEmpty ? '' : _causaController.text,
        'tiempoReparacion': _tiempoReparacionController.text.isEmpty
            ? ''
            : _tiempoReparacionController.text,
        'equipo': '2000${(100 + demandas.length).toString()}',
        'denominacionEquipo': 'Equipo ${demandas.length + 1}',
        'ubicacionTecnica': 'VAN-018-XXX-XXX-XXXXX',
        'prioridad': selectedPrioridad,
        'status': 'PENDIENTE',
        'centroResponsable': '1801',
        'puestoTrabajo': 'PM_GENERAL',
        'fechaCreacion': DateFormat('dd.MM.yyyy').format(now),
        'horaCreacion': DateFormat('HH:mm:ss').format(now),
      };

      setState(() {
        demandas.insert(0, newDemand);
      });

      Navigator.of(context).pop();

      // Mostrar notificación
      NotificationService.showFailureAlert(
        equipmentCode: newDemand['equipo']!,
        failureDescription: newDemand['tituloAviso']!,
        urgency: newDemand['prioridad']!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Demanda creada exitosamente'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
