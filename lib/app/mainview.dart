import 'package:flutter/material.dart';
import 'package:bk_app/app/salesentryform.dart';
import 'package:bk_app/app/itemlist.dart';
import 'package:bk_app/app/transactionlist.dart';

class MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: SalesEntryForm(title: "Sales Entry"),
    );
  }
}
