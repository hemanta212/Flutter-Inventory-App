import 'package:bk_app/models/user.dart';
import 'package:flutter/material.dart';

import 'package:bk_app/app/wrapper.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/services/crud.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/cache.dart';
import 'package:bk_app/utils/loading.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';
import 'package:provider/provider.dart';

class SalesEntryForm extends StatefulWidget {
  final String title;
  final String transactionId;
  final ItemTransaction transaction;
  final bool forEdit;
  // When an item is right swiped from itemList a quick sales form is presented
  // This form obiously shouldNot have itemName field so the itemList will pass
  // the name of item to this form
  final Item swipeData;

  SalesEntryForm(
      {this.title,
      this.transaction,
      this.transactionId,
      this.forEdit,
      this.swipeData});

  @override
  State<StatefulWidget> createState() {
    return _SalesEntryFormState(
        this.title, this.transactionId, this.transaction);
  }
}

class _SalesEntryFormState extends State<SalesEntryForm> {
  // Variables
  String title;
  String transactionId;
  ItemTransaction transaction;
  _SalesEntryFormState(this.title, this.transactionId, this.transaction);

  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;
  List<String> _forms = ['Sales Entry', 'Stock Entry', 'Item Entry'];
  String formName;
  String _currentFormSelected;

  static CrudHelper crudHelper;
  static UserData userData;
  List<Map> itemNamesAndNicknames = List<Map>();
  String disclaimerText = '';
  String stringUnderName = '';
  String tempItemId;
  bool enableAdvancedFields = false;

