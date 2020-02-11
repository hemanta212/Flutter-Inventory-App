import 'dart:async';
import 'package:flutter/material.dart';

import 'package:bk_app/utils/dbhelper.dart';
import 'package:intl/intl.dart';

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
      return null;
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
      return null;
    }
    fullItemTransactionMap.forEach((Map map) {
      itemTransactionMap[map['id']] = {
        'type': map['type'],
        'itemId': map['item_id'],
        'amount': map['amount'] / map['items'],
        'costPrice': map['cost_price'],
        'items': map['items'],
        'date': map['date']
      };
    });
    debugPrint("Cached transaction cache $itemTransactionMap");
    return itemTransactionMap;
  }
}
