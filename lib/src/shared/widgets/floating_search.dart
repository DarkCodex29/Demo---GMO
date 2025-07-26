import 'package:flutter/material.dart';
import 'package:demo/src/theme/app_colors.dart';
import 'package:demo/src/theme/app_text_styles.dart';

class FloatingSearch extends StatefulWidget {
  const FloatingSearch({super.key});

  @override
  FloatingSearchState createState() => FloatingSearchState();
}

class FloatingSearchState extends State<FloatingSearch>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  Offset _position = const Offset(16, 20); // Posición inicial (right, bottom)
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
      _focusNode.requestFocus();
    } else {
      _animationController.reverse();
      _searchController.clear();
      _focusNode.unfocus();
    }
  }

  void _performSearch(String query) {
    if (query.isNotEmpty) {
      // Aquí iría la lógica de búsqueda
      debugPrint('Buscando: $query');
      _showSearchResults(query);
    }
  }

  void _showSearchResults(String query) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryDarkTeal,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.white),
                    const SizedBox(width: 12),
                    Text(
                      'Resultados para "$query"',
                      style: AppTextStyles.heading6.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSearchResultItem(
                      'Equipo ${query.toUpperCase()}',
                      'Bomba centrífuga - Ubicación: PLANTA-A',
                      Icons.engineering,
                      AppColors.primaryDarkTeal,
                    ),
                    _buildSearchResultItem(
                      'Orden ZIA1-$query',
                      'Mantenimiento preventivo - Estado: Planificada',
                      Icons.assignment,
                      AppColors.primaryMediumTeal,
                    ),
                    _buildSearchResultItem(
                      'Material $query',
                      'Repuesto disponible - Stock: 25 unidades',
                      Icons.inventory,
                      AppColors.primaryMintGreen,
                    ),
                    _buildSearchResultItem(
                      'Aviso AV-$query',
                      'Mantenimiento correctivo - Prioridad: Alta',
                      Icons.warning,
                      AppColors.secondaryCoralRed,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultItem(
      String title, String subtitle, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.neutralTextGray.withOpacity(0.8),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.neutralTextGray,
        ),
        onTap: () {
          Navigator.pop(context);
          _toggleSearch();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: _position.dy,
      right: _position.dx,
      child: GestureDetector(
        onPanStart: (details) {
          if (!_isExpanded) {
            setState(() {
              _isDragging = true;
            });
          }
        },
        onPanUpdate: (details) {
          if (!_isExpanded && _isDragging) {
            setState(() {
              final screenSize = MediaQuery.of(context).size;
              final newX = _position.dx - details.delta.dx;
              final newY = _position.dy - details.delta.dy;

              // Límites para mantener el botón dentro de la pantalla
              const minX = 16.0;
              final maxX =
                  screenSize.width - 72; // 56 (ancho del botón) + 16 (margen)
              const minY = 16.0;
              final maxY =
                  screenSize.height - 140; // Altura del botón + margen inferior

              _position = Offset(
                newX.clamp(minX, maxX),
                newY.clamp(minY, maxY),
              );
            });
          }
        },
        onPanEnd: (details) {
          if (!_isExpanded) {
            setState(() {
              _isDragging = false;
            });
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: _isDragging ? 0 : 300),
          width: _isExpanded ? 280 : 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryDarkTeal,
            borderRadius: BorderRadius.circular(_isExpanded ? 25 : 28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isDragging ? 0.3 : 0.2),
                blurRadius: _isDragging ? 12 : 8,
                offset: Offset(0, _isDragging ? 6 : 4),
              ),
            ],
          ),
          child: _isExpanded ? _buildExpandedSearch() : _buildCollapsedSearch(),
        ),
      ),
    );
  }

  Widget _buildCollapsedSearch() {
    return InkWell(
      onTap: _toggleSearch,
      borderRadius: BorderRadius.circular(28),
      child: const Center(
        child: Icon(
          Icons.search,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildExpandedSearch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.search,
            color: AppColors.white,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onSubmitted: _performSearch,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
              ),
              cursorColor: AppColors.white,
              decoration: InputDecoration(
                hintText: 'Buscar...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
                fillColor: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _toggleSearch,
            child: const Icon(
              Icons.close,
              color: AppColors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
