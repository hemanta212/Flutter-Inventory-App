import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:bk_app/models/item.dart';
import 'package:flutter/material.dart';


class DbHelper {

  static DbHelper _dbHelper; // Singleton dbHelper
  static Database _database;

  String itemTable = 'item_table';
  String colId = 'id';
  String colName = 'name';
  String colNickName = 'nick_name';
  String colDescription = 'description';
  String colCostPrice = 'cost_price';
  String colMarkedPrice = 'marked_price';

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
    String path = directory.path + 'items4.db';

    // Open/create the db at a given path
    var itemsDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return itemsDatabase;
  }


  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $itemTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT, $colNickName TEXT, '
        '$colDescription TEXT, $colCostPrice REAL, $colMarkedPrice REAL)');
  }


  // Fetch operation: Get all item objects from database
  Future<List<Map<String, dynamic>>> getItemMapList() async {
    Database db = await this.database;
    var result = await db.query(itemTable, orderBy: '$colCostPrice ASC');
    return result;
  }

  // Insert Operation: insert a item to the database
  Future<int> insertItem(Item item) async {
    Database db = await this.database;
    var noti = item.toMap();
    debugPrint('insert item $noti');
    var result = await db.insert(itemTable, item.toMap());
    return result;
  }


  // Update Operation: Update a item from database
  Future<int> updateItem(Item item) async {
    Database db = await this.database;
    var result = await db.update(itemTable, item.toMap(), where: '$colId = ?', whereArgs: [item.id]);
    return result;
  }

  // Delete Operation: delete a item from the database
  Future<int> deleteItem(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $itemTable WHERE $colId = $id');
    return result;
  }

  // Get number of item objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $itemTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the list of map from db and convert to 'Item List ' [List <Item>]
  Future<List<Item>> getItemList() async {
    var itemMapList = await getItemMapList();
    int count = itemMapList.length;

    List<Item> itemList = List<Item>();
    // For loop to creae a 'Item List '  from a 'Map List'
    for (int i=0; i < count; i++){
      itemList.add(Item.fromMapObject(itemMapList[i]));
    }

    return itemList;
  }
}
