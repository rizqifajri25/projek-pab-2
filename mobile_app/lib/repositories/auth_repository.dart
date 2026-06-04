import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthRepository {
  AuthRepository(this.auth, this.db);
  final FirebaseAuth auth;
  final FirebaseFirestore db;

  Future<UserCredential> login(
  String email,
  String password,
) async {

  final credential =
      await auth
          .signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  final doc = await db
      .collection('users')
      .doc(credential.user!.uid)
      .get();

  final data = doc.data();

  if (data == null) {
    throw Exception(
      'Data user tidak ditemukan',
    );
  }

  if (data['status'] ==
      'suspended') {

    await auth.signOut();

    throw Exception(
      'Akun telah diblokir admin',
    );
  }

  return credential;
}
  Future<void> resetPassword(String email) => auth.sendPasswordResetEmail(email: email);
  Future<void> logout() => auth.signOut();
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {

    final credential =
        await auth
            .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user!
        .updateDisplayName(name);

    await db
        .collection('users')
        .doc(credential.user!.uid)
        .set({
      'uid': credential.user!.uid,
      'name': name,
      'email': email,
      'photoUrl': '',
      'role': 'user',
      'status': 'active',
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    return credential;
  }
  Future<void> updateProfile({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    final user = auth.currentUser;

    if (user == null) return;

    await user.updateDisplayName(name);

    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    if (user.email != email) {
      await user.verifyBeforeUpdateEmail(email);
    }

    await db.collection('users').doc(user.uid).update({
      'name': name,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });

    await user.reload();
  }

  Future<void> updatePhoto(
    String photoUrl,
  ) async {

  final user =
      auth.currentUser;

  if (user == null) return;

  await user.updatePhotoURL(
    photoUrl,
  );

  await db
      .collection('users')
      .doc(user.uid)
      .update({
    'photoUrl': photoUrl,
  });

  await user.reload();
}

  Future<void> reauthenticate(String currentPassword) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not signed in');
    final email = user.email;
    if (email == null) throw Exception('User has no email');
    final credential = EmailAuthProvider.credential(email: email, password: currentPassword);
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> updatePassword(String newPassword) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not signed in');
    await user.updatePassword(newPassword);
    // Record a timestamp in Firestore to indicate password change (do not store the password)
    await db.collection('users').doc(user.uid).update({
      'passwordUpdatedAt': FieldValue.serverTimestamp(),
    });
    await user.reload();
  }
  }
