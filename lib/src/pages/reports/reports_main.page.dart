import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/pages/reports/stock_report.page.dart';
import 'package:demo/src/pages/reports/orders_report.page.dart';
import 'package:demo/src/pages/reports/capacity_report.page.dart';
import 'package:demo/src/pages/reports/equipment_report.page.dart';

class ReportsMainPage extends StatefulWidget {
  const ReportsMainPage({super.key});

  @override
  ReportsMainPageState createState() => ReportsMainPageState();
}

class ReportsMainPageState extends State<ReportsMainPage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Reportes y Análisis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 2,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade100, Colors.orange.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Centro de Reportes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accede a reportes detallados de stock, órdenes de mantenimiento, capacidades y equipos. Información actualizada en tiempo real.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Grid de reportes
            if (isMobile)
              _buildMobileReportsGrid()
            else if (isTablet)
              _buildTabletReportsGrid()
            else
              _buildDesktopReportsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileReportsGrid() {
    return Column(
      children: [
        _buildReportCard(
          title: 'Reporte de Stock',
          subtitle: 'Inventario y disponibilidad de materiales',
          icon: Icons.inventory_2,
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StockReportPage()),
          ),
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          title: 'Reporte de Órdenes',
          subtitle: 'Órdenes de mantenimiento y su estado',
          icon: Icons.assignment,
          color: Colors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrdersReportPage()),
          ),
        ),
        const SizedBox(height: 12),
        /*
        _buildReportCard(
          title: 'Reporte de Capacidades',
          subtitle: 'Análisis de capacidad por centro de trabajo',
          icon: Icons.analytics,
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CapacityReportPage()),
          ),
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          title: 'Reporte de Equipos',
          subtitle: 'Estado y ubicación de equipos',
          icon: Icons.precision_manufacturing,
          color: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EquipmentReportPage()),
          ),
        ),
        */
      ],
    );
  }

  Widget _buildTabletReportsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildReportCard(
          title: 'Reporte de Stock',
          subtitle: 'Inventario y disponibilidad de materiales',
          icon: Icons.inventory_2,
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StockReportPage()),
          ),
        ),
        _buildReportCard(
          title: 'Reporte de Órdenes',
          subtitle: 'Órdenes de mantenimiento y su estado',
          icon: Icons.assignment,
          color: Colors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrdersReportPage()),
          ),
        ),
        _buildReportCard(
          title: 'Reporte de Capacidades',
          subtitle: 'Análisis de capacidad por centro de trabajo',
          icon: Icons.analytics,
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CapacityReportPage()),
          ),
        ),
        _buildReportCard(
          title: 'Reporte de Equipos',
          subtitle: 'Estado y ubicación de equipos',
          icon: Icons.precision_manufacturing,
          color: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const EquipmentReportPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopReportsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      childAspectRatio: 1.1,
      children: [
        _buildReportCard(
          title: 'Reporte de Stock',
          subtitle: 'Inventario y disponibilidad de materiales',
          icon: Icons.inventory_2,
          color: Colors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StockReportPage()),
          ),
        ),
        _buildReportCard(
          title: 'Reporte de Órdenes',
          subtitle: 'Órdenes de mantenimiento y su estado',
          icon: Icons.assignment,
          color: Colors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const OrdersReportPage()),
          ),
        ),
        _buildReportCard(
          title: 'Reporte de Capacidades',
          subtitle: 'Análisis de capacidad por centro de trabajo',
          icon: Icons.analytics,
          color: Colors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CapacityReportPage()),
          ),
        ),
        _buildReportCard(
          title: 'Reporte de Equipos',
          subtitle: 'Estado y ubicación de equipos',
          icon: Icons.precision_manufacturing,
          color: Colors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const EquipmentReportPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),

              const SizedBox(height: 16),

              // Título
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Subtítulo
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Indicador de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Ver reporte',
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, color: color, size: 12),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
