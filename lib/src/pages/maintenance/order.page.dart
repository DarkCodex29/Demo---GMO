import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class OrdenPage extends StatefulWidget {
  const OrdenPage({super.key});

  @override
  OrdenPageState createState() => OrdenPageState();
}

class OrdenPageState extends State<OrdenPage> {
  List<Map<String, dynamic>> ordenes = [];
  Map<String, dynamic>? selectedOrden;

  @override
  void initState() {
    super.initState();
    _loadOrdenes();
  }

  Future<void> _loadOrdenes() async {
    final String response =
        await rootBundle.loadString('assets/data/ordenes.json');
    final data = await json.decode(response);
    setState(() {
      ordenes = List<Map<String, dynamic>>.from(data['ordenes']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orden'),
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
                    return ordenes.where((Map<String, dynamic> orden) {
                      return orden['nroOrden'].contains(textEditingValue.text);
                    });
                  },
                  displayStringForOption: (Map<String, dynamic> option) =>
                      option['nroOrden'],
                  onSelected: (Map<String, dynamic> selection) {
                    setState(() {
                      selectedOrden = selection;
                    });
                  },
                  fieldViewBuilder: (context, textEditingController, focusNode,
                      onFieldSubmitted) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Buscar Orden...',
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
                  _buildCard(context, 'Orden', Icons.assignment),
                  _buildCard(context, 'Operaciones', Icons.list),
                  _buildCard(context, 'Componentes', Icons.extension),
                  _buildCard(context, 'Costos', Icons.attach_money),
                  _buildCard(context, 'Datos Adicionales', Icons.more_horiz),
                  _buildCard(context, 'Emplazamiento', Icons.place),
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
          if (selectedOrden != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrdenDetailPage(
                  title: title,
                  ordenData: selectedOrden!,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Por favor, selecciona una orden.'),
              ),
            );
          }
        },
      ),
    );
  }
}

class OrdenDetailPage extends StatelessWidget {
  final String title;
  final Map<String, dynamic> ordenData;

  const OrdenDetailPage(
      {super.key, required this.title, required this.ordenData});

