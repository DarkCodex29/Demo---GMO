import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  EquipmentPageState createState() => EquipmentPageState();
}

class EquipmentPageState extends State<EquipmentPage> {
  List<Map<String, dynamic>> equipments = [];
  Map<String, dynamic>? selectedEquipment;

  @override
  void initState() {
    super.initState();
    _loadEquipments();
  }

  Future<void> _loadEquipments() async {
    final String response =
        await rootBundle.loadString('assets/data/equipament.json');
    final data = await json.decode(response);
    setState(() {
      equipments = List<Map<String, dynamic>>.from(data['equipos']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipos'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
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
                    return equipments.where((Map<String, dynamic> equipment) {
                      return equipment['equipo']
                              .toString()
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()) ||
                          equipment['descripcion']
                              .toString()
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      option['equipo'],
                  onSelected: (Map<String, dynamic> selection) {
                    setState(() {
                      selectedEquipment = selection;
                    });
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Buscar equipo...',
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
                  _buildCard(context, 'General', Icons.info),
                  _buildCard(context, 'Emplazamiento', Icons.location_on),
                  _buildCard(context, 'Organización', Icons.business),
                  _buildCard(context, 'Estructura', Icons.account_tree),
                  _buildCard(context, 'Garantías', Icons.shield),
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
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          if (selectedEquipment != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EquipmentDetailPage(
                  title: title,
                  equipmentData: selectedEquipment!,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, selecciona un equipo.'),
              ),
            );
          }
        },
      ),
    );
  }
}

class EquipmentDetailPage extends StatelessWidget {
  final String title;
  final Map<String, dynamic> equipmentData;

  const EquipmentDetailPage(
      {super.key, required this.title, required this.equipmentData});

  @override
  Widget build(BuildContext context) {
    final dynamic detailData = equipmentData[_getDetailKey(title)];
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.orange,
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
            if (detailData != null) ...[
              ...detailData.entries.map<Widget>((entry) {
                return _buildDetailTile(
                    _formatTitle(entry.key), entry.value.toString());
              }).toList(),
            ] else ...[
              const Text('No hay información disponible.'),
            ],
          ],
        ),
      ),
    );
  }

  String _getDetailKey(String title) {
    switch (title) {
      case 'General':
        return 'general';
      case 'Emplazamiento':
        return 'emplazamiento';
      case 'Organización':
        return 'organizacion';
      case 'Estructura':
        return 'estructura';
      case 'Garantías':
        return 'garantias';
      default:
        return '';
    }
  }

  String _formatTitle(String title) {
    return title.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
