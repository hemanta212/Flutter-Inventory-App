import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bk_app/services/crud.dart';
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

  static Future<bool> saveTransactionAndUpdateItem(
      transaction, item, String itemId,
      {String transactionId}) async {
    Firestore db = Firestore.instance;
    bool success = true;

    try {
      WriteBatch batch = db.batch();
      if (transactionId == null) {
        transaction.createdAt = DateTime.now().millisecondsSinceEpoch;
        transaction.date = DateFormat.yMMMd().add_jms().format(DateTime.now());
        if (transaction.type == 1) item.lastStockEntry = transaction.date;
        batch.setData(
            db.collection('transactions').document(), transaction.toMap());
      } else {
        batch.updateData(db.collection('transactions').document(transactionId),
            transaction.toMap());
      }

      item.used += 1;
      batch.updateData(db.collection('items').document(itemId), item.toMap());
      batch.commit();
    } catch (e) {
      success = false;
    }
    return success;
  }

  static void deleteTransactionAndUpdateItem(callback, transaction,
      transactionId, DocumentSnapshot itemSnapshot) async {
    // Sync newly updated item and delete transaction from db in batch
    CrudHelper crudHelper = CrudHelper();
    Firestore db = Firestore.instance;
    bool success = true;

    // Reset item to state before this sales transaction
    if (itemSnapshot.data == null) {
      // condition for orphan transaction cases
      crudHelper.deleteItemTransaction(transactionId);
      callback(success);
      return;
    }

    Item item = Item.fromMapObject(itemSnapshot.data);
    item.used += 1;

    if (transaction.type == 0) {
      item.increaseStock(transaction.items);
    } else {
      item.decreaseStock(transaction.items);
    }
    try {
      WriteBatch batch = db.batch();
      batch.delete(db.collection('transactions').document(transactionId));
      batch.updateData(db.collection('items').document(itemSnapshot.documentID),
          item.toMap());
      batch.commit();
    } catch (e) {
      success = false;
    }

    callback(success);
  }
}
