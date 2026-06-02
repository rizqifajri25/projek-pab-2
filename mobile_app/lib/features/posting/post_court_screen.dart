import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/providers.dart';
import '../../models/court.dart';
import '../../repositories/providers.dart';
import '../../services/location_service.dart';

class PostCourtScreen extends ConsumerStatefulWidget { const PostCourtScreen({super.key}); @override ConsumerState<PostCourtScreen> createState() => _PostCourtScreenState(); }
class _PostCourtScreenState extends ConsumerState<PostCourtScreen> { final name=TextEditingController(), desc=TextEditingController(), address=TextEditingController(), facilities=TextEditingController(); double? lat,lng; File? image; bool loading=false;
  Future<void> gps() async { final p = await LocationService().currentPosition(); setState(() { lat=p.latitude; lng=p.longitude; }); }
  Future<void> submit() async { final user = ref.read(authProvider).currentUser; if (user==null || lat==null || lng==null) return; setState(() => loading=true); final id = const Uuid().v4(); await ref.read(courtRepositoryProvider).createCourt(Court(courtId: id, name: name.text, description: desc.text, address: address.text, latitude: lat!, longitude: lng!, imageUrl: '', facilities: facilities.text.split(',').map((e)=>e.trim()).where((e)=>e.isNotEmpty).toList(), createdBy: user.uid), image); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Posting dikirim dan menunggu persetujuan admin.'))); name.clear(); desc.clear(); address.clear(); facilities.clear(); setState(() { image=null; lat=null; lng=null; loading=false; }); }}
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Posting Lapangan')), body: ListView(padding: const EdgeInsets.all(16), children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Nama Lapangan')), const SizedBox(height: 12), TextField(controller: address, decoration: const InputDecoration(labelText: 'Alamat')), const SizedBox(height: 12), TextField(controller: desc, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Deskripsi')), const SizedBox(height: 12), TextField(controller: facilities, decoration: const InputDecoration(labelText: 'Fasilitas (pisahkan koma)')), const SizedBox(height: 12), OutlinedButton.icon(onPressed: gps, icon: const Icon(Icons.my_location), label: Text(lat == null ? 'Ambil lokasi GPS' : 'Lat $lat, Long $lng')), OutlinedButton.icon(onPressed: () async { final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80); if (picked!=null) setState(() => image=File(picked.path)); }, icon: const Icon(Icons.photo), label: Text(image==null ? 'Pilih foto' : 'Foto dipilih')), const SizedBox(height: 24), FilledButton(onPressed: loading ? null : submit, child: const Text('Kirim Posting'))])); }
