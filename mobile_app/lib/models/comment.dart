import 'package:cloud_firestore/cloud_firestore.dart';

class CourtComment {
  const CourtComment({
    required this.commentId,
    required this.courtId,
    required this.userId,
    required this.comment,
    this.userName = 'User',
    this.userPhotoUrl,
    this.rating = 0,
    this.createdAt,
  });

  final String commentId, courtId, userId, comment, userName;
  final String? userPhotoUrl;
  final int rating;
  final DateTime? createdAt;

  factory CourtComment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return CourtComment(
      commentId: d['commentId'] ?? doc.id,
      courtId: d['courtId'] ?? '',
      userId: d['userId'] ?? '',
      comment: d['comment'] ?? '',
      userName: d['userName'] ?? d['name'] ?? 'User',
      userPhotoUrl: d['userPhotoUrl'] ?? d['photoUrl'],
      rating: (d['rating'] as num?)?.toInt() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'commentId': commentId,
        'courtId': courtId,
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'comment': comment,
        'rating': rating,
        'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt!),
      };
}
