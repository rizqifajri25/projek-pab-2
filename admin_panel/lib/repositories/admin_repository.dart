import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../models/comment.dart';
import '../models/court.dart';
import '../models/report.dart';

class AdminRepository { AdminRepository(this.auth, this.db); final FirebaseAuth auth; final FirebaseFirestore db;
  Future<void> login(String email, String password) => auth.signInWithEmailAndPassword(email: email, password: password);
  Future<void> logout() => auth.signOut();
  Stream<List<AppUser>> users() => db.collection('users').orderBy('createdAt', descending: true).snapshots().map((s)=>s.docs.map(AppUser.fromDoc).toList());
  Stream<List<Court>> courts([String? status]) { var q = db.collection('courts').orderBy('createdAt', descending: true); if (status != null && status != 'all') return db.collection('courts').where('status', isEqualTo: status).snapshots().map((s)=>s.docs.map(Court.fromDoc).toList()); return q.snapshots().map((s)=>s.docs.map(Court.fromDoc).toList()); }
  Stream<List<CourtComment>> comments() => db.collection('comments').orderBy('createdAt', descending: true).snapshots().map((s)=>s.docs.map(CourtComment.fromDoc).toList());
  Stream<List<AppReport>> reports() => db.collection('reports').orderBy('createdAt', descending: true).snapshots().map((s)=>s.docs.map(AppReport.fromDoc).toList());
  Future<void> setUserStatus(String uid, String status) => db.collection('users').doc(uid).update({'status': status});
  Future<void> deleteUserDoc(String uid) => db.collection('users').doc(uid).delete();
  Future<void> setCourtStatus(String id, String status) => db.collection('courts').doc(id).update({'status': status});
  Future<void> deleteComment(String id) => db.collection('comments').doc(id).delete();
  Future<void> setReportStatus(String id, String status) => db.collection('reports').doc(id).update({'status': status});
  Stream<Map<String,int>> stats() => db.snapshotsInSync().asyncMap((_) async => {'users': (await db.collection('users').count().get()).count ?? 0, 'courts': (await db.collection('courts').count().get()).count ?? 0, 'comments': (await db.collection('comments').count().get()).count ?? 0, 'reports': (await db.collection('reports').count().get()).count ?? 0, 'pending': (await db.collection('courts').where('status', isEqualTo: 'pending').count().get()).count ?? 0});
}
