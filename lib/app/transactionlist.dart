import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bk_app/app/salesentryform.dart';
import 'package:bk_app/app/stockentryform.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:sqflite/sqflite.dart';

class TransactionList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TransactionListState();
  }
}

class TransactionListState extends State<TransactionList> {
  DbHelper databaseHelper = DbHelper();
  List<ItemTransaction> transactionList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (transactionList == null) {
      transactionList = List<ItemTransaction>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
      ),
      drawer: CustomScaffold.setDrawer(context),
      body: getTransactionListView(),
    );
  }

  ListView getTransactionListView() {
    TextStyle nameStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
            color: Colors.white,
            elevation: 2.0,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.keyboard_arrow_right),
              ),
              title: Text(this.transactionList[position].description,
                  style: nameStyle),
              subtitle: Text(this.transactionList[position].date),
              onTap: () {
                navigateToDetail(
                    this.transactionList[position], 'Edit Transaction');
              },
            ));
      },
    );
  }

  void navigateToDetail(ItemTransaction transaction, String name) async {
    var form;
    if (transaction.type == 0) {
      form =
          SalesEntryForm(title: name, transaction: transaction, forEdit: true);
    } else {
      form =
          StockEntryForm(title: name, transaction: transaction, forEdit: true);
    }

    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return form;
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<ItemTransaction>> transactionListFuture =
          databaseHelper.getItemTransactionList();
      transactionListFuture.then((transactionList) {
        setState(() {
          this.transactionList = transactionList;
          this.count = transactionList.length;
        });
      });
    });
  }
}
