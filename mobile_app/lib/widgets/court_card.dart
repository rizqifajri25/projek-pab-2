import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/court.dart';

class CourtCard extends StatelessWidget {
  const CourtCard({super.key, required this.court});
  final Court court;
  @override
  Widget build(BuildContext context) => Card(
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
                Row(children: [Icon(Icons.chat_bubble_outline, size: 18), Text(' ${court.commentsCount}'), const SizedBox(width: 18), Icon(Icons.favorite_outline, size: 18), Text(' ${court.favoritesCount}')]),
              ]),
            ),
          ]),
        ),
      );
}
