import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bk_app/app/wrapper.dart';
import 'package:bk_app/app/transactions/transactionList.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/models/user.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/cache.dart';
import 'package:bk_app/utils/loading.dart';
import 'package:bk_app/services/crud.dart';

class DueTransaction extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DueTransactionState();
  }
}

class DueTransactionState extends State<DueTransaction> {
  static CrudHelper crudHelper;
  Map itemMapCache = Map();
  List<ItemTransaction> payableTransactions;
  List<ItemTransaction> receivableTransactions;
  bool loading = true;
  static UserData userData;

  @override
  void initState() {
    _initializeItemMapCache();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    if (userData != null) {
      crudHelper = CrudHelper(userData: userData);
      _updateListView();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Wrapper();
    }
    List<Tab> viewTabs = <Tab>[
      Tab(text: "To receive"),
      Tab(text: "To pay"),
    ];
    return DefaultTabController(
        length: viewTabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Due Transactions"),
            bottom: TabBar(tabs: viewTabs),
          ),
          drawer: CustomScaffold.setDrawer(context),
          body: TabBarView(children: <Widget>[
            getDueTransactionView(type: 'receivable'),
            getDueTransactionView(type: 'payable'),
          ]),
          bottomNavigationBar: buildBottomAppBar(context),
        ));
  }

  static BottomAppBar buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      color: Theme.of(context).primaryColor,
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.card_travel),
              onPressed: () => WindowUtils.navigateToPage(context,
                  target: 'Transactions', caller: 'Due Transactions')),
          SizedBox(width: 20.0),
          IconButton(
              icon: Icon(Icons.access_alarm),
              onPressed: () => WindowUtils.navigateToPage(context,
                  target: 'Due Transactions', caller: 'Due Transactions')),
          SizedBox(width: 150.0),
          IconButton(
              icon: Icon(Icons.history),
              onPressed: () => WindowUtils.navigateToPage(context,
                  target: 'Month History', caller: 'Due Transactions'))
        ],
      ),
    );
  }

  Widget getDueTransactionView({type}) {
    Map transactionMap = {
      'payable': this.payableTransactions,
      'receivable': this.receivableTransactions,
    };
    List<ItemTransaction> transactions = transactionMap[type];
    return transactions != null
        ? ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (BuildContext context, int index) {
              ItemTransaction transaction = transactions[index];
              return Card(
                  color: Colors.white,
                  elevation: 2.0,
                  child: ListTile(
                    leading: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 10.0),
                        Text("Amount"),
                        Text(
                            "Rs. ${FormUtils.fmtToIntIfPossible(transaction.amount)}"),
                      ],
                    ),
                    title: TransactionListState.getDescription(
                        context, transaction, this.itemMapCache),
                    onTap: () {
                      TransactionListState.navigateToDetail(
                          context, transaction, 'Edit Item',
                          updateListView: this._updateListView);
                    },
                  ));
            },
          )
        : Loading();
  }

  void _updateListView() async {
    List<ItemTransaction> dueTransactions =
        await crudHelper.getDueTransactions();

    setState(() {
      this.receivableTransactions = dueTransactions.sublist(0);
      debugPrint(
          "all transactions ${dueTransactions.length} and recievables ${this.receivableTransactions}");
      this.receivableTransactions.retainWhere((ItemTransaction transaction) {
        if (transaction.type == 0)
          return true;
        else
          return false;
      });

      this.payableTransactions = dueTransactions.sublist(0);
      this.payableTransactions.retainWhere((ItemTransaction transaction) {
        if (transaction.type == 1)
          return true;
        else
          return false;
      });
    });
  }

  void _initializeItemMapCache() async {
    this.itemMapCache = await StartupCache().itemMap;
    setState(() {
      this.loading = false;
    });
  }
}
