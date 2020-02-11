import 'package:flutter/material.dart';
import 'package:bk_app/app/itementryform.dart';
import 'package:bk_app/app/salesentryform.dart';
import 'package:bk_app/app/stockentryform.dart';

class WindowUtils {
  static void dropDownItemSelected(BuildContext context,
      {String caller, String target}) async {
    Map _stringToForm = {
      'Item Entry': ItemEntryForm(title: target),
      'Sales Entry': SalesEntryForm(title: target),
      'Stock Entry': StockEntryForm(title: target),
    };

    if (caller == target) {
      return;
    }

    var getForm = _stringToForm[target];
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return getForm;
    }));
  }

  static void moveToLastScreen(BuildContext context, {bool modified = false}) {
    debugPrint("I am called. Going back screen");
    Navigator.pop(context, modified);
  }

  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  static void showAlertDialog(
      BuildContext context, String title, String message,
      {onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text(
            title,
          ),
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: new Text(
              message,
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text(
                "OK",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                moveToLastScreen(context);
                if (onPressed != null) {
                  onPressed(context);
                }
              },
              color: Theme.of(context).accentColor,
            ),
          ],
        );
      },
    );
  }

  static String formValidator(String value, String labelText) {
    if (value.isEmpty) {
      return "Please enter $labelText";
    }
  }

  static Widget genTextField(
      {String labelText,
      String hintText,
      TextStyle textStyle,
      TextEditingController controller,
      TextInputType keyboardType = TextInputType.text,
      var onChanged,
      var validator = formValidator,
      bool enabled = true}) {
    final double _minimumPadding = 5.0;

    return Padding(
      padding: EdgeInsets.only(top: _minimumPadding, bottom: _minimumPadding),
      child: TextFormField(
        enabled: enabled,
        keyboardType: keyboardType,
        style: textStyle,
        controller: controller,
        validator: (String value) {
          return validator(value, labelText);
        },
        onChanged: (value) {
          onChanged();
        },
        decoration: InputDecoration(
            labelText: labelText,
            labelStyle: textStyle,
            hintText: hintText,
            errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
      ), // Textfield
    );
  } // genTextField function

  static Widget genButton(BuildContext context, String name, var onPressed) {
    return Expanded(
        child: RaisedButton(
            color: Theme.of(context).accentColor,
            textColor: Colors.white, // Theme.of(context).primaryColorLight,
            child: Text(name, textScaleFactor: 1.5),
            onPressed: onPressed) // RaisedButton Calculate
        ); //Expanded
  }
}
