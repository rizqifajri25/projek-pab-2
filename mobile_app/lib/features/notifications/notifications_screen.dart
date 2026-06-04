import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../providers/notification_provider.dart';
import '../../repositories/notification_repository.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final authState = ref.watch(authStateProvider);
    final userId = authState.maybeWhen(data: (user) => user?.uid, orElse: () => null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (userId != null)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Tandai semua dibaca',
              onPressed: () => ref.read(notificationRepositoryProvider).markAllRead(userId),
            ),
        ],
      ),
      body: notificationsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Belum ada notifikasi.'),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final notification = items[index];
              return ListTile(
                tileColor: notification.read ? null : Colors.blue.shade50,
                title: Text(notification.message),
                subtitle: Text(notification.createdAt != null
                    ? notification.createdAt!.toLocal().toString().split('.').first
                    : 'Waktu tidak tersedia'),
                trailing: notification.read ? null : const Icon(Icons.fiber_manual_record, size: 12, color: Colors.blue),
                onTap: notification.read
                    ? null
                    : () => ref.read(notificationRepositoryProvider).markRead(notification.notificationId),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
