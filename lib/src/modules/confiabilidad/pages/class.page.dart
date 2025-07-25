import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:demo/src/shared/layouts/main_layout.dart';

class ClasesPage extends StatefulWidget {
  const ClasesPage({super.key});

  @override
  ClasesPageState createState() => ClasesPageState();
}

class ClasesPageState extends State<ClasesPage> {
  List<Map<String, dynamic>> clases = [];
  Map<String, dynamic>? selectedClase;

  @override
  void initState() {
    super.initState();
    _loadClases();
  }

  Future<void> _loadClases() async {
    final String response =
        await rootBundle.loadString('assets/data/class.json');
    final data = await json.decode(response);
    setState(() {
      clases = List<Map<String, dynamic>>.from(data['clases']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentModule: 'confiabilidad',
      customTitle: 'Clases',
      showBackButton: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Autocomplete<Map<String, dynamic>>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const Iterable<Map<String, dynamic>>.empty();
                    }
                    return clases.where((Map<String, dynamic> clase) {
                      return clase['claseEquipo']
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      option['claseEquipo'],
                  onSelected: (Map<String, dynamic> selection) {
                    setState(() {
                      selectedClase = selection;
                    });
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Buscar Clase...',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: <Widget>[
                  _buildCard(
                      context, 'Categoría', Icons.category, 'categoriaClase'),
                  _buildCard(
                      context, 'Clase de Equipo', Icons.build, 'claseEquipo'),
                  _buildCard(context, 'Características', Icons.list,
                      'caracteristicas'),
                  _buildCard(context, 'Datos Adicionales', Icons.more_horiz,
                      'datosAdicionales'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, String key) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          if (selectedClase != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClaseDetailPage(
                  title: title,
                  claseData: selectedClase!,
                  detailKey: key,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, selecciona una clase.'),
              ),
            );
          }
        },
      ),
    );
  }
}

class ClaseDetailPage extends StatelessWidget {
  final String title;
  final Map<String, dynamic> claseData;
  final String detailKey;

  const ClaseDetailPage(
      {super.key,
      required this.title,
      required this.claseData,
      required this.detailKey});

  @override
  Widget build(BuildContext context) {
    final dynamic detailData = claseData[detailKey];
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de $title',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            if (detailKey == 'categoriaClase') ...[
              _buildDetailTile('Categoría', detailData),
            ],
            if (detailKey == 'claseEquipo') ...[
              _buildDetailTile('Clase de Equipo', detailData),
              _buildDetailTile('Válido desde', claseData['validoDe']),
            ],
            if (detailKey == 'caracteristicas') ...[
              const SizedBox(height: 8.0),
              ...detailData.map<Widget>((caracteristica) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle),
                    title: Text(caracteristica),
                  ),
                );
              }).toList(),
            ],
            if (detailKey == 'datosAdicionales') ...[
              const SizedBox(height: 8.0),
              _buildDetailTile('Fabricante', detailData['fabricante']),
              _buildDetailTile('Peso', detailData['peso']),
              _buildDetailTile('Altura', detailData['altura']),
              _buildDetailTile('Ubicación', detailData['ubicacion']),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(String title, String? content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content ?? 'N/A'),
      ),
    );
  }
}
