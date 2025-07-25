import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class JobPage extends StatefulWidget {
  const JobPage({super.key});

  @override
  JobPageState createState() => JobPageState();
}

class JobPageState extends State<JobPage> {
  List<Map<String, dynamic>> jobs = [];
  Map<String, dynamic>? selectedJob;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final String response = await rootBundle.loadString('assets/data/job.json');
    final data = await json.decode(response);
    setState(() {
      jobs = List<Map<String, dynamic>>.from(data['puestos_trabajo']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Puestos de Trabajo'),
        
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
                    return jobs.where((Map<String, dynamic> job) {
                      return job['puesto']
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      option['puesto'],
                  onSelected: (Map<String, dynamic> selection) {
                    setState(() {
                      selectedJob = selection;
                    });
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Buscar puesto de trabajo...',
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
                  _buildCard(context, 'Datos Básicos', Icons.info),
                  _buildCard(context, 'Valores Propuestos', Icons.check_circle),
                  _buildCard(context, 'Capacidades', Icons.assessment),
                  _buildCard(context, 'Programación', Icons.schedule),
                  _buildCard(context, 'Cálculo de Coste', Icons.attach_money),
                  _buildCard(context, 'Tecnología', Icons.build),
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
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          if (selectedJob != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailPage(
                  title: title,
                  jobData: selectedJob!,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, selecciona un puesto de trabajo.'),
              ),
            );
          }
        },
      ),
    );
  }
}

class JobDetailPage extends StatelessWidget {
  final String title;
  final Map<String, dynamic> jobData;

  const JobDetailPage({super.key, required this.title, required this.jobData});

  @override
  Widget build(BuildContext context) {
    final dynamic detailData = jobData[_getDetailKey(title)];
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
      case 'Datos Básicos':
        return 'datos_basicos';
      case 'Valores Propuestos':
        return 'valores_propuestos';
      case 'Capacidades':
        return 'capacidades';
      case 'Programación':
        return 'programacion';
      case 'Cálculo de Coste':
        return 'calculo_coste';
      case 'Tecnología':
        return 'tecnologia';
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
