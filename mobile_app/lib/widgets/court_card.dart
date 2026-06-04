import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/court.dart';
import '../repositories/providers.dart';
import '../core/providers.dart';

class CourtCard extends ConsumerWidget {
  const CourtCard({super.key, required this.court});
  final Court court;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Card(
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/court/${court.courtId}'),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AspectRatio(aspectRatio: 16 / 9, child: court.imageUrl.isEmpty ? Container(color: const Color(0xFFE2E8F0), child: const Icon(Icons.sports_tennis, size: 56)) : Image.network(court.imageUrl, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(court.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(court.address, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.chat_bubble_outline, size: 18),
                  Text(' ${court.commentsCount}'),
                  const SizedBox(width: 18),
                  Builder(builder: (ctx) {
                    final user = ref.watch(authProvider).currentUser;
                    if (user == null) {
                      return Row(children: [Icon(Icons.favorite_outline, size: 18), StreamBuilder<int>(
                        stream: ref
                            .read(courtRepositoryProvider)
                            .favoriteCount(court.courtId),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;

                          return Text(' $count');
                        },
                      )]);
                    }
                    return StreamBuilder<bool>(
                      stream: ref.read(courtRepositoryProvider).isFavorite(user.uid, court.courtId),
                      builder: (context, snapshot) {
                        final isFav = snapshot.data ?? false;
                        return Row(children: [Icon(isFav ? Icons.favorite : Icons.favorite_outline, size: 18, color: isFav ? Colors.red : null), StreamBuilder<int>(
                          stream: ref
                              .read(courtRepositoryProvider)
                              .favoriteCount(court.courtId),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;

                            return Text(' $count');
                          },
                        )]);
                      },
                    );
                  })
                ]),
              ]),
            ),
          ]),
        ),
      );
}
