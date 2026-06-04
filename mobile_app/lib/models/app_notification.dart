import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.notificationId,
    required this.userId,
    required this.message,
    required this.read,
    this.courtId,
    this.commentId,
    this.reportId,
    this.createdAt,
  });

  final String notificationId;
  final String userId;
  final String message;
  final bool read;
  final String? courtId;
  final String? commentId;
  final String? reportId;
  final DateTime? createdAt;

  factory AppNotification.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppNotification(
      notificationId: data['notificationId'] ?? doc.id,
      userId: data['userId'] ?? '',
      message: data['message'] ?? '',
      read: data['read'] ?? false,
      courtId: data['courtId'],
      commentId: data['commentId'],
      reportId: data['reportId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
