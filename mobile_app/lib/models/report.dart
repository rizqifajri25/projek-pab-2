import 'package:cloud_firestore/cloud_firestore.dart';

class AppReport {
  const AppReport({required this.reportId, required this.reporterId, this.courtId, this.commentId, required this.reason, this.description, this.status = 'open', this.adminFeedback, this.createdAt});
  final String reportId, reporterId, reason, status;
  final String? courtId, commentId, description, adminFeedback;
  final DateTime? createdAt;
  Map<String, dynamic> toMap() => {
        'reportId': reportId,
        'reporterId': reporterId,
        'courtId': courtId,
        'commentId': commentId,
        'reason': reason,
        'description': description,
        'status': status,
        'adminFeedback': adminFeedback,
        'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!)
      };
}
