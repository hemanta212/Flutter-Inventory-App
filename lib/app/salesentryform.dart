import 'package:flutter/material.dart';

import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/cache.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';

class SalesEntryForm extends StatefulWidget {
  final String title;
  final ItemTransaction transaction;
  final bool forEdit;
  // When an item is right swiped from itemList a quick sales form is presented
  // This form obiously shouldNot have itemName field so the itemList will pass
  // the name of item to this form
  final Item swipeData;

  SalesEntryForm({this.title, this.transaction, this.forEdit, this.swipeData});

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
  String formName;
  String _currentFormSelected;
  DbHelper databaseHelper = DbHelper();
  List<Map> itemNamesAndNicknames = List<Map>();

  String disclaimerText = '';
  String stringUnderName = '';
  int tempItemId;
  bool enableAdvancedFields = false;

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();
  TextEditingController duePriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.formName = _forms[0];
    _currentFormSelected = this.formName;
    _initializeItemNamesAndNicknamesMapCache();
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
        if (item == null) {
          setState(() {
            this.disclaimerText =
                'Orphan Transaction: The item associated with this transaction has been deleted';
          });
        } else {
          debugPrint("hi this item is $item");
          this.tempItemId = this.transaction.itemId;
          this.itemNameController.text = '${item.name}';
          this.descriptionController.text = transaction.description ?? '';
          this.duePriceController.text =
              FormUtils.fmtToIntIfPossible(this.transaction.dueAmount);
          if (this.descriptionController.text.isNotEmpty ||
              this.duePriceController.text.isNotEmpty) {
            this.enableAdvancedFields = true;
          }
        }
      });
    }

    if (this.widget.swipeData != null) {
      this.tempItemId = this.widget.swipeData.id;
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
                    Visibility(
                      visible: this.widget.swipeData == null ? true : false,
                      child: WindowUtils.genAutocompleteTextField(
                          labelText: "Item name",
                          hintText: "Name of item sold",
                          textStyle: textStyle,
                          controller: itemNameController,
                          getSuggestions: this._getAutoCompleteSuggestions,
                          onChanged: () {
                            return setState(() {
                              this.updateItemName();
                            });
                          },
                          suggestions: this.itemNamesAndNicknames),
                    ),

                    Visibility(
                      visible: stringUnderName.isNotEmpty,
                      child: Padding(
                          padding: EdgeInsets.all(_minimumPadding),
                          child: Text(this.stringUnderName)),
                    ),

                    // No of items
                    WindowUtils.genTextField(
                        labelText: "Quantity",
                        hintText: "No of items sold",
                        textStyle: textStyle,
                        controller: this.itemNumberController,
                        keyboardType: TextInputType.number,
                        onChanged: () {}),

                    // Selling price
                    WindowUtils.genTextField(
                      labelText: "Total selling price",
                      textStyle: textStyle,
                      controller: this.sellingPriceController,
                      keyboardType: TextInputType.number,
                      onChanged: this.updateSellingPrice,
                    ),

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
                            bottom: _minimumPadding * 3,
                            top: 3 * _minimumPadding),
                        child: Row(children: <Widget>[
                          WindowUtils.genButton(
                              context, "Save", this.checkAndSave),
                          Container(
                            width: _minimumPadding,
                          ),
                          WindowUtils.genButton(context, "Delete", this._delete)
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
    this.transaction.amount =
        double.parse(this.sellingPriceController.text).abs();
  }

  void updateDuePrice() {
    this.transaction.dueAmount =
        double.parse(this.duePriceController.text).abs();
  }

  void updateTransactionDescription() {
    this.transaction.description = this.descriptionController.text;
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

  void clearFieldsAndTransaction() {
    this.itemNameController.text = '';
    this.itemNumberController.text = '';
    this.sellingPriceController.text = '';
    this.descriptionController.text = '';
    this.duePriceController.text = '';
    this.enableAdvancedFields = false;
    this.transaction = ItemTransaction(0, null, 0.0, 0.0, '');
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
      WindowUtils.showAlertDialog(context, "Failed!", "Item not registered");
      return;
    }

    double items = double.parse(this.itemNumberController.text).abs();

    // Additional checks.
    if (this.transaction.id == null && this.transaction.itemId != item.id) {
      // Case insert
      if (item.totalStock < items) {
        WindowUtils.showAlertDialog(
            context, "Failed!", "Empty stock. Cannot sell.");
        return;
      } else {
        item.decreaseStock(items);
      }
    } else {
      // Case update
      debugPrint(
          "updating transaction and this is current stock ${item.totalStock} of ${item.name}");
      double netAddition = items - this.transaction.items;
      if (item.totalStock < netAddition) {
        WindowUtils.showAlertDialog(
            context, "Failed!", "Empty or insufficient stock.\nCannot sell.");
        return;
      } else {
        item.decreaseStock(netAddition);
      }
    }

    this.transaction.itemId = item.id;
    this.transaction.items = items;
    this.transaction.costPrice = item.costPrice;

    bool success =
        await FormUtils.saveTransactionAndUpdateItem(this.transaction, item);

    this.saveCallback(success);
  }

  // Delete item data
  void _delete() async {
    // Initialize the item to reset it.
    debugPrint(
        "this id is ${this.transaction.id} item id is ${this.transaction.itemId}");
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
          this.context, "Status", 'Sales updated successfully');
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
