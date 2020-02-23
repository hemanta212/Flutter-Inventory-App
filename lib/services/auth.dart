import 'package:bk_app/models/user.dart';
import 'package:bk_app/services/crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserData _userDataFromUser(FirebaseUser user) {
    return user == null
        ? user
        : UserData(
            uid: user.uid, email: user.email, verified: user.isEmailVerified);
  }

  // auth change user stream
  Stream<UserData> get user {
    return _firebaseAuth.onAuthStateChanged.map(_userDataFromUser);
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // register with email and password
  Future register(String email, String password) async {
    try {
      AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;
      // create a new document for the user with the uid
      DocumentSnapshot duplicate =
          await CrudHelper().getUserData('email', user.email);
      if (duplicate?.data ?? false) {
        print("duplicate email");
        return null;
      }
      UserData userData = UserData(
          uid: user.uid,
          email: user.email,
          verified: user.isEmailVerified,
          roles: Map());

      await CrudHelper().updateUserData(userData);
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _firebaseAuth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
}
