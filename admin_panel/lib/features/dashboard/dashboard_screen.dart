import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/providers.dart';
final statsProvider = StreamProvider((ref)=>ref.watch(adminRepositoryProvider).stats());
class DashboardScreen extends ConsumerWidget {
	const DashboardScreen({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) => Scaffold(
				appBar: AppBar(title: const Text('Dashboard Realtime')),
				body: ref.watch(statsProvider).when(
							data: (s) {
								// fixed order and icons for readability
								final keys = ['users', 'courts', 'comments', 'reports', 'pending'];
								final icons = {
									'users': Icons.people,
									'courts': Icons.sports_tennis,
									'comments': Icons.comment,
									'reports': Icons.flag,
									'pending': Icons.pending_actions,
								};

								final cards = keys.map((k) {
									final v = s[k] ?? 0;
									final denied = v < 0;
									return SizedBox(
										width: 220,
										child: Card(
											child: Padding(
												padding: const EdgeInsets.all(20),
												child: Row(
													children: [
														Icon(icons[k], size: 36, color: const Color(0xFF0D9488)),
														const SizedBox(width: 12),
														Expanded(
															child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
																Text(k.toUpperCase()),
																const SizedBox(height: 8),
																denied
																		? const Text('Akses ditolak', style: TextStyle(color: Colors.red))
																		: Text('$v', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
															]),
														),
													],
												),
											),
										),
									);
								}).toList();

								final chartItems = keys.map((k) => MapEntry(k, s[k] ?? 0)).toList();
final maxValue = chartItems.fold<int>(0, (prev, element) => prev > element.value ? prev : element.value);
final chartMaxY =
    ((maxValue + 2).toDouble().clamp(5.0, double.infinity)).toDouble();
final interval = maxValue <= 10
  ? 1.0
  : (maxValue / 5).ceilToDouble();

return ListView(
padding: const EdgeInsets.all(24),
children: [
Wrap(spacing: 16, runSpacing: 16, children: cards),
const SizedBox(height: 24),
Card(
child: Padding(
padding: const EdgeInsets.all(20),
child: SizedBox(
height: 320,
child: BarChart(
BarChartData(
maxY: chartMaxY,
titlesData: FlTitlesData(
bottomTitles: AxisTitles(
sideTitles: SideTitles(
showTitles: true,
reservedSize: 60,
getTitlesWidget: (value, _) {
final index = value.toInt();
if (index < 0 || index >= chartItems.length) {
return const SizedBox.shrink();
}
return Padding(
padding: const EdgeInsets.only(top: 8),
child: Text(
chartItems[index].key.toUpperCase(),
textAlign: TextAlign.center,
style: Theme.of(context).textTheme.bodySmall,
),
);
},
),
),
leftTitles: AxisTitles(
  sideTitles: SideTitles(
    showTitles: true,
    interval: interval,
    reservedSize: 35,
  ),
),
rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
),
barGroups: chartItems.asMap().entries.map((entry) {
final index = entry.key;
final value = entry.value.value.toDouble();
return BarChartGroupData(
x: index,
barRods: [
BarChartRodData(
toY: value,
color: const Color(0xFF0D9488),
width: 24,
),
],
);
}).toList(),
),
),
),
))],
);
},
error: (e, _) {
								final msg = e.toString();
								if (msg.contains('permission-denied')) {
									return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Akses ditolak. Pastikan akun admin memiliki role admin di Firestore atau gunakan custom claim admin.')));
								}
								return Center(child: Text('$e'));
							},
							loading: () => const Center(child: CircularProgressIndicator()),
						),
			);
}
