import 'package:flutter/material.dart';
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
  static CrudHelper crudHelper;
  static UserData userData;

  String title;
  Item item;

  _ItemEntryFormState(this.item, this.title);

  List<String> _forms = ['Sales Entry', 'Stock Entry', 'Item Entry'];
  String formName;
  String stringUnderName = '';
  String stringUnderNickName = '';
  String _currentFormSelected;

  Map<String, double> units = Map<String, double>();
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

    if (this.item.id != null) {
      this.itemNameController.text = '${item.name}';
      this.itemNickNameController.text = '${item.nickName ?? ''}';
      this.markedPriceController.text = this.item.markedPrice;
      if (this.item.totalStock != 0) {
        this.totalStockController.text =
            FormUtils.fmtToIntIfPossible(this.item.totalStock);
      }
      this.descriptionController.text = this.item.description ?? '';
      // this.units
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
                        visible: this.item.markedPrice?.isNotEmpty ??
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

                    SizedBox(height: 20.0),
                    Row(children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                            child: Text('Custom Units', style: textStyle)),
                      ),
                      RaisedButton(
                          color: Colors.blue[400],
                          child: Text(
                            'Add units',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            setState(() {
                              this.showDialogForUnits();
                            });
                          }),
                    ]),
                    this.showUnitsMapping(),
                    SizedBox(height: 20.0),
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
        return WindowUtils.moveToLastScreen(context);
      },
      child: CustomScaffold.setScaffold(context, title, buildForm),
    );
  }

  // Update the title of the Item obj
  void updateItemName() {
    String givenName = this.itemNameController.text;
    Future<Item> duplicate = crudHelper.getItem('name', givenName);
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
    this.item.markedPrice = this.markedPriceController.text;
  }

  void updateItemDescription() {
    this.item.description = this.descriptionController.text;
  }

  void updateItemNickName() {
    String givenNickName = this.itemNickNameController.text;
    Future<Item> duplicate = crudHelper.getItem('nick_name', givenNickName);
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
      if (this.item.id != null) {
        // Case 1: Update operation
        debugPrint("Updated item");
        this.item.used += 1;
        crudHelper.updateItem(this.item);
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
    if (this.item.id == null) {
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

    crudHelper.deleteItem(this.item.id);

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

  Widget showUnitsMapping() {
    double _minimumPadding = 5.0;
    print("Units ${this.item.units}");
    return this.item.units?.isNotEmpty ?? false
        ? Padding(
            padding: EdgeInsets.only(right: 1.0, left: 1.0),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: this.item.units.keys?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  String name = this.item.units.keys.toList()[index];
                  double quantity = double.parse("${this.item.units[name]}");
                  return Card(
                      elevation: 5.0,
                      child: Row(children: <Widget>[
                        Expanded(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: _minimumPadding * 3,
                                  bottom: _minimumPadding * 3),
                              padding: EdgeInsets.all(_minimumPadding),
                              child: Text(name, softWrap: true),
                            )),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.all(_minimumPadding),
                          child: Text(FormUtils.fmtToIntIfPossible(quantity),
                              softWrap: true),
                        )),
                        GestureDetector(
                            child: Icon(Icons.edit),
                            onTap: () {
                              setState(() {
                                showDialogForUnits(
                                    name: name, quantity: quantity);
                              });
                            }),
                      ]));
                }))
        : SizedBox(width: 20.0);
  }

  void showDialogForUnits({String name, double quantity}) {
    final _unitFormKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              elevation: 5.0,
              title: Text(
                "Add units",
              ),
              content: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                      key: _unitFormKey,
                      child: ListView(children: <Widget>[
                        TextFormField(
                            initialValue: name ?? '',
                            decoration: InputDecoration(
                              labelText: "Unit name",
                            ),
                            onChanged: (val) => setState(() => name = val),
                            validator: (val) {
                              if (val?.isEmpty ?? false) {
                                return "Please fill this field";
                              } else {
                                return null;
                              }
                            }),
                        SizedBox(width: 20.0),
                        TextFormField(
                            initialValue:
                                FormUtils.fmtToIntIfPossible(quantity),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Quantity",
                            ),
                            validator: (val) {
                              if (val?.isEmpty ?? false) {
                                return "Please fill this field";
                              }
                              try {
                                quantity = double.parse(val).abs();
                                return null;
                              } catch (e) {
                                return "Invalid value";
                              }
                            }),
                        SizedBox(width: 20.0),
                        RaisedButton(
                            color: Colors.blue[400],
                            child: Text(
                              'Add',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              if (_unitFormKey.currentState.validate()) {
                                if (this.item.units == null) {
                                  this.item.units = Map();
                                }
                                this.item.units[name] = quantity;
                                print("Updating this item ${this.item.units}");
                                setState(() => Navigator.pop(context));
                              }
                            }),
                        RaisedButton(
                            color: Colors.red[400],
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                            onPressed: () async {
                              if (this.item.units.containsKey(name)) {
                                this.item.units.remove(name);
                              }
                              quantity =
                                  null; // it will be formatted to '' in TextField
                              name = '';
                              setState(() => Navigator.pop(context));
                            }),
                      ]))));
        });
  }
}
