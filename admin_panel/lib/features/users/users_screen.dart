import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/providers.dart';
import '../../core/providers.dart';

final usersProvider = StreamProvider((ref) => ref.watch(adminRepositoryProvider).users());

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
      ),
      body: ref.watch(usersProvider).when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada user yang terdaftar.')));
              }
              return ListView(
                padding: const EdgeInsets.all(16),
                children: items
                    .map(
                      (u) => Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text(u.name.isEmpty ? 'U' : u.name[0].toUpperCase())),
                          title: Text(u.name.isEmpty ? u.email : u.name),
                          subtitle: Text('${u.email} • ${u.role} • ${u.status}'),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              TextButton(
                                onPressed: () => ref.read(adminRepositoryProvider).setUserStatus(u.uid, 'active'),
                                child: const Text('Aktifkan'),
                              ),
                              TextButton(
                                onPressed: () => ref.read(adminRepositoryProvider).setUserStatus(u.uid, 'disabled'),
                                child: const Text('Nonaktifkan'),
                              ),
                              IconButton(
                                onPressed: () => ref.read(adminRepositoryProvider).deleteUserDoc(u.uid),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            error: (e, _) {
              final message = e.toString();
              debugPrint('UsersScreen error: $e');
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

