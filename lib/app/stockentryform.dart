import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';

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
  String formName;
  String disclaimerText = '';
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
    this.formName = _forms[1];
    this._currentFormSelected = formName;
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
        if (item == null) {
          setState(() {
            this.disclaimerText =
                'Orphan Transaction: The item associated with this transaction has been deleted';
          });
        }
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
          WindowUtils.dropDownItemSelected(context,
              caller: this.formName, target: newValueSelected);
        }, //onChanged

        value: _currentFormSelected,
      ), // DropdownButton

      Expanded(
          child: Form(
              key: this._formKey,
              child: Padding(
                  padding: EdgeInsets.all(_minimumPadding * 2),
                  child: ListView(children: <Widget>[
                    // Any disclaimer for user
                    Visibility(
                      visible: this.disclaimerText.isNotEmpty,
                      child: Padding(
                          padding: EdgeInsets.all(_minimumPadding),
                          child: Text(this.disclaimerText)),
                    ),

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
                      visible: stringUnderName.isNotEmpty,
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
                            bottom: 3 * _minimumPadding,
                            top: 3 * _minimumPadding),
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
    String itemNo = FormUtils.fmtToIntIfPossible(this.transaction.items);
    String amount = FormUtils.fmtToIntIfPossible(this.transaction.amount);
    this.transaction.description =
        "Sold: $itemNo ${item.name} \nAmount: $amount";

    item.markedPrice = double.parse(this.markedPriceController.text).abs();
    item.increaseStock(items);

    bool success =
        await FormUtils.saveTransactionAndUpdateItem(this.transaction, item);

    this.saveCallback(success);
  }

  // Delete item data
  void _delete() async {
    Item item =
        await this.databaseHelper.getItem("id", this.transaction.itemId);
    item.decreaseStock(this.transaction.items);

    if (this.transaction.id == null) {
      // Case 1: Abandon new item creation
      this.clearTextFields();
      WindowUtils.showAlertDialog(context, "Status", 'Item not created');
      return;
    } else {
      // Case 2: Delete item from database after user confirms again
      WindowUtils.showAlertDialog(context, "Delete?",
          "This may delete important information forever. Delete?",
          onPressed: (buildContext) {
        FormUtils.deleteTransactionAndUpdateItem(
            this.saveCallback, this.transaction, item);
      });
    }
  }

  void saveCallback(bool success) {
    // close the confirm dialog for delete
    WindowUtils.moveToLastScreen(context);

    if (success) {
      this.clearTextFields();
      if (this.widget.forEdit ?? false) {
        WindowUtils.moveToLastScreen(this.context, modified: true);
      }

      // Success
      WindowUtils.showAlertDialog(
          this.context, "Status", 'Stock updated successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(
          this.context, 'Failed!', 'Problem updating stock, try again!');
    }
  }
}
