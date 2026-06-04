import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers.dart';
import '../../features/detail/report_screen.dart';
import '../../models/report.dart';
import '../../repositories/providers.dart';

final courtProvider = StreamProvider.family((ref, String id) => ref.watch(courtRepositoryProvider).court(id));
final commentsProvider = StreamProvider.family((ref, String id) => ref.watch(courtRepositoryProvider).comments(id));
class CourtDetailScreen extends ConsumerWidget { const CourtDetailScreen({super.key, required this.courtId}); final String courtId;
  @override Widget build(BuildContext context, WidgetRef ref) { final input = TextEditingController(); final user = ref.watch(authProvider).currentUser; return Scaffold(appBar: AppBar(title: const Text('Detail Lapangan')), body: ref.watch(courtProvider(courtId)).when(data: (court) => ListView(padding: const EdgeInsets.all(16), children: [
    ClipRRect(borderRadius: BorderRadius.circular(24), child: AspectRatio(aspectRatio: 16/9, child: court.imageUrl.isEmpty ? Container(color: const Color(0xFFE2E8F0), child: const Icon(Icons.sports_tennis, size: 72)) : Image.network(court.imageUrl, fit: BoxFit.cover))), const SizedBox(height: 16),
    Text(court.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), Text(court.address), const SizedBox(height: 12), Wrap(spacing: 8, children: court.facilities.map((f) => Chip(label: Text(f))).toList()), Text(court.description), const SizedBox(height: 16), SizedBox(height: 220, child: ClipRRect(borderRadius: BorderRadius.circular(24), child: FlutterMap(options: MapOptions(initialCenter: LatLng(court.latitude, court.longitude), initialZoom: 15), children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'id.palembang.padelfinder'), MarkerLayer(markers: [Marker(point: LatLng(court.latitude, court.longitude), child: const Icon(Icons.location_on, color: Colors.red, size: 44))])]))),
    Row(
      children: [
        Expanded(
          child: StreamBuilder<int>(
            stream: ref
                .read(courtRepositoryProvider)
                .favoriteCount(court.courtId),
            builder: (context, snapshot) {
              final favoriteCount =
                  snapshot.data ?? 0;

              return Text(
                '$favoriteCount favorit • ${court.commentsCount} komentar',
                overflow:
                    TextOverflow.ellipsis,
              );
            },
          ),
        ),

        if (user != null)
          StreamBuilder<bool>(
            stream: ref
                .read(courtRepositoryProvider)
                .isFavorite(
                  user.uid,
                  court.courtId,
                ),
            builder: (
              context,
              snapshot,
            ) {
              final isFav =
                  snapshot.data ?? false;

              return Tooltip(
                message: 'Favorite',
                child: IconButton(
                  onPressed: () {
                    ref
                        .read(
                          courtRepositoryProvider,
                        )
                        .toggleFavorite(
                          user.uid,
                          court.courtId,
                        );
                  },
                  icon: Icon(
                    isFav
                        ? Icons.favorite
                        : Icons
                            .favorite_border,
                    color: isFav
                        ? Colors.red
                        : null,
                  ),
                ),
              );
            },
          ),

        Tooltip(
          message: 'Laporkan',
          child: IconButton(
            onPressed: user == null
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ReportScreen(
                          courtId:
                              court.courtId,
                        ),
                      ),
                    );
                  },
            icon: const Icon(
              Icons.flag_outlined,
            ),
          ),
        ),
      ],
    ),
    const Divider(), Text('Komentar', style: Theme.of(context).textTheme.titleLarge), if (user != null) Row(children: [Expanded(child: TextField(controller: input, decoration: const InputDecoration(hintText: 'Tulis komentar'))), IconButton(onPressed: () { ref.read(courtRepositoryProvider).addComment(courtId, user.uid, input.text); input.clear(); }, icon: const Icon(Icons.send))]),
    ref.watch(commentsProvider(courtId)).when(data: (items) => Column(children: items.map((c) => ListTile(title: Text(c.comment), subtitle: Text(c.userId), trailing: user?.uid == c.userId ? PopupMenuButton(itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Hapus'))], onSelected: (_) => ref.read(courtRepositoryProvider).deleteComment(courtId, c.commentId)) : IconButton(icon: const Icon(Icons.flag_outlined), onPressed: user == null ? null : () => ref.read(courtRepositoryProvider).report(AppReport(reportId: const Uuid().v4(), reporterId: user.uid, courtId: courtId, commentId: c.commentId, reason: 'Komentar tidak pantas'))))).toList()), error: (e, _) => Text('$e'), loading: () => const CircularProgressIndicator()),
  ]), error: (e, _) => Center(child: Text('$e')), loading: () => const Center(child: CircularProgressIndicator()))); }}
