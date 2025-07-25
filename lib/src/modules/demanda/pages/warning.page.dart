import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:demo/src/shared/layouts/main_layout.dart';

class AvisoPage extends StatefulWidget {
  const AvisoPage({super.key});

  @override
  AvisoPageState createState() => AvisoPageState();
}

class AvisoPageState extends State<AvisoPage> {
  List<Map<String, dynamic>> avisos = [];
  Map<String, dynamic>? selectedAviso;

  @override
  void initState() {
    super.initState();
    _loadAvisos();
  }

  Future<void> _loadAvisos() async {
    final String response =
        await rootBundle.loadString('assets/data/avisos.json');
    final data = await json.decode(response);
    setState(() {
      avisos = List<Map<String, dynamic>>.from(data['avisos']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentModule: 'demanda',
      customTitle: 'Avisos',
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
                    return avisos.where((Map<String, dynamic> aviso) {
                      return aviso['nroAviso'].contains(textEditingValue.text);
                    });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      option['nroAviso'],
                  onSelected: (Map<String, dynamic> selection) {
                    setState(() {
                      selectedAviso = selection;
                    });
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Buscar Aviso...',
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
                  _buildCard(context, 'Aviso', Icons.assignment),
                  _buildCard(context, 'Avería/Parada', Icons.warning),
                  _buildCard(context, 'Datos de Emplazamiento', Icons.place),
                  _buildCard(context, 'Autor del Aviso', Icons.person),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          if (selectedAviso != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailPage(
                  title: title,
                  avisoData: selectedAviso!,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, selecciona un aviso.'),
              ),
            );
          }
        },
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  final String title;
  final Map<String, dynamic> avisoData;

  const DetailPage({super.key, required this.title, required this.avisoData});

  @override
  Widget build(BuildContext context) {
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            if (title == 'Aviso') ...[
              _buildDetailTile('Número de Aviso', avisoData['nroAviso']),
              _buildDetailTile('Orden', avisoData['orden']),
              _buildDetailTile('Status Mensaje', avisoData['statusMensaje']),
              _buildDetailTile(
                  'Ubicación Técnica', avisoData['ubicacionTecnica']),
              _buildDetailTile('Equipo', avisoData['equipo']),
              _buildDetailTile('Descripción', avisoData['descripcion']),
              _buildDetailTile('Punto Trabajo Resp',
                  avisoData['datosEmplazamiento']['puestoTrabajo']),
              _buildDetailTile('Autor del Aviso', avisoData['autor']),
              _buildDetailTile('Fecha Aviso', avisoData['fecha']),
            ],
            if (title == 'Avería/Parada') ...[
              _buildDetailTile(
                  'Inicio Avería', avisoData['averiaParada']['inicioAveria']),
              _buildDetailTile(
                  'Fin Avería', avisoData['averiaParada']['finAveria']),
              _buildDetailTile('Duración Parada',
                  avisoData['averiaParada']['duracionParada']),
              _buildDetailTile(
                  'Prioridad', avisoData['averiaParada']['prioridad']),
            ],
            if (title == 'Datos de Emplazamiento') ...[
              _buildDetailTile('Centro de Emplazamiento',
                  avisoData['datosEmplazamiento']['ceEmplazamiento']),
              _buildDetailTile('Emplazamiento',
                  avisoData['datosEmplazamiento']['emplazamiento']),
              _buildDetailTile('Área de Empresa',
                  avisoData['datosEmplazamiento']['areaEmpresa']),
              _buildDetailTile('Puesto de Trabajo',
                  avisoData['datosEmplazamiento']['puestoTrabajo']),
            ],
            if (title == 'Autor del Aviso') ...[
              _buildDetailTile('Autor del Aviso', avisoData['autor']),
              _buildDetailTile('Fecha Aviso', avisoData['fecha']),
              _buildDetailTile('Fecha Inicio Avería',
                  avisoData['averiaParada']['inicioAveria']),
              _buildDetailTile(
                  'Fecha Fin Avería', avisoData['averiaParada']['finAveria']),
              _buildDetailTile('Fecha de Cierre', avisoData['fechaCierre']),
              _buildDetailTile('Fecha Ref', avisoData['fechaRef']),
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
