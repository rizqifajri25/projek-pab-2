import 'package:cloud_firestore/cloud_firestore.dart';

class AppReport {
  const AppReport({required this.reportId, required this.reporterId, this.courtId, this.commentId, required this.reason, this.status = 'open', this.createdAt});
  final String reportId, reporterId, reason, status;
  final String? courtId, commentId;
  final DateTime? createdAt;
  Map<String, dynamic> toMap() => {'reportId': reportId, 'reporterId': reporterId, 'courtId': courtId, 'commentId': commentId, 'reason': reason, 'status': status, 'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!)};
}
