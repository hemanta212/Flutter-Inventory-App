import 'package:flutter/material.dart';
import 'package:bk_app/app/sellingform.dart';
import 'package:bk_app/app/itemform.dart';
import 'package:bk_app/app/itementryform.dart';
import 'package:bk_app/app/itemlist.dart';

class MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bookkeeping app',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.indigo,
        accentColor: Colors.indigoAccent,
        primarySwatch: Colors.deepPurple,
      ), // ThemeData
      routes: <String, WidgetBuilder>{
        "/spForm": (BuildContext context) => SellingForm(title: "Register Sales"), 
        "/itemForm": (BuildContext context) => ItemForm(title: "Register Item"), 
        "/itemEntryForm": (BuildContext context) => ItemEntryForm(title: "Stock Entry"), 
      },
      home: ItemList(),
    );

  }

}
