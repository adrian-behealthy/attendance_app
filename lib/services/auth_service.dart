import 'package:attendance_app/models/user.dart';
import 'package:attendance_app/services/user_db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  Future<User> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      if (user != null) {
        return User(uid: user.uid);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  Future registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      if (user != null) {
        return User(uid: user.uid);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future registerNewUser(
      String email, String password, String firstName, String lastName) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      if (user != null) {
        UserDbService(uid: user.uid).addUser(
          firstName: firstName,
          lastName: lastName,
        );
        return User(uid: user.uid);
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
      return null;
    }
  }
}
