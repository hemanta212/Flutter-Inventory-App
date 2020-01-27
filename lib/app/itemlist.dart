import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/app/itementryform.dart';
import 'package:bk_app/app/itemform.dart';
import 'package:sqflite/sqflite.dart';


class ItemList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ItemListState();
  }
}

class ItemListState extends State<ItemList> {
  DbHelper databaseHelper = DbHelper();
  List<Item> itemList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (itemList == null) {
      itemList = List<Item>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Items"),
      ),
      body: getItemListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Item('', 0, 0), 'Create Item');
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  ListView getItemListView() {
    TextStyle nameStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.yellow,
                child: Icon(Icons.keyboard_arrow_right),
              ),
              title: Text(this.itemList[position].name, style: nameStyle),
              subtitle: Text(this.itemList[position].name),
              trailing: GestureDetector(
                child: Icon(Icons.delete, color: Colors.grey),
                onTap: () {
                  _delete(context, itemList[position]);
                },
              ),
              onTap: () {
                navigateToDetail(this.itemList[position], 'Edit Item');
              },
            ));
      },
    );
  }

  void _delete(BuildContext context, Item item) async {
    int result = await databaseHelper.deleteItem(item.id);
    if (result != 0) {
      _showSnackBar(context, 'Item successfully deleted');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Item item, String name) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ItemForm(item: item, title:name);
    }));

    if (result == true){
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then( (database) {

      Future<List<Item>> itemListFuture = databaseHelper.getItemList();
      itemListFuture.then( (itemList) {
        setState( () {
          this.itemList = itemList;
          this.count = itemList.length;
        });
      });
    });
  }
}
