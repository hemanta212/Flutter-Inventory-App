import 'package:flutter/material.dart';
import 'package:bk_app/utils/window.dart';
import 'package:bk_app/utils/scaffold.dart';
import 'package:bk_app/app/forms.dart';
import 'package:bk_app/models/item.dart';

class MainForm extends StatefulWidget {
  final String title;
  final String formType;
  var obj;

  MainForm({this.title, this.formType, this.obj});

  @override
  State<StatefulWidget> createState() {
    return _MainFormState(this.title, this.formType, this.obj);
  }

}

class _MainFormState extends State<MainForm>{

  // Variables
  String title;
  String _currentFormSelected;
  var obj;

  _MainFormState(this.title, this._currentFormSelected, this.obj);

  var _formKey = GlobalKey<FormState>();
  final double _minimumPadding = 5.0;

  List<String> _forms = ['Sales Entry', 'Stock Entry', 'Item Entry'];
  var displayResult = '';

  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemNumberController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();

  Form Function() getForm;

  @override
  void initState() {
    super.initState();
    if (_currentFormSelected == null){
      _currentFormSelected = _forms[0];
    }
    if (obj == null){
      obj = new Item('');
    }
  }


  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    if (getForm == null){
      _dropDownItemSelected(this._currentFormSelected);
    }

    Widget buildBody() {
      return ListView(
        children: <Widget>[

          DropdownButton<String>(
            items: _forms.map( (String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Text(dropDownStringItem),
                ); // DropdownMenuItem
            }).toList(),

            onChanged: (String newValueSelected){
              _dropDownItemSelected(newValueSelected);
            }, //onChanged

            value: _currentFormSelected,
          ), // DropdownButton

          this.getForm(),
        ]
      );
    }

    return CustomScaffold.setScaffold(context, widget.title, buildBody);
  }

  void _dropDownItemSelected(String newValueSelected) {

    Map _stringToForm = {
      'Item Entry': ItemForm(context, this.obj),
      'Stock Entry': ItemEntryForm(context, this.obj),
      'Sales Entry': SalesForm(context, this.obj),
    };

    setState( () {
        this.getForm = _stringToForm[newValueSelected].genForm;
        this.title = newValueSelected;
        this._currentFormSelected = newValueSelected;
    }); // setState
  }

}
