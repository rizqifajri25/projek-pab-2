import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/providers.dart';
import '../../core/providers.dart';

final courtStatusProvider = StateProvider((_) => 'all');
final adminCourtsProvider = StreamProvider(
  (ref) => ref.watch(adminRepositoryProvider).courts(ref.watch(courtStatusProvider)),
);

class CourtsScreen extends ConsumerWidget {
  const CourtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Lapangan & Postingan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('Semua')),
                ButtonSegment(value: 'pending', label: Text('Pending')),
                ButtonSegment(value: 'approved', label: Text('Approved')),
                ButtonSegment(value: 'rejected', label: Text('Rejected')),
              ],
              selected: {ref.watch(courtStatusProvider)},
              onSelectionChanged: (v) => ref.read(courtStatusProvider.notifier).state = v.first,
            ),
          ),
          Expanded(
        child: ref.watch(adminCourtsProvider).when(
          data: (items) => ListView(
                    padding: const EdgeInsets.all(16),
                    children: items
                        .map(
                          (c) => Card(
                            clipBehavior: Clip.hardEdge,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (c.imageUrl.isNotEmpty)
                                  SizedBox(
                                    height: 180,
                                    child: Image.network(
                                      c.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                                      loadingBuilder: (_, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                    ),
                                  )
                                else
                                  Container(
                                    height: 180,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(Icons.sports_tennis, size: 64, color: Colors.grey),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(c.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      Text(c.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 10),
                                      Text(c.address, style: Theme.of(context).textTheme.bodyMedium),
                                      const SizedBox(height: 10),
                                      Text('Status: ${c.status} • ${c.createdBy}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => ref.read(adminRepositoryProvider).setCourtStatus(c.courtId, 'approved'),
                                              child: const Text('Approve'),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => ref.read(adminRepositoryProvider).setCourtStatus(c.courtId, 'rejected'),
                                              child: const Text('Reject'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  error: (e, _) {
                    final msg = e.toString();
                    debugPrint('CourtsScreen error: $e');
                    if (msg.contains('permission-denied')) {
                      return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Akses ditolak. Pastikan akun admin memiliki role admin di Firestore.')));
                    }
                    return Center(child: Text('$e'));
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                ),
          ),
        ],
      ),
    );
  }
}

