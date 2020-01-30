import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/utils/dbhelper.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:intl/intl.dart';

class ItemForm extends StatefulWidget {
  String title;
  final Item item;

  ItemForm({this.item, this.title});

  @override
  State<StatefulWidget> createState() {
    return _ItemForm(this.item, this.title);
  }

}

class _ItemForm extends State<ItemForm>{

  // Variables
  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;
  DbHelper databaseHelper = DbHelper();

  String title;
  Item item;

  _ItemForm(this.item, this.title);

  @override
  void initState() {
    if (this.item == null){
      this.item = Item('');
    }
    super.initState();
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNickNameController = TextEditingController();


  @override
  Widget build(BuildContext context){

    TextStyle textStyle = Theme.of(context).textTheme.title;

    itemNameController.text = item.name;
    itemNickNameController.text = item.nickName;

    Widget buildForm(){
      return Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(_minimumPadding * 2),
          child: ListView(
            children: <Widget>[

              // Item name
              WindowUtils.genTextField(
                labelText: "Item name",
                hintText: "Name of item you sold",
                textStyle: textStyle,
                controller: itemNameController,
                onChanged: updateItemName
              ),

              // Nick name
              WindowUtils.genTextField(
                labelText: "Nick name (id)",
                textStyle: textStyle,
                controller: itemNickNameController,
                onChanged: updateItemNickName
              ),

              // TODO
              /* Provide user to define Big unit terms like  
              1 box = 15 items
              1 cartoon = 5 box
              */

            // save
            Padding(
              padding: EdgeInsets.only(bottom: _minimumPadding, top:_minimumPadding),
              child: Row(
                children: <Widget>[

                  Expanded(
                    child: RaisedButton(
                      color: Theme.of(context).accentColor,
                      child: Text("Save", textScaleFactor: 1.5),
                      onPressed: () {
                        setState( () {
                          debugPrint("Save button clicked");
                          _save();
                        });
                      }
                    ) // RaisedButton Calculate
                  ), //Expanded

                ]

              ) // Row 2 Submit and reset buttons
            ), // Padding

            ] // Column widget list
          ) //List view
        ) // Padding
      ); // form
   }

   return WillPopScope (
     onWillPop: () {
       // When user presses the back button write some code to control
       WindowUtils.moveToLastScreen(context);
     },
     child: CustomScaffold.setScaffold(
       context, title, buildForm),
   );

 }

  // Update the title of the Item obj
  void updateItemName() {
    item.name = itemNameController.text;
  }

  // Update the description of the Item obj
  void updateItemNickName() {
    item.nickName = itemNickNameController.text;
  }

  // Save data to database
  void _save() async {
    WindowUtils.moveToLastScreen(context);

    // item.date = DateFormat.yMMMd().format(DateTime.now());

    int result;
    if (item.id != null) {
      // Case 1: Update operation
      debugPrint("Updated item");
      result = await databaseHelper.updateItem(item);
    } else {
      // Case 2: Insert operation
      result = await databaseHelper.insertItem(item);
    }

    if (result != 0) {
      // Success
      WindowUtils.showAlertDialog(context, 'Status', 'Item saved successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(context, 'Status', 'Problem saving item, try again!');
    }
  }

  // Delete item data
  void _delete() async {
    WindowUtils.moveToLastScreen(context);
    if (item.id == null) {
      // Case 1: Abandon new item creation
      WindowUtils.showAlertDialog(context, 'Status', 'Item not created');
      return;
    }

    // Case 2: Delete item from database
    int result = await databaseHelper.deleteItem(item.id);


    if (result != 0) {
      // Success
      WindowUtils.showAlertDialog(context, 'Status', 'Item deleted successfully');
    } else {
      // Failure
      WindowUtils.showAlertDialog(context, 'Status', 'Problem deleting item, try again!');
    }
  }

}
