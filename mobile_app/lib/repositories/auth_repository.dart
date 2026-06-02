import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthRepository {
  AuthRepository(this.auth, this.db);
  final FirebaseAuth auth;
  final FirebaseFirestore db;

  Future<UserCredential> login(String email, String password) => auth.signInWithEmailAndPassword(email: email, password: password);
  Future<void> resetPassword(String email) => auth.sendPasswordResetEmail(email: email);
  Future<void> logout() => auth.signOut();
  Future<UserCredential> register({required String name, required String email, required String password}) async {
    final credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    await credential.user!.updateDisplayName(name);
    await db.collection('users').doc(credential.user!.uid).set(AppUser(uid: credential.user!.uid, name: name, email: email).toMap());
    return credential;
  }
}
