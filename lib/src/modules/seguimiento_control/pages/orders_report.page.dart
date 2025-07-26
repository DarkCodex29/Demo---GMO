import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
class OrdersReportPage extends StatefulWidget {
  const OrdersReportPage({super.key});

  @override
  OrdersReportPageState createState() => OrdersReportPageState();
}

class OrdersReportPageState extends State<OrdersReportPage> {
  List<Map<String, dynamic>> ordenes = [];
  List<Map<String, dynamic>> filteredOrdenes = [];
  bool isLoading = true;
  String searchQuery = '';

  // Filtros
  String selectedClaseOrden = 'Todas';
  String selectedStatus = 'Todos';
  String selectedCentro = 'Todos';
  String selectedActividad = 'Todas';

  Set<String> clasesOrden = {'Todas'};
  Set<String> statusList = {'Todos'};
  Set<String> centros = {'Todos'};
  Set<String> actividades = {'Todas'};

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
        ordenes = data.map<Map<String, dynamic>>((orden) {
          return {
            'equipo': orden['Equipo']?.toString() ?? '',
            'textoBrave': orden['Texto breve']?.toString() ?? '',
            'claseOrden': orden['Clase de orden']?.toString() ?? '',
            'statusSistema': orden['Status del sistema']?.toString() ?? '',
            'statusUsuario': orden['Status de usuario']?.toString() ?? '',
            'centroPlanificacion': orden['Centro planificación']?.toString() ?? '',
            'actividadPM': orden['Clase actividad PM']?.toString() ?? '',
            'ubicacionTecnica': orden['Ubicación técnica']?.toString() ?? '',
            'denominacionUbicacion': orden['Denominación de la ubicación técnica']?.toString() ?? '',
            'puestoTrabajo': orden['Pto.tbjo.responsable']?.toString() ?? '',
            'fechaInicioExtrema': _formatDateFromSAP(orden['Fecha de inicio extrema']?.toString() ?? ''),
            'inicioProgramado': _formatDateFromSAP(orden['Inicio programado']?.toString() ?? ''),
            'inicioReal': _formatDateFromSAP(orden['Fecha inicio real']?.toString() ?? ''),
            'finReal': _formatDateFromSAP(orden['Fecha real de fin de la orden']?.toString() ?? ''),
            'costePlan': double.tryParse(orden['Suma de costes plan']?.toString() ?? '0') ?? 0,
            'costeReal': double.tryParse(orden['Costes tot.reales']?.toString() ?? '0') ?? 0,
            'horaInicioReal': orden['Hora inicio real']?.toString() ?? '',
            'horaFinReal': orden['Fin real (hora)']?.toString() ?? '',
            'campoClasificacion': orden['Campo de clasificación']?.toString() ?? '',
            'emplazamiento': orden['Emplazamiento']?.toString() ?? '',
          };
        }).toList();
        
        filteredOrdenes = ordenes;
        
        // Extraer valores únicos para filtros
        for (var orden in ordenes) {
          clasesOrden.add(orden['claseOrden']?.toString() ?? '');
          statusList.add(orden['statusUsuario']?.toString() ?? '');
          centros.add(orden['centroPlanificacion']?.toString() ?? '');
          actividades.add(orden['actividadPM']?.toString() ?? '');
        }
        
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

  String _formatDateFromSAP(String sapDate) {
    if (sapDate.isEmpty || sapDate == 'null' || sapDate == '') return '';
    
    try {
      String dateOnly = sapDate.trim().split(' ')[0];
      List<String> parts = dateOnly.split('-');
      if (parts.length == 3 && parts[0].length == 4) {
        String day = parts[2].padLeft(2, '0');
        String month = parts[1].padLeft(2, '0');
        String year = parts[0];
        return '$day.$month.$year';
      }
    } catch (e) {
      return '';
    }
    return '';
  }

