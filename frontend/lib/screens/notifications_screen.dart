import 'package:flutter/material.dart';
import '../widgets/auto_hide_bottom_nav.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final notifications = await NotificationService.getNotifications();
    
    if (!mounted) return;
    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;
    
    final success = await NotificationService.markAsRead(notification.id);
    if (success && mounted) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = notification.copyWith(isRead: true);
        }
      });
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    final success = await NotificationService.deleteNotification(notification.id);
    if (success && mounted) {
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification deleted'),
            backgroundColor: Color(0xFF26C281),
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final success = await NotificationService.markAllAsRead();
    if (success && mounted) {
      setState(() {
        _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Color(0xFF26C281),
          ),
        );
      }
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'location_sharing':
        return Icons.location_on;
      case 'bus_arrival':
        return Icons.directions_bus;
      case 'reward':
        return Icons.card_giftcard;
      case 'security':
        return Icons.security;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'location_sharing':
        return const Color(0xFF26C281);
      case 'bus_arrival':
        return const Color(0xFF19C6FF);
      case 'reward':
        return const Color(0xFFFFD700);
      case 'security':
        return const Color(0xFFFF6B6B);
      case 'system':
        return const Color(0xFF7A2CF0);
      default:
        return const Color(0xFF19C6FF);
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF000817),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF19C6FF)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000817),
        title: Text('Notifications', style: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.width * 0.05)),
        automaticallyImplyLeading: false,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all, color: Color(0xFF19C6FF)),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: _loadNotifications,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        elevation: 0,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: AutoHideBottomNav.show,
        child: _notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: MediaQuery.of(context).size.width * 0.2,
                      color: Colors.white38,
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text(
                      'You\'ll receive notifications when buses\nstart sharing their location nearby',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadNotifications,
                color: const Color(0xFF19C6FF),
                backgroundColor: const Color(0xFF001021),
                child: ListView.separated(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  itemBuilder: (context, idx) {
                    final notification = _notifications[idx];
                    final notificationColor = _getNotificationColor(notification.type);
                    
                    return Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.05),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B6B),
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.025),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) => _deleteNotification(notification),
                      child: GestureDetector(
                        onTap: () => _markAsRead(notification),
                        child: Container(
                          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                          decoration: BoxDecoration(
                            color: notification.isRead ? const Color(0xFF001021) : const Color(0xFF001021).withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.025),
                            border: notification.isRead ? null : Border.all(
                              color: notificationColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: MediaQuery.of(context).size.width * 0.05,
                                    backgroundColor: notificationColor.withValues(alpha: 0.2),
                                    child: Icon(
                                      _getNotificationIcon(notification.type),
                                      color: notificationColor,
                                      size: MediaQuery.of(context).size.width * 0.055,
                                    ),
                                  ),
                                  if (!notification.isRead)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: notificationColor,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF001021), width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: TextStyle(
                                        color: notification.isRead ? Colors.white70 : Colors.white,
                                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                                        fontSize: MediaQuery.of(context).size.width * 0.04,
                                      ),
                                    ),
                                    SizedBox(height: MediaQuery.of(context).size.height * 0.0025),
                                    Text(
                                      notification.message,
                                      style: TextStyle(
                                        color: notification.isRead ? Colors.white38 : Colors.white54,
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _getTimeAgo(notification.createdAt),
                                    style: TextStyle(
                                      color: Colors.white38,
                                      fontSize: MediaQuery.of(context).size.width * 0.03,
                                    ),
                                  ),
                                  if (notification.type == 'location_sharing' && notification.data != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: notificationColor.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Track',
                                        style: TextStyle(
                                          color: notificationColor,
                                          fontSize: MediaQuery.of(context).size.width * 0.025,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
