import 'package:sqflite/sqflite.dart';
import 'package:bk_app/utils/dbhelper.dart';

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

  static Future<bool> saveTransactionAndUpdateItem(transaction, item) async {
    var success = false;
    Database db = await DbHelper().database;

    try {
      var batch = db.batch();
      batch.update('item_table', item.toMap(),
          where: 'id = ?', whereArgs: [item.id]);
      if (transaction.id == null) {
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

  static void deleteTransactionAndUpdateItem(
      callback, transaction, item) async {
    // Sync newly updated item and delete transaction from db in batch
    var results;
    bool success = false;
    Database db = await DbHelper().database;

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
