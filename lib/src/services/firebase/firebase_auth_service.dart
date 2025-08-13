import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:txt_invite/src/interfaces/auth_service.dart';
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
    Future<User?> get currentUser async {
      return _userFromFirebase(_auth.currentUser);
    }

    @override
    Future<User?> signIn(String email, String password) async {
      try {
        await _auth.setPersistence(firebase_auth.Persistence.LOCAL);
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
}