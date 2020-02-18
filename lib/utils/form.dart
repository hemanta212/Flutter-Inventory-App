import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'package:bk_app/services/crudHelper.dart';
import 'package:bk_app/models/item.dart';

class FormUtils {
  static String fmtToIntIfPossible(double value) {
    if (value == null) {
      return '';
    }

    String intString = '${value.ceil()}';
    if (double.parse(intString) == value) {
      return intString;
    } else {
      return '$value';
    }
  }

  static double getShortDouble(double value, {round = 2}) {
    return double.parse(value.toStringAsFixed(round));
  }

  static Future<bool> saveTransactionAndUpdateItem(transaction, item) async {
    var success = false;
    Database db = await DbHelper().database;

    try {
      var batch = db.batch();
      batch.update('item_table', item.toMap(),
          where: 'id = ?', whereArgs: [item.id]);
      if (transaction.id == null) {
        transaction.date = DateFormat.yMMMd().add_jms().format(DateTime.now());

        batch.insert('transaction_table', transaction.toMap());
      } else {
        batch.update('transaction_table', transaction.toMap(),
            where: 'id = ?', whereArgs: [transaction.id]);
      }
      var results = await batch.commit();
      if (results.contains(0) == false) {
        success = true;
      }
    } catch (e) {
      success = false;
    }
    return success;
  }

  static void deleteTransactionAndUpdateItem(callback, transaction,
      transactionId, DocumentSnapshot itemSnapshot) async {
    // Sync newly updated item and delete transaction from db in batch
    var results;
    CrudHelper crudHelper = CrudHelper();
    Firestore db = Firestore.instance;
    WriteBatch batch = db.batch();
    /*

    batch.setData(
     db.collection('items').add());

     batch.updateData(
     db.collection(’users’).document(’id’),{'status': 'Rejected'});
     batch.delete(db.collection(’users’).document(’id’));
     batch.commit();
     
     */

    // Reset item to state before this sales transaction

    if (itemSnapshot.exists == false) {
      // condition for orphan transaction cases
      crudHelper().deleteItemTransaction(transaction.id);
      callback(true);
      return;
    } else {
      var item = Item.fromMapObject(itemSnapshot.data);
      if (transaction.type == 0) {
        item.increaseStock(transaction.items);
      } else {
        item.decreaseStock(transaction.items);
      }
    }

    try {
      var batch = db.batch();
      batch.delete('transaction_table',
          where: 'id = ?', whereArgs: [transaction.id]);
      batch.update('item_table', item.toMap(),
          where: 'id = ?', whereArgs: [item.id]);

      results = await batch.commit();
      if (results.contains(0) == false) {
        success = true;
      }
    } catch (e) {
      success = true;
    }

    callback(success);
  }
}
