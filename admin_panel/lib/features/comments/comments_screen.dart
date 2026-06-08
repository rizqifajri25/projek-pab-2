import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/providers.dart';
import '../../core/providers.dart';

final allCommentsProvider = StreamProvider((ref) => ref.watch(adminRepositoryProvider).comments());

class CommentsScreen extends ConsumerWidget {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moderasi Komentar')),
      body: ref.watch(allCommentsProvider).when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada komentar untuk dimoderasi.')));
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: items
                    .map(
                      (c) => Card(
                        child: ListTile(
                          title: Text(c.comment),
                          subtitle: Text('Lapangan: ${c.courtId} • ${c.userName} • ${c.rating}★'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => ref.read(adminRepositoryProvider).deleteComment(c.commentId),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
                 error: (e, _) {
                   final message = e.toString();
                   debugPrint('CommentsScreen error: $e');
              if (message.contains('permission-denied')) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Akses ditolak. Pastikan akun admin memiliki role admin di Firestore.')));
              }
              return Center(child: Text('$e'));
            },
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
    );
  }
}

