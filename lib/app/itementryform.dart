import 'package:flutter/material.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/utils/form.dart';

class ItemEntryForm extends StatefulWidget {
  final String title;
  final Item item;
  final bool forEdit;

  ItemEntryForm({this.item, this.title, this.forEdit});

  @override
  State<StatefulWidget> createState() {
    return _ItemEntryFormState(this.item, this.title);
  }
}

class _ItemEntryFormState extends State<ItemEntryForm> {
  // Variables
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;
  DbHelper databaseHelper = DbHelper();

  String title;
  Item item;

  _ItemEntryFormState(this.item, this.title);

  List<String> _forms = ['Sales Entry', 'Stock Entry', 'Item Entry'];
  String formName;
  String stringUnderName = '';
  String stringUnderNickName = '';
  String _currentFormSelected;

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNickNameController = TextEditingController();
  TextEditingController markedPriceController = TextEditingController();
  TextEditingController totalStockController = TextEditingController();

  @override
  void initState() {
    super.initState();
    this.formName = _forms[2];
    this._currentFormSelected = formName;
    _initiateItemData();
  }

  void _initiateItemData() {
    if (this.item == null) {
      this.item = Item('');
    }

    if (this.item.id != null) {
      this.itemNameController.text = '${item.name}';
      this.itemNickNameController.text = '${item.nickName ?? ''}';
      this.markedPriceController.text =
          FormUtils.fmtToIntIfPossible(this.item.markedPrice);
      if (this.item.totalStock != 0) {
        this.totalStockController.text =
            FormUtils.fmtToIntIfPossible(this.item.totalStock);
      }
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
                        visible: stringUnderName.isNotEmpty,
                        child: Padding(
                          padding: EdgeInsets.all(_minimumPadding),
                          child: Text(this.stringUnderName),
                        )),

                    // Nick name
                    WindowUtils.genTextField(
                        labelText: "Nick name (id)",
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
    Future<Item> duplicate = this.databaseHelper.getItem("name", givenName);
    duplicate.then((value) {
      // Don't show the error while updating the item.
      if (value != null && this.item.id != value.id) {
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

  void updateItemNickName() {
    String givenNickName = this.itemNickNameController.text;
    Future<Item> duplicate =
        this.databaseHelper.getItem('nick_name', givenNickName);
    duplicate.then((value) {
      // Don't show the error while updating the item.
      if (value != null && this.item.id != value.id) {
        this.stringUnderNickName = 'Nick name already registered';
      } else {
        this.stringUnderNickName = '';
        this.item.nickName = givenNickName;
      }
    });
  }

  void clearTextFields() {
    this.itemNameController.text = '';
    this.itemNickNameController.text = '';
    this.markedPriceController.text = '';
  }

  void checkAndSave() {
    if (this._formKey.currentState.validate()) {
      this._save();
    }
  }

  // Save data to database
  void _save() async {
    int result;
    String message;

    if (this.item.name == '' || this.stringUnderNickName != '') {
      // item name is set to '' if its duplicate in above function updateIteName
      message = "Name or Nick name already registered";
      WindowUtils.showAlertDialog(this.context, 'Failed!', message);
      return;
    }

    try {
      if (this.item.id != null) {
        // Case 1: Update operation
        debugPrint("Updated item");
        result = await this.databaseHelper.updateItem(this.item);
      } else {
        // Case 2: Insert operation
        result = await this.databaseHelper.insertItem(this.item);
      }
    } catch (e) {
      message = 'Problem saving item, try again!';
    }

    if (message == null && result != 0) {
      if (widget.forEdit ?? false) {
        WindowUtils.moveToLastScreen(context, modified: true);
      }

      // Success
      this.clearTextFields();
      message = 'Item saved successfully';
    }

    WindowUtils.showAlertDialog(this.context, 'Status', message);
  }

  // Delete item data
  void _delete() async {
    if (widget.forEdit ?? false) {
      WindowUtils.moveToLastScreen(context, modified: true);
    }

    this.clearTextFields();

    if (this.item.id == null) {
      // Case 1: Abandon new item creation
      WindowUtils.showAlertDialog(this.context, 'Status', 'Item not created');
      return;
    }

    // Case 2: Delete item from database
    int result = await this.databaseHelper.deleteItem(this.item.id);

    if (result != 0) {
      // Success
      WindowUtils.showAlertDialog(
          this.context, 'Status', 'Item deleted successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(
          this.context, 'Status', 'Problem deleting item, try again!');
    }
  }
}
