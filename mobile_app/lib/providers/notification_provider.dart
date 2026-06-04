import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepository(ref.watch(firestoreProvider)),
);

final userNotificationsProvider = StreamProvider.autoDispose(
  (ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        if (user == null) {
          return const Stream<List<dynamic>>.empty().cast();
        }
        return ref.watch(notificationRepositoryProvider).notificationsForUser(user.uid);
      },
      loading: () => const Stream<List<dynamic>>.empty().cast(),
      error: (_, __) => const Stream<List<dynamic>>.empty().cast(),
    );
  },
);

final unreadNotificationCountProvider = StreamProvider.autoDispose<int>(
  (ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        if (user == null) {
          return Stream<int>.value(0);
        }
        return ref.watch(notificationRepositoryProvider).unreadCount(user.uid);
      },
      loading: () => Stream<int>.value(0),
      error: (_, __) => Stream<int>.value(0),
    );
  },
);
