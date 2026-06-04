import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/providers.dart';
import '../../models/report.dart';
import '../../repositories/providers.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, required this.courtId, this.commentId});

  final String courtId;
  final String? commentId;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  var _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = ref.read(authProvider).currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan login terlebih dahulu.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final report = AppReport(
      reportId: const Uuid().v4(),
      reporterId: user.uid,
      courtId: widget.courtId,
      commentId: widget.commentId,
      reason: 'Laporan lapangan',
      description: _descriptionController.text.trim(),
      status: 'open',
    );

    await ref.read(courtRepositoryProvider).report(report);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Laporan terkirim. Mohon tunggu verifikasi admin.'),
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporkan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jelaskan masalah atau alasan pelaporan di bawah ini. Admin akan meninjau laporan Anda.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi laporan',
                  hintText: 'Tuliskan detail laporan di sini...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi laporan harus diisi.';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Kirim Laporan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
