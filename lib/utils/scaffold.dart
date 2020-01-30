import 'package:flutter/material.dart';


class CustomScaffold{
  static Widget setDrawer(context){
      return Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Home"),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: Text("Register Item"),
              onTap: () => Navigator.of(context).pushNamed("/itemForm"),
            ),
            ListTile(
              title: Text('Add Stock'),
              onTap: () => Navigator.of(context).pushNamed("/itemEntryForm"),
            ),
            ListTile(
              title: Text('Items'),
              onTap: () => Navigator.of(context).pushNamed("/itemList"),
            ),
          ]
        )
      );
    }

    static Widget setAppBar(title){
      return AppBar(
        title: Text(title),
      );
    }

    static Widget setScaffold(
      BuildContext context,
      String title,
      var getBody,
      {
        appBar = setAppBar
      }
    ){
      return Scaffold(
        appBar: appBar(title),
        drawer: setDrawer(context),
        body: getBody(),
      );// Scaffold
    }

  } // Custom Scaffold
