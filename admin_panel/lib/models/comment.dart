import 'package:cloud_firestore/cloud_firestore.dart';

class CourtComment {
  const CourtComment({required this.commentId, required this.courtId, required this.userId, required this.comment, this.createdAt});
  final String commentId, courtId, userId, comment;
  final DateTime? createdAt;
  factory CourtComment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return CourtComment(commentId: d['commentId'] ?? doc.id, courtId: d['courtId'] ?? '', userId: d['userId'] ?? '', comment: d['comment'] ?? '', createdAt: (d['createdAt'] as Timestamp?)?.toDate());
  }
  Map<String, dynamic> toMap() => {'commentId': commentId, 'courtId': courtId, 'userId': userId, 'comment': comment, 'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!)};
}
