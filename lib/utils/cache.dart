import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bk_app/utils/dbhelper.dart';

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
    var databaseHelper = DbHelper();
    Map itemMap = Map();
    List<Map> fullItemMap = await databaseHelper.getItemMapList();
    if (fullItemMap.isEmpty) {
      return itemMap;
    }
    fullItemMap.forEach((Map map) {
      itemMap[map['id']] = [map['name'], map['nick_name']];
    });
    debugPrint("Done $itemMap");
    return itemMap;
  }

  Future<Map> initializeItemTransactionMap() async {
    debugPrint("Initializing item map cache");
    var databaseHelper = DbHelper();
    Map itemTransactionMap = Map();
    List<Map> fullItemTransactionMap =
        await databaseHelper.getItemTransactionMapList();

    if (fullItemTransactionMap.isEmpty) {
      return itemTransactionMap;
    }
    fullItemTransactionMap.forEach((Map map) {
      String date = map['date'];
      if (_isNotOfToday(date)) {
        return;
      }
      itemTransactionMap[map['id']] = {
        'type': map['type'],
        'itemId': map['item_id'],
        'amount': map['amount'] / map['items'],
        'costPrice': map['cost_price'],
        'dueAmount': map['due_amount'],
        'items': map['items'],
        'date': map['date'],
        'description': map['description']
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
