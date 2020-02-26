import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:bk_app/app/wrapper.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';
import 'package:bk_app/utils/cache.dart';
import 'package:bk_app/services/crud.dart';
import 'package:bk_app/models/user.dart';

class ItemEntryForm extends StatefulWidget {
  final String title;
  final Item item;
  final bool forEdit;
  final String itemId;

  ItemEntryForm({this.item, this.title, this.itemId, this.forEdit});

  @override
  State<StatefulWidget> createState() {
    return _ItemEntryFormState(this.item, this.itemId, this.title);
  }
}

class _ItemEntryFormState extends State<ItemEntryForm> {
  // Variables
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;
  static CrudHelper crudHelper;
  static UserData userData;

  String title;
  Item item;
  String itemId;

  _ItemEntryFormState(this.item, this.itemId, this.title);

  List<String> _forms = ['Sales Entry', 'Stock Entry', 'Item Entry'];
  String formName;
  String stringUnderName = '';
  String stringUnderNickName = '';
  String _currentFormSelected;

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNickNameController = TextEditingController();
  TextEditingController markedPriceController = TextEditingController();
  TextEditingController totalStockController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    this.formName = _forms[2];
    this._currentFormSelected = formName;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    userData = Provider.of<UserData>(context);
    if (userData != null) {
      crudHelper = CrudHelper(userData: userData);
      _initiateItemData();
    }
  }

  void _initiateItemData() {
    if (this.item == null) {
      this.item = Item('');
    }

    if (this.itemId != null) {
      this.itemNameController.text = '${item.name}';
      this.itemNickNameController.text = '${item.nickName ?? ''}';
      this.markedPriceController.text =
          FormUtils.fmtToIntIfPossible(this.item.markedPrice);
      if (this.item.totalStock != 0) {
        this.totalStockController.text =
            FormUtils.fmtToIntIfPossible(this.item.totalStock);
      }
      this.descriptionController.text = this.item.description ?? '';
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
                    // Item name
                    WindowUtils.genTextField(
                        labelText: "Item name",
                        hintText: "Name of the new item",
                        textStyle: textStyle,
                        controller: this.itemNameController,
                        onChanged: () {
                          return setState(() {
                            this.updateItemName();
                          });
                        }),

                    Visibility(
                        visible: stringUnderName.isNotEmpty,
                        child: Padding(
                          padding: EdgeInsets.all(_minimumPadding),
                          child: Text(this.stringUnderName),
                        )),

                    // Nick name
                    WindowUtils.genTextField(
                        labelText: "Nick name (id)",
                        hintText: "Short & unique [optional]",
                        textStyle: textStyle,
                        controller: this.itemNickNameController,
                        onChanged: () {
                          return setState(() {
                            this.updateItemNickName();
                          });
                        },
                        validator: (value, labelText) {}),

                    Visibility(
                        visible: stringUnderNickName.isNotEmpty,
                        child: Padding(
                          padding: EdgeInsets.all(_minimumPadding),
                          child: Text(this.stringUnderNickName),
                        )),

                    // Marked Price of item
                    Visibility(
                        visible: this.item.markedPrice?.isFinite ??
                            false, // defaults to false if MP is null
                        child: WindowUtils.genTextField(
                          labelText: "Marked price",
                          hintText: "Expected selling price",
                          textStyle: textStyle,
                          controller: this.markedPriceController,
                          keyboardType: TextInputType.number,
                          onChanged: this.updateMarkedPrice,
                        )),

                    // Marked Price of item
                    Visibility(
                        visible: this.totalStockController.text.isNotEmpty,
                        child: WindowUtils.genTextField(
                          labelText: "Total Stock",
                          textStyle: textStyle,
                          controller: this.totalStockController,
                          enabled: false,
                          onChanged: () {},
                        )),

                    // TODO
                    /* Provide user to define Big unit terms like
                      1 box = 15 items
                      1 cartoon = 5 box
                    */

                    // Item Description
                    WindowUtils.genTextField(
                        labelText: "Description",
                        hintText:
                            "Any notes for this item \nLike its location, wholeseller\nor anything you'd like to remember",
                        textStyle: textStyle,
                        maxLines: 3,
                        controller: this.descriptionController,
                        validator: (value, labelText) {},
                        onChanged: () {
                          return setState(() {
                            this.updateItemDescription();
                          });
                        }),

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

                        ), // Padding
                  ] // Column widget list
                      ) //List view
                  ) // Padding
              ))
    ]); // form
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Wrapper();
    }
    return WillPopScope(
      onWillPop: () {
        // When user presses the back button write some code to control
        WindowUtils.moveToLastScreen(context);
      },
      child: CustomScaffold.setScaffold(context, title, buildForm),
    );
  }

  // Update the title of the Item obj
  void updateItemName() {
    String givenName = this.itemNameController.text;
    Future<DocumentSnapshot> duplicate = crudHelper.getItem('name', givenName);
    duplicate.then((value) {
      // Don't show the error while updating the item.
      if (value != null && this.itemId != value.documentID) {
        this.stringUnderName = 'Name already registered';
        this.item.name = '';
      } else {
        this.stringUnderName = '';
        this.item.name = givenName;
      }
    });
  }

  void updateMarkedPrice() {
    this.item.markedPrice = double.parse(this.markedPriceController.text);
  }

  void updateItemDescription() {
    this.item.description = this.descriptionController.text;
  }

  void updateItemNickName() {
    String givenNickName = this.itemNickNameController.text;
    Future<DocumentSnapshot> duplicate =
        crudHelper.getItem('nick_name', givenNickName);
    duplicate.then((value) {
      // Don't show the error while updating the item.
      if (value != null && this.itemId != value.documentID) {
        this.stringUnderNickName = 'Nick name already registered';
      } else {
        this.stringUnderNickName = '';
        this.item.nickName = givenNickName;
      }
    });
  }

  void clearFieldsAndItem() {
    this.itemNameController.text = '';
    this.itemNickNameController.text = '';
    this.markedPriceController.text = '';
    this.item = Item('');
  }

  void checkAndSave() {
    if (this._formKey.currentState.validate()) {
      this._save();
    }
  }

  // Save data to database
  void _save() async {
    String message;

    if (!FormUtils.isDatabaseOwner(userData)) {
      message = "Permission Denied";
    }

    if (this.item.name == '' || this.stringUnderNickName != '') {
      // item name is set to '' if its duplicate in above function updateIteName
      message = "Name or Nick name already registered";
      WindowUtils.showAlertDialog(this.context, 'Failed!', message);
      return;
    }

    try {
      if (this.itemId != null) {
        // Case 1: Update operation
        debugPrint("Updated item");
        this.item.used += 1;
        crudHelper.updateItem(this.itemId, this.item);
      } else {
        // Case 2: Insert operation
        crudHelper.addItem(this.item);
      }
    } catch (e) {
      message = 'Problem saving item, try again!';
    }

    if (message == null) {
      // Success
      if (this.widget.forEdit ?? false) {
        WindowUtils.moveToLastScreen(context, modified: true);
      }

      this.clearFieldsAndItem();
      message = 'Item saved successfully';
      refreshItemMapCache();
      debugPrint("item saved but here is ${this.itemNickNameController.text}");
    }
    WindowUtils.showAlertDialog(this.context, 'Status', message);
  }

  // Delete item data
  void _delete() async {
    if (this.itemId == null) {
      // Case 1: Abandon new item creation
      if (this.widget.forEdit ?? false) {
        WindowUtils.moveToLastScreen(context, modified: true);
      }

      this.clearFieldsAndItem();
      WindowUtils.showAlertDialog(this.context, 'Status', 'Item not created');
      return;
    } else {
      // Case 2: Delete item from database after user confirms again
      WindowUtils.showAlertDialog(context, "Delete?",
          "This will delete all associated transactions also. You may want to migrate transaction under another item before proceeding Delete?",
          onPressed: (buildContext) {
        _deleteItemFromDb();
      });
    }
  }

  void _deleteItemFromDb() async {
    // Case 2: Delete item from database
    if (!FormUtils.isDatabaseOwner(userData)) {
      WindowUtils.showAlertDialog(
          this.context, 'Failed!', 'Permission denied!');
      return;
    }

    crudHelper.deleteItem(this.itemId);

    if (this.widget.forEdit ?? false) {
      WindowUtils.moveToLastScreen(context, modified: true);
    }
    refreshItemMapCache();
    this.clearFieldsAndItem();
    WindowUtils.showAlertDialog(
        this.context, 'Status', 'Item deleted successfully');
  }

  void refreshItemMapCache() async {
    // refresh item map cache since item is changed.
    await StartupCache(userData: userData, reload: true).itemMap;
  }
}
