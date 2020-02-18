import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';

class CrudHelper {
  // Item
  Future<int> addItem(Item item) async {
    await Firestore.instance
        .collection('items')
        .add(item.toMap())
        .catchError((e) {
      print(e);
      return 0;
    });
    return 1;
  }

  Stream<QuerySnapshot> getItems() {
    return Firestore.instance.collection('items').snapshots();
  }

  Future<DocumentSnapshot> getItem(String field, String value) async {
    QuerySnapshot itemSnapshot = await Firestore.instance
        .collection('items')
        .where(field, isEqualTo: value)
        .getDocuments();
    return itemSnapshot.documents.first;
  }

  Future<DocumentSnapshot> getItemById(String id) async {
    DocumentSnapshot item =
        await Firestore.instance.document('items/$id').get();
    return item;
  }

  Future<QuerySnapshot> getItemQuerySnapshot() {
    return Firestore.instance.collection('items').getDocuments();
  }

  Future<int> updateItem(String itemId, Item newItem) async {
    await Firestore.instance
        .collection('items')
        .document(itemId)
        .updateData(newItem.toMap())
        .catchError((e) {
      print(e);
      return 0;
    });
    return 1;
  }

  Future<int> deleteItem(String itemId) async {
    await Firestore.instance
        .collection('items')
        .document(itemId)
        .delete()
        .catchError((e) {
      print(e);
      return 0;
    });
    return 1;
  }

  // Item Transaction
  Future<int> addItemTransaction(ItemTransaction transaction) async {
    await Firestore.instance
        .collection('transactions')
        .add(transaction.toMap())
        .catchError((e) {
      print(e);
      return 0;
    });
    return 1;
  }

  Stream<QuerySnapshot> getItemTransactions() {
    return Firestore.instance.collection('transactions').snapshots();
  }

  Future<QuerySnapshot> getItemTransactionQuerySnapshot() {
    return Firestore.instance.collection('transactions').getDocuments();
  }

  Future<int> updateItemTransaction(
      String transactionId, ItemTransaction newItemTransaction) async {
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
    await Firestore.instance
        .collection('transactions')
        .document(transactionId)
        .delete()
        .catchError((e) {
      print(e);
      return 0;
    });
    return 1;
  }
}