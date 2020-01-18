import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notekeeping_app/models/note.dart';
import 'package:notekeeping_app/utils/db_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}



class NoteDetailState extends State<NoteDetail> {

  static var _priorities = ['High', 'Low'];

  DbHelper databaseHelper = DbHelper();

  String appBarTitle;
  Note note;


  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(

      onWillPop: () {
          // When user presses the back button write some code to control
          moveToLastScreen();
        },
        child: Scaffold(
          appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    moveToLastScreen();
                  })),
          body: Padding(
              padding: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
              child: ListView(
                children: <Widget>[
                  // First element
                  ListTile(
                      title: DropdownButton(
                    items: _priorities.map((String dropDownStringItem) {
                      return DropdownMenuItem<String>(
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem));
                    }).toList(),
                    style: textStyle,
                    value: getPriorityAsString(note.priority),
                    onChanged: (valueSelectedByUser) {
                      setState(() {
                        debugPrint('User selected $valueSelectedByUser');
                        updatePriorityAsInt(valueSelectedByUser);
                      });
                    },
                  )),

                  // Second element
                  Padding(
                      padding:
                          EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextField(
                        controller: titleController,
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint('Something changed in the title bey');
                          updateNoteTitle();
                        },
                        decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      )),

                  // Third element
                  Padding(
                      padding:
                          EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: TextField(
                        controller: descriptionController,
                        style: textStyle,
                        onChanged: (value) {
                          debugPrint('Something changed in the desc bey');
                          updateNoteDescription();
                        },
                        decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      )),

                  // Fourth element
                  Padding(
                      padding:
                          EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Save',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                debugPrint("save button clicked");
                                _save();
                              });
                            },
                          )),
                          Container(
                            width: 5.0,
                          ),
                          Expanded(
                              child: RaisedButton(
                            color: Theme.of(context).primaryColorDark,
                            textColor: Theme.of(context).primaryColorLight,
                            child: Text(
                              'Delete',
                              textScaleFactor: 1.5,
                            ),
                            onPressed: () {
                              setState(() {
                                debugPrint("delete button clicked");
                                _delete();
                              });
                            },
                          ))
                        ],
                      ))
                ],
              )),
        ));
  } // Build method

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the string priority in form of int to save in db
  void updatePriorityAsInt(String value) {
    if (value == 'High') {
      note.priority = 1;
    } else {
      note.priority = 2;
    }
  }

  // Convert the int priority from db to string to display in ui
  String getPriorityAsString(int priority) {
    String result;
    if (priority == 1) {
      result = _priorities[0]; // High
    } else {
      result = _priorities[1]; // Low
    }
    return result;
  }

  // Update the title of the Note obj
  void updateNoteTitle() {
    note.title = titleController.text;
  }

  // Update the description of the Note obj
  void updateNoteDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {
    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {
      // Case 1: Update operation
      debugPrint("Updated note");
      result = await databaseHelper.updateNote(note);
    } else {
      // Case 2: Insert operation
      result = await databaseHelper.insertNote(note);
    }

    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note saved successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem saving note, try again!');
    }
  }

  // Delete note data
  void _delete() async {
    moveToLastScreen();
    if (note.id == null) {
      // Case 1: Abandon new note creation
      _showAlertDialog('Status', 'Note not created');
      return;
    }

    // Case 2: Delete note from database
    int result = await databaseHelper.deleteNote(note.id);


    if (result != 0) {
      // Success
      _showAlertDialog('Status', 'Note deleted successfully');
    } else {
      // Failure
      _showAlertDialog('Status', 'Problem deleting note, try again!');
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
