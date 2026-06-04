import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../models/comment.dart';
import '../models/court.dart';
import '../models/report.dart';

class AdminRepository {
  AdminRepository(this.auth, this.db);

  final FirebaseAuth auth;
  final FirebaseFirestore db;

  Stream<AppUser?> currentAdmin() {
    final user = auth.currentUser;
    if (user == null) {
      return Stream.value(null);
    }
    return db.collection('users').doc(user.uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromDoc(doc) : null,
        );
  }

  Future<void> updatePhoto(String photoUrl) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Admin belum login');
    }
    await user.updatePhotoURL(photoUrl);
    await db.collection('users').doc(user.uid).update({'photoUrl': photoUrl});
    await user.reload();
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Admin belum login');
    }

    final email = user.email;
    if (email == null) {
      throw Exception('Email admin tidak ditemukan');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
    await db.collection('users').doc(user.uid).update({
      'passwordUpdatedAt': FieldValue.serverTimestamp(),
    });
    await user.reload();
  }

  Future<void> login(
  String email,
  String password,
) async {

  final cred =
      await auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  final doc = await db
      .collection('users')
      .doc(cred.user!.uid)
      .get();

  final data = doc.data();

  if (data == null) {
    await auth.signOut();
    throw Exception('Data user tidak ditemukan');
  }

  final role = data['role'];

  if (role != 'admin' &&
      role != 'super_admin') {
    await auth.signOut();
    throw Exception(
      'Akun ini bukan administrator',
    );
  }
}
  Future<void> logout() => auth.signOut();
  Stream<List<AppUser>> users() => db.collection('users').orderBy('createdAt', descending: true).snapshots().map((s)=>s.docs.map(AppUser.fromDoc).toList());
Stream<List<Court>> courts([
  String? status,
]) {

  Query<Map<String,dynamic>> q =
      db.collection('courts');

  if (
      status != null &&
      status != 'all'
  ) {
    q = q.where(
      'status',
      isEqualTo: status,
    );
  }

  q = q.orderBy(
    'createdAt',
    descending: true,
  );

  return q.snapshots().map(
    (s) => s.docs
        .map(Court.fromDoc)
        .toList(),
  );
}
  Stream<List<CourtComment>> comments() => db.collection('comments').orderBy('createdAt', descending: true).snapshots().map((s)=>s.docs.map(CourtComment.fromDoc).toList());
  Stream<List<AppReport>> reports() => db.collection('reports').orderBy('createdAt', descending: true).snapshots().map((s)=>s.docs.map(AppReport.fromDoc).toList());
  Future<void> setUserStatus(String uid, String status) => db.collection('users').doc(uid).update({'status': status});

  Future<void> deleteUserDoc(String uid) => db.collection('users').doc(uid).delete();

  Future<void> suspendUser(String uid) => db.collection('users').doc(uid).update({
        'status': 'suspended',
      });

  Future<void> _createNotification(
    String userId,
    String message, {
    String? courtId,
    String? commentId,
    String? reportId,
  }) async {
    final notificationId = const Uuid().v4();
    await db.collection('notifications').doc(notificationId).set({
      'notificationId': notificationId,
      'userId': userId,
      'message': message,
      'courtId': courtId,
      'commentId': commentId,
      'reportId': reportId,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setCourtStatus(String id, String status) async {
    final courtRef = db.collection('courts').doc(id);
    final courtDoc = await courtRef.get();
    final ownerId = courtDoc.data()?['createdBy'] as String?;

    await courtRef.update({
      'status': status,
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': auth.currentUser?.uid,
    });

    if (ownerId != null) {
      final statusMessage = status == 'approved'
          ? 'Postingan lapangan Anda telah disetujui oleh admin.'
          : status == 'rejected'
              ? 'Postingan lapangan Anda ditolak oleh admin.'
              : 'Status postingan lapangan Anda diubah menjadi $status oleh admin.';
      await _createNotification(ownerId, statusMessage, courtId: id);
    }
  }

  Future<void> deleteCourt(String id) async {
    final courtDoc = await db.collection('courts').doc(id).get();
    final ownerId = courtDoc.data()?['createdBy'] as String?;

    await db.collection('courts').doc(id).delete();

    if (ownerId != null) {
      await _createNotification(ownerId, 'Admin telah menghapus postingan lapangan Anda.', courtId: id);
    }
  }

  Future<void> deleteComment(String id) async {
    final commentDoc = await db.collection('comments').doc(id).get();
    final commentData = commentDoc.data();
    final authorId = commentData?['userId'] as String?;
    final courtId = commentData?['courtId'] as String?;

    if (commentDoc.exists) {
      final batch = db.batch();
      batch.delete(db.collection('comments').doc(id));
      if (courtId != null) {
        batch.update(db.collection('courts').doc(courtId), {'commentsCount': FieldValue.increment(-1)});
      }
      await batch.commit();

      if (authorId != null) {
        await _createNotification(authorId, 'Admin telah menghapus komentar Anda pada postingan ini.', courtId: courtId, commentId: id);
      }
    }
  }

  Future<void> setReportStatus(String id, String status, {String? adminFeedback}) async {
    final reportRef = db.collection('reports').doc(id);
    final reportDoc = await reportRef.get();
    final reporterId = reportDoc.data()?['reporterId'] as String?;

    final updateData = <String, Object>{
      'status': status,
    };
    if (adminFeedback != null) {
      updateData['adminFeedback'] = adminFeedback;
    }

    await reportRef.update(updateData);

    if (reporterId != null) {
      final statusText = status == 'resolved'
          ? 'selesai'
          : status == 'in progress'
              ? 'dalam proses'
              : status;
      var message = 'Laporan Anda telah diperbarui: status $statusText.';
      if (adminFeedback != null && adminFeedback.isNotEmpty) {
        message = 'Admin menanggapi laporan Anda: $adminFeedback';
      }
      await _createNotification(reporterId, message, reportId: id);
    }
  }

  Future<void> setReportFeedback(String id, String feedback) async {
    final reportRef = db.collection('reports').doc(id);
    final reportDoc = await reportRef.get();
    final reporterId = reportDoc.data()?['reporterId'] as String?;

    await reportRef.update({'adminFeedback': feedback});

    if (reporterId != null) {
      await _createNotification(reporterId, 'Admin menanggapi laporan Anda: $feedback', reportId: id);
    }
  }

  Stream<Map<String,int>> stats() async* {
    Future<int> safeCount(Query<Map<String, dynamic>> q) async {
      try {
        final res = await q.count().get();
        return res.count ?? 0;
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') return -1;
        rethrow;
      }
    }

    while (true) {
      try {
        final users = await safeCount(db.collection('users'));
        final courts = await safeCount(db.collection('courts'));
        final comments = await safeCount(db.collection('comments'));
        final reports = await safeCount(db.collection('reports'));
        final pending = await safeCount(db.collection('courts').where('status', isEqualTo: 'pending'));

        yield {
          'users': users,
          'courts': courts,
          'comments': comments,
          'reports': reports,
          'pending': pending,
        };
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          yield {
            'users': -1,
            'courts': -1,
            'comments': -1,
            'reports': -1,
            'pending': -1,
          };
        } else {
          rethrow;
        }
      }
      await Future.delayed(const Duration(seconds: 10));
    }
  }
}
