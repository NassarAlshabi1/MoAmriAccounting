import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/shared/theme/app_palette.dart';
import 'package:moamri_accounting/services/notifications_controller.dart';
import 'package:moamri_accounting/shared/widgets/buttons.dart';

/// Notifications Page
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text(
          'الإشعارات',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppPalette.surface,
        actions: [
          TextButton(
            onPressed: () => controller.markAllAsRead(),
            child: Text(
              'تحديد الكل كمقروء',
              style: GoogleFonts.cairo(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return Column(
          children: [
            // Summary bar
            _buildSummaryBar(controller),

            // Notifications list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notification = controller.notifications[index];
                  return _buildNotificationItem(controller, notification);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: AppPalette.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: AppPalette.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جميع الأمور على ما يرام!',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppPalette.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(NotificationsController controller) {
    return Obx(() {
      final counts = controller.getCountsByType();
      final outOfStock = counts[NotificationType.outOfStock] ?? 0;
      final lowStock = counts[NotificationType.lowStock] ?? 0;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          border: Border(
            bottom: BorderSide(color: AppPalette.outline.withOpacity(0.5)),
          ),
        ),
        child: Row(
          children: [
            if (outOfStock > 0)
              _buildSummaryItem(
                'نفاد',
                outOfStock,
                AppPalette.expense,
              ),
            if (lowStock > 0) ...[
              const SizedBox(width: 16),
              _buildSummaryItem(
                'منخفض',
                lowStock,
                AppPalette.warning,
              ),
            ],
            const Spacer(),
            Text(
              '${controller.notifications.length} إشعار',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppPalette.textHint,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    NotificationsController controller,
    AppNotification notification,
  ) {
    final color = _getNotificationColor(notification.type);
    final icon = _getNotificationIcon(notification.type);
    final isRead = notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead ? AppPalette.surface : color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRead
              ? AppPalette.outline.withOpacity(0.5)
              : color.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: GoogleFonts.cairo(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                ),
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppPalette.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(notification.createdAt),
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: AppPalette.textHint,
              ),
            ),
          ],
        ),
        trailing: notification.type == NotificationType.lowStock ||
                notification.type == NotificationType.outOfStock
            ? AppSecondaryButton(
                text: 'طلب توريد',
                onPressed: () {},
              )
            : null,
        onTap: () {
          controller.markAsRead(notification.id);
        },
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.outOfStock:
        return AppPalette.expense;
      case NotificationType.lowStock:
        return AppPalette.warning;
      case NotificationType.overdueDebt:
        return AppPalette.expense;
      case NotificationType.dueSoonDebt:
        return AppPalette.warning;
      case NotificationType.system:
        return AppPalette.info;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.outOfStock:
        return Icons.error_rounded;
      case NotificationType.lowStock:
        return Icons.warning_rounded;
      case NotificationType.overdueDebt:
        return Icons.schedule_rounded;
      case NotificationType.dueSoonDebt:
        return Icons.access_time_rounded;
      case NotificationType.system:
        return Icons.info_rounded;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

/// Notifications Badge Widget
class NotificationsBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const NotificationsBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());

    return Obx(() {
      return Stack(
        children: [
          IconButton(
            onPressed: onTap ??
                () {
                  Get.to(() => const NotificationsPage());
                },
            icon: const Icon(Icons.notifications_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppPalette.surfaceVariant,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          if (controller.unreadCount.value > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppPalette.expense,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  controller.unreadCount.value > 99
                      ? '99+'
                      : '${controller.unreadCount.value}',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    });
  }
}
