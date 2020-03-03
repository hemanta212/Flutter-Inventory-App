import 'dart:async';

import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:bk_app/services/crud.dart';

class StartupCache {
  static StartupCache _startupCache;
  static Map _itemMap;
  bool reload;
  UserData userData;

  StartupCache._createInstance();

  factory StartupCache({bool reload, UserData userData}) {
    // This will execute only once, singleton obj
    if (_startupCache == null) {
      _startupCache = StartupCache._createInstance();
    }
    _startupCache.reload = reload ?? false;
    _startupCache.userData = userData;
    return _startupCache;
  }

  Future<Map> get itemMap async {
    if (_itemMap == null || this.reload) {
      debugPrint('reload is ${this.reload}');
      _itemMap = await initializeItemMap();
    }
    return _itemMap;
  }

  Future<Map> initializeItemMap() async {
    debugPrint("Initializing item map cache");
    Map itemMap = Map();
    CrudHelper crudHelper = CrudHelper(userData: this.userData);
    List<Item> items = await crudHelper.getItems();
    if (items.isEmpty) {
      return itemMap;
    }
    items.forEach((Item item) {
      itemMap[item.id] = [
        item.name,
        item.nickName,
      ];
    });
    debugPrint("Done $itemMap");
    return itemMap;
  }
}