  @override
  Widget build(BuildContext context) {
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
            if (title == 'Orden') ...[
              _buildDetailTile('Número de Orden', ordenData['nroOrden']),
              _buildDetailTile('Clase de Orden', ordenData['claseOrden']),
              _buildDetailTile('Status Mensaje', ordenData['statusMensaje']),
              const SizedBox(height: 16),
              const Text(
                'Responsable',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              _buildDetailTile('Grupo de Planificación',
                  ordenData['responsable']['grupoPlanificacion']),
              _buildDetailTile('Puesto de Trabajo Responsable',
                  ordenData['responsable']['puestoTrabajoResponsable']),
              _buildDetailTile('Jefe de Mantenimiento',
                  ordenData['responsable']['jefeMantenimiento']),
              const SizedBox(height: 16),
              const Text(
                'Fechas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              _buildDetailTile(
                  'Inicio Ejecución', ordenData['fechas']['inicioEjecucion']),
              _buildDetailTile(
                  'Fin Ejecución', ordenData['fechas']['finEjecucion']),
              _buildDetailTile('Prioridad', ordenData['fechas']['prioridad']),
              _buildDetailTile('Revisión', ordenData['fechas']['revision']),
              const SizedBox(height: 16),
              const Text(
                'Objeto de Referencia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              _buildDetailTile('Ubicación Técnica',
                  ordenData['objetoReferencia']['ubicacionTecnica']),
              _buildDetailTile(
                  'Equipo', ordenData['objetoReferencia']['equipo']),
              _buildDetailTile(
                  'Conjunto', ordenData['objetoReferencia']['conjunto']),
              const SizedBox(height: 16),
              const Text(
                'Primera Operación',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              _buildDetailTile(
                  'Operación', ordenData['primeraOperacion']['operacion']),
              _buildDetailTile('Puesto de Trabajo/Centro',
                  ordenData['primeraOperacion']['puestoTrabajoCentro']),
              _buildDetailTile('Clase de Control',
                  ordenData['primeraOperacion']['claseControl']),
              _buildDetailTile('Número de Operación',
                  ordenData['primeraOperacion']['numeroOperacion']),
              _buildDetailTile(
                  'Trabajo Real', ordenData['primeraOperacion']['trabajoReal']),
              _buildDetailTile('Trabajo Invertido',
                  ordenData['primeraOperacion']['trabajoInvertido']),
            ],
            if (title == 'Operaciones') ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ordenData['operaciones'].length,
                itemBuilder: (context, index) {
                  final operacion = ordenData['operaciones'][index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text('Operación ${operacion['op']}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(operacion['textoBreveOperacion']),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OperacionDetailPage(
                              operacionData: operacion,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            if (title == 'Componentes') ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ordenData['componentes'].length,
                itemBuilder: (context, index) {
                  final componente = ordenData['componentes'][index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Text('Componente ${componente['posicion']}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(componente['denominacion']),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComponenteDetailPage(
                              componenteData: componente,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            if (title == 'Costos') ...[
              _buildCostosCategoryCard(
                  context, 'Materiales', ordenData['costos']['materiales']),
              _buildCostosCategoryCard(
                  context, 'Servicios', ordenData['costos']['servicios']),
            ],
            // Aquí podrías seguir con el resto de las cards o detalles si es necesario.
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

  Widget _buildCostosCategoryCard(BuildContext context, String title,
      Map<String, dynamic> costosCategoriaData) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CostosCategoriaDetailPage(
                categoria: title,
                costosCategoriaData: costosCategoriaData,
              ),
            ),
          );
        },
      ),
    );
  }
}

class OperacionDetailPage extends StatelessWidget {
  final Map<String, dynamic> operacionData;

  const OperacionDetailPage({super.key, required this.operacionData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Operación'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles de la Operación',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailTile('Operación', operacionData['op']),
            _buildDetailTile(
                'Puesto de Trabajo', operacionData['puestoTrabajo']),
            _buildDetailTile('Centro', operacionData['centro']),
            _buildDetailTile('Clave de Control', operacionData['clase']),
            _buildDetailTile('Texto Breve de Operación',
                operacionData['textoBreveOperacion']),
            _buildDetailTile('Trabajo Real', operacionData['trabajoReal']),
            _buildDetailTile('Trabajo', operacionData['trabajo']),
            _buildDetailTile('Unidad de Trabajo (Horas)',
                operacionData['unidadTrabajoHoras']),
            _buildDetailTile('Cantidad', operacionData['cantidad']),
            _buildDetailTile('Duración', operacionData['duracion']),
            _buildDetailTile('Ubicación', operacionData['ubicacion']),
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

class ComponenteDetailPage extends StatelessWidget {
  final Map<String, dynamic> componenteData;

  const ComponenteDetailPage({super.key, required this.componenteData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Componente'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detalles del Componente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailTile('Posición', componenteData['posicion']),
            _buildDetailTile('Componente', componenteData['componente']),
            _buildDetailTile('Denominación', componenteData['denominacion']),
            _buildDetailTile(
                'Cantidad Necesaria', componenteData['cantidadNecesaria']),
            _buildDetailTile('Tipo de Aprovisionamiento',
                componenteData['tipoAprovisionamiento']),
            _buildDetailTile('Destinatario', componenteData['destinatario']),
            _buildDetailTile(
                'Puesto de Descarga', componenteData['puestoDescarga']),
            _buildDetailTile('Unidad de Medida', componenteData['um']),
            _buildDetailTile('Tipo', componenteData['tp']),
            _buildDetailTile('Estado', componenteData['s']),
            _buildDetailTile(
                'Almacenamiento', componenteData['almacenamiento']),
            _buildDetailTile('Centro', componenteData['ce']),
            _buildDetailTile('Operación', componenteData['op']),
            _buildDetailTile('Lote', componenteData['lote']),
            _buildDetailTile('Tipo de Aprovisionamiento',
                componenteData['tipoAprovisionamiento']),
            _buildDetailTile('Destinatario', componenteData['destinatario']),
            _buildDetailTile(
                'Puesto de Descarga', componenteData['puestoDescarga']),
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

class CostosCategoriaDetailPage extends StatelessWidget {
  final String categoria;
  final Map<String, dynamic> costosCategoriaData;

  const CostosCategoriaDetailPage(
      {super.key, required this.categoria, required this.costosCategoriaData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de $categoria'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de $categoria',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailTile(
                'Costes Estimados', costosCategoriaData['costesEstimados']),
            _buildDetailTile('Costes Plan', costosCategoriaData['costesPlan']),
            _buildDetailTile(
                'Costes Reales', costosCategoriaData['costesReales']),
            _buildDetailTile('Moneda', costosCategoriaData['moneda']),
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
