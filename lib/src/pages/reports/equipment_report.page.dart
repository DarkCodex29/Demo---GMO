import 'package:flutter/material.dart';

class EquipmentReportPage extends StatefulWidget {
  const EquipmentReportPage({super.key});

  @override
  EquipmentReportPageState createState() => EquipmentReportPageState();
}

class EquipmentReportPageState extends State<EquipmentReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Reporte de Equipos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.precision_manufacturing, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Reporte de Equipos',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'En desarrollo',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 