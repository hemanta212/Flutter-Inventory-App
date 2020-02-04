import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/app/itementryform.dart';
import 'package:bk_app/app/stockentryform.dart';

class SalesEntryForm extends StatefulWidget {
  final String title;
  final ItemTransaction transaction;
  final bool forEdit;

  SalesEntryForm({this.title, this.transaction, this.forEdit});

  @override
  State<StatefulWidget> createState() {
    return _SalesEntryFormState(this.title, this.transaction);
  }
}

class _SalesEntryFormState extends State<SalesEntryForm> {
  // Variables
  String title;
  ItemTransaction transaction;
  _SalesEntryFormState(this.title, this.transaction);

  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;
  List<String> _forms = ['Sales Entry', 'Stock Entry', 'Item Entry'];
  String _currentFormSelected;
  DbHelper databaseHelper = DbHelper();

  String stringUnderName = '';
  int tempItemId;

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentFormSelected = _forms[0];
    _initiateTransactionData();
  }

  void _initiateTransactionData() {
    if (this.transaction == null) {
      debugPrint("Building own transaction obj");
      this.transaction = ItemTransaction(0, null, 0.0, 0.0, '');
    }

    if (this.transaction.id != null) {
      debugPrint("Getting transaction obj");
      this.itemNumberController.text =
          FormUtils.fmtToIntIfPossible(this.transaction.items);
      this.sellingPriceController.text =
          FormUtils.fmtToIntIfPossible(this.transaction.amount);

      Future<Item> itemFuture =
          this.databaseHelper.getItem("id", this.transaction.itemId);
      itemFuture.then((item) {
        this.tempItemId = this.transaction.itemId;
        this.itemNameController.text = '${item.name}';
      });
    }
  }

  Widget buildForm(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    return Column(children: <Widget>[
      DropdownButton<String>(
        items: _forms.map((String dropDownStringItem) {
          return DropdownMenuItem<String>(
            value: dropDownStringItem,
            child: Text(dropDownStringItem),
          ); // DropdownMenuItem
        }).toList(),

        onChanged: (String newValueSelected) {
          _dropDownItemSelected(newValueSelected);
        }, //onChanged

        value: _currentFormSelected,
      ), // DropdownButton

      Expanded(
          child: Form(
              key: this._formKey,
              child: Padding(
                  padding: EdgeInsets.all(_minimumPadding * 2),
                  child: ListView(children: <Widget>[
                    // Item name
                    WindowUtils.genTextField(
                        labelText: "Item name",
                        hintText: "Name of item you sold",
                        textStyle: textStyle,
                        controller: this.itemNameController,
                        onChanged: () {
                          return setState(() {
                            this.updateItemName();
                          });
                        }),

                    Visibility(
                      visible: stringUnderName.isEmpty ? false : true,
                      child: Padding(
                          padding: EdgeInsets.all(_minimumPadding),
                          child: Text(this.stringUnderName)),
                    ),

                    // No of items
                    WindowUtils.genTextField(
                        labelText: "No of items",
                        textStyle: textStyle,
                        controller: this.itemNumberController,
                        keyboardType: TextInputType.number,
                        onChanged: () {}),

                    // Selling price
                    WindowUtils.genTextField(
                      labelText: "Selling price",
                      textStyle: textStyle,
                      controller: this.sellingPriceController,
                      keyboardType: TextInputType.number,
                      onChanged: this.updateSellingPrice,
                    ),

                    // save
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: _minimumPadding * 3, top: 3 * _minimumPadding),
                        child: Row(children: <Widget>[
                          WindowUtils.genButton(
                              context, "Save", this.checkAndSave),
                          Container(
                            width: _minimumPadding,
                          ),
                          WindowUtils.genButton(
                              context, "Delete", this._delete)
                        ]) // Row

                        ), // Paddin
                  ]) //List view
                  ) // Padding
              ))
    ]); // return
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold.setScaffold(context, title, buildForm);
  }

  void updateSellingPrice() {
    this.transaction.amount = double.parse(this.sellingPriceController.text).abs();
  }

  void updateItemName() {
    var name = this.itemNameController.text;
    Future<Item> itemFuture = this.databaseHelper.getItem("name", name);
    itemFuture.then((item) {
      if (item == null) {
        this.stringUnderName = 'Unregistered name';
        this.tempItemId = null;
      } else {
        this.stringUnderName = '';
        this.tempItemId = item.id;
      }
    }, onError: (e) {
      debugPrint('UpdateitemName Error::  $e');
    });
  }

  void clearTextFields() {
    this.itemNameController.text = '';
    this.itemNumberController.text = '';
    this.sellingPriceController.text = '';
  }

  void checkAndSave() {
    debugPrint("Save button clicked");
    if (this._formKey.currentState.validate()) {
      debugPrint("validated");
      this._save();
    }
  }

  // Save data to database
  void _save() async {
    Item item = await this.databaseHelper.getItem("id", this.tempItemId);
    if (item == null) {
      WindowUtils.showAlertDialog(
          context, "Failed!", "Item not registered");
      return;
    }

    double items = double.parse(this.itemNumberController.text).abs();
    this.transaction.itemId = item.id;
    this.transaction.date = DateFormat.yMMMd().add_Hms().format(DateTime.now());
    this.transaction.items = items;
    this.transaction.description =
        'Amount: ${this.transaction.amount}\n Sold: ${item.name}';
    item.decreaseStock(items);

    _saveTransactionAndUpdateItem(transaction, item);
  }

  // Delete item data
  void _delete() async {

    if (this.transaction.id == null) {
      // Case 1: Abandon new item creation
      this.clearTextFields();
      WindowUtils.showAlertDialog(context, "Status", 'Item not created');
      return;
    }else{
      // Case 2: Delete item from database after user confirms again
      WindowUtils.showAlertDialog(
        context,
        "Delete?",
        '''Deleting a transaction may delete important information
        It cannot be undone. Delete?''',
        onPressed: _deleteTransactionAndUpdateItem,
      );
    }
  }

  void _saveTransactionAndUpdateItem(ItemTransaction transaction, Item item) async {
    var success;
    Database db = await this.databaseHelper.database;

    try {
      var batch = db.batch();
      batch.update(
        'item_table', item.toMap(), where: 'id = ?', whereArgs: [item.id]
      );
      if (transaction.id == null){
        batch.insert('transaction_table', transaction.toMap());
      } else {
        batch.update(
          'transaction_table',
          transaction.toMap(),
          where: 'id = ?',
          whereArgs: [transaction.id]
        );
      }
      var results = await batch.commit();
      if (results.contains(0) == false){
        success = true;
      }

    } catch(e) {
      success = false;
    }

    if (success){
      if (widget.forEdit ?? false) {
        WindowUtils.moveToLastScreen(context);
      }
      this.clearTextFields();

      // Success
      WindowUtils.showAlertDialog(
        context, "Status", 'Stock updated successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(
          context, 'Failed!', 'Problem updating stock, try again!');
    }

  }

  void _deleteTransactionAndUpdateItem(BuildContext context) async {
    // Reset item to state before this sales transaction
    Item item = await this.databaseHelper.getItem("id", this.transaction.itemId);
    item.increaseStock(this.transaction.items);

    // Sync this newly updated item and delete transaction from db in batch
    var results;
    Database db = await this.databaseHelper.database;

    try {
      var batch = db.batch();
      batch.delete(
        'transaction_table', where: 'id = ?', whereArgs: [this.transaction.id]
      );
      batch.update(
        'item_table', item.toMap(), where: 'id = ?', whereArgs: [item.id]
      );

      results = await batch.commit();
    } catch(e) {
      // Failure
      debugPrint("ERROR, batch delete, Sales entry form: $e");
      // close confirmation dialog
      WindowUtils.moveToLastScreen(context);
      WindowUtils.showAlertDialog(
          context, 'Failed!', 'Problem deleting item, try again!');
      return;
    }

    // close the delete confirm dialog now that its confirmed
    WindowUtils.moveToLastScreen(context);

    // Go to previous screen if for editing.
    if (widget.forEdit ?? false) {
      WindowUtils.moveToLastScreen(context, isTrue:true);
    }

    // Label as failed if results has one or more zero
    if (results.contains(0)) {
      // Failure
      WindowUtils.showAlertDialog(
          context, 'Failed!', 'Problem deleting item, try again!');
    } else {
      // Success
      this.clearTextFields();
      WindowUtils.showAlertDialog(
          context, "Status", 'Item deleted successfully');
    }
  }

  void _dropDownItemSelected(String title) async {
    Map _stringToForm = {
      'Item Entry': ItemEntryForm(title: title),
      'Stock Entry': StockEntryForm(title: title),
    };

    if (title == 'Sales Entry') {
      return;
    }

    var getForm = _stringToForm[title];
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return getForm;
    }));
  }

}
