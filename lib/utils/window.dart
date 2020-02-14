import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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
      int maxLines = 1,
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
        maxLines: maxLines,
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

  static Widget genAutocompleteTextField(
      {String labelText,
      String hintText,
      TextStyle textStyle,
      TextEditingController controller,
      TextInputType keyboardType = TextInputType.text,
      BuildContext context,
      List<Map> suggestions,
      bool enabled,
      var validator = formValidator,
      var onChanged}) {
    debugPrint("got suggestions $suggestions");
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        enabled: enabled,
        autofocus: true,
        style: textStyle,
        controller: controller,
        decoration: InputDecoration(
            labelText: labelText,
            labelStyle: textStyle,
            hintText: hintText,
            errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15.0),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
      ),
      validator: (String value) {
        return validator(value, labelText);
      },
      suggestionsCallback: (givenString) {
        return suggestions?.where((Map map) {
              String itemName = map['name'].toLowerCase();
              String itemNickName = map['nickName']?.toLowerCase() ?? '';

              // Take the user given string and construct a simple regexPattern to do fuzzy search
              // Word like "zam" will be turned ".*z.*a.*m.*" its matching on name & nickname is done.
              List<String> strsWithWildCards = "$givenString"
                  .split("")
                  .map((letter) => ".*$letter")
                  .toList(); // Makes "zam" -> ".*z.*a.*m"
              strsWithWildCards.add('.*'); // ".*z.*a.*m" -> ".*z.*a.*m.*"
              String regexPattern = strsWithWildCards.join('');
              regexPattern = regexPattern.replaceAll(r"\", r"\\");
              debugPrint("escaped regexPattern $regexPattern");

              RegExp regExp = new RegExp(
                "$regexPattern",
                caseSensitive: false,
                multiLine: false,
              );

              return regExp.hasMatch("$itemName") ||
                  regExp.hasMatch("$itemNickName");
            }) ??
            suggestions;
      },
      itemBuilder: (context, suggestion) {
        return Container(
            padding: EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  suggestion['name'],
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(width: 10),
                Text(
                  suggestion['nickName'] ?? '',
                ),
              ],
            ));
      },
      onSuggestionSelected: (suggestion) {
        controller.text = suggestion['name'];
        onChanged();
      },
    );
  }

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
