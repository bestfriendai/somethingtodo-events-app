import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../config/theme.dart' as old_theme;
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../events/event_details_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _listAnimationController;
  bool _isSelectionMode = false;
  Set<String> _selectedNotifications = {};

  final List<AppNotification> _notifications = [
    AppNotification(
      id: '1',
      type: NotificationType.eventReminder,
      title: 'Jazz Night Tonight!',
      message:
          'Don\'t forget about the Jazz Night at Blue Note starting at 8 PM',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
      eventId: 'event1',
      actionUrl: null,
    ),
    AppNotification(
      id: '2',
      type: NotificationType.newEvent,
      title: 'New Food Festival Added',
      message:
          'A new food festival "Taste of the City" has been added near you',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      eventId: 'event2',
      actionUrl: null,
    ),
    AppNotification(
      id: '3',
      type: NotificationType.recommendation,
      title: 'Events You Might Like',
      message: 'We found 3 music events that match your interests',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isRead: true,
      eventId: null,
      actionUrl: null,
    ),
    AppNotification(
      id: '4',
      type: NotificationType.eventUpdate,
      title: 'Event Location Changed',
      message: 'Art Gallery Opening has moved to a new venue',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      eventId: 'event3',
      actionUrl: null,
    ),
    AppNotification(
      id: '5',
      type: NotificationType.social,
      title: 'Friend Activity',
      message: 'Sarah added 2 events to her favorites',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      eventId: null,
      actionUrl: null,
    ),
    AppNotification(
      id: '6',
      type: NotificationType.system,
      title: 'Welcome to Premium!',
      message:
          'Your premium subscription is now active. Enjoy unlimited features!',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      eventId: null,
      actionUrl: null,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _listAnimationController = AnimationController(
      duration: AppTheme.animationSlow,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedNotifications.clear();
      }
    });
  }

  void _selectNotification(String notificationId) {
    setState(() {
      if (_selectedNotifications.contains(notificationId)) {
        _selectedNotifications.remove(notificationId);
      } else {
        _selectedNotifications.add(notificationId);
      }
    });
  }

  void _selectAllNotifications() {
    setState(() {
      if (_selectedNotifications.length == _notifications.length) {
        _selectedNotifications.clear();
      } else {
        _selectedNotifications = _notifications.map((n) => n.id).toSet();
      }
    });
  }

  void _markSelectedAsRead() {
    setState(() {
      for (final notification in _notifications) {
        if (_selectedNotifications.contains(notification.id)) {
          notification.isRead = true;
        }
      }
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications marked as read'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _deleteSelectedNotifications() {
    setState(() {
      _notifications.removeWhere(
        (notification) => _selectedNotifications.contains(notification.id),
      );
      _selectedNotifications.clear();
      _isSelectionMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifications deleted'),
        backgroundColor: AppTheme.errorColor,
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.isRead = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Notifications'),
        content: const Text(
          'Are you sure you want to delete all notifications? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _notifications.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications cleared'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _onNotificationTapped(AppNotification notification) {
    if (_isSelectionMode) {
      _selectNotification(notification.id);
      return;
    }

    // Mark as read
    setState(() {
      notification.isRead = true;
    });

    // Handle different notification actions
    switch (notification.type) {
      case NotificationType.eventReminder:
      case NotificationType.newEvent:
      case NotificationType.eventUpdate:
        if (notification.eventId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EventDetailsScreen(eventId: notification.eventId),
            ),
          );
        }
        break;
      case NotificationType.recommendation:
        // Navigate to recommended events
        break;
      case NotificationType.social:
        // Navigate to social features
        break;
      case NotificationType.system:
        // Handle system notifications
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.currentUser == null) {
            return _buildSignInPrompt();
          }

          if (_notifications.isEmpty) {
            return _buildEmptyState();
          }

          return _buildNotificationsList();
        },
      ),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBottomBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _isSelectionMode
          ? Text('${_selectedNotifications.length} selected')
          : const Text('Notifications'),
      leading: _isSelectionMode
          ? IconButton(
              onPressed: _toggleSelectionMode,
              icon: const Icon(Icons.close),
            )
          : null,
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            onPressed: _selectAllNotifications,
            icon: const Icon(Icons.select_all),
          ),
        ] else ...[
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'select':
                    _toggleSelectionMode();
                    break;
                  case 'mark_all_read':
                    _markAllAsRead();
                    break;
                  case 'clear_all':
                    _clearAllNotifications();
                    break;
                  case 'settings':
                    Navigator.pushNamed(context, '/settings');
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'select',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline),
                      SizedBox(width: AppTheme.spaceSm),
                      Text('Select'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'mark_all_read',
                  child: Row(
                    children: [
                      Icon(Icons.mark_email_read),
                      SizedBox(width: AppTheme.spaceSm),
                      Text('Mark All as Read'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all),
                      SizedBox(width: AppTheme.spaceSm),
                      Text('Clear All'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: AppTheme.spaceSm),
                      Text('Notification Settings'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }

  Widget _buildSignInPrompt() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: AppTheme.space3xl + 16, color: Colors.grey[400]),
            SizedBox(height: AppTheme.spaceLg),
            Text(
              'Sign in for notifications',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: AppTheme.spaceMd - 4),
            Text(
              'Get notified about events you care about and never miss out.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.spaceXl),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/auth'),
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
            ),
          ],
        ),
      ),
      ).animate().fadeIn(duration: AppTheme.animationSlow).slideY(begin: 0.3);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: AppTheme.space3xl + 16, color: Colors.grey[400]),
            SizedBox(height: AppTheme.spaceLg),
            Text(
              'No notifications',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: AppTheme.spaceMd - 4),
            Text(
              'When you have notifications, they\'ll appear here.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      ).animate().fadeIn(duration: AppTheme.animationSlow).slideY(begin: 0.3);
  }

  Widget _buildNotificationsList() {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
          itemCount: _notifications.length,
          itemBuilder: (context, index) {
            final notification = _notifications[index];
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _listAnimationController.value)),
              child: Opacity(
                opacity: _listAnimationController.value,
                child: _buildNotificationItem(notification, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationItem(AppNotification notification, int index) {
    final isSelected = _selectedNotifications.contains(notification.id);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceLg - 4),
        color: AppTheme.errorColor,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _notifications.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                setState(() {
                  _notifications.insert(index, notification);
                });
              },
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead
              ? null
              : AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: _isSelectionMode && isSelected
              ? Border.all(color: AppTheme.primaryColor, width: 2)
              : null,
        ),
        child: ListTile(
          leading: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getNotificationColor(
                    notification.type,
                  ).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 20,
                ),
              ),
              if (!notification.isRead)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead
                  ? FontWeight.normal
                  : FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(notification.timestamp),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          trailing: _isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (_) => _selectNotification(notification.id),
                )
              : const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _onNotificationTapped(notification),
          onLongPress: () {
            if (!_isSelectionMode) {
              _toggleSelectionMode();
              _selectNotification(notification.id);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSelectionBottomBar() {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedNotifications.isNotEmpty
                    ? _markSelectedAsRead
                    : null,
                icon: const Icon(Icons.mark_email_read),
                label: const Text('Mark Read'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedNotifications.isNotEmpty
                    ? _deleteSelectedNotifications
                    : null,
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.eventReminder:
        return Icons.alarm;
      case NotificationType.newEvent:
        return Icons.event;
      case NotificationType.recommendation:
        return Icons.recommend;
      case NotificationType.eventUpdate:
        return Icons.update;
      case NotificationType.social:
        return Icons.people;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.eventReminder:
        return AppTheme.warningColor;
      case NotificationType.newEvent:
        return AppTheme.primaryColor;
      case NotificationType.recommendation:
        return AppTheme.successColor;
      case NotificationType.eventUpdate:
        return AppTheme.secondaryColor;
      case NotificationType.social:
        return Colors.purple;
      case NotificationType.system:
        return Colors.grey[600]!;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }
}

enum NotificationType {
  eventReminder,
  newEvent,
  recommendation,
  eventUpdate,
  social,
  system,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;
  final String? eventId;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.eventId,
    this.actionUrl,
  });
}
