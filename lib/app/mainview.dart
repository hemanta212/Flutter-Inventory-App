import 'package:bk_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bk_app/app/wrapper.dart';
import 'package:bk_app/app/salesentryform.dart';
import 'package:bk_app/app/itemlist.dart';
import 'package:bk_app/app/transactionlist.dart';
import 'package:bk_app/services/auth.dart';

class MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserData>.value(
      value: AuthService().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bookkeeping app',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ), // ThemeData
        routes: <String, WidgetBuilder>{
          "/mainForm": (BuildContext context) =>
              SalesEntryForm(title: "Sales Entry"),
          "/itemList": (BuildContext context) => ItemList(),
          "/transactionList": (BuildContext context) => TransactionList(),
        },
        home: Wrapper(),
      ),
    );
  }
}
