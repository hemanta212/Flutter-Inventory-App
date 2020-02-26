import 'dart:async';
import 'package:bk_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bk_app/models/item.dart';
import 'package:bk_app/services/auth.dart';

class CrudHelper {
  AuthService auth = AuthService();
  final userData;
  CrudHelper({this.userData});

  // Item
  Future<int> addItem(Item item) async {
      String targetEmail = this.userData.targetEmail;
    if (targetEmail == this.userData.email) {
      await Firestore.instance
          .collection('$targetEmail-items')
          .add(item.toMap())
          .catchError((e) {
        print(e);
        return 0;
      });
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> updateItem(String itemId, Item newItem) async {
      String targetEmail = this.userData.targetEmail;
    if (targetEmail == this.userData.email) {
      await Firestore.instance
          .collection('$targetEmail-items')
          .document(itemId)
          .updateData(newItem.toMap())
          .catchError((e) {
        print(e);
        return 0;
      });
      return 1;
    } else {
      return 0;
    }
  }

  Future<int> deleteItem(String itemId) async {
      String targetEmail = this.userData.targetEmail;
    if (targetEmail == this.userData.email) {
      await Firestore.instance
          .collection('$targetEmail-items')
          .document(itemId)
          .delete()
          .catchError((e) {
        print(e);
        return 0;
      });
      return 1;
    } else {
      return 0;
    }
  }

  Stream<QuerySnapshot> getItems() {
    String email = this.userData.targetEmail;
    return Firestore.instance
        .collection('$email-items')
        .orderBy('used', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot> getItem(String field, String value) async {
    String email = this.userData.targetEmail;
    QuerySnapshot itemSnapshot = await Firestore.instance
        .collection('$email-items')
        .where(field, isEqualTo: value)
        .getDocuments()
        .catchError((e) {
      return null;
    });

    if (itemSnapshot.documents.isEmpty) {
      return null;
    }
    return itemSnapshot.documents.first;
  }

  Future<DocumentSnapshot> getItemById(String id) async {
    String email = this.userData.targetEmail;
    DocumentSnapshot item = await Firestore.instance
        .document('$email-items/$id')
        .get()
        .catchError((e) {
      return null;
    });

    return item;
  }

  Future<QuerySnapshot> getItemQuerySnapshot() {
    String email = this.userData.targetEmail;
    return Firestore.instance
        .collection('$email-items')
        .orderBy('used', descending: true)
        .getDocuments();
  }

  // Item Transactions
  Stream<QuerySnapshot> getItemTransactions() {
    String email = this.userData.targetEmail;
    return Firestore.instance
        .collection('$email-transactions')
        .where('signature', isEqualTo: email)
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getItemTransactionQuerySnapshot() {
    String email = this.userData.targetEmail;
    return Firestore.instance
        .collection('$email-transactions')
        .orderBy('created_at', descending: true)
        .where('signature', isEqualTo: email)
        .getDocuments();
  }

  Future<QuerySnapshot> getPendingTransactionQuerySnapshot() async {
    String email = this.userData.targetEmail;
    UserData user = await this
        .getUserData('email', email)
        .then((snapshot) => UserData.fromMapObject(snapshot.data));
    List roles = user.roles.keys.toList();
    print("roles $roles");
    return Firestore.instance
        .collection('$email-transactions')
        .orderBy('created_at', descending: false)
        .where('signature', whereIn: roles)
        .getDocuments();
  }

  // Users
  Future<DocumentSnapshot> getUserData(String field, String value) async {
    QuerySnapshot userDataSnapshot = await Firestore.instance
        .collection('users')
        .where(field, isEqualTo: value)
        .getDocuments()
        .catchError((e) {
      return null;
    });
    if (userDataSnapshot.documents.isEmpty) {
      return null;
    }
    return userDataSnapshot.documents.first;
  }

  Future<UserData> getUserDataByUid(String uid) async {
    DocumentSnapshot _userData =
        await Firestore.instance.document('users/$uid').get().catchError((e) {
      print("error getting userdata $e");
      return null;
    });

    if (_userData.data == null) {
      print("error getting userdata is $uid");
      return null;
    }

    UserData userData = UserData.fromMapObject(_userData.data);
    print("here we go $userData");
    return userData;
  }

  Future<int> updateUserData(UserData userData) async {
    await Firestore.instance
        .collection('users')
        .document(userData.uid)
        .setData(userData.toMap())
        .catchError((e) {
      print(e);
      return 0;
    });
    return 1;
  }
}
