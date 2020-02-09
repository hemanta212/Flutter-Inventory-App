import 'package:flutter/material.dart';

import 'package:bk_app/app/itementryform.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/blocs/database_bloc.dart';

class ItemList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ItemListState();
  }
}

class ItemListState extends State<ItemList> {
  DbHelper databaseHelper = DbHelper();
  final bloc = ItemBloc();

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Items"),
      ),
      drawer: CustomScaffold.setDrawer(context),
      body: getItemListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Item(''), 'Create Item');
        },
        tooltip: 'Add Item',
        child: Icon(Icons.add),
      ),
    );
  }

  StreamBuilder<List<Item>> getItemListView() {
    TextStyle nameStyle = Theme.of(context).textTheme.subhead;

    return StreamBuilder<List<Item>>(
      stream: bloc.items,
      builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              Item item = snapshot.data[index];
              return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.keyboard_arrow_right),
                    ),
                    title: Text(item.name, style: nameStyle),
                    subtitle: Text(item.nickName ?? ''),
                    onTap: () {
                      navigateToDetail(item, 'Edit Item');
                    },
                  ));
            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void navigateToDetail(Item item, String name) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ItemEntryForm(title: name, item: item, forEdit: true);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    setState(() {
      this.bloc.getItems();
    });
  }
}
