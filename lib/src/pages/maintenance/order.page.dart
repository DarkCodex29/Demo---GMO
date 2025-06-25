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
      final String response = await rootBundle.loadString('assets/data/ordenes_pm.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        // Adaptar los datos reales a la estructura esperada por la aplicación
        ordenes = data.map<Map<String, dynamic>>((orden) {
          return {
            'nroOrden': orden['Equipo']?.toString() ?? 'N/A',
            'fecha': _formatDateFromSAP(orden['Fecha inicio real']?.toString() ?? ''),
            'claseOrden': orden['Clase de orden']?.toString() ?? '',
            'textoBrave': orden['Texto breve']?.toString() ?? '',
            'statusMensaje': orden['Status del sistema']?.toString() ?? '',
            'equipo': orden['Equipo']?.toString() ?? '',
            'denominacionEquipo': orden['Denominación de objeto técnico']?.toString() ?? '',
            'ubicacionTecnica': orden['Ubicación técnica']?.toString() ?? '',
            'denominacionUbicacion': orden['Denominación de la ubicación técnica']?.toString() ?? '',
            'responsable': {
              'centroPlanificacion': orden['Centro planificación']?.toString() ?? '',
              'puestoTrabajoResponsable': orden['Pto.tbjo.responsable']?.toString() ?? '',
              'areaEmpresa': orden['Área de empresa']?.toString() ?? ''
            },
            'fechas': {
              'inicioExtrema': _formatDateFromSAP(orden['Fecha de inicio extrema']?.toString() ?? ''),
              'finExtrema': _formatDateFromSAP(orden['Fecha fin extrema']?.toString() ?? ''),
              'inicioProgramado': _formatDateFromSAP(orden['Inicio programado']?.toString() ?? ''),
              'fechaReferencia': _formatDateFromSAP(orden['Fecha de referencia']?.toString() ?? ''),
              'inicioReal': _formatDateFromSAP(orden['Fecha inicio real']?.toString() ?? ''),
              'finReal': _formatDateFromSAP(orden['Fecha real de fin de la orden']?.toString() ?? ''),
              'horaInicioReal': orden['Hora inicio real']?.toString() ?? '',
              'horaFinReal': orden['Fin real (hora)']?.toString() ?? ''
            },
            'costos': {
              'costePlan': orden['Suma de costes plan']?.toString() ?? '0',
              'costeReal': orden['Costes tot.reales']?.toString() ?? '0',
              'moneda': 'PEN'
            },
            'clasificacion': {
              'campoClasificacion': orden['Campo de clasificación']?.toString() ?? '',
              'claseActividadPM': orden['Clase actividad PM']?.toString() ?? ''
            },
            'status': {
              'sistemaStatus': orden['Status del sistema']?.toString() ?? '',
              'usuarioStatus': orden['Status de usuario']?.toString() ?? ''
            },
            // Campos adicionales específicos de SAP
            'emplazamiento': orden['Emplazamiento']?.toString() ?? '',
            'planMantenimientoPreventivo': orden['Plan mant.preventivo']?.toString() ?? '',
            'hojaRuta': orden['Hoja de Ruta']?.toString() ?? '',
            'grupoHojasRuta': orden['Grupo hojas ruta']?.toString() ?? '',
            'fechaEntrada': _formatDateFromSAP(orden['Fecha entrada']?.toString() ?? ''),
            'fechaModificacion': _formatDateFromSAP(orden['Fecha modific.maestro orden']?.toString() ?? ''),
            'horaInicioProgr': orden['Hora de inicio prog.']?.toString() ?? '',
            'horaFinProgr': orden['Hora de fin progr.']?.toString() ?? '',
            'horaFinExtrema': orden['Hora de fin extrema']?.toString() ?? ''
          };
        }).toList();
        
        filteredOrdenes = ordenes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error detallado al cargar órdenes: $e');
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
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // Función auxiliar para extraer número de orden del texto breve
  String _extractOrdenNumber(String textoBrave) {
    // Intentar extraer un número de orden del texto breve
    final match = RegExp(r'\b\d{5,}\b').firstMatch(textoBrave);
    if (match != null) {
      return match.group(0) ?? 'N/A';
    }
    return 'N/A';
  }

  // Función auxiliar para convertir fechas de SAP (YYYY-MM-DD HH:MM:SS) a formato DD.MM.YYYY
  String _formatDateFromSAP(String sapDate) {
    if (sapDate.isEmpty || sapDate == 'null' || sapDate == '') return '';
    
    try {
      // Extraer solo la parte de la fecha (antes del espacio si hay hora)
      String dateOnly = sapDate.trim().split(' ')[0];
      
      // Dividir la fecha YYYY-MM-DD
      List<String> parts = dateOnly.split('-');
      if (parts.length == 3 && parts[0].length == 4) {
        String day = parts[2].padLeft(2, '0');
        String month = parts[1].padLeft(2, '0');
        String year = parts[0];
        return '$day.$month.$year'; // DD.MM.YYYY
      }
    } catch (e) {
      print('Error parsing date: $sapDate - Error: $e');
      // Si hay error, devolver fecha vacía
      return '';
    }
    
    return '';
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
        _buildTableRow('Información General', 'Orden', orden['nroOrden'] ?? 'N/A'),
        _buildTableRow('', 'Clase orden', orden['claseOrden'] ?? 'N/A'),
        _buildTableRow('', 'Equipo', '${orden['equipo'] ?? 'N/A'} - ${orden['denominacionEquipo'] ?? ''}'),
        _buildTableRow('', 'Ubicación', orden['denominacionUbicacion'] ?? 'N/A'),
        _buildTableRow('', 'Centro planif.', orden['responsable']?['centroPlanificacion'] ?? 'N/A'),
        _buildTableRow('', 'Área empresa', orden['responsable']?['areaEmpresa'] ?? 'N/A'),
        _buildTableRow('Fechas y Tiempos', 'Fecha entrada', orden['fechaEntrada'] ?? 'N/A'),
        _buildTableRow('', 'Inicio progr.', '${orden['fechas']?['inicioProgramado'] ?? 'N/A'} ${orden['horaInicioProgr'] ?? ''}'),
        _buildTableRow('', 'Inicio real', '${orden['fechas']?['inicioReal'] ?? 'N/A'} ${orden['fechas']?['horaInicioReal'] ?? ''}'),
        _buildTableRow('', 'Fin real', '${orden['fechas']?['finReal'] ?? 'N/A'} ${orden['fechas']?['horaFinReal'] ?? ''}'),
        _buildTableRow('', 'Fecha refer.', orden['fechas']?['fechaReferencia'] ?? 'N/A'),
        _buildTableRow('Responsable', 'Puesto trabajo', orden['responsable']?['puestoTrabajoResponsable'] ?? 'N/A'),
        _buildTableRow('', 'Emplazamiento', orden['emplazamiento'] ?? 'N/A'),
        _buildTableRow('Costos', 'Costo planif.', '${orden['costos']?['costePlan'] ?? '0'} ${orden['costos']?['moneda'] ?? ''}'),
        _buildTableRow('', 'Costo real', '${orden['costos']?['costeReal'] ?? '0'} ${orden['costos']?['moneda'] ?? ''}'),
        _buildTableRow('Status', 'Sistema', _formatStatusShort(orden['status']?['sistemaStatus'] ?? 'N/A')),
        _buildTableRow('', 'Usuario', orden['status']?['usuarioStatus'] ?? 'N/A'),
        _buildTableRow('Clasificación', 'Campo clasif.', orden['clasificacion']?['campoClasificacion'] ?? 'N/A'),
        _buildTableRow('', 'Actividad PM', orden['clasificacion']?['claseActividadPM'] ?? 'N/A'),
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
        _buildDetailRow('Número de Orden', orden['nroOrden'] ?? 'N/A'),
        _buildDetailRow('Clase Orden', orden['claseOrden'] ?? 'N/A'),
        _buildDetailRow('Equipo', '${orden['equipo'] ?? 'N/A'} - ${orden['denominacionEquipo'] ?? ''}'),
        _buildDetailRow('Ubicación', orden['denominacionUbicacion'] ?? 'N/A'),
        _buildDetailRow('Centro Planificación', orden['responsable']?['centroPlanificacion'] ?? 'N/A'),
        _buildDetailRow('Área Empresa', orden['responsable']?['areaEmpresa'] ?? 'N/A'),
        _buildDetailRow('Fecha Entrada', orden['fechaEntrada'] ?? 'N/A'),
        _buildDetailRow('Inicio Programado', '${orden['fechas']?['inicioProgramado'] ?? 'N/A'} ${orden['horaInicioProgr'] ?? ''}'),
        _buildDetailRow('Inicio Real', '${orden['fechas']?['inicioReal'] ?? 'N/A'} ${orden['fechas']?['horaInicioReal'] ?? ''}'),
        _buildDetailRow('Fin Real', '${orden['fechas']?['finReal'] ?? 'N/A'} ${orden['fechas']?['horaFinReal'] ?? ''}'),
        _buildDetailRow('Fecha Referencia', orden['fechas']?['fechaReferencia'] ?? 'N/A'),
        _buildDetailRow('Puesto Trabajo', orden['responsable']?['puestoTrabajoResponsable'] ?? 'N/A'),
        _buildDetailRow('Emplazamiento', orden['emplazamiento'] ?? 'N/A'),
        _buildDetailRow('Costo Planificado', '${orden['costos']?['costePlan'] ?? '0'} ${orden['costos']?['moneda'] ?? ''}'),
        _buildDetailRow('Costo Real', '${orden['costos']?['costeReal'] ?? '0'} ${orden['costos']?['moneda'] ?? ''}'),
        _buildDetailRow('Status Sistema', _formatStatusShort(orden['status']?['sistemaStatus'] ?? 'N/A')),
        _buildDetailRow('Status Usuario', orden['status']?['usuarioStatus'] ?? 'N/A'),
        _buildDetailRow('Campo Clasificación', orden['clasificacion']?['campoClasificacion'] ?? 'N/A'),
        _buildDetailRow('Actividad PM', orden['clasificacion']?['claseActividadPM'] ?? 'N/A'),
      ],
    );
  }

  // Función para formatear status largos a versión corta
  String _formatStatusShort(String status) {
    if (status.isEmpty || status == 'N/A') return status;
    
    // Tomar solo los primeros 3 status codes si hay múltiples
    List<String> statusCodes = status.split(' ').take(3).toList();
    return statusCodes.join(' ');
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
