import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Servicio centralizado para gestión de datos del sistema GMO
/// Organizado según estructura modular SAP PM
class DataService {
  static DataService? _instance;
  static DataService get instance => _instance ??= DataService._();
  DataService._();

  // Cache para datos cargados
  final Map<String, dynamic> _cache = {};

  /// MÓDULO CONFIABILIDAD - Datos maestros
  
  /// Obtiene clases de equipos
  Future<List<dynamic>> getClasses() async {
    return await _loadJsonData('assets/data/class.json');
  }

  /// Obtiene ubicaciones técnicas
  Future<List<dynamic>> getLocations() async {
    return await _loadJsonData('assets/data/locations.json');
  }

  /// Obtiene puestos de trabajo
  Future<List<dynamic>> getJobs() async {
    return await _loadJsonData('assets/data/job.json');
  }

  /// Obtiene equipos
  Future<List<dynamic>> getEquipment() async {
    return await _loadJsonData('assets/data/equipament.json');
  }

  /// Obtiene materiales
  Future<List<dynamic>> getMaterials() async {
    return await _loadJsonData('assets/data/materials.json');
  }

  /// Obtiene estrategias de mantenimiento
  Future<List<dynamic>> getMaintenanceStrategies() async {
    return await _loadJsonData('assets/data/estrategias_mantenimiento.json');
  }

  /// Obtiene hojas de ruta
  Future<List<dynamic>> getRoadmaps() async {
    return await _loadJsonData('assets/data/hojas_ruta.json');
  }

  /// Obtiene ciclos de mantenimiento
  Future<List<dynamic>> getMaintenanceCycles() async {
    return await _loadJsonData('assets/data/ciclos_mantenimiento.json');
  }

  /// Obtiene instrucciones de trabajo
  Future<List<dynamic>> getWorkInstructions() async {
    return await _loadJsonData('assets/data/instrucciones_trabajo.json');
  }

  /// Obtiene equipos de trabajo
  Future<List<dynamic>> getWorkTeams() async {
    return await _loadJsonData('assets/data/equipos_trabajo.json');
  }

  /// Obtiene UBTs (Unidades Básicas de Trabajo)
  Future<List<dynamic>> getUBTs() async {
    return await _loadJsonData('assets/data/ubts.json');
  }

  /// MÓDULO DEMANDA - Gestión de avisos y notificaciones

  /// Obtiene avisos
  Future<List<dynamic>> getNotifications() async {
    return await _loadJsonData('assets/data/avisos.json');
  }

  /// Obtiene demandas
  Future<List<dynamic>> getDemands() async {
    return await _loadJsonData('assets/data/demandas.json');
  }

  /// MÓDULO PLANIFICACIÓN - Órdenes y programación

  /// Obtiene órdenes de trabajo
  Future<List<dynamic>> getOrders() async {
    return await _loadJsonData('assets/data/ordenes.json');
  }

  /// Obtiene órdenes PM (Preventive Maintenance)
  Future<List<dynamic>> getPMOrders() async {
    return await _loadJsonData('assets/data/ordenes_pm.json');
  }

  /// Obtiene planificación de mantenimiento
  Future<List<dynamic>> getMaintenancePlanning() async {
    return await _loadJsonData('assets/data/planificacion_mantenimiento.json');
  }

  /// MÓDULO PROGRAMACIÓN - Recursos y capacidades

  /// Obtiene capacidades de recursos
  Future<List<dynamic>> getCapacities() async {
    return await _loadJsonData('assets/data/capacidades.json');
  }

  /// MÓDULO AUTH - Usuarios del sistema

  /// Obtiene usuarios
  Future<List<dynamic>> getUsers() async {
    return await _loadJsonData('assets/data/users.json');
  }

  /// MÉTODOS UTILITARIOS

