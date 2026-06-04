import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../repositories/providers.dart';
import '../../widgets/court_card.dart';
import '../../widgets/notification_icon_button.dart';
import '../../models/court.dart';

final favoriteCourtsProvider = StreamProvider<List<Court>>((ref) {
  final user = ref.watch(authProvider).currentUser;

  if (user == null) {
    return const Stream.empty();
  }

  return ref.watch(courtRepositoryProvider).favorites(user.uid);
});
class FavoritesScreen extends ConsumerWidget { const FavoritesScreen({super.key}); @override Widget build(BuildContext context, WidgetRef ref) => Scaffold(appBar: AppBar(title: const Text('Favorit Saya'), actions: const [NotificationIconButton()]), body: ref.watch(favoriteCourtsProvider).when(data: (items) => ListView(
  padding: const EdgeInsets.all(16),
  children: items
      .map<Widget>((c) => CourtCard(court: c))
      .toList(),
), error: (e, _) => Center(child: Text('$e')), loading: () => const Center(child: CircularProgressIndicator()))); }
