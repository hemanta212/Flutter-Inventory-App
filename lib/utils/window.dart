import 'package:flutter/material.dart';

class WindowUtils {

  static void moveToLastScreen(BuildContext context) {
    Navigator.pop(context, true);
  }


  static void showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }


  static void showAlertDialog(
    BuildContext context,
    String title,
    String message
  ) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
      context: context,
      builder: (_) => alertDialog,
    );
  }

  static String formValidator(String value, String labelText){
    if (value.isEmpty) {
      return "Please enter $labelText";
    }
  }

  static Widget genTextField({
     String labelText,
     String hintText,
     TextStyle textStyle,
     TextEditingController controller,
     TextInputType keyboardType = TextInputType.text,
     var onChanged,
     var validator = formValidator
  }) {

    final double _minimumPadding = 5.0;

    return Padding(
      padding: EdgeInsets.only(top:_minimumPadding, bottom:_minimumPadding),
      child: TextFormField(
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

  static Widget genButton(BuildContext context, String name, var onPressed){
    return Expanded(
      child: RaisedButton(
        color: Theme.of(context).accentColor,
        child: Text(name, textScaleFactor: 1.5),
        onPressed: onPressed
      ) // RaisedButton Calculate
    ); //Expanded
  }

}