  /// Carga datos JSON con caché
  Future<List<dynamic>> _loadJsonData(String path) async {
    if (_cache.containsKey(path)) {
      return _cache[path];
    }

    try {
      final String jsonString = await rootBundle.loadString(path);
      final dynamic decoded = json.decode(jsonString);
      
      List<dynamic> data;
      if (decoded is List) {
        data = decoded;
      } else if (decoded is Map) {
        // Si es un Map, buscar la primera clave que contenga un array
        String? firstArrayKey;
        try {
          firstArrayKey = decoded.keys.firstWhere(
            (key) => decoded[key] is List,
          );
        } catch (e) {
          firstArrayKey = null;
        }
        if (firstArrayKey != null) {
          data = decoded[firstArrayKey];
        } else {
          print('No array found in $path');
          data = [];
        }
      } else {
        print('Unexpected JSON structure in $path');
        data = [];
      }
      
      _cache[path] = data;
      return data;
    } catch (e) {
      print('Error loading $path: $e');
      return [];
    }
  }

  /// Limpia el caché de datos
  void clearCache() {
    _cache.clear();
  }

  /// Obtiene estadísticas del dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final orders = await getOrders();
      final notifications = await getNotifications();
      final equipment = await getEquipment();
      final pmOrders = await getPMOrders();

      // Calcular estadísticas básicas
      final activeOrders = orders.where((order) => 
        order['estado']?.toLowerCase() != 'cerrada' && 
        order['estado']?.toLowerCase() != 'completada').length;

      final pendingNotifications = notifications.where((notif) => 
        notif['estado']?.toLowerCase() == 'abierto' || 
        notif['estado']?.toLowerCase() == 'pendiente').length;

      final operationalEquipment = equipment.where((eq) => 
        eq['estado']?.toLowerCase() == 'operativo' || 
        eq['estado']?.toLowerCase() == 'disponible').length;

      final totalEquipment = equipment.length;
      final availability = totalEquipment > 0 
        ? ((operationalEquipment / totalEquipment) * 100).round()
        : 0;

      return {
        'activeOrders': activeOrders,
        'pendingNotifications': pendingNotifications,
        'operationalEquipment': operationalEquipment,
        'totalEquipment': totalEquipment,
        'efficiency': 94, // Valor calculado o predeterminado
        'availability': availability,
      };
    } catch (e) {
      print('Error calculating dashboard stats: $e');
      return {
        'activeOrders': 0,
        'pendingNotifications': 0,
        'operationalEquipment': 0,
        'totalEquipment': 0,
        'efficiency': 0,
        'availability': 0,
      };
    }
  }

  /// Buscar en todos los datos
  Future<List<Map<String, dynamic>>> searchGlobal(String query) async {
    final results = <Map<String, dynamic>>[];
    final lowerQuery = query.toLowerCase();

    try {
      // Buscar en equipos
      final equipment = await getEquipment();
      for (var item in equipment) {
        if (item['denominacion']?.toLowerCase().contains(lowerQuery) == true ||
            item['codigo']?.toLowerCase().contains(lowerQuery) == true) {
          results.add({
            'type': 'equipment',
            'title': item['denominacion'] ?? 'Equipo sin nombre',
            'subtitle': 'Código: ${item['codigo']} - ${item['ubicacion'] ?? 'Sin ubicación'}',
            'data': item,
          });
        }
      }

      // Buscar en órdenes
      final orders = await getOrders();
      for (var item in orders) {
        if (item['numero']?.toLowerCase().contains(lowerQuery) == true ||
            item['descripcion']?.toLowerCase().contains(lowerQuery) == true) {
          results.add({
            'type': 'order',
            'title': 'Orden ${item['numero']}',
            'subtitle': '${item['descripcion']} - Estado: ${item['estado']}',
            'data': item,
          });
        }
      }

      // Buscar en avisos
      final notifications = await getNotifications();
      for (var item in notifications) {
        if (item['descripcion']?.toLowerCase().contains(lowerQuery) == true) {
          results.add({
            'type': 'notification',
            'title': 'Aviso ${item['numero'] ?? ''}',
            'subtitle': '${item['descripcion']} - Prioridad: ${item['prioridad']}',
            'data': item,
          });
        }
      }
    } catch (e) {
      print('Error in global search: $e');
    }

    return results;
  }
}