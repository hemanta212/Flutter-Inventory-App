import 'package:flutter/material.dart';

class CustomScaffold {
  static Widget setDrawer(context) {
    return Drawer(
        child: ListView(children: <Widget>[
      ListTile(
        title: Text("Home"),
        onTap: () => Navigator.of(context).pushNamed("/mainForm"),
      ),
      ListTile(
        title: Text('Items'),
        onTap: () => Navigator.of(context).pushNamed("/itemList"),
      ),
      ListTile(
        title: Text('test'),
        onTap: () => Navigator.of(context).pushNamed("/itemList"),
      ),
      ListTile(
        title: Text('Transactions'),
        onTap: () => Navigator.of(context).pushNamed("/transactionList"),
      ),
    ]));
  }

  static Widget setAppBar(title) {
    return AppBar(
      title: Text(title),
    );
  }

  static Widget setScaffold(BuildContext context, String title, var getBody,
      {appBar = setAppBar}) {
    return Scaffold(
      appBar: appBar(title),
      drawer: setDrawer(context),
      body: getBody(context),
    ); // Scaffold
  }
} // Custom Scaffold
