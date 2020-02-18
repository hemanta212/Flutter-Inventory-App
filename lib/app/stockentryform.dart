import 'package:flutter/material.dart';

import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/cache.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';

class StockEntryForm extends StatefulWidget {
  final String title;
  final ItemTransaction transaction;
  final bool forEdit;
  final String transactionId;

  StockEntryForm(
      {this.transaction, this.title, this.transactionId, this.forEdit});

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
  List<Map> itemNamesAndNicknames = List<Map>();
  bool enableAdvancedFields = false;

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController costPriceController = TextEditingController();
  TextEditingController markedPriceController = TextEditingController();
  TextEditingController duePriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.formName = _forms[1];
    this._currentFormSelected = formName;
    _initializeItemNamesAndNicknamesMapCache();
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
          this.transaction.itemId = null;
          setState(() {
            this.disclaimerText =
                'Orphan Transaction: The item associated with this transaction has been deleted';
          });
        } else {
          this.tempItemId = this.transaction.itemId;
          this.itemNameController.text = '${item.name}';
          this.markedPriceController.text =
              FormUtils.fmtToIntIfPossible(item.markedPrice);
          this.descriptionController.text = this.transaction.description ?? '';
          this.duePriceController.text =
              FormUtils.fmtToIntIfPossible(this.transaction.dueAmount);
          if (this.descriptionController.text.isNotEmpty ||
              this.duePriceController.text.isNotEmpty) {
            this.enableAdvancedFields = true;
          }
        }
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
                    WindowUtils.genAutocompleteTextField(
                        labelText: "Item name",
                        hintText: "Name of item you bought",
                        textStyle: textStyle,
                        controller: itemNameController,
                        getSuggestions: this._getAutoCompleteSuggestions,
                        onChanged: () {
                          return setState(() {
                            this.updateItemName();
                          });
                        },
                        suggestions: this.itemNamesAndNicknames),

                    Visibility(
                      visible: stringUnderName.isNotEmpty,
                      child: Padding(
                          padding: EdgeInsets.all(_minimumPadding),
                          child: Text(this.stringUnderName)),
                    ),

                    // No of items
                    WindowUtils.genTextField(
                      labelText: "Quantity",
                      hintText: "No of items",
                      textStyle: textStyle,
                      controller: this.itemNumberController,
                      keyboardType: TextInputType.number,
                      validator: (String value, String labelText) {
                        if (value == '0.0' || value == '0' || value.isEmpty) {
                          return '';
                        }
                      },
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
                      hintText: "Price per item",
                      textStyle: textStyle,
                      controller: this.markedPriceController,
                      keyboardType: TextInputType.number,
                      onChanged: () {},
                    ),

                    // Checkbox
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Checkbox(
                            onChanged: (value) {
                              setState(() => this.enableAdvancedFields = value);
                            },
                            value: this.enableAdvancedFields),
                        Text(
                          "Show advanced fields",
                          style: textStyle,
                        ),
                      ],
                    ),

                    // Unpaid price
                    Visibility(
                        visible: this.enableAdvancedFields,
                        child: WindowUtils.genTextField(
                            labelText: "Unpaid amount",
                            hintText: "Amount remaining to be collected",
                            textStyle: textStyle,
                            controller: this.duePriceController,
                            keyboardType: TextInputType.number,
                            onChanged: this.updateDuePrice,
                            validator: (value, labelText) {})),

                    // Description
                    Visibility(
                        visible: this.enableAdvancedFields,
                        child: WindowUtils.genTextField(
                            labelText: "Description",
                            hintText: "Any notes for this transaction",
                            textStyle: textStyle,
                            maxLines: 3,
                            controller: this.descriptionController,
                            validator: (value, labelText) {},
                            onChanged: () {
                              return setState(() {
                                this.updateTransactionDescription();
                              });
                            })),

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

  void updateDuePrice() {
    this.transaction.dueAmount =
        double.parse(this.duePriceController.text).abs();
  }

  void updateTransactionDescription() {
    this.transaction.description = this.descriptionController.text;
  }

  void clearFieldsAndTransaction() {
    this.itemNameController.text = '';
    this.itemNumberController.text = '';
    this.costPriceController.text = '';
    this.markedPriceController.text = '';
    this.duePriceController.text = '';
    this.descriptionController.text = '';
    this.enableAdvancedFields = false;
    this.transaction = ItemTransaction(1, null, 0.0, 0.0, '');
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
    double netAddition;

    if (this.transaction.id != null && this.transaction.itemId == item.id) {
      // Update case.
      debugPrint("Update case stock entry");
      netAddition = items - this.transaction.items;
    } else {
      netAddition = items;
    }

    this.transaction.itemId = item.id;
    this.transaction.items = items;

    item.costPrice = this.transaction.amount / items;
    item.markedPrice = double.parse(this.markedPriceController.text).abs();
    item.increaseStock(netAddition);

    bool success =
        await FormUtils.saveTransactionAndUpdateItem(this.transaction, item);

    this.saveCallback(success);
  }

  // Delete item data
  void _delete() async {
    Item item =
        await this.databaseHelper.getItem("id", this.transaction.itemId);

    if (this.transaction.id == null) {
      // Case 1: Abandon new item creation
      this.clearFieldsAndTransaction();
      WindowUtils.showAlertDialog(context, "Status", 'Item not created');
      return;
    } else {
      // Case 2: Delete item from database after user confirms again
      WindowUtils.showAlertDialog(context, "Delete?",
          "This action is very dangerous and you may lose vital information. Delete?",
          onPressed: (buildContext) {
        FormUtils.deleteTransactionAndUpdateItem(
            this.saveCallback, this.transaction, item);
      });
    }
  }

  void saveCallback(bool success) {
    if (success) {
      this.clearFieldsAndTransaction();
      if (this.widget.forEdit ?? false) {
        WindowUtils.moveToLastScreen(this.context, modified: true);
      }

      // Success
      refreshItemTransactionMapCache();
      WindowUtils.showAlertDialog(
          this.context, "Status", 'Stock updated successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(
          this.context, 'Failed!', 'Problem updating stock, try again!');
    }
  }

  void refreshItemTransactionMapCache() async {
    // refresh item transaction map cache since transaction is changed.
    await StartupCache(reload: true).itemTransactionMap;
  }

  void _initializeItemNamesAndNicknamesMapCache() async {
    Map itemMap = await StartupCache().itemMap;
    List<Map> cacheItemAndNickNames = List<Map>();
    if (itemMap.isNotEmpty) {
      itemMap.forEach((key, value) {
        Map nameNickNameMap = {'name': value.first, 'nickName': value.last};
        cacheItemAndNickNames.add(nameNickNameMap);
      });
    }
    debugPrint("Ok list of items and nicKnames $cacheItemAndNickNames");
    setState(() {
      this.itemNamesAndNicknames = cacheItemAndNickNames;
    });
  }

  List<Map> _getAutoCompleteSuggestions() {
    // A way for autocomplete generator to access the itemNamesAndNicknames proprety of this class
    // Sometimes at the start of program empty suggestions gets passed and there is no way to update that.
    return this.itemNamesAndNicknames;
  }
}
