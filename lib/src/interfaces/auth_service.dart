
import 'package:txt_invite/src/models/profile.dart';

import '../models/user.dart';

abstract class AuthService {
  User? get currentUser;
  Future<Profile?> getUserProfile(String userId);
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(String email, String password);
  Future<void> createProfile(String userId, Profile profile);
  Future<void> signOut();
}
