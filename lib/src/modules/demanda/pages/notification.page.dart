import 'package:flutter/material.dart';
import 'package:demo/src/shared/layouts/main_layout.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  List<Map<String, dynamic>> notifications = [];
  Map<String, dynamic>? selectedNotification;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // For now, we'll create some demo notification data
    // In the future, this could load from assets/data/notifications.json
    setState(() {
      notifications = [
        {
          'id': 'NOT-001',
          'title': 'Nueva orden de mantenimiento',
          'message': 'Se ha creado una nueva orden de mantenimiento para el equipo PUMP-001',
          'type': 'order',
          'timestamp': '2024-01-15 14:30:00',
          'isRead': false,
          'priority': 'alta',
        },
        {
          'id': 'NOT-002',
          'title': 'Alerta de capacidad',
          'message': 'La capacidad de trabajo est� al 85% esta semana',
          'type': 'capacity',
          'timestamp': '2024-01-15 12:15:00',
          'isRead': true,
          'priority': 'media',
        },
        {
          'id': 'NOT-003',
          'title': 'Falla detectada',
          'message': 'Se ha detectado una falla en el equipo MOTOR-003',
          'type': 'failure',
          'timestamp': '2024-01-15 10:45:00',
          'isRead': false,
          'priority': 'critica',
        },
      ];
    });
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'capacity':
        return Colors.orange;
      case 'failure':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.assignment;
      case 'capacity':
        return Icons.warning;
      case 'failure':
        return Icons.error;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentModule: 'demanda',
      customTitle: 'Notificaciones',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Search bar
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar notificaciones...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            
            // Notifications list
            Expanded(
              child: notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationCard(notification);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las notificaciones aparecer�n aqu� cuando est�n disponibles',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final notificationColor = _getNotificationColor(notification['type']);
    final notificationIcon = _getNotificationIcon(notification['type']);
    final isRead = notification['isRead'] ?? false;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isRead ? Colors.grey.shade300 : notificationColor,
            width: isRead ? 0.5 : 2,
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: notificationColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: notificationColor.withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Icon(
              notificationIcon,
              color: notificationColor,
              size: 20,
            ),
          ),
          title: Text(
            notification['title'] ?? 'Sin t�tulo',
            style: TextStyle(
              fontWeight: isRead ? FontWeight.w500 : FontWeight.w700,
              color: isRead ? Colors.grey[700] : Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification['message'] ?? 'Sin mensaje',
                style: TextStyle(
                  color: isRead ? Colors.grey[600] : Colors.black54,
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notification['timestamp'] ?? 'Sin fecha',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(notification['priority']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getPriorityColor(notification['priority']).withOpacity(0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      notification['priority']?.toUpperCase() ?? 'MEDIA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getPriorityColor(notification['priority']),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: !isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: notificationColor,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            setState(() {
              notification['isRead'] = true;
            });
            _showNotificationDetails(notification);
          },
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'critica':
        return Colors.red;
      case 'alta':
        return Colors.orange;
      case 'media':
        return Colors.blue;
      case 'baja':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              _getNotificationIcon(notification['type']),
              color: _getNotificationColor(notification['type']),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                notification['title'] ?? 'Sin t�tulo',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mensaje:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(notification['message'] ?? 'Sin mensaje'),
            const SizedBox(height: 16),
            Text(
              'Fecha y hora:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(notification['timestamp'] ?? 'Sin fecha'),
            const SizedBox(height: 16),
            Text(
              'Prioridad:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getPriorityColor(notification['priority']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getPriorityColor(notification['priority']).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Text(
                notification['priority']?.toUpperCase() ?? 'MEDIA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getPriorityColor(notification['priority']),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}