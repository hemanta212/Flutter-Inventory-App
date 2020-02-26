import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:bk_app/models/user.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/services/crud.dart';
import 'package:bk_app/utils/loading.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/window.dart';

class MonthlyHistory extends StatefulWidget {
  @override
  _MonthlyHistoryState createState() => _MonthlyHistoryState();
}

class _MonthlyHistoryState extends State<MonthlyHistory> {
  static CrudHelper crudHelper;
  static UserData userData;

  Map currentMonthHistory = Map();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    if (userData != null) {
      crudHelper = CrudHelper(userData: userData);
      _initializeCurrentMonthHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly History"),
      ),
      drawer: CustomScaffold.setDrawer(context),
      body: this.showTransactionHistoryForCurrentMonth(),
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  BottomAppBar _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      color: Theme.of(context).primaryColor,
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.card_travel),
              onPressed: () => WindowUtils.navigateToPage(context,
                  target: 'Transactions', caller: 'Month History')),
          SizedBox(width: 220.0),
          IconButton(
              icon: Icon(Icons.history),
              onPressed: () => WindowUtils.navigateToPage(context,
                  target: 'Month History', caller: 'Month History'))
        ],
      ),
    );
  }


  Widget showTransactionHistoryForCurrentMonth() {
    if (this.currentMonthHistory != null) {
      return ListView.builder(
        itemCount: this.currentMonthHistory.length,
        itemBuilder: (BuildContext context, int index) {
          String date = this.currentMonthHistory.keys.toList()[index];
          Map data = this.currentMonthHistory[date];
          return Card(
              color: Colors.white,
              elevation: 2.0,
              child: ListTile(
                leading: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Text(date),
                  ],
                ),
                title: this._getMonthlyDescription(context, data),
              ));
        },
      );
    } else {
      return Loading();
    }
  }

  Widget _getMonthlyDescription(BuildContext context, Map history) {
    ThemeData localTheme = Theme.of(context);
    String profit = FormUtils.fmtToIntIfPossible(
        FormUtils.getShortDouble(history['profit']));

    String sales = FormUtils.fmtToIntIfPossible(
        FormUtils.getShortDouble(history['sales']));

    return Row(children: <Widget>[
      Expanded(
          flex: 1,
          child: Column(children: <Widget>[
            Text("Sales", style: localTheme.textTheme.subhead),
            Text("Rs. $sales"),
          ])),
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text("Profit", style: localTheme.textTheme.subhead),
          Text("Rs. $profit"),
        ],
      ),
    ]);
  }

  void _initializeCurrentMonthHistory() async {
    final allTransactions = await crudHelper.getItemTransactionQuerySnapshot();

    setState(() {
      allTransactions.documents.forEach((doc) {
        ItemTransaction transaction = ItemTransaction.fromMapObject(doc.data);
        DateTime transactionDate =
            DateFormat.yMMMd().add_jms().parse(transaction.date);
        DateTime current = DateTime.now();

        if (transaction.type == 0 &&
            transactionDate.year == current.year &&
            transactionDate.month == current.month) {
          String day = DateFormat.MMMd().format(transactionDate);
          double profit =
              transaction.amount - transaction.items * transaction.costPrice;
          if (this.currentMonthHistory.containsKey(day) ?? false) {
            this.currentMonthHistory[day]['profit'] += profit;
            this.currentMonthHistory[day]['sales'] += transaction.amount;
          } else {
            this.currentMonthHistory[day] = {
              'profit': profit,
              'sales': transaction.amount,
            };
          }
        }
      });
    });
  }
}
