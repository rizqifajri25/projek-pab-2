import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_provider.dart';
import '../../providers/profile_stats_provider.dart';
import '../../repositories/providers.dart';
import '../../services/cloudinary_service.dart';
import '../../widgets/notification_icon_button.dart';

class ProfileScreen
    extends ConsumerWidget {

  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {

    final userAsync =
        ref.watch(
      currentUserProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
        ),
        actions: const [NotificationIconButton()],
      ),
      body: userAsync.when(
        data: (user) {

          if (user == null) {
            return const Center(
              child:
                  Text('User tidak ditemukan'),
            );
          }

          return ListView(
            padding:
                const EdgeInsets.all(16),
            children: [

              Center(
                child: Stack(
                  children: [

                    CircleAvatar(
                      radius: 55,
                      backgroundImage:
                          user.photoUrl != null &&
                                  user.photoUrl!
                                      .isNotEmpty
                              ? NetworkImage(
                                  user.photoUrl!,
                                )
                              : null,
                      child: user.photoUrl ==
                                  null ||
                              user.photoUrl!
                                  .isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 55,
                            )
                          : null,
                    ),

                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: FloatingActionButton.small(
                        onPressed: () async {

                          final picked =
                              await ImagePicker()
                                  .pickImage(
                            source:
                                ImageSource.gallery,
                          );

                          if (picked ==
                              null) return;

                          final url =
                              await CloudinaryService
                                  .uploadImage(
                            picked,
                          );

                          if (url == null)
                            return;

                          await ref
                              .read(
                                  authRepositoryProvider)
                              .updatePhoto(
                                url,
                              );
                        },
                        child:
                            const Icon(
                          Icons.camera_alt,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Center(
                child: Text(
                  user.name,
                  style: Theme.of(
                          context)
                      .textTheme
                      .headlineSmall,
                ),
              ),

              Center(
                child:
                    Text(user.email),
              ),

              Center(
                child: Chip(
                  label: Text(
                    user.role
                        .toUpperCase(),
                  ),
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              ref
                  .watch(
                    profileStatsProvider,
                  )
                  .when(
                    data: (stats) {

                      return Card(
                        child:
                            Padding(
                          padding:
                              const EdgeInsets
                                  .all(
                                      16),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceAround,
                            children: [

                              Column(
                                children: [
                                  Text(
                                    '${stats['courts']}',
                                  ),
                                  const Text(
                                    'Postingan',
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  Text(
                                    '${stats['comments']}',
                                  ),
                                  const Text(
                                    'Komentar',
                                  ),
                                ],
                              ),

                              Column(
                                children: [
                                  Text(
                                    '${stats['favorites']}',
                                  ),
                                  const Text(
                                    'Favorit',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () =>
                        const Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                    error:
                        (e, _) =>
                            Text(
                      '$e',
                    ),
                  ),

              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Ubah Password'),
                onTap: () async {
                  // Step 1: ask for current password
                  final oldCtrl = TextEditingController();
                  final old = await showDialog<String?>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Konfirmasi Password Lama'),
                      content: TextField(
                        controller: oldCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(hintText: 'Password lama'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(null), child: const Text('Batal')),
                        TextButton(onPressed: () => Navigator.of(ctx).pop(oldCtrl.text), child: const Text('Lanjut')),
                      ],
                    ),
                  );

                  if (old == null || old.isEmpty) return;

                  // Try reauthenticate
                  try {
                    await ref.read(authRepositoryProvider).reauthenticate(old);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Password lama salah: $e')));
                    }
                    return;
                  }

                  // Step 2: ask for new password + confirmation
                  final newCtrl = TextEditingController();
                  final confCtrl = TextEditingController();
                  final ok = await showDialog<bool?>(
                    context: context,
                    builder: (ctx) => StatefulBuilder(
                      builder: (ctx, setState) => AlertDialog(
                        title: const Text('Ubah Password'),
                        content: Column(mainAxisSize: MainAxisSize.min, children: [
                          TextField(
                            controller: newCtrl,
                            obscureText: true,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(hintText: 'Password baru'),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: confCtrl,
                            obscureText: true,
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(hintText: 'Konfirmasi password baru'),
                          ),
                          const SizedBox(height: 12),
                          if (newCtrl.text.isNotEmpty && confCtrl.text.isNotEmpty && newCtrl.text != confCtrl.text)
                            const Text('password harus sama', style: TextStyle(color: Colors.red, fontSize: 12))
                          else if (newCtrl.text.isNotEmpty && confCtrl.text.isNotEmpty && newCtrl.text == confCtrl.text)
                            const Text('password sama ✓', style: TextStyle(color: Colors.green, fontSize: 12))
                        ]),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Batal')),
                          TextButton(
                            onPressed: newCtrl.text.isEmpty || confCtrl.text.isEmpty || newCtrl.text != confCtrl.text ? null : () => Navigator.of(ctx).pop(true),
                            child: const Text('Ubah Password'),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (ok != true) return;

                  // perform password update
                  try {
                    await ref.read(authRepositoryProvider).updatePassword(newCtrl.text);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password berhasil diubah')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mengubah password: $e')));
                    }
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  final should = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Konfirmasi'),
                      content: const Text('Apakah anda ingin logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (should != true) return;

                  await ref.read(authRepositoryProvider).logout();

                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          );
        },
        loading: () =>
            const Center(
          child:
              CircularProgressIndicator(),
        ),
        error: (e, _) =>
            Center(
          child: Text(
            '$e',
          ),
        ),
      ),
    );
  }
}