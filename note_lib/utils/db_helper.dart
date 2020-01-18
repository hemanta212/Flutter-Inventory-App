import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:notekeeping_app/models/note.dart';
import 'package:flutter/material.dart';


class DbHelper {

  static DbHelper _dbHelper; // Singleton dbHelper
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'descripton';
  String colPriority = 'priority';
  String colDate = 'date';

  DbHelper._createInstance(); // Named constructor to create instance of DbHelper

  factory DbHelper() {
    if (_dbHelper == null){
      _dbHelper = DbHelper._createInstance(); // This will execute only once, singleton obj
    }
    return _dbHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }


  Future<Database> initializeDatabase() async {
    // Get the directory path for both android and ios to store Database
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // Open/create the db at a given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }


  void _createDb(Database db, int newVersion) async {

    await db.execute('CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }


  // Fetch operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // Insert Operation: insert a note to the database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var noti = note.toMap();
    debugPrint('insert note $noti');
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }


  // Update Operation: Update a note from database
  Future<int> updateNote(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation: delete a note from the database
  Future<int> deleteNote(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  // Get number of note objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the list of map from db and convert to 'Note List ' [List <Note>]
  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    // For loop to creae a 'Note List '  from a 'Map List'
    for (int i=0; i < count; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}
