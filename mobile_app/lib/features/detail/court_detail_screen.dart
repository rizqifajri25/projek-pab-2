import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers.dart';
import '../../features/detail/report_screen.dart';
import '../../models/comment.dart';
import '../../models/report.dart';
import '../../repositories/providers.dart';

final courtProvider = StreamProvider.family((ref, String id) => ref.watch(courtRepositoryProvider).court(id));
final commentsProvider = StreamProvider.family((ref, String id) => ref.watch(courtRepositoryProvider).comments(id));

class CourtDetailScreen extends ConsumerStatefulWidget {
  const CourtDetailScreen({super.key, required this.courtId});
  final String courtId;

  @override
  ConsumerState<CourtDetailScreen> createState() => _CourtDetailScreenState();
}

class _CourtDetailScreenState extends ConsumerState<CourtDetailScreen> {
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(String userId) async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar wajib diisi.')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(courtRepositoryProvider).addReview(widget.courtId, userId, _commentController.text, _rating);
      _commentController.clear();
      setState(() => _rating = 5);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review berhasil dikirim.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengirim review: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Lapangan')),
      body: ref.watch(courtProvider(widget.courtId)).when(
            data: (court) => ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(.18), blurRadius: 24, offset: const Offset(0, 12))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          court.imageUrl.isEmpty
                              ? Container(color: const Color(0xFFE2E8F0), child: const Icon(Icons.sports_tennis, size: 72))
                              : Image.network(court.imageUrl, fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(.65)],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 18,
                            right: 18,
                            bottom: 18,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(court.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 6),
                                Text(court.address, style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _RatingSummary(rating: court.averageRating, count: court.ratingsCount),
                            const Spacer(),
                            if (user != null)
                              StreamBuilder<bool>(
                                stream: ref.read(courtRepositoryProvider).isFavorite(user.uid, court.courtId),
                                builder: (context, snapshot) {
                                  final isFav = snapshot.data ?? false;
                                  return FilledButton.tonalIcon(
                                    onPressed: () => ref.read(courtRepositoryProvider).toggleFavorite(user.uid, court.courtId),
                                    icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : null),
                                    label: Text(isFav ? 'Favorit' : 'Simpan'),
                                  );
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, runSpacing: 8, children: court.facilities.map((f) => Chip(label: Text(f), avatar: const Icon(Icons.check_circle_outline, size: 18))).toList()),
                        const SizedBox(height: 12),
                        Text(court.description),
                        const SizedBox(height: 12),
                        StreamBuilder<int>(
                          stream: ref.read(courtRepositoryProvider).favoriteCount(court.courtId),
                          builder: (context, snapshot) => Text('${snapshot.data ?? 0} favorit • ${court.commentsCount} review', style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 220,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: FlutterMap(
                      options: MapOptions(initialCenter: LatLng(court.latitude, court.longitude), initialZoom: 15),
                      children: [
                        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'id.palembang.padelfinder'),
                        MarkerLayer(markers: [Marker(point: LatLng(court.latitude, court.longitude), child: const Icon(Icons.location_on, color: Colors.red, size: 44))]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (user != null) _ReviewComposer(rating: _rating, controller: _commentController, submitting: _submitting, onRatingChanged: (v) => setState(() => _rating = v), onSubmit: () => _submitReview(user.uid)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Review Pengguna', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Laporkan tempat',
                      onPressed: user == null ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportScreen(courtId: court.courtId))),
                      icon: const Icon(Icons.flag_outlined),
                    ),
                  ],
                ),
                ref.watch(commentsProvider(widget.courtId)).when(
                      data: (items) => items.isEmpty
                          ? const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Center(child: Text('Belum ada review. Jadilah yang pertama!')))
                          : Column(children: items.map((c) => _ReviewTile(comment: c, currentUserId: user?.uid, onDelete: () => ref.read(courtRepositoryProvider).deleteComment(widget.courtId, c.commentId), onReport: user == null ? null : () => ref.read(courtRepositoryProvider).report(AppReport(reportId: const Uuid().v4(), reporterId: user.uid, courtId: widget.courtId, commentId: c.commentId, reason: 'Komentar tidak pantas', description: c.comment)))).toList()),
                      error: (e, _) => Text('$e'),
                      loading: () => const Center(child: CircularProgressIndicator()),
                    ),
              ],
            ),
            error: (e, _) => Center(child: Text('$e')),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
    );
  }
}

class _RatingSummary extends StatelessWidget {
  const _RatingSummary({required this.rating, required this.count});
  final double rating;
  final int count;
  @override
  Widget build(BuildContext context) => Row(children: [
        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 30),
        const SizedBox(width: 6),
        Text(rating == 0 ? 'Baru' : rating.toStringAsFixed(1), style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(width: 6),
        Text('($count rating)'),
      ]);
}

class _ReviewComposer extends StatelessWidget {
  const _ReviewComposer({required this.rating, required this.controller, required this.submitting, required this.onRatingChanged, required this.onSubmit});
  final int rating;
  final TextEditingController controller;
  final bool submitting;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Beri rating dan komentar', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: List.generate(5, (i) => IconButton(onPressed: () => onRatingChanged(i + 1), icon: Icon(i < rating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFF59E0B), size: 32)))),
            TextField(controller: controller, maxLines: 3, decoration: const InputDecoration(hintText: 'Ceritakan pengalaman Anda di tempat ini...')),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(onPressed: submitting ? null : onSubmit, icon: submitting ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded), label: const Text('Kirim Review')),
            ),
          ]),
        ),
      );
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.comment, required this.currentUserId, required this.onDelete, required this.onReport});
  final CourtComment comment;
  final String? currentUserId;
  final VoidCallback onDelete;
  final VoidCallback? onReport;
  @override
  Widget build(BuildContext context) {
    final formatted = comment.createdAt == null ? 'Baru saja' : DateFormat('dd MMM yyyy, HH:mm').format(comment.createdAt!.toLocal());
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: (comment.userPhotoUrl ?? '').isNotEmpty ? NetworkImage(comment.userPhotoUrl!) : null,
          child: (comment.userPhotoUrl ?? '').isEmpty ? Text(comment.userName.isEmpty ? 'U' : comment.userName[0].toUpperCase()) : null,
        ),
        title: Row(children: [Expanded(child: Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.w700))), ...List.generate(5, (i) => Icon(i < comment.rating ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFF59E0B), size: 18))]),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(formatted, style: Theme.of(context).textTheme.bodySmall), const SizedBox(height: 6), Text(comment.comment)]),
        ),
        trailing: currentUserId == comment.userId
            ? PopupMenuButton(itemBuilder: (_) => const [PopupMenuItem(value: 'delete', child: Text('Hapus'))], onSelected: (_) => onDelete())
            : IconButton(icon: const Icon(Icons.flag_outlined), onPressed: onReport),
      ),
    );
  }
}
