import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/services/notification_service.dart';

class OrdenPage extends StatefulWidget {
  const OrdenPage({super.key});

  @override
  OrdenPageState createState() => OrdenPageState();
}

class OrdenPageState extends State<OrdenPage> {
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error al cargar órdenes: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterOrdenes(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredOrdenes = ordenes;
      } else {
        filteredOrdenes = ordenes.where((orden) {
          final nroOrden = orden['nroOrden']?.toString().toLowerCase() ?? '';
          final textoBrave = orden['textoBrave']?.toString().toLowerCase() ?? '';
          final equipo = orden['equipo']?.toString().toLowerCase() ?? '';
          final ubicacion = orden['denominacionUbicacion']?.toString().toLowerCase() ?? '';
          
          final searchLower = query.toLowerCase();
          
          return nroOrden.contains(searchLower) ||
                 textoBrave.contains(searchLower) ||
                 equipo.contains(searchLower) ||
                 ubicacion.contains(searchLower);
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

  Color _getStatusColor(String? status) {
    if (status == null || status.trim().isEmpty) return Colors.grey;
    
    if (status.contains('NLIQ')) return Colors.blue;
    if (status.contains('PREC')) return Colors.green;
    if (status.contains('JBFI')) return Colors.orange;
    if (status.contains('CTEC')) return Colors.purple;
    return Colors.blue;
  }

  IconData _getStatusIcon(String? status) {
    if (status == null || status.trim().isEmpty) return Icons.help_outline;
    
    if (status.contains('NLIQ')) return Icons.payment;
    if (status.contains('PREC')) return Icons.check_circle;
    if (status.contains('JBFI')) return Icons.engineering;
    if (status.contains('CTEC')) return Icons.assignment;
    return Icons.assignment;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: ResponsiveRowColumn(
          layout: ResponsiveRowColumnType.ROW,
          children: [
            const ResponsiveRowColumnItem(
              child: Icon(Icons.assignment_turned_in, color: Colors.white),
            ),
            const ResponsiveRowColumnItem(
              child: SizedBox(width: 8),
            ),
            ResponsiveRowColumnItem(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Gestión de Órdenes',
                  style: TextStyle(
                    fontSize: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 18.0),
                        const Condition.largerThan(name: MOBILE, value: 20.0),
                      ],
                    ).value,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        elevation: 2,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ResponsiveRowColumn(
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _filterOrdenes,
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
                      ? 'Buscar órdenes...' 
                      : 'Buscar por número, descripción, equipo...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500], 
                    fontSize: ResponsiveValue<double>(
                      context,
                      conditionalValues: [
                        const Condition.smallerThan(name: TABLET, value: 13.0),
                        const Condition.largerThan(name: MOBILE, value: 15.0),
                      ],
                    ).value,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.orange.shade600, size: 24),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () {
                            _filterOrdenes('');
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

          // Lista de órdenes responsiva
          ResponsiveRowColumnItem(
            child: Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    )
                  : filteredOrdenes.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                searchQuery.isEmpty
                                    ? 'No hay órdenes disponibles'
                                    : 'No se encontraron órdenes',
                                style: TextStyle(
                                  fontSize: ResponsiveValue<double>(
                                    context,
                                    conditionalValues: [
                                      const Condition.smallerThan(name: TABLET, value: 16.0),
                                      const Condition.largerThan(name: MOBILE, value: 18.0),
                                    ],
                                  ).value,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _buildOrdenList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdenList() {
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
      itemCount: filteredOrdenes.length,
      itemBuilder: (context, index) {
        final orden = filteredOrdenes[index];
        return _buildOrdenCard(orden, index);
      },
    );
  }

  Widget _buildOrdenCard(Map<String, dynamic> orden, int index) {
    final status = orden['statusMensaje']?.toString() ?? '';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
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
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            iconColor: Colors.orange,
            textColor: Colors.orange,
            collapsedTextColor: Colors.black87,
            collapsedIconColor: Colors.orange,
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
                      _formatValue(orden['nroOrden']),
                      style: TextStyle(
                        fontSize: ResponsiveValue<double>(
                          context,
                          conditionalValues: [
                            const Condition.smallerThan(name: TABLET, value: 14.0),
                            const Condition.largerThan(name: MOBILE, value: 15.0),
                          ],
                        ).value,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatValue(orden['textoBrave']),
                      style: TextStyle(
                        fontSize: ResponsiveValue<double>(
                          context,
                          conditionalValues: [
                            const Condition.smallerThan(name: TABLET, value: 12.0),
                            const Condition.largerThan(name: MOBILE, value: 13.0),
                          ],
                        ).value,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.settings, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Equipo: ${_formatValue(orden['equipo'])}',
                            style: TextStyle(
                              fontSize: ResponsiveValue<double>(
                                context,
                                conditionalValues: [
                                  const Condition.smallerThan(name: TABLET, value: 11.0),
                                  const Condition.largerThan(name: MOBILE, value: 12.0),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade300, width: 0.5),
                          ),
                          child: Text(
                            _formatValue(orden['claseOrden']),
                            style: TextStyle(
                              fontSize: ResponsiveValue<double>(
                                context,
                                conditionalValues: [
                                  const Condition.smallerThan(name: TABLET, value: 9.0),
                                  const Condition.largerThan(name: MOBILE, value: 10.0),
                                ],
                              ).value,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor.withOpacity(0.4), width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.flag,
                                size: 10,
                                color: statusColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                status.contains('PREC') ? 'PREC' : 
                                status.contains('NLIQ') ? 'NLIQ' :
                                status.contains('JBFI') ? 'JBFI' : 'CTEC',
                                style: TextStyle(
                                  fontSize: ResponsiveValue<double>(
                                    context,
                                    conditionalValues: [
                                      const Condition.smallerThan(name: TABLET, value: 9.0),
                                      const Condition.largerThan(name: MOBILE, value: 10.0),
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
                    const SizedBox(height: 4),
                    // Fecha
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatValue(orden['fecha']),
                          style: TextStyle(
                            fontSize: ResponsiveValue<double>(
                              context,
                              conditionalValues: [
                                const Condition.smallerThan(name: TABLET, value: 11.0),
                                const Condition.largerThan(name: MOBILE, value: 12.0),
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
            _buildOrdenDetails(orden),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdenDetails(Map<String, dynamic> orden) {
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
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Header de detalles
          ResponsiveRowColumn(
            layout: ResponsiveRowColumnType.ROW,
            children: [
              ResponsiveRowColumnItem(
                child: Icon(Icons.info_outline, color: Colors.orange.shade600, size: 20),
              ),
              const ResponsiveRowColumnItem(
                child: SizedBox(width: 8),
              ),
              ResponsiveRowColumnItem(
                child: Text(
                  'Notificación de órdenes y Cierre de orden',
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
          SizedBox(height: ResponsiveValue<double>(
            context,
            conditionalValues: [
              const Condition.smallerThan(name: TABLET, value: 8.0),
              const Condition.largerThan(name: MOBILE, value: 12.0),
            ],
          ).value),
          
          // Tabla de detalles responsive
          if (isDesktop || isTablet)
            _buildTableView(orden)
          else
            _buildListView(orden),
        ],
      ),
    );
  }

  Widget _buildTableView(Map<String, dynamic> orden) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300, width: 0.5),
      columnWidths: const {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(2),
      },
      children: [
        _buildTableHeader(),
        _buildTableRow('proceso', 'Orden', orden['nroOrden'] ?? '45000'),
        _buildTableRow('', 'operacion', '0010'),
        _buildTableRow('', 'fecha inicio', orden['fecha'] ?? '18.06.2025'),
        _buildTableRow('', 'hora inicio', orden['fechas']?['horaInicioReal'] ?? '10:00:00'),
        _buildTableRow('', 'fecha fin', orden['fecha'] ?? '18.06.2025'),
        _buildTableRow('', 'hora fin', orden['fechas']?['horaFinReal'] ?? '12:00:00'),
        _buildTableRow('', 'tiempo real', '2'),
        _buildTableRow('Notificacion de ordenes', 'Operario', orden['responsable']?['puestoTrabajoResponsable'] ?? 'Juan Sanchez'),
        _buildTableRow('', 'motivo de desviacion', ''),
        _buildTableRow('Cierre de orden', 'orden', orden['nroOrden'] ?? '45000'),
        _buildTableRow('', 'fecha de cierre', orden['fecha'] ?? '18.06.2025'),
      ],
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey.shade100),
      children: [
        _buildTableCell('proceso', isHeader: true),
        _buildTableCell('Campo', isHeader: true),
        _buildTableCell('Valor', isHeader: true),
      ],
    );
  }

  TableRow _buildTableRow(String proceso, String campo, dynamic valor) {
    return TableRow(
      children: [
        _buildTableCell(proceso),
        _buildTableCell(campo),
        _buildTableCell(_formatValue(valor)),
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
          color: isHeader ? Colors.black87 : Colors.black54,
        ),
      ),
    );
  }

  Widget _buildListView(Map<String, dynamic> orden) {
    return Column(
      children: [
        _buildDetailRow('Número de Orden', orden['nroOrden'] ?? '45000'),
        _buildDetailRow('Operación', '0010'),
        _buildDetailRow('Fecha Inicio', orden['fecha'] ?? '18.06.2025'),
        _buildDetailRow('Hora Inicio', orden['fechas']?['horaInicioReal'] ?? '10:00:00'),
        _buildDetailRow('Fecha Fin', orden['fecha'] ?? '18.06.2025'),
        _buildDetailRow('Hora Fin', orden['fechas']?['horaFinReal'] ?? '12:00:00'),
        _buildDetailRow('Tiempo Real', '2'),
        _buildDetailRow('Operario', orden['responsable']?['puestoTrabajoResponsable'] ?? 'Juan Sanchez'),
        _buildDetailRow('Motivo de Desviación', ''),
        _buildDetailRow('Fecha de Cierre', orden['fecha'] ?? '18.06.2025'),
      ],
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
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
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 3,
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
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
