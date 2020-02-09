import 'package:flutter/material.dart';

import 'package:bk_app/app/salesentryform.dart';
import 'package:bk_app/app/stockentryform.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/blocs/database_bloc.dart';

class TransactionList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TransactionListState();
  }
}

class TransactionListState extends State<TransactionList> {
  DbHelper databaseHelper = DbHelper();
  final bloc = TransactionBloc();

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
      ),
      drawer: CustomScaffold.setDrawer(context),
      body: getTransactionListView(),
    );
  }

  StreamBuilder<List<ItemTransaction>> getTransactionListView() {
    TextStyle nameStyle = Theme.of(context).textTheme.subhead;

    return StreamBuilder<List<ItemTransaction>>(
      stream: bloc.transactions,
      builder: (BuildContext context,
          AsyncSnapshot<List<ItemTransaction>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              ItemTransaction transaction = snapshot.data[index];
              return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red,
                      child: Icon(Icons.keyboard_arrow_right),
                    ),
                    title: Text(transaction.description, style: nameStyle),
                    subtitle: Text(transaction.date ?? ''),
                    onTap: () {
                      navigateToDetail(transaction, 'Edit Item');
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
    setState(() {
      this.bloc.getTransactions();
    });
  }
}
