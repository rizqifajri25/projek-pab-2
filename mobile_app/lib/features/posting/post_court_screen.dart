import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers.dart';
import '../../models/court.dart';
import '../../repositories/providers.dart';
import '../../services/location_service.dart';

class PostCourtScreen extends ConsumerStatefulWidget {
  const PostCourtScreen({super.key});

  @override
  ConsumerState<PostCourtScreen> createState() => _PostCourtScreenState();
}

class _PostCourtScreenState extends ConsumerState<PostCourtScreen> {
  final name = TextEditingController();
  final desc = TextEditingController();
  final address = TextEditingController();
  final facilities = TextEditingController();

  double? lat;
  double? lng;

  XFile? image;

  bool loading = false;

  Future<void> gps() async {
    final p = await LocationService().currentPosition();

    setState(() {
      lat = p.latitude;
      lng = p.longitude;
    });
  }

  Future<void> submit() async {
    final user = ref.read(authProvider).currentUser;

    if (user == null || lat == null || lng == null) {
      return;
    }

    setState(() => loading = true);

    try {
      final id = const Uuid().v4();

      await ref.read(courtRepositoryProvider).createCourt(
            Court(
              courtId: id,
              name: name.text,
              description: desc.text,
              address: address.text,
              latitude: lat!,
              longitude: lng!,
              imageUrl: '',
              facilities: facilities.text
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
              createdBy: user.uid,
            ),
            image,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Posting dikirim dan menunggu persetujuan admin.',
          ),
        ),
      );

      name.clear();
      desc.clear();
      address.clear();
      facilities.clear();

      setState(() {
        image = null;
        lat = null;
        lng = null;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posting Lapangan'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(
              labelText: 'Nama Lapangan',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: address,
            decoration: const InputDecoration(
              labelText: 'Alamat',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: desc,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: facilities,
            decoration: const InputDecoration(
              labelText: 'Fasilitas (pisahkan koma)',
            ),
          ),
          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: gps,
            icon: const Icon(Icons.my_location),
            label: Text(
              lat == null
                  ? 'Ambil lokasi GPS'
                  : 'Lat $lat, Long $lng',
            ),
          ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () async {
              final picked = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );

              if (picked != null) {
                setState(() {
                  image = picked;
                });
              }
            },
            icon: const Icon(Icons.photo),
            label: Text(
              image == null
                  ? 'Pilih foto'
                  : image!.name,
            ),
          ),

          const SizedBox(height: 16),

          if (image != null)
            FutureBuilder(
              future: image!.readAsBytes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    snapshot.data!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          FilledButton(
            onPressed: loading ? null : submit,
            child: loading
                ? const CircularProgressIndicator()
                : const Text('Kirim Posting'),
          ),
        ],
      ),
    );
  }
}