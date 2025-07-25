import 'package:flutter/material.dart';

class CapacityReportPage extends StatefulWidget {
  const CapacityReportPage({super.key});

  @override
  CapacityReportPageState createState() => CapacityReportPageState();
}

class CapacityReportPageState extends State<CapacityReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text(
          'Reporte de Capacidades',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.purple,
        elevation: 2,
        centerTitle: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'Reporte de Capacidades',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
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