import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:bk_app/app/itementryform.dart';
import 'package:bk_app/app/salesentryform.dart';

class StockEntryForm extends StatefulWidget {
  final String title;
  final ItemTransaction transaction;
  final bool forEdit;

  StockEntryForm({this.transaction, this.title, this.forEdit});

  @override
  State<StatefulWidget> createState() {
    return _StockEntryFormState(this.transaction, this.title);
  }
}

class _StockEntryFormState extends State<StockEntryForm> {
  String title;
  ItemTransaction transaction;
  _StockEntryFormState(this.transaction, this.title);

  // Variables
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;
  DbHelper databaseHelper = DbHelper();

  List<String> _forms = ['Sales Entry', 'Stock Entry', 'Item Entry'];
  String stringUnderName = '';
  String _currentFormSelected;
  int tempItemId;

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController costPriceController = TextEditingController();
  TextEditingController markedPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this._currentFormSelected = this._forms[1];
    _initiateTransactionData();
  }

  void _initiateTransactionData() {
    if (this.transaction == null) {
      debugPrint("Building own transaction obj");
      this.transaction = ItemTransaction(1, null, 0.0, 0.0, '');
    }

    if (this.transaction.id != null) {
      debugPrint("Getting transanction obj");
      this.itemNumberController.text =
          FormUtils.fmtToIntIfPossible(this.transaction.items);
      this.costPriceController.text =
          FormUtils.fmtToIntIfPossible(this.transaction.amount);

      Future<Item> itemFuture =
          this.databaseHelper.getItem("id", this.transaction.itemId);
      itemFuture.then((item) {
        this.tempItemId = this.transaction.itemId;
        this.itemNameController.text = '${item.name}';
        this.markedPriceController.text =
            FormUtils.fmtToIntIfPossible(item.markedPrice);
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
                      },
                    ),

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
                      onChanged: () {},
                    ),

                    // TODO
                    /* Provide user to register using  Big unit terms like
            1 box = 15 items
            1 cartoon = 5 box
            */

                    // Cost price
                    WindowUtils.genTextField(
                      labelText: "Total cost price",
                      textStyle: textStyle,
                      controller: this.costPriceController,
                      keyboardType: TextInputType.number,
                      onChanged: this.updateCostPrice,
                    ),

                    // Marked price
                    WindowUtils.genTextField(
                      labelText: "Expected selling price",
                      textStyle: textStyle,
                      controller: this.markedPriceController,
                      keyboardType: TextInputType.number,
                      onChanged: () {},
                    ),

                    // save
                    Padding(
                        padding: EdgeInsets.only(
                            bottom: 3 * _minimumPadding, top: 3 * _minimumPadding),
                        child: Row(children: <Widget>[
                          WindowUtils.genButton(
                              this.context, "Save", this.checkAndSave),
                          Container(
                            width: 5.0,
                          ),
                          WindowUtils.genButton(
                              this.context, "Delete", this._delete)
                        ]) // Row

                        ), // Paddin
                  ]) //List view
                  ) // Padding
              ))
    ]); // Container
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold.setScaffold(context, this.title, buildForm);
  }

  void updateItemName() {
    var name = this.itemNameController.text;
    Future<Item> itemFuture = this.databaseHelper.getItem("name", name);
    itemFuture.then((item) {
      if (item == null) {
        this.stringUnderName = 'Unregistered item';
        this.tempItemId = null;
      } else {
        this.stringUnderName = '';
        this.tempItemId = item.id;
      }
    }, onError: (e) {
      debugPrint('UpdateitemName Error::  $e');
    });
  }

  void updateCostPrice() {
    this.transaction.amount = double.parse(this.costPriceController.text).abs();
  }

  void clearTextFields() {
    this.itemNameController.text = '';
    this.itemNumberController.text = '';
    this.costPriceController.text = '';
    this.markedPriceController.text = '';
  }

  void checkAndSave() {
    if (this._formKey.currentState.validate()) {
      this._save();
    }
  }

  // Save data to database
  void _save() async {
    Item item = await this.databaseHelper.getItem("id", this.tempItemId);
    if (item == null) {
      WindowUtils.showAlertDialog(
          this.context, "Failed!", "Item not registered");
      return;
    }

    double items = double.parse(this.itemNumberController.text).abs();

    this.transaction.itemId = item.id;
    this.transaction.date = DateFormat.yMMMd().add_Hms().format(DateTime.now());
    this.transaction.items = items;
    this.transaction.description =
        'Amount: ${this.transaction.amount}\n Added: ${item.name}';

    item.markedPrice = double.parse(this.markedPriceController.text).abs();
    item.increaseStock(items);

    int result;
    List<int> results = [];
    if (this.transaction.id != null) {
      // Case 1: Update operation
      debugPrint("Updated item");
      result =
          await this.databaseHelper.updateItemTransaction(this.transaction);
    } else {
      // Case 2: Insert operation
      result =
          await this.databaseHelper.insertItemTransaction(this.transaction);
    }

    var result2 = await this.databaseHelper.updateItem(item);
    results = [result, result2];

    if (results.contains(0)) {
      // Failure
      WindowUtils.showAlertDialog(
          this.context, 'Status', 'Problem updating stock, try again!');
    } else {
      if (widget.forEdit ?? false) {
        WindowUtils.moveToLastScreen(context);
      }
      this.clearTextFields();
      // Success
      WindowUtils.showAlertDialog(
          this.context, 'Status', 'Stock updated successfully');
    }
  }

  // Delete item data
  void _delete() async {
    if (widget.forEdit ?? false) {
      WindowUtils.moveToLastScreen(context);
    }

    this.clearTextFields();
    if (this.transaction.id == null) {
      // Case 1: Abandon new item creation
      WindowUtils.showAlertDialog(this.context, 'Status', 'Item not created');
      return;
    }
    // Case 2: Delete item from database
    int result =
        await this.databaseHelper.deleteItemTransaction(this.transaction.id);

    if (result != 0) {
      // Success
      WindowUtils.showAlertDialog(
          this.context, 'Status', 'Item deleted successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(
          this.context, 'Failed!', 'Problem deleting item, try again!');
    }
  }

  void _dropDownItemSelected(String title) async {
    Map _stringToForm = {
      'Item Entry': ItemEntryForm(title: title),
      'Sales Entry': SalesEntryForm(title: title),
    };

    if (title == 'Stock Entry') {
      return;
    }

    var getForm = _stringToForm[title];
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return getForm;
    }));
  }
}
