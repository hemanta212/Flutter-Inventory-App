import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bk_app/services/crud.dart';

class StartupCache {
  static StartupCache _startupCache; // Singleton dbHelper
  static Map _itemMap;
  static Map _itemTransactionMap;
  bool reload;

  StartupCache._createInstance(); // Named constructor to create instance of DbHelper

  factory StartupCache({bool reload}) {
    if (_startupCache == null) {
      _startupCache = StartupCache
          ._createInstance(); // This will execute only once, singleton obj
    }
    _startupCache.reload = reload ?? false;
    return _startupCache;
  }

  Future<Map> get itemMap async {
    if (_itemMap == null || this.reload) {
      debugPrint('reload is ${this.reload}');
      _itemMap = await initializeItemMap();
    }
    return _itemMap;
  }

  Future<Map> get itemTransactionMap async {
    if (_itemTransactionMap == null || this.reload) {
      debugPrint('reload is ${this.reload}');
      _itemTransactionMap = await initializeItemTransactionMap();
    }
    return _itemTransactionMap;
  }

  Future<Map> initializeItemMap() async {
    debugPrint("Initializing item map cache");
    CrudHelper crudHelper = CrudHelper();
    Map itemMap = Map();
    QuerySnapshot itemSnapshot = await crudHelper.getItemQuerySnapshot();
    if (itemSnapshot.documents.isEmpty) {
      return itemMap;
    }
    itemSnapshot.documents.forEach((document) {
      itemMap[document.documentID] = [
        document.data['name'],
        document.data['nick_name']
      ];
    });
    debugPrint("Done $itemMap");
    return itemMap;
  }

  Future<Map> initializeItemTransactionMap() async {
    debugPrint("Initializing item transaction map cache");
    CrudHelper crudHelper = CrudHelper();
    Map itemTransactionMap = Map();
    QuerySnapshot itemTransactionSnapshot =
        await crudHelper.getItemTransactionQuerySnapshot();
    if (itemTransactionSnapshot.documents.isEmpty) {
      return itemMap;
    }
    itemTransactionSnapshot.documents.forEach((document) {
      Map transactionMap = document.data;
      String date = transactionMap['date'];
      if (_isNotOfToday(date)) {
        return;
      }
      itemTransactionMap[document.documentID] = {
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
    debugPrint("Cached transaction cache $itemTransactionMap");
    return itemTransactionMap;
  }

  static bool _isNotOfToday(String date) {
    DateTime givenDate = DateFormat.yMMMd().add_jms().parse(date);
    DateTime current = DateTime.now();
    return givenDate.year != current.year ||
        givenDate.month != current.month ||
        givenDate.day != current.day;
  }
}
