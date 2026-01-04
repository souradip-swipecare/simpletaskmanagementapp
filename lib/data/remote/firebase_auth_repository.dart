import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthRepository {
  fb.FirebaseAuth get _auth => fb.FirebaseAuth.instance;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Stream<fb.User?> authStateChanges() => _auth.authStateChanges();

  fb.User? get currentUser => _auth.currentUser;

  Future<fb.UserCredential> signInWithEmail(
    String email,
    String password,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _ensureUserDoc(cred.user!);
    return cred;
  }

  Future<fb.UserCredential> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
    String role = 'member',
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.updateDisplayName(displayName);
    await _ensureUserDoc(cred.user!, displayName: displayName, role: role);
    return cred;
  }


  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> isSessionValid() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;
      await user.getIdToken(true);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Returns the current user's ID token, or null if not signed in.
  Future<String?> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await user.getIdToken();
  }

  Future<void> setUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).set({
      'role': role,
    }, SetOptions(merge: true));
  }

  Future<void> _ensureUserDoc(
    fb.User user, {
    String? displayName,
    String role = 'member',
  }) async {
    final doc = _firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'name': displayName ?? user.displayName ?? '',
        'email': user.email ?? '',
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Ensure role exists (do not overwrite existing role unintentionally)
      final data = snapshot.data();
      if (data == null || data['role'] == null) {
        await doc.set({'role': role}, SetOptions(merge: true));
      }
    }
  }
}
