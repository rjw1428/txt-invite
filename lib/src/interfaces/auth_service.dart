
import '../models/user.dart';

abstract class AuthService {
  User? get currentUser;
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(String email, String password);
  Future<void> signOut();
}
