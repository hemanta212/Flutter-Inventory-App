import 'package:bk_app/models/user.dart';
import 'package:bk_app/utils/cache.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bk_app/app/authenticate/authenticate.dart';
import 'package:bk_app/app/itemlist.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize the cache for app
    final user = Provider.of<UserData>(context);

    final StartupCache startupCache =
        StartupCache(userData: user, reload: true);

    // return either the Home or Authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      _initializeCache(startupCache);
      return ItemList(); // SalesEntryForm(title: "Sales Entry");
    }
  }

  void _initializeCache(startupCache) async {
    // Loads cache into memory with help of singleton class instance
    await startupCache.itemMap;
    await startupCache.itemTransactionMap;
  }
}
