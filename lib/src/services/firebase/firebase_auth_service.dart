import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:txt_invite/src/interfaces/auth_service.dart';
import 'package:txt_invite/src/models/profile.dart';
import 'package:txt_invite/src/models/user.dart';

class FirebaseAuthService implements AuthService {

  final firebase_auth.FirebaseAuth _auth;

  FirebaseAuthService._internal()
      : _auth = firebase_auth.FirebaseAuth.instance;

  FirebaseAuthService() : this._internal();

  User? _userFromFirebase(firebase_auth.User? user) {
      if (user == null) {
        return null;
      }
      return User(id: user.uid, email: user.email!);
    }

    @override
    User? get currentUser {
      return _userFromFirebase(_auth.currentUser);
    }

    @override
    Future<User?> signIn(String email, String password) async {
      try {
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return _userFromFirebase(credential.user);
      } catch (e) {
        print('Error signing in: $e');
        return null;
      }
    }

    @override
    Future<void> signOut() async {
      await _auth.signOut();
    }

    @override
    Future<User?> signUp(String email, String password) async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _userFromFirebase(credential.user);
    }

    @override
    Future<void> createProfile(String userId, Profile profile) async {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set(profile.toMap());
      } catch (e) {
        print('Error creating profile: $e');
      }
    }
}