import 'package:get/get.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/database/debts_database.dart';

/// Notification Type
enum NotificationType {
  lowStock,
  outOfStock,
  overdueDebt,
  dueSoonDebt,
  system,
}

/// Notification Model
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

/// Notifications Controller
///
/// Manages app notifications for low stock, overdue debts, etc.
class NotificationsController extends GetxController {
  // State
  RxList<AppNotification> notifications = <AppNotification>[].obs;
  RxInt unreadCount = 0.obs;
  RxBool isLoading = false.obs;

  // Thresholds
  final int lowStockThreshold = 10;
  final int dueSoonDays = 7;

  @override
  void onInit() {
    super.onInit();
    checkAllNotifications();
  }

  /// Check all notification conditions
  Future<void> checkAllNotifications() async {
    isLoading.value = true;
    notifications.clear();

    await Future.wait([
      checkLowStock(),
      checkOverdueDebts(),
    ]);

    _sortNotifications();
    _updateUnreadCount();
    isLoading.value = false;
  }

  /// Check for low stock and out of stock items
  Future<void> checkLowStock() async {
    try {
      // Get all materials
      final materials = await MyMaterialsDatabase.getMaterials(0);

      for (final material in materials) {
        // Check out of stock
        if (material.quantity <= 0) {
          notifications.add(AppNotification(
            id: 'out_of_stock_${material.id}',
            title: 'نفاد المخزون',
            message: 'المنتج "${material.name}" نفذ من المخزون!',
            type: NotificationType.outOfStock,
            createdAt: DateTime.now(),
            data: {
              'materialId': material.id,
              'materialName': material.name,
              'barcode': material.barcode,
            },
          ));
        }
        // Check low stock
        else if (material.quantity <= lowStockThreshold) {
          notifications.add(AppNotification(
            id: 'low_stock_${material.id}',
            title: 'مخزون منخفض',
            message: 'المنتج "${material.name}" مخزونه منخفض (${material.quantity} ${material.unit})',
            type: NotificationType.lowStock,
            createdAt: DateTime.now(),
            data: {
              'materialId': material.id,
              'materialName': material.name,
              'currentQuantity': material.quantity,
              'unit': material.unit,
            },
          ));
        }
      }
    } catch (e) {
      print('Error checking low stock: $e');
    }
  }

  /// Check for overdue and due soon debts
  Future<void> checkOverdueDebts() async {
    try {
      // Get all debts
      // This would be implemented based on your debt structure
      // For now, using sample data

      // Check for overdue debts
      // final overdueDebts = await DebtsDatabase.getOverdueDebts();
      // for (final debt in overdueDebts) {
      //   notifications.add(AppNotification(
      //     id: 'overdue_debt_${debt.id}',
      //     title: 'دين متأخر',
      //     message: 'دين بقيمة ${debt.amount} للعميل ${debt.customerName} متأخر',
      //     type: NotificationType.overdueDebt,
      //     createdAt: DateTime.now(),
      //     data: {
      //       'debtId': debt.id,
      //       'customerId': debt.customerId,
      //       'amount': debt.amount,
      //     },
      //   ));
      // }

      // Check for debts due soon
      // final dueSoonDebts = await DebtsDatabase.getDebtsDueSoon(days: dueSoonDays);
      // for (final debt in dueSoonDebts) {
      //   notifications.add(AppNotification(
      //     id: 'due_soon_debt_${debt.id}',
      //     title: 'دين مستحق قريباً',
      //     message: 'دين بقيمة ${debt.amount} للعميل ${debt.customerName} مستحق خلال ${debt.daysUntilDue} أيام',
      //     type: NotificationType.dueSoonDebt,
      //     createdAt: DateTime.now(),
      //     data: {
      //       'debtId': debt.id,
      //       'customerId': debt.customerId,
      //       'amount': debt.amount,
      //       'dueDate': debt.dueDate,
      //     },
      //   ));
      // }
    } catch (e) {
      print('Error checking overdue debts: $e');
    }
  }

  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _updateUnreadCount();
    }
  }

  /// Mark all as read
  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      notifications[i] = notifications[i].copyWith(isRead: true);
    }
    _updateUnreadCount();
  }

  /// Clear all notifications
  void clearAll() {
    notifications.clear();
    _updateUnreadCount();
  }

  /// Remove notification
  void removeNotification(String notificationId) {
    notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
  }

  /// Get notifications by type
  List<AppNotification> getByType(NotificationType type) {
    return notifications.where((n) => n.type == type).toList();
  }

  /// Get unread notifications
  List<AppNotification> getUnread() {
    return notifications.where((n) => !n.isRead).toList();
  }

  /// Sort notifications by priority and date
  void _sortNotifications() {
    notifications.sort((a, b) {
      // Priority: outOfStock > overdueDebt > lowStock > dueSoonDebt
      final priorityOrder = [
        NotificationType.outOfStock,
        NotificationType.overdueDebt,
        NotificationType.lowStock,
        NotificationType.dueSoonDebt,
        NotificationType.system,
      ];

      final aPriority = priorityOrder.indexOf(a.type);
      final bPriority = priorityOrder.indexOf(b.type);

      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }

      return b.createdAt.compareTo(a.createdAt);
    });
  }

  /// Update unread count
  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  /// Add custom notification
  void addNotification(AppNotification notification) {
    notifications.insert(0, notification);
    _updateUnreadCount();
  }

  /// Get notification counts by type
  Map<NotificationType, int> getCountsByType() {
    final counts = <NotificationType, int>{};
    for (final type in NotificationType.values) {
      counts[type] = notifications.where((n) => n.type == type).length;
    }
    return counts;
  }

  /// Refresh notifications
  Future<void> refresh() async {
    await checkAllNotifications();
  }
}