  void _applyFilters() {
    setState(() {
      filteredOrdenes = ordenes.where((orden) {
        final matchesSearch = searchQuery.isEmpty ||
            orden['equipo'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
            orden['textoBrave'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
            orden['ubicacionTecnica'].toString().toLowerCase().contains(searchQuery.toLowerCase());
            
        final matchesClase = selectedClaseOrden == 'Todas' || 
            orden['claseOrden'].toString() == selectedClaseOrden;
            
        final matchesStatus = selectedStatus == 'Todos' || 
            orden['statusUsuario'].toString() == selectedStatus;
            
        final matchesCentro = selectedCentro == 'Todos' || 
            orden['centroPlanificacion'].toString() == selectedCentro;
            
        final matchesActividad = selectedActividad == 'Todas' || 
            orden['actividadPM'].toString() == selectedActividad;

        return matchesSearch && matchesClase && matchesStatus && 
               matchesCentro && matchesActividad;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedClaseOrden = 'Todas';
      selectedStatus = 'Todos';
      selectedCentro = 'Todos';
      selectedActividad = 'Todas';
      searchQuery = '';
      filteredOrdenes = ordenes;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CREA': return AppColors.secondaryBrightBlue;
      case 'LIBE': return AppColors.secondaryAquaGreen;
      case 'EJEC': return AppColors.secondaryGoldenYellow;
      case 'CERR': return AppColors.neutralTextGray;
      default: return AppColors.neutralTextGray;
    }
  }

  Color _getActividadColor(String actividad) {
    switch (actividad.toUpperCase()) {
      case 'REP': return AppColors.secondaryCoralRed;
      case 'CAM': return AppColors.secondaryGoldenYellow;
      case 'CAL': return AppColors.secondaryBrightBlue;
      case 'ALT': return AppColors.primaryMintGreen;
      default: return AppColors.neutralTextGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MainLayout(
        currentModule: 'seguimiento_control',
        customTitle: 'Reporte de Órdenes',
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
      currentModule: 'seguimiento_control',
      customTitle: 'Reporte de Órdenes',
      showBackButton: true,
      child: ResponsiveRowColumn(
        layout: ResponsiveRowColumnType.COLUMN,
        children: [
          // Panel de filtros
          ResponsiveRowColumnItem(
            child: _buildFiltersPanel(isMobile),
          ),
          
          // Estadísticas resumidas
          ResponsiveRowColumnItem(
            child: _buildSummaryStats(),
          ),
          
          // Lista/tabla de órdenes
          ResponsiveRowColumnItem(
            child: Expanded(
              child: isMobile 
                  ? _buildMobileList()
                  : _buildDesktopTable(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Búsqueda
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por equipo, descripción o ubicación...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                        });
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.green),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
              _applyFilters();
            },
          ),
          
          const SizedBox(height: 12),
          
          // Filtros
          if (isMobile)
            _buildMobileFilters()
          else
            _buildDesktopFilters(),
        ],
      ),
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildFilterDropdown('Clase', selectedClaseOrden, clasesOrden, (value) {
              setState(() { selectedClaseOrden = value!; });
              _applyFilters();
            })),
            const SizedBox(width: 8),
            Expanded(child: _buildFilterDropdown('Status', selectedStatus, statusList, (value) {
              setState(() { selectedStatus = value!; });
              _applyFilters();
            })),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildFilterDropdown('Centro', selectedCentro, centros, (value) {
              setState(() { selectedCentro = value!; });
              _applyFilters();
            })),
            const SizedBox(width: 8),
            Expanded(child: _buildFilterDropdown('Actividad', selectedActividad, actividades, (value) {
              setState(() { selectedActividad = value!; });
              _applyFilters();
            })),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _clearFilters,
          icon: const Icon(Icons.clear_all),
          label: const Text('Limpiar filtros'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(child: _buildFilterDropdown('Clase Orden', selectedClaseOrden, clasesOrden, (value) {
          setState(() { selectedClaseOrden = value!; });
          _applyFilters();
        })),
        const SizedBox(width: 12),
        Expanded(child: _buildFilterDropdown('Status', selectedStatus, statusList, (value) {
          setState(() { selectedStatus = value!; });
          _applyFilters();
        })),
        const SizedBox(width: 12),
        Expanded(child: _buildFilterDropdown('Centro', selectedCentro, centros, (value) {
          setState(() { selectedCentro = value!; });
          _applyFilters();
        })),
        const SizedBox(width: 12),
        Expanded(child: _buildFilterDropdown('Actividad PM', selectedActividad, actividades, (value) {
          setState(() { selectedActividad = value!; });
          _applyFilters();
        })),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _clearFilters,
          icon: const Icon(Icons.clear_all),
          label: const Text('Limpiar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String label, String value, Set<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSummaryStats() {
    final totalOrdenes = filteredOrdenes.length;
    final ordenesCreadas = filteredOrdenes.where((o) => o['statusUsuario'] == 'CREA').length;
    final costoTotal = filteredOrdenes.fold<double>(0, (sum, orden) => sum + orden['costeReal']);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard('Total Órdenes', totalOrdenes.toString(), Icons.assignment, Colors.green),
          _buildStatCard('Creadas', ordenesCreadas.toString(), Icons.add_circle, Colors.blue),
          _buildStatCard('Costo Total', 'S/ ${costoTotal.toStringAsFixed(2)}', Icons.attach_money, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrdenes.length,
      itemBuilder: (context, index) {
        final orden = filteredOrdenes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Equipo: ${orden['equipo']}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            orden['textoBrave'],
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(orden['statusUsuario']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        orden['statusUsuario'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip('Centro', orden['centroPlanificacion'], Colors.blue),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getActividadColor(orden['actividadPM']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        orden['actividadPM'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (orden['inicioReal'].isNotEmpty)
                      Text(
                        orden['inicioReal'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.green.shade50),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          columns: const [
            DataColumn(label: Text('Equipo')),
            DataColumn(label: Text('Descripción')),
            DataColumn(label: Text('Clase')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Centro')),
            DataColumn(label: Text('Actividad')),
            DataColumn(label: Text('Inicio Real')),
            DataColumn(label: Text('Costo Real')),
          ],
          rows: filteredOrdenes.map((orden) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    orden['equipo'],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 200,
                    child: Text(
                      orden['textoBrave'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(orden['claseOrden'])),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(orden['statusUsuario']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      orden['statusUsuario'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(orden['centroPlanificacion'])),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getActividadColor(orden['actividadPM']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      orden['actividadPM'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                DataCell(Text(orden['inicioReal'])),
                DataCell(Text('S/ ${orden['costeReal'].toStringAsFixed(2)}')),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
} 