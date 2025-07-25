import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  ResourcesPageState createState() => ResourcesPageState();
}

class ResourcesPageState extends State<ResourcesPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> materials = [];
  List<Map<String, dynamic>> filteredMaterials = [];
  List<Map<String, dynamic>> equipos = [];
  List<Map<String, dynamic>> filteredEquipos = [];
  List<Map<String, dynamic>> personal = [];
  List<Map<String, dynamic>> filteredPersonal = [];
  bool isLoading = true;
  String searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMaterials();
    _loadEquipos();
    _loadPersonal();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMaterials() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/materials.json');
      final data = json.decode(response);
      setState(() {
        materials = List<Map<String, dynamic>>.from(data['materials']);
        filteredMaterials = materials;
      });
    } catch (e) {
      debugPrint('Error al cargar materiales: $e');
    }
    _checkLoadingComplete();
  }

  Future<void> _loadEquipos() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/equipament.json');
      final data = json.decode(response);
      setState(() {
        equipos = List<Map<String, dynamic>>.from(data['equipos']);
        filteredEquipos = equipos;
      });
    } catch (e) {
      debugPrint('Error al cargar equipos: $e');
    }
    _checkLoadingComplete();
  }

  void _checkLoadingComplete() {
    if (materials.isNotEmpty && equipos.isNotEmpty && personal.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadPersonal() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/equipos_trabajo.json');
      final List<dynamic> data = json.decode(response);
      if (data.isNotEmpty) {
        final equiposData = data[0]['datos']['equipos'];
        setState(() {
          personal = List<Map<String, dynamic>>.from(equiposData);
          filteredPersonal = personal;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar personal: $e');
    }
    _checkLoadingComplete();
  }

  void _filterMaterials(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredMaterials = materials;
        filteredEquipos = equipos;
        filteredPersonal = personal;
      } else {
        filteredMaterials = materials.where((material) {
          return material.values.any((value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()));
        }).toList();
        
        filteredEquipos = equipos.where((equipo) {
          return equipo.values.any((value) {
            if (value is Map) {
              return value.values.any((subValue) =>
                  subValue.toString().toLowerCase().contains(query.toLowerCase()));
            }
            return value.toString().toLowerCase().contains(query.toLowerCase());
          });
        }).toList();
        
        filteredPersonal = personal.where((person) {
          return person.values.any((value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MainLayout(
        currentModule: 'programacion',
        customTitle: 'Recursos Disponibles',
        showBackButton: true,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryDarkTeal,
          ),
        ),
      );
    }

    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return MainLayout(
      currentModule: 'programacion',
      customTitle: 'Recursos Disponibles',
      showBackButton: true,
      child: Column(
        children: [
          // Barra de búsqueda
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutralMediumBorder.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: _filterMaterials,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: isMobile
                    ? 'Buscar recursos...'
                    : 'Buscar por código, descripción o tipo...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.neutralTextGray.withOpacity(0.6),
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryDarkTeal,
                  size: 24,
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.neutralTextGray,
                        ),
                        onPressed: () {
                          _filterMaterials('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primaryDarkTeal,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.neutralTextGray,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Materiales'),
                Tab(text: 'Equipamiento'),
                Tab(text: 'Personal'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMaterialsTab(),
                _buildEquipmentTab(),
                _buildPersonalTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Estadísticas de materiales
          _buildMaterialsStats(),
          const SizedBox(height: 16),

          // Lista de materiales
          _buildMaterialsList(),
        ],
      ),
    );
  }

  Widget _buildMaterialsStats() {
    final disponibles =
        filteredMaterials.where((m) => m['disponible'] == true).length;
    final criticos =
        filteredMaterials.where((m) => (m['cantidad'] ?? 0) < 10).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${filteredMaterials.length}',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.primaryDarkTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Total Items',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryDarkTeal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$disponibles',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.secondaryAquaGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Disponibles',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondaryAquaGreen,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$criticos',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.secondaryCoralRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Stock Crítico',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondaryCoralRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsList() {
    if (filteredMaterials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.neutralTextGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No hay materiales disponibles'
                  : 'No se encontraron materiales',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.neutralTextGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredMaterials
          .map(
            (material) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildMaterialCard(material),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final cantidad = material['cantidad'] ?? 0;
    final disponible = material['disponible'] ?? false;
    final stockColor = cantidad < 10
        ? AppColors.secondaryCoralRed
        : cantidad < 50
            ? AppColors.primaryMediumTeal
            : AppColors.secondaryAquaGreen;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutralMediumBorder.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMediumBorder.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    material['codigo'] ?? '',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryDarkTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: disponible
                        ? AppColors.secondaryAquaGreen.withOpacity(0.1)
                        : AppColors.secondaryCoralRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    disponible ? 'Disponible' : 'No Disponible',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: disponible
                          ? AppColors.secondaryAquaGreen
                          : AppColors.secondaryCoralRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: stockColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$cantidad unidades',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: stockColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              material['descripcion'] ?? 'Sin descripción',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 16,
                  color: AppColors.neutralTextGray.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'Tipo: ${material['tipo'] ?? 'No especificado'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutralTextGray.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            if (material['ubicacion'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ubicación: ${material['ubicacion']}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutralTextGray.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Estadísticas de equipos
          _buildEquipmentStats(),
          const SizedBox(height: 16),

          // Lista de equipos
          _buildEquipmentList(),
        ],
      ),
    );
  }

  Widget _buildEquipmentStats() {
    final operativos =
        filteredEquipos.where((e) => e['general']?['estado'] == 'Operativo').length;
    final criticidad =
        filteredEquipos.where((e) => e['general']?['criticidad'] == 'Alta').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${filteredEquipos.length}',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.primaryDarkTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Total Equipos',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryDarkTeal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$operativos',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.secondaryAquaGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Operativos',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondaryAquaGreen,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$criticidad',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.secondaryCoralRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Críticos',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondaryCoralRed,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentList() {
    if (filteredEquipos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.precision_manufacturing,
              size: 64,
              color: AppColors.neutralTextGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No hay equipos disponibles'
                  : 'No se encontraron equipos',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.neutralTextGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredEquipos
          .map(
            (equipo) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildEquipmentCard(equipo),
            ),
          )
          .toList(),
    );
  }

  Widget _buildEquipmentCard(Map<String, dynamic> equipo) {
    final general = equipo['general'] ?? {};
    final emplazamiento = equipo['emplazamiento'] ?? {};
    final estado = general['estado'] ?? 'Desconocido';
    final criticidad = general['criticidad'] ?? 'Media';
    
    final estadoColor = _getEquipmentEstadoColor(estado);
    final criticidadColor = _getCriticidadColor(criticidad);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutralMediumBorder.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMediumBorder.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    equipo['equipo'] ?? '',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primaryDarkTeal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    estado,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: estadoColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: criticidadColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    criticidad,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: criticidadColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              equipo['descripcion'] ?? 'Sin descripción',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.precision_manufacturing,
                  size: 16,
                  color: AppColors.neutralTextGray.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'Tipo: ${general['tipo_equipo'] ?? 'No especificado'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutralTextGray.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            if (general['modelo'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Modelo: ${general['modelo']}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutralTextGray.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
            if (emplazamiento['ubicacion_tecnica'] != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.neutralTextGray.withOpacity(0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ubicación: ${emplazamiento['ubicacion_tecnica']}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.neutralTextGray.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getEquipmentEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'operativo':
        return AppColors.secondaryAquaGreen;
      case 'mantenimiento':
        return AppColors.primaryMediumTeal;
      case 'fuera de servicio':
        return AppColors.secondaryCoralRed;
      default:
        return AppColors.neutralTextGray;
    }
  }

  Color _getCriticidadColor(String criticidad) {
    switch (criticidad.toLowerCase()) {
      case 'alta':
        return AppColors.secondaryCoralRed;
      case 'media':
        return AppColors.primaryMediumTeal;
      case 'baja':
        return AppColors.secondaryAquaGreen;
      default:
        return AppColors.neutralTextGray;
    }
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Estadísticas de personal
          _buildPersonalStats(),
          const SizedBox(height: 16),

          // Lista de equipos de trabajo
          _buildPersonalList(),
        ],
      ),
    );
  }

  Widget _buildPersonalStats() {
    final activos =
        filteredPersonal.where((p) => p['estado'] == 'Activo').length;
    final totalMiembros = filteredPersonal.fold<int>(0, (sum, equipo) {
      final miembros = int.tryParse(equipo['miembros']?.toString() ?? '0') ?? 0;
      return sum + miembros;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryAquaGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '${filteredPersonal.length}',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.secondaryAquaGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Equipos',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.secondaryAquaGreen,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$activos',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.primaryMintGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Activos',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryMintGreen,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$totalMiembros',
                  style: AppTextStyles.heading4.copyWith(
                    color: AppColors.primaryDarkTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Personal',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primaryDarkTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalList() {
    if (filteredPersonal.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.neutralTextGray.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No hay equipos de trabajo disponibles'
                  : 'No se encontraron equipos',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.neutralTextGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredPersonal
          .map(
            (equipo) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildPersonalCard(equipo),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPersonalCard(Map<String, dynamic> equipo) {
    final estado = equipo['estado'] ?? 'Desconocido';
    final especialidad = equipo['especialidad'] ?? '';
    final turno = equipo['turno'] ?? '';
    
    final estadoColor = _getPersonalEstadoColor(estado);
    final especialidadColor = _getEspecialidadColor(especialidad);
    final turnoColor = _getTurnoColor(turno);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.neutralMediumBorder.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutralMediumBorder.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryAquaGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    equipo['id'] ?? '',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.secondaryAquaGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    estado,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: estadoColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: turnoColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    turno,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: turnoColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              equipo['nombre'] ?? 'Sin nombre',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.neutralTextGray.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  'Líder: ${equipo['lider'] ?? 'Sin asignar'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutralTextGray.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.groups_outlined,
                  size: 16,
                  color: AppColors.neutralTextGray.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '${equipo['miembros'] ?? '0'} miembros',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutralTextGray.withOpacity(0.8),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.neutralTextGray.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  equipo['ubicacion'] ?? 'Sin ubicación',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.neutralTextGray.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: especialidadColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                especialidad,
                style: AppTextStyles.labelMedium.copyWith(
                  color: especialidadColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPersonalEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'activo':
        return AppColors.secondaryAquaGreen;
      case 'en formación':
        return AppColors.primaryMediumTeal;
      case 'inactivo':
        return AppColors.secondaryCoralRed;
      default:
        return AppColors.neutralTextGray;
    }
  }

  Color _getEspecialidadColor(String especialidad) {
    switch (especialidad.toLowerCase()) {
      case 'mantenimiento mecánico':
        return AppColors.primaryDarkTeal;
      case 'mantenimiento eléctrico':
        return AppColors.primaryDarkTeal;
      case 'instrumentación y control':
      case 'instrumentación':
        return AppColors.primaryMediumTeal;
      case 'soldadura':
        return AppColors.secondaryCoralRed;
      default:
        return AppColors.neutralTextGray;
    }
  }

  Color _getTurnoColor(String turno) {
    switch (turno.toLowerCase()) {
      case 'mañana':
        return AppColors.primaryMintGreen;
      case 'tarde':
        return AppColors.primaryMediumTeal;
      case 'noche':
        return AppColors.primaryDarkTeal;
      default:
        return AppColors.neutralTextGray;
    }
  }
}
