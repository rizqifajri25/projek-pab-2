from pathlib import Path
p = Path(r'D:/FOLDER TUGAS/pab/projek_pab_2/admin_panel/lib/features/dashboard/dashboard_screen.dart')
text = p.read_text(encoding='utf-8')
start = text.index('                                final chartItems = keys.map((k) => MapEntry(k, s[k] ?? 0)).toList();')
end = text.index('\t\t\t\t\t\t\t\t\t\t\t]);\n', start)
old = text[start:end]
new = '''                                final chartItems = keys.map((k) => MapEntry(k, s[k] ?? 0)).toList();
                                final maxValue = chartItems.fold<int>(0, (prev, element) => prev > element.value ? prev : element.value);
                                final chartMaxY = (maxValue + 2).toDouble().clamp(5.0, double.infinity) as double;

                                return ListView(padding: const EdgeInsets.all(24), children: [
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
                                                                        if (index < 0 || index >= chartItems.length) return const SizedBox.shrink();
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
                                                                sideTitles: SideTitles(showTitles: true, interval: chartMaxY / 5),
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
                                                                    BarChartRodData(toY: value, color: const Color(0xFF0D9488), width: 24),
                                                                ],
                                                            );
                                                        }).toList(),
                                                    ),
                                                ),
                                            ),
                                        ),
                                    ),
                                '''
if old not in text:
    raise SystemExit('old block not found')
text = text.replace(old, new, 1)
p.write_text(text, encoding='utf-8')
print('patched')
