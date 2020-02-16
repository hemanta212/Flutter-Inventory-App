import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
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

  static void deleteTransactionAndUpdateItem(
      callback, transaction, item) async {
    // Sync newly updated item and delete transaction from db in batch
    var results;
    bool success = false;
    Database db = await DbHelper().database;

    // Reset item to state before this sales transaction
    if (item == null) {
      // condition for orphan transaction cases
      int result = await DbHelper().deleteItemTransaction(transaction.id);
      if (result != 0) {
        success = true;
      }
      callback(success);
      return;
    } else {
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
