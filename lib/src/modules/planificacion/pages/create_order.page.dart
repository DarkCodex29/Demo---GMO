import 'package:flutter/material.dart';
import 'package:demo/src/core/services/notification_service.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  CreateOrderPageState createState() => CreateOrderPageState();
}

class CreateOrderPageState extends State<CreateOrderPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores según los campos del proceso real
  final TextEditingController _claseOrdenController = TextEditingController();
  final TextEditingController _prioridadController = TextEditingController();
  final TextEditingController _equipoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _operacionController = TextEditingController();
  final TextEditingController _centroCostoController = TextEditingController();
  final TextEditingController _cantidadPersonasController =
      TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  final TextEditingController _componentesController = TextEditingController();
  final TextEditingController _trabajoPlanController = TextEditingController();
  final TextEditingController _centroController = TextEditingController();
  final TextEditingController _almacenController = TextEditingController();
  final TextEditingController _tipoMaterialController = TextEditingController();
  final TextEditingController _ubicacionTecnicaController =
      TextEditingController();

  // Datos para dropdowns
  final List<String> clasesOrden = [
    'ZPM1',
    'ZPM2',
    'ZIA1',
    'ZM23',
    'ZM24',
    'ZM25'
  ];
  final List<String> prioridades = [
    '1 URGENTE',
    '2 PRIORITARIO',
    '3 NORMAL',
    '4 BAJO'
  ];
  final List<String> tiposPlan = [
    'Plan preventivo',
    'Plan correctivo',
    'Mantenimiento de 500 km'
  ];

  String? selectedClaseOrden;
  String? selectedPrioridad;
  String? selectedTipoPlan;

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return MainLayout(
      currentModule: 'planificacion',
      customTitle: 'Crear Orden de Trabajo',
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: ResponsiveRowColumn(
            layout: isDesktop
                ? ResponsiveRowColumnType.ROW
                : ResponsiveRowColumnType.COLUMN,
            rowCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDesktop) ...[
                ResponsiveRowColumnItem(
                  rowFlex: 1,
                  child: _buildLeftColumn(),
                ),
                const ResponsiveRowColumnItem(
                  child: SizedBox(width: 24),
                ),
                ResponsiveRowColumnItem(
                  rowFlex: 1,
                  child: _buildRightColumn(),
                ),
              ] else ...[
                ResponsiveRowColumnItem(
                  child: _buildLeftColumn(),
                ),
                ResponsiveRowColumnItem(
                  child: SizedBox(height: isMobile ? 16 : 24),
                ),
                ResponsiveRowColumnItem(
                  child: _buildRightColumn(),
                ),
              ],
              ResponsiveRowColumnItem(
                child: SizedBox(height: isMobile ? 16 : 24),
              ),
              ResponsiveRowColumnItem(
                child: _buildActionButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        _buildInfoGeneralCard(),
        const SizedBox(height: 16),
        _buildOperacionCard(),
      ],
    );
  }

  Widget _buildRightColumn() {
    return Column(
      children: [
        _buildMaterialesCard(),
      ],
    );
  }

  Widget _buildInfoGeneralCard() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDarkTealLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Información General',
                  style: AppTextStyles.heading6,
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            _buildResponsiveRow([
              _buildDropdownField(
                label: 'Clase de orden',
                value: selectedClaseOrden,
                items: clasesOrden,
                onChanged: (value) =>
                    setState(() => selectedClaseOrden = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
              _buildDropdownField(
                label: 'Prioridad',
                value: selectedPrioridad,
                items: prioridades,
                onChanged: (value) => setState(() => selectedPrioridad = value),
                validator: (value) => value == null ? 'Requerido' : null,
              ),
            ]),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _equipoController,
              label: 'Equipo',
              hint: 'Ej: 10000001',
              validator: (value) => value?.isEmpty == true
                  ? 'Ingrese el código del equipo'
                  : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descripcionController,
              label: 'Descripción de la orden',
              hint: 'Describa el trabajo a realizar',
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty == true ? 'Ingrese una descripción' : null,
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Tipo de plan',
              value: selectedTipoPlan,
              items: tiposPlan,
              onChanged: (value) => setState(() => selectedTipoPlan = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperacionCard() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMintGreenLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Detalles de Operación',
                  style: AppTextStyles.heading6,
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            _buildResponsiveRow([
              _buildTextField(
                controller: _operacionController,
                label: 'Operación',
                hint: 'Ej: 0010',
              ),
              _buildTextField(
                controller: _centroCostoController,
                label: 'Centro de costo',
                hint: 'Ej: 10000001',
              ),
            ]),
            const SizedBox(height: 16),
            _buildResponsiveRow([
              _buildTextField(
                controller: _cantidadPersonasController,
                label: 'Cantidad de personas',
                hint: 'Ej: 2',
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                controller: _duracionController,
                label: 'Duración',
                hint: 'Ej: 2h',
              ),
            ]),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _trabajoPlanController,
              label: 'Trabajo plan',
              hint: 'Descripción del trabajo planificado',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialesCard() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryAquaGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Materiales y Recursos',
                  style: AppTextStyles.heading6,
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            _buildResponsiveRow([
              _buildTextField(
                controller: _centroController,
                label: 'Centro',
                hint: 'Ej: 1001',
              ),
              _buildTextField(
                controller: _almacenController,
                label: 'Almacén',
                hint: 'Ej: 2001',
              ),
            ]),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _componentesController,
              label: 'Componentes',
              hint: 'Lista de componentes necesarios',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _ubicacionTecnicaController,
              label: 'Ubicación técnica',
              hint: 'Ej: PERU-CHI-PCBN-RA-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveRow(List<Widget> children) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (isMobile) {
      return Column(
        children: children
            .expand((widget) => [widget, const SizedBox(height: 16)])
            .take(children.length * 2 - 1)
            .toList(),
      );
    }

    return Row(
      children: children
          .expand(
              (widget) => [Expanded(child: widget), const SizedBox(width: 16)])
          .take(children.length * 2 - 1)
          .toList(),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
      ),
      value: value,
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildActionButtons() {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isTablet = ResponsiveBreakpoints.of(context).isTablet;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: _saveDraft,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: Text('Guardar Borrador',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.black)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _saveOrder,
            icon: const Icon(Icons.check_circle, size: 18),
            label: Text('Crear Orden', style: AppTextStyles.buttonMedium),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment:
          isTablet ? MainAxisAlignment.center : MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: _saveDraft,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text('Guardar Borrador', style: AppTextStyles.buttonMedium),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _saveOrder,
          icon: const Icon(Icons.check_circle, size: 18),
          label: Text('Crear Orden', style: AppTextStyles.buttonMedium),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  void _saveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Borrador guardado exitosamente'),
      ),
    );
  }

  void _saveOrder() {
    if (_formKey.currentState!.validate()) {
      // Generar número de orden
      final orderNumber =
          'ZIA1-${DateTime.now().millisecondsSinceEpoch % 10000}';

      // Mostrar confirmación
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Orden Creada'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow('Número de orden:', orderNumber),
              _buildInfoRow('Clase:', selectedClaseOrden ?? 'N/A'),
              _buildInfoRow('Prioridad:', selectedPrioridad ?? 'N/A'),
              _buildInfoRow('Equipo:', _equipoController.text),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSuccessItem('Orden creada exitosamente'),
                    _buildSuccessItem('Notificaciones enviadas'),
                    _buildSuccessItem('Programación actualizada'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _createAnotherOrder();
              },
              child: const Text('Crear Otra'),
            ),
          ],
        ),
      );

      // Enviar notificación
      NotificationService.showOrderNotification(
        orderNumber: orderNumber,
        description: _descripcionController.text,
        priority: selectedPrioridad ?? 'NORMAL',
      );
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  void _createAnotherOrder() {
    // Limpiar formulario para nueva orden
    setState(() {
      _claseOrdenController.clear();
      _equipoController.clear();
      _descripcionController.clear();
      _operacionController.clear();
      _centroCostoController.clear();
      _cantidadPersonasController.clear();
      _duracionController.clear();
      _componentesController.clear();
      _trabajoPlanController.clear();
      _centroController.clear();
      _almacenController.clear();
      _ubicacionTecnicaController.clear();

      selectedClaseOrden = null;
      selectedPrioridad = null;
      selectedTipoPlan = null;
    });
  }

  @override
  void dispose() {
    _claseOrdenController.dispose();
    _prioridadController.dispose();
    _equipoController.dispose();
    _descripcionController.dispose();
    _operacionController.dispose();
    _centroCostoController.dispose();
    _cantidadPersonasController.dispose();
    _duracionController.dispose();
    _componentesController.dispose();
    _trabajoPlanController.dispose();
    _centroController.dispose();
    _almacenController.dispose();
    _tipoMaterialController.dispose();
    _ubicacionTecnicaController.dispose();
    super.dispose();
  }
}
