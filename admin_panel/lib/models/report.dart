import 'package:cloud_firestore/cloud_firestore.dart';

class AppReport {
  const AppReport({
    required this.reportId,
    required this.reporterId,
    this.courtId,
    this.commentId,
    required this.reason,
    this.description,
    required this.status,
    this.adminFeedback,
    this.createdAt,
  });

  final String reportId, reporterId, reason, status;
  final String? courtId, commentId, description, adminFeedback;
  final DateTime? createdAt;

  factory AppReport.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppReport(
      reportId: d['reportId'] ?? doc.id,
      reporterId: d['reporterId'] ?? '',
      courtId: d['courtId'],
      commentId: d['commentId'],
      reason: d['reason'] ?? '',
      description: d['description'],
      status: d['status'] ?? 'open',
      adminFeedback: d['adminFeedback'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

