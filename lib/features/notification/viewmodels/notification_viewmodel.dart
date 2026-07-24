import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purwa_digital/core/errors/app_exception.dart';
import '../providers/notification_providers.dart';
import '../models/notification_model.dart';
import 'notification_state.dart';

class NotificationViewModel extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    Future.microtask(() => loadNotifications());
    return const NotificationState(isLoading: true);
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final service = ref.read(notificationServiceProvider);
      final notifications = await service.getNotifications();
      
      final unreadCount = notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        isLoading: false,
        notifications: notifications,
        unreadCount: unreadCount,
      );
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat notifikasi.',
      );
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.markAsRead(id);
      
      final updatedNotifications = state.notifications.map((n) {
        if (n.id == id) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            category: n.category,
            description: n.description,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      // Handle error gracefully without disrupting the UI too much
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.markAllAsRead();
      
      final updatedNotifications = state.notifications.map((n) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          category: n.category,
          description: n.description,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal menandai semua sudah dibaca.');
    }
  }
}

final notificationViewModelProvider = NotifierProvider<NotificationViewModel, NotificationState>(
  NotificationViewModel.new,
);
