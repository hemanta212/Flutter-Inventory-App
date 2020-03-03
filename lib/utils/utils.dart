import 'dart:async';
import 'package:bk_app/models/user.dart';
import 'package:provider/provider.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/services/crud.dart';
import 'package:bk_app/utils/date.dart';

class AppUtils {
  static Future<Map> getTransactionsForToday(context) async {
    UserData userData = Provider.of<UserData>(context);
    CrudHelper crudHelper = CrudHelper(userData: userData);

    Map itemTransactionMap = Map();
    List<ItemTransaction> transactions = await crudHelper.getItemTransactions();
    if (transactions.isEmpty) {
      return itemTransactionMap;
    }
    transactions.forEach((transaction) {
      Map transactionMap = transaction.toMap();
      String date = transactionMap['date'];
      if (DateUtils.isNotOfToday(date)) {
        return;
      }
      itemTransactionMap[transactionMap['id']] = {
        'type': transactionMap['type'],
        'itemId': transactionMap['item_id'],
        'amount': transactionMap['amount'] / transactionMap['items'],
        'costPrice': transactionMap['cost_price'],
        'dueAmount': transactionMap['due_amount'],
        'items': transactionMap['items'],
        'date': date,
        'description': transactionMap['description']
      };
    });
    return itemTransactionMap;
  }
}
