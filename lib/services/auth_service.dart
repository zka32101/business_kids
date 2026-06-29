import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel> signUp(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final user = UserModel(
      uid: uid,
      email: email,
      childIds: [],
      createdAt: DateTime.now(),
    );
    await _db.collection(AppConstants.colUsers).doc(uid).set(user.toFirestore());
    return user;
  }

  Future<UserModel> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final doc = await _db.collection(AppConstants.colUsers).doc(uid).get();
    if (!doc.exists) {
      final user = UserModel(
        uid: uid,
        email: email,
        childIds: [],
        createdAt: DateTime.now(),
      );
      await _db.collection(AppConstants.colUsers).doc(uid).set(user.toFirestore());
      return user;
    }
    return UserModel.fromFirestore(doc);
  }

  Future<void> signOut() => _auth.signOut();

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      final doc = await _db.collection(AppConstants.colUsers).doc(user.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (_) {
      return null;
    }
  }
}
