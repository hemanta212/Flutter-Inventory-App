import 'dart:async';

import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/utils/dbhelper.dart';

class ItemBloc {
  final _itemController = StreamController<List<Item>>.broadcast();

  get items => _itemController.stream;

  dispose() {
    _itemController.close();
  }

  getItems() async {
    _itemController.sink.add(await DbHelper().getItemList());
  }

  ItemBloc() {
    getItems();
  }

  delete(int id) {
    DbHelper().deleteItem(id);
    getItems();
  }

  add(Item item) {
    DbHelper().insertItem(item);
    getItems();
  }

  update(Item item) {
    DbHelper().updateItem(item);
    getItems();
  }
}

class TransactionBloc {
  final _transactionController =
      StreamController<List<ItemTransaction>>.broadcast();

  get transactions => _transactionController.stream;

  dispose() {
    _transactionController.close();
  }

  getTransactions() async {
    _transactionController.sink.add(await DbHelper().getItemTransactionList());
  }

  TransactionBloc() {
    getTransactions();
  }

  delete(int id) {
    DbHelper().deleteItemTransaction(id);
    getTransactions();
  }

  add(ItemTransaction transaction) {
    DbHelper().insertItemTransaction(transaction);
    getTransactions();
  }

/*
  update(ItemTransaction transaction) {
    DbHelper().updateItemTransaction(transaction);
    getTransactions();
  }
  */
}
