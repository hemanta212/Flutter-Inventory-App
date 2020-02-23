import 'dart:async';
import 'package:bk_app/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/services/auth.dart';
import 'package:provider/provider.dart';

class CrudHelper {
  AuthService auth = AuthService();
  final userData;
  CrudHelper({this.userData});

  // Item
  Future<int> addItem(Item item) async {
    if (this.userData.targetEmail == this.userData.email) {
      await Firestore.instance
          .collection('${this.userData.targetEmail}-items')
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
    if (this.userData.targetEmail == this.userData.email) {
      await Firestore.instance
          .collection('items')
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
    if (this.userData.targetEmail == this.userData.email) {
      await Firestore.instance
          .collection('items')
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
    print("hello subha bihani ${this.userData.email} ${this.userData.targetEmail}");
    String email = this.userData.targetEmail;
    return Firestore.instance
        .collection('$email-items')
        .orderBy('used', descending: true)
        .getDocuments();
  }

// Item Transaction
  /*
  Future<int> addItemTransaction(ItemTransaction transaction) async {
    if (this.userData.targetEmail == this.userData.email) {
      transaction.verified = true;
    } else {
        print("yes turning to false");
      transaction.verified = false;
        print("yes turned to false ${transaction.verified}");
    }
    await Firestore.instance
        .collection('${this.userData.targetEmail}-transactions')
        .add(transaction.toMap())
        .catchError((e) {
      print(e);
      return 0;
    });
    return 1;
  }

  Future<int> updateItemTransaction(
      String transactionId, ItemTransaction newItemTransaction) async {
    if (this.userData.targetEmail == this.userData.email) {
      newItemTransaction.verified = true;
    } else {
      newItemTransaction.verified = false;
    }
    await Firestore.instance
        .collection('transactions')
        .document(transactionId)
        .updateData(newItemTransaction.toMap())
        .catchError((e) {
      print(e);
      return 0;
    });
    return 1;
  }

  Future<int> deleteItemTransaction(String transactionId) async {
    if (this.userData.targetEmail == this.userData.email) {
      await Firestore.instance
          .collection('transactions')
          .document(transactionId)
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
  */

  Stream<QuerySnapshot> getItemTransactions() {
    String email = this.userData.targetEmail;
    return Firestore.instance
        .collection('$email-transactions')
        .orderBy('created_at', descending: true)
        .snapshots();
  }

  Future<QuerySnapshot> getItemTransactionQuerySnapshot() {
    String email = this.userData.targetEmail;
    return Firestore.instance
        .collection('$email-transactions')
        .orderBy('created_at', descending: true)
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

// Item
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
