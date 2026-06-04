import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/providers.dart';
import '../../models/report.dart';
import '../../core/providers.dart';

final reportsProvider = StreamProvider((ref) => ref.watch(adminRepositoryProvider).reports());

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan dan Pengaduan')),
      body: ref.watch(reportsProvider).when(
            data: (items) {
              if (items.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('Belum ada laporan saat ini.')));
              }

              String statusLabel(String status) {
                switch (status) {
                  case 'open':
                    return 'Open - Perlu ditinjau';
                  case 'in progress':
                    return 'Dalam proses';
                  case 'resolved':
                    return 'Selesai';
                  default:
                    return status;
                }
              }

              Color statusColor(String status) {
                switch (status) {
                  case 'open':
                    return Colors.orange;
                  case 'in progress':
                    return Colors.blue;
                  case 'resolved':
                    return Colors.green;
                  default:
                    return Colors.grey;
                }
              }

              String reportType(AppReport r) {
                if (r.courtId != null) return 'Postingan lapangan';
                if (r.commentId != null) return 'Komentar';
                return 'Umum';
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: items
                    .map(
                      (r) {
                        final createdAt = r.createdAt != null ? r.createdAt!.toLocal().toString().split('.').first : '-';
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        r.reason,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Chip(
                                      label: Text(statusLabel(r.status), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      backgroundColor: statusColor(r.status),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text('Pelapor: ${r.reporterId}'),
                                Text('Tipe laporan: ${reportType(r)}'),
                                if (r.courtId != null) Text('Lapangan ID: ${r.courtId}'),
                                if (r.commentId != null) Text('Komentar ID: ${r.commentId}'),
                                const SizedBox(height: 8),
                                Text('Deskripsi: ${r.description ?? '-'}'),
                                if (r.adminFeedback != null && r.adminFeedback!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Feedback admin: ${r.adminFeedback}',
                                    style: const TextStyle(color: Colors.black87, fontStyle: FontStyle.italic),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text('Dibuat: $createdAt', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    DropdownButton<String>(
                                      value: r.status,
                                      items: const [
                                        DropdownMenuItem(value: 'open', child: Text('Open - Perlu ditinjau')),
                                        DropdownMenuItem(value: 'in progress', child: Text('Dalam proses')),
                                        DropdownMenuItem(value: 'resolved', child: Text('Selesai')),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) {
                                          ref.read(adminRepositoryProvider).setReportStatus(r.reportId, v);
                                        }
                                      },
                                    ),
                                    if (r.courtId != null)
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('Hapus postingan'),
                                        onPressed: () async {
                                          await ref.read(adminRepositoryProvider).deleteCourt(r.courtId!);
                                          await ref.read(adminRepositoryProvider).setReportStatus(r.reportId, 'resolved');
                                        },
                                      ),
                                    if (r.commentId != null)
                                      OutlinedButton.icon(
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('Hapus komentar'),
                                        onPressed: () async {
                                          await ref.read(adminRepositoryProvider).deleteComment(r.commentId!);
                                          await ref.read(adminRepositoryProvider).setReportStatus(r.reportId, 'resolved');
                                        },
                                      ),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.feedback_outlined),
                                      label: const Text('Kirim feedback'),
                                      onPressed: () async {
                                        final controller = TextEditingController(text: r.adminFeedback ?? '');
                                        final shouldSave = await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text('Feedback untuk pelapor'),
                                              content: TextField(
                                                controller: controller,
                                                maxLines: 5,
                                                decoration: const InputDecoration(
                                                  labelText: 'Tulis feedback admin',
                                                  hintText: 'Contoh: Laporan sudah kami proses, terima kasih.',
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(false),
                                                  child: const Text('Batal'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () => Navigator.of(context).pop(true),
                                                  child: const Text('Simpan'),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (shouldSave == true) {
                                          final feedback = controller.text.trim();
                                          await ref.read(adminRepositoryProvider).setReportStatus(r.reportId, r.status, adminFeedback: feedback);
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                              content: Text('Feedback telah dikirim ke pelapor.'),
                                            ));
                                          }
                                        }
                                      },
                                    ),
                                    if (r.courtId == null && r.commentId == null)
                                      OutlinedButton(
                                        onPressed: () => ref.read(adminRepositoryProvider).setReportStatus(r.reportId, 'resolved'),
                                        child: const Text('Tandai selesai'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    .toList(),
              );
            },
            error: (e, _) {
              final message = e.toString();
              debugPrint('ReportsScreen error: $e');
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

