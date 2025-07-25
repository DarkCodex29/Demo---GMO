import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Configuración para Android solamente
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Manejar cuando el usuario toque la notificación
        print('Notificación tocada: ${response.payload}');
      },
    );

    // Solicitar permisos para Android
    await _requestPermissions();
  }

  static Future<void> _requestPermissions() async {
    // Solicitar permiso de notificaciones en Android 13+
    await Permission.notification.request();
    
    // Para Android 12+ solicitar permisos de alarma exacta
    await Permission.scheduleExactAlarm.request();
  }

  // Notificación para nuevas órdenes de mantenimiento
  static Future<void> showOrderNotification({
    required String orderNumber,
    required String description,
    required String priority,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'maintenance_orders',
      'Órdenes de Mantenimiento',
      channelDescription: 'Notificaciones de órdenes de mantenimiento',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Nueva Orden: $orderNumber',
      '$description - Prioridad: $priority',
      details,
      payload: 'order:$orderNumber',
    );
  }

  // Notificación para gestión de capacidades
  static Future<void> showCapacityAlert({
    required String workCenter,
    required String message,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'capacity_management',
      'Gestión de Capacidades',
      channelDescription: 'Alertas de capacidad y programación',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
      'Alerta de Capacidad: $workCenter',
      message,
      details,
      payload: 'capacity:$workCenter',
    );
  }

  // Notificación para avisos de fallo
  static Future<void> showFailureAlert({
    required String equipmentCode,
    required String failureDescription,
    required String urgency,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'failure_alerts',
      'Avisos de Fallo',
      channelDescription: 'Notificaciones de fallos de equipos',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2,
      '🚨 Fallo en Equipo: $equipmentCode',
      '$failureDescription - Urgencia: $urgency',
      details,
      payload: 'failure:$equipmentCode',
    );
  }

  // Notificación simple programada (sin timezone - usando Duration)
  static Future<void> scheduleMaintenanceReminder({
    required int id,
    required String title,
    required String body,
    required Duration delay,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'maintenance_reminders',
      'Recordatorios de Mantenimiento',
      channelDescription: 'Recordatorios programados de mantenimiento',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    // Programar para mostrar después del delay especificado
    Future.delayed(delay, () async {
      await _notificationsPlugin.show(
        id,
        '⏰ $title',
        'Recordatorio: $body',
        details,
        payload: 'reminder:$id',
      );
    });
  }

  // Simular notificaciones automáticas del sistema
  static Future<void> simulateSystemNotifications() async {
    // Simular notificación de nueva orden cada 10 segundos
    Future.delayed(const Duration(seconds: 10), () async {
      await showOrderNotification(
        orderNumber: "ZIA1-${DateTime.now().millisecondsSinceEpoch % 1000}",
        description: "Mantenimiento preventivo programado",
        priority: "ALTA",
      );
    });

    // Simular alerta de capacidad cada 30 segundos
    Future.delayed(const Duration(seconds: 30), () async {
      await showCapacityAlert(
        workCenter: "PM_MECANICO",
        message: "Capacidad al 85% - Semana 20",
      );
    });

    // Simular alerta de fallo cada 60 segundos
    Future.delayed(const Duration(seconds: 60), () async {
      await showFailureAlert(
        equipmentCode: "VAN-018-001",
        failureDescription: "Temperatura elevada detectada",
        urgency: "CRITICA",
      );
    });
  }

  // Obtener notificaciones activas
  static Future<List<ActiveNotification>> getActiveNotifications() async {
    return await _notificationsPlugin.getActiveNotifications();
  }

  // Cancelar notificación específica
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancelar todas las notificaciones
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Verificar si las notificaciones están habilitadas
  static Future<bool> areNotificationsEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }
} 