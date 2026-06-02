import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../repositories/providers.dart';
import '../../widgets/court_card.dart';

final approvedCourtsProvider = StreamProvider((ref) => ref.watch(courtRepositoryProvider).approvedCourts());
class HomeScreen extends ConsumerWidget { const HomeScreen({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final courts = ref.watch(approvedCourtsProvider); return Scaffold(appBar: AppBar(title: const Text('Lapangan Padel Palembang')), body: courts.when(data: (items) => ListView(padding: const EdgeInsets.all(16), children: [SizedBox(height: 300, child: ClipRRect(borderRadius: BorderRadius.circular(24), child: FlutterMap(options: const MapOptions(initialCenter: LatLng(-2.9761, 104.7754), initialZoom: 12), children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'id.palembang.padelfinder'), MarkerLayer(markers: items.map((c) => Marker(point: LatLng(c.latitude, c.longitude), child: const Icon(Icons.location_on, color: Colors.red, size: 40))).toList())]))), const SizedBox(height: 24), Text('Feed terbaru', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 12), ...items.map((c) => CourtCard(court: c))]), error: (e, _) => Center(child: Text('$e')), loading: () => const Center(child: CircularProgressIndicator()))); }}
