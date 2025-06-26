import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:responsive_framework/responsive_framework.dart';

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

  // Filtros
  String selectedCentro = 'Todos';
  String selectedAlmacen = 'Todos';
  String selectedTipoMaterial = 'Todos';
  String selectedClasificacion = 'Todos';

  Set<String> centros = {'Todos'};
  Set<String> almacenes = {'Todos'};
  Set<String> tiposMaterial = {'Todos'};
  Set<String> clasificaciones = {'Todos'};

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
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
                  child: Text('Error al cargar materiales: ${e.toString()}'),
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

        return matchesSearch && matchesCentro && matchesAlmacen && 
               matchesTipo && matchesClasificacion;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedCentro = 'Todos';
      selectedAlmacen = 'Todos';
      selectedTipoMaterial = 'Todos';
      selectedClasificacion = 'Todos';
      searchQuery = '';
      filteredMaterials = materials;
    });
  }

  Color _getStockColor(String stockLibre) {
    final stockValue = int.tryParse(stockLibre.split(' ').first) ?? 0;
    if (stockValue <= 10) return Colors.red;
    if (stockValue <= 25) return Colors.orange;
    return Colors.green;
  }

  Color _getClasificacionColor(String clasificacion) {
    switch (clasificacion.toUpperCase()) {
      case 'A': return Colors.red;
      case 'B': return Colors.orange;
      case 'C': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.inventory_2, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Reporte de Stock',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        elevation: 2,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Función de exportación en desarrollo'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            tooltip: 'Exportar reporte',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : Column(
              children: [
                // Panel de filtros
                _buildFiltersPanel(isMobile),
                
                // Estadísticas resumidas
                _buildSummaryStats(),
                
                // Lista/tabla de materiales
                Expanded(
                  child: isMobile 
                      ? _buildMobileList()
                      : _buildDesktopTable(),
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
              hintText: 'Buscar por material o descripción...',
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
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
                borderSide: const BorderSide(color: Colors.blue),
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
          
          // Filtros en grid responsivo
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
        const SizedBox(width: 12),
        Expanded(child: _buildFilterDropdown('Clasificación', selectedClasificacion, clasificaciones, (value) {
          setState(() { selectedClasificacion = value!; });
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
    final totalMateriales = filteredMaterials.length;
    final stockBajo = filteredMaterials.where((m) {
      final stockValue = int.tryParse(m['stockLibre'].toString().split(' ').first) ?? 0;
      return stockValue <= 10;
    }).length;
    
    final valorTotal = filteredMaterials.fold<double>(0, (sum, material) {
      final precio = double.tryParse(material['precio']?.toString() ?? '0') ?? 0;
      final stockValue = int.tryParse(material['stockLibre'].toString().split(' ').first) ?? 0;
      return sum + (precio * stockValue);
    });

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
          _buildStatCard('Total Materiales', totalMateriales.toString(), Icons.inventory_2, Colors.blue),
          _buildStatCard('Stock Bajo', stockBajo.toString(), Icons.warning, Colors.orange),
          _buildStatCard('Valor Total', 'S/ ${valorTotal.toStringAsFixed(2)}', Icons.attach_money, Colors.green),
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
      itemCount: filteredMaterials.length,
      itemBuilder: (context, index) {
        final material = filteredMaterials[index];
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
                            material['material'],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            material['descripcion'],
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
                        color: _getStockColor(material['stockLibre']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        material['stockLibre'],
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
                    _buildInfoChip('Centro', material['centro'], Colors.blue),
                    const SizedBox(width: 8),
                    _buildInfoChip('Almacén', material['almacen'], Colors.green),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getClasificacionColor(material['clasificacion']),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        material['clasificacion'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
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
          headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          columns: const [
            DataColumn(label: Text('Material')),
            DataColumn(label: Text('Centro')),
            DataColumn(label: Text('Almacén')),
            DataColumn(label: Text('Stock Libre')),
            DataColumn(label: Text('Descripción')),
            DataColumn(label: Text('Tipo')),
            DataColumn(label: Text('Clase')),
            DataColumn(label: Text('Precio')),
            DataColumn(label: Text('Ubicación')),
          ],
          rows: filteredMaterials.map((material) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    material['material'],
                    style: const TextStyle(
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      material['tipoMaterial'],
                      style: const TextStyle(fontSize: 11),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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