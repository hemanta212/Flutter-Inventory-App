import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bk_app/models/item.dart';
import 'package:bk_app/utils/dbhelper.dart';
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
    super.initState();
  }

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNickNameController = TextEditingController();
  TextEditingController wholeSellerNameController = TextEditingController();


  @override
  Widget build(BuildContext context){

    TextStyle textStyle = Theme.of(context).textTheme.title;

    itemNameController.text = item.name;
    itemNickNameController.text = item.nickName;

    return WillPopScope (
      onWillPop: () {
        // When user presses the back button write some code to control
        moveToLastScreen();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              moveToLastScreen();
            }
          )
        ),// AppBar

      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(_minimumPadding * 2),
          child: ListView(
            children: <Widget>[

              // Item name
              genTextField(
                labelText: "Item name",
                hintText: "Name of item you sold",
                textStyle: textStyle,
                controller: itemNameController,
                onChanged: updateItemName
              ),

              // Nick name
              genTextField(
                labelText: "Nick name (id)",
                textStyle: textStyle,
                controller: itemNickNameController,
                onChanged: updateItemNickName
              ),

              // Wholeseller name: They are separate entity of their own with properties like name, number, location, etc
              genTextField(
                labelText: "Wholeseller name",
                textStyle: textStyle,
                controller: wholeSellerNameController,
                onChanged: updateWholeSellerName
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
                      textColor: Theme.of(context).primaryColorDark,
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
          ) //Column
        ) // Padding
      ) // Container
    ) // Scaffold
  );

}

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  Widget genTextField({String labelText, String hintText, TextStyle textStyle, TextEditingController controller, TextInputType keyboardType = TextInputType.text, var onChanged} ) {
    return Padding(
      padding: EdgeInsets.only(top:_minimumPadding, bottom:_minimumPadding),
      child: TextFormField(
        keyboardType: keyboardType,
        style: textStyle,
        controller: controller,
        validator: (String value) {
          if (value.isEmpty) {
            return "Please enter $labelText";
          }
        },
        onChanged: (value) {
          onChanged();
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: textStyle,
          hintText: hintText,
          errorStyle: TextStyle(
            color: Colors.yellowAccent,
            fontSize: 15.0
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0)
          )
        ),
      ), // Textfield
    );
  } // genTextField function

  // Update the title of the Item obj
  void updateItemName() {
    item.name = itemNameController.text;
  }

  // Update the description of the Item obj
  void updateItemNickName() {
    item.nickName = itemNickNameController.text;
  }

  // Update the description of the Item obj
  void updateWholeSellerName() {
    debugPrint("wholeseller name changed");
  }


  // Save data to database
  void _save() async {
    moveToLastScreen();

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
      _showAlertDialog('Status', 'Item saved successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem saving item, try again!');
    }
  }

  // Delete item data
  void _delete() async {
    moveToLastScreen();
    if (item.id == null) {
      // Case 1: Abandon new item creation
      _showAlertDialog('Status', 'Item not created');
      return;
    }

    // Case 2: Delete item from database
    int result = await databaseHelper.deleteItem(item.id);


    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Item deleted successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem deleting item, try again!');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }
}
