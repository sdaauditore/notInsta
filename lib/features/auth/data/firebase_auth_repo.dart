import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:not_insta/features/auth/domain/repos/auth_repo.dart';
import '../domain/entities/app_user.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      // attempt SignIn
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: '',
      );

      return user;
    } catch (e) {
      throw Exception('Login Failed $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      // attempt SignIn
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      return user;
    } catch (e) {
      throw Exception('Login Failed $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;
    if (firebaseUser == null) {
      return null;
    }
    return AppUser(uid: firebaseUser.uid, email: firebaseUser.email!, name: '');
  }
}