  List units = List();
  String selectedUnit = '';
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();
  TextEditingController duePriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController costPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.formName = _forms[0];
    this._currentFormSelected = this.formName;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    if (userData != null) {
      crudHelper = CrudHelper(userData: userData);
      _initiateTransactionData();
      _initializeItemNamesAndNicknamesMapCache();
    } else {
      Loading();
    }
  }

  void _initiateTransactionData() {
    if (this.transaction == null) {
      debugPrint("Building own transaction obj");
      this.transaction = ItemTransaction(0, null, 0.0, 0.0, '');
    }
    if (this.widget.swipeData != null) {
      Item item = this.widget.swipeData;
      this.units = item.units?.keys?.toList() ?? List();
      if (this.units.isNotEmpty) {
        this.units.add('');
      }
    }

    if (this.transactionId != null) {
      debugPrint("Getting transaction obj");
      this.itemNumberController.text =
          FormUtils.fmtToIntIfPossible(this.transaction.items);
      this.sellingPriceController.text =
          FormUtils.fmtToIntIfPossible(this.transaction.amount);
      this.costPriceController.text =
          FormUtils.fmtToIntIfPossible(this.transaction.costPrice);
      this.descriptionController.text = this.transaction.description ?? '';
      this.duePriceController.text =
          FormUtils.fmtToIntIfPossible(this.transaction.dueAmount);
      if (this.descriptionController.text.isNotEmpty ||
          this.duePriceController.text.isNotEmpty) {
        setState(() {
          this.enableAdvancedFields = true;
        });
      }

      Future<Item> itemFuture = crudHelper.getItemById(
        this.transaction.itemId,
      );
      itemFuture.then((item) {
        if (item == null) {
          setState(() {
            this.disclaimerText =
                'Orphan Transaction: The item associated with this transaction has been deleted';
          });
        } else {
          debugPrint("hi this item is $item");
          this.itemNameController.text = '${item.name}';
          this.tempItemId = item.id;
          this._addUnitsIfPresent(item);
        }
      });
    }
  }

  Widget buildForm(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    debugPrint("making build form");
    return Column(children: <Widget>[
      DropdownButton<String>(
        items: _forms.map((String dropDownStringItem) {
          return DropdownMenuItem<String>(
            value: dropDownStringItem,
            child: Text(dropDownStringItem),
          ); // DropdownMenuItem
        }).toList(),

        onChanged: (String newValueSelected) {
          WindowUtils.navigateToPage(context,
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

                    Row(children: <Widget>[
                      // No of items
                      Expanded(
                        flex: 2,
                        child: WindowUtils.genTextField(
                            labelText: "Quantity",
                            hintText: "No of items sold",
                            textStyle: textStyle,
                            controller: this.itemNumberController,
                            keyboardType: TextInputType.number,
                            validator: (String value, String labelText) {
                              if (value == '0.0' ||
                                  value == '0' ||
                                  value.isEmpty) {
                                return "$labelText is empty or zero";
                              } else {
                                return null;
                              }
                            },
                            onChanged: () {}),
                      ),
                      Visibility(
                          visible: this.units.isNotEmpty,
                          child: Padding(
                              padding: EdgeInsets.only(right: 5.0, left: 10.0),
                              child: DropdownButton<String>(
                                items: this.units.map((dropDownStringItem) {
                                  return DropdownMenuItem<String>(
                                    value: dropDownStringItem,
                                    child: Text(dropDownStringItem),
                                  ); // DropdownMenuItem
                                }).toList(),

                                onChanged: (String newValueSelected) {
                                  setState(() {
                                    this.selectedUnit = newValueSelected;
                                  });
                                }, //onChanged

                                value: this.selectedUnit,
                              ))), // DropdownButton
                    ]),

                    // Selling price
                    WindowUtils.genTextField(
                      labelText: "Total selling price",
                      textStyle: textStyle,
                      controller: this.sellingPriceController,
                      keyboardType: TextInputType.number,
                      onChanged: this.updateSellingPrice,
                    ),

                    // Cost price
                    Visibility(
                        visible:
                            this.transaction.costPrice == null ? false : true,
                        child: WindowUtils.genTextField(
                          labelText: "Cost price",
                          hintText: "Cost price per item",
                          textStyle: textStyle,
                          controller: this.costPriceController,
                          keyboardType: TextInputType.number,
                          onChanged: this.updateCostPrice,
                        )),

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
    if (userData == null) {
      return Wrapper();
    }
    return CustomScaffold.setScaffold(context, title, buildForm);
  }

  void updateSellingPrice() {
    this.transaction.amount =
        double.parse(this.sellingPriceController.text).abs();
  }

  void updateCostPrice() {
    this.transaction.costPrice =
        double.parse(this.costPriceController.text).abs();
  }

  void updateDuePrice() {
    double amount = 0.0;
    if (this.duePriceController.text.isNotEmpty) {
      amount = double.parse(this.duePriceController.text).abs();
    }
    this.transaction.dueAmount = amount;
    debugPrint("Updated the due price to ${this.transaction.dueAmount}");
  }

  void updateTransactionDescription() {
    this.transaction.description = this.descriptionController.text;
  }

  void updateItemName() {
    var name = this.itemNameController.text;
    Future<Item> itemFuture = crudHelper.getItem(
      "name",
      name,
    );
    itemFuture.then((item) {
      if (item == null) {
        this.stringUnderName = 'Unregistered name';
        this.tempItemId = null;
        setState(() => this.units = List());
      } else {
        this.stringUnderName = '';
        this.tempItemId = item.id;
        setState(() => this._addUnitsIfPresent(item));
      }
    }, onError: (e) {
      debugPrint('UpdateitemName Error::  $e');
    });
  }

  void clearFieldsAndTransaction() {
    this.itemNameController.text = '';
    this.itemNumberController.text = '';
    this.sellingPriceController.text = '';
    this.costPriceController.text = '';
    this.descriptionController.text = '';
    this.duePriceController.text = '';
    this.enableAdvancedFields = false;
    this.units = List();
    this.selectedUnit = '';
    this.transaction = ItemTransaction(0, null, 0.0, 0.0, '');
  }

  void _addUnitsIfPresent(item) {
    if (item.units != null) {
      this.units = item.units.keys.toList();
      this.units.add('');
    } else {
      this.units = List();
    }
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
    void _alertFail(message) {
      WindowUtils.showAlertDialog(context, "Failed!", message);
    }

    Item item;
    if (this.widget.swipeData != null) {
      debugPrint("Using swipeData to save");
      item = this.widget.swipeData;
    } else {
      item = await crudHelper
          .getItemById(
        this.tempItemId,
      )
          .catchError((e) {
        return null;
      });
    }

    debugPrint("Saving sales item is $item");
    if (item == null) {
      _alertFail("Item not registered");
      return;
    }

    String itemId = item.id;
    double unitMultiple = 1.0;
    if (this.selectedUnit != '') {
      if (item.units?.containsKey(this.selectedUnit) ?? false) {
        unitMultiple = item.units[this.selectedUnit];
      }
    }
    double items =
        double.parse(this.itemNumberController.text).abs() * unitMultiple;

    // Additional checks.
    if ((this.transactionId == null && this.transaction.itemId != itemId) ||
        _beingApproved()) {
      // Case insert
      if (item.totalStock < items) {
        _alertFail("Empty stock. Cannot sell.");
        return;
      }

      // Cp of transaction is set only once during insert.
      this.transaction.costPrice = item.costPrice;
      item.decreaseStock(items);
    } else {
      // Case update
      debugPrint(
          "updating transaction and this is current stock ${item.totalStock} of ${item.name}");
      double netAddition = items - this.transaction.items;
      if (item.totalStock < netAddition) {
        _alertFail("Empty or insufficient stock.\nCannot sell.");
        return;
      } else {
        item.decreaseStock(netAddition);
      }
    }

    this.transaction.itemId = itemId;
    this.transaction.items = items;

    String message = await FormUtils.saveTransactionAndUpdateItem(
        this.transaction, item, itemId,
        transactionId: this.transactionId, userData: userData);

    this.saveCallback(message);
  }

  bool _beingApproved() {
    // If current user is database owner and trnsaction is not from him he is approving it.
    return FormUtils.isDatabaseOwner(userData) &&
        !FormUtils.isTransactionOwner(userData, this.transaction);
  }

  void _delete() async {
    if (this.transactionId == null) {
      // Case 1: Abandon new item creation
      this.clearFieldsAndTransaction();
      WindowUtils.showAlertDialog(context, "Status", 'Item not created');
      return;
    } else {
      // Initialize the item to reset it.
      Item item = await crudHelper.getItemById(this.transaction.itemId);

      // Case 2: Delete item from database after user confirms again
      WindowUtils.showAlertDialog(context, "Delete?",
          "This action is very dangerous and you may lose vital information. Delete?",
          onPressed: (buildContext) {
        FormUtils.deleteTransactionAndUpdateItem(this.saveCallback,
            this.transaction, this.transactionId, item, userData);

        refreshItemTransactionMapCache();
      });
    }
  }

  void saveCallback(String message) {
    if (message.isEmpty) {
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
      WindowUtils.showAlertDialog(this.context, 'Failed!', message);
    }
  }

  void refreshItemTransactionMapCache() async {
    // refresh item transaction map cache since transaction is changed.
    debugPrint("Refreshing transaction cache");
    await StartupCache(userData: userData, reload: true).itemTransactionMap;
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
