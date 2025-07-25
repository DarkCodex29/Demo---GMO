import 'package:flutter/material.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';

class CaracteristicsPage extends StatelessWidget {
  const CaracteristicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentModule: 'confiabilidad',
      customTitle: 'Características',
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailTile('Capacidad', '500 L/H'),
            _buildDetailTile('Fases', '3'),
            _buildDetailTile('Voltaje', '220 V'),
            _buildDetailTile('Grado de Protección', 'IP55'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String value) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }
}
