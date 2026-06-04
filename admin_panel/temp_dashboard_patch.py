from pathlib import Path
path = Path(r'D:\FOLDER TUGAS\pab\projek_pab_2\admin_panel\lib\features\dashboard\dashboard_screen.dart')
text = path.read_text(encoding='utf-8')
old = "barGroups: chartItems.asMap().entries.map((entry) {\n\t\t\t\t\t\t\t\t\t\t6,\n\t\t\t\t\t\t\t\t\t\t(i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (i + 1) * (courtsCount.toDouble() + 1) / 6, color: const Color(0xFF0D9488))]),\n\t\t\t\t\t\t\t\t\t\t),\n"
new = "barGroups: chartItems.asMap().entries.map((entry) {\n\t\t\t\t\t\t\t\t\t\t\tfinal index = entry.key;\n\t\t\t\t\t\t\t\t\t\t\tfinal value = entry.value.value.toDouble();\n\t\t\t\t\t\t\t\t\t\t\treturn BarChartGroupData(\n\t\t\t\t\t\t\t\t\t\t\t\tx: index,\n\t\t\t\t\t\t\t\t\t\t\tbarRods: [BarChartRodData(toY: value, color: const Color(0xFF0D9488), width: 24)],\n\t\t\t\t\t\t\t\t\t\t\t);\n\t\t\t\t\t\t\t\t\t\t}).toList(),\n"
if old not in text:
    raise SystemExit('old block not found')
text = text.replace(old, new)
path.write_text(text, encoding='utf-8')
print('patched')
