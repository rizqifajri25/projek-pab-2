import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
// cloud_firestore not used directly here
import '../dashboard/dashboard_screen.dart';

import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../repositories/providers.dart';
import '../../models/app_user.dart';
import '../../services/cloudinary_service.dart';

final currentAdminProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(adminRepositoryProvider).currentAdmin();
});

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  Future<void> _updatePhoto(BuildContext context, WidgetRef ref) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final url = await CloudinaryService.uploadImage(picked);
    if (url == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengunggah foto')));
      }
      return;
    }

    try {
      await ref.read(adminRepositoryProvider).updatePhoto(url);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil berhasil diperbarui')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memperbarui foto: $e')));
      }
    }
  }

  Future<void> _changePassword(BuildContext context, WidgetRef ref, String email) async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final mismatch = newCtrl.text.isNotEmpty && confirmCtrl.text.isNotEmpty && newCtrl.text != confirmCtrl.text;
            return AlertDialog(
              title: const Text('Ubah Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password lama'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password baru'),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Konfirmasi password baru'),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (mismatch)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text('Password tidak sama', style: TextStyle(color: Colors.red, fontSize: 12)),
                    ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
                TextButton(
                  onPressed: currentCtrl.text.isNotEmpty && newCtrl.text.isNotEmpty && newCtrl.text == confirmCtrl.text
                      ? () => Navigator.of(ctx).pop(true)
                      : null,
                  child: const Text('Ubah Password'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    try {
      await ref.read(adminRepositoryProvider).updatePassword(currentCtrl.text, newCtrl.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengubah password: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Admin')),
      body: ref.watch(currentAdminProvider).when(
            data: (user) {
              final authUser = ref.watch(authProvider).currentUser;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 54,
                          // safely handle nullable photoUrl
                          backgroundImage: (user?.photoUrl ?? '').isNotEmpty ? NetworkImage(user!.photoUrl!) as ImageProvider : null,
                          child: (user?.photoUrl ?? '').isEmpty ? const Icon(Icons.person, size: 54) : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: FloatingActionButton.small(
                            onPressed: () => _updatePhoto(context, ref),
                            child: const Icon(Icons.camera_alt),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      user?.name ?? authUser?.email ?? 'Admin',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(child: Text(user?.email ?? authUser?.email ?? '-')),
                  const SizedBox(height: 8),
                  if (user != null)
                    Center(
                      child: Chip(label: Text(user.role.toUpperCase())),
                    ),
                  const SizedBox(height: 8),
                  if (user != null && user.role != 'admin' && user.role != 'super_admin')
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                      child: Card(
                        color: Colors.yellow[100],
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Text('Peringatan: akun ini tidak terdaftar sebagai admin. Beberapa fitur mungkin ditolak oleh aturan Firestore.'),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ref.watch(statsProvider).when(
                        data: (stats) {
                          final anyDenied = stats.values.any((v) => v < 0);
                          return Column(
                            children: [
                              if (anyDenied)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Card(
                                    color: Colors.yellow[100],
                                    child: const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text('Beberapa statistik tidak tersedia karena aturan Firestore (permission-denied). Periksa role admin atau custom claim.'),
                                    ),
                                  ),
                                ),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(children: [Text('${stats['courts']}'), const Text('Lapangan')]),
                                      Column(children: [Text('${stats['comments']}'), const Text('Komentar')]),
                                      Column(children: [Text('${stats['reports']}'), const Text('Laporan')]),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('$e')),
                      ),
                  const SizedBox(height: 20),

                  Card(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Dark Mode Admin'),
                      subtitle: const Text('Aktifkan tampilan gelap untuk panel admin'),
                      value: ref.watch(adminDarkModeProvider),
                      onChanged: (value) => ref.read(adminDarkModeProvider.notifier).state = value,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Ubah Password'),
                    onTap: () {
                      final email = authUser?.email;
                      if (email != null) {
                        _changePassword(context, ref, email);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email admin tidak tersedia')));
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () async {
                      await ref.read(adminRepositoryProvider).logout();
                      if (context.mounted) {
                        context.go('/');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
    );
  }
}
