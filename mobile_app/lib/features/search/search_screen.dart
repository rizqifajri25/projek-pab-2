import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/providers.dart';
import '../../widgets/court_card.dart';
import '../../widgets/notification_icon_button.dart';

final queryProvider = StateProvider<String>((_) => '');
final searchProvider = StreamProvider((ref) => ref.watch(courtRepositoryProvider).search(ref.watch(queryProvider)));
class SearchScreen extends ConsumerWidget { const SearchScreen({super.key}); @override Widget build(BuildContext context, WidgetRef ref) { final results = ref.watch(searchProvider); return Scaffold(appBar: AppBar(title: const Text('Cari Lapangan'), actions: const [NotificationIconButton()]), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Nama, lokasi, atau fasilitas'), onChanged: (v) => ref.read(queryProvider.notifier).state = v), const SizedBox(height: 16), Expanded(child: results.when(data: (items) => ListView(children: items.map((c) => CourtCard(court: c)).toList()), error: (e, _) => Text('$e'), loading: () => const Center(child: CircularProgressIndicator()))) ]))); }}
