import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:bk_app/models/item.dart';
import 'package:bk_app/models/transaction.dart';

class DbHelper {
  static DbHelper _dbHelper; // Singleton dbHelper
  static Database _database;

  // Items setup
  String itemTable = 'item_table';
  String colId = 'id';
  String colName = 'name';
  String colNickName = 'nick_name';
  String colDescription = 'description';
  String colCostPrice = 'cost_price';
  String colMarkedPrice = 'marked_price';
  String colInTransaction = 'in_transaction';
  String colOutTransaction = 'out_transaction';

  // ItemTransaction setup
  String transactionTable = 'transaction_table';
  String col2Id = 'id';
  String col2ItemId = 'item_id';
  String col2Description = 'description';
  String col2Amount = 'amount';
  String col2Type = 'type';
  String col2Date = 'date';
  String col2Items = 'items';

  DbHelper._createInstance(); // Named constructor to create instance of DbHelper

  factory DbHelper() {
    if (_dbHelper == null) {
      _dbHelper = DbHelper
          ._createInstance(); // This will execute only once, singleton obj
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
    String path = directory.path + 'items1.db';

    // Open/create the db at a given path
    var itemsDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return itemsDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    // Item
    await db.execute('''
CREATE TABLE $itemTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colName TEXT UNIQUE, $colNickName TEXT UNIQUE, '''
        '$colDescription TEXT, $colCostPrice REAL, $colInTransaction INTEGER, $colOutTransaction INTEGER, $colMarkedPrice REAL)');

    // ItemTransaction
    await db.execute(
        'CREATE TABLE $transactionTable($col2Id INTEGER PRIMARY KEY AUTOINCREMENT, $col2ItemId INTEGER, $col2Type INTEGER, '
        '$col2Description TEXT, $col2Date TEXT, $col2Amount REAL, $col2Items REAL)');
  }

  // Fetch operation: Get all item objects from database
  Future<List<Map<String, dynamic>>> getItemMapList() async {
    Database db = await this.database;
    var result = await db.query(itemTable, orderBy: '$colName ASC');
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
    var result = await db.update(itemTable, item.toMap(),
        where: '$colId = ?', whereArgs: [item.id]);
    return result;
  }

  // Delete Operation: delete a item from the database
  Future<int> deleteItem(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $itemTable WHERE $colId = $id');
    return result;
  }

  // Get number of item objects in database
  Future<int> getItemCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $itemTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get item from item name
  Future<Item> getItem(String columnName, value) async {
    if (value == null) {
      return null;
    }

    Database db = await this.database;
    List<Map<String, dynamic>> mapResult =
        await db.query(itemTable, where: '$columnName = ?', whereArgs: [value]);

    if (mapResult.length == 0) {
      return null;
    }
    Item result = Item.fromMapObject(mapResult[0]);
    return result;
  }

  // Get the list of map from db and convert to 'Item List ' [List <Item>]
  Future<List<Item>> getItemList() async {
    var itemMapList = await getItemMapList();
    int count = itemMapList.length;

    List<Item> itemList = List<Item>();
    // For loop to creae a 'Item List '  from a 'Map List'
    for (int i = 0; i < count; i++) {
      itemList.add(Item.fromMapObject(itemMapList[i]));
    }

    return itemList;
  }

  // ItemTransaction Functions

  // Fetch operation: Get all transaction objects from database
  Future<List<Map<String, dynamic>>> getItemTransactionMapList() async {
    Database db = await this.database;
    var result = await db.query(transactionTable, orderBy: '$col2Id DESC');
    return result;
  }

  // Insert Operation: insert a transaction to the database
  Future<int> insertItemTransaction(ItemTransaction transaction) async {
    Database db = await this.database;
    var noti = transaction.toMap();
    debugPrint('insert transaction $noti');
    var result = await db.insert(transactionTable, transaction.toMap());
    return result;
  }

  // Update Operation: Update a transaction from database
  Future<int> updateItemTransaction(ItemTransaction transaction) async {
    Database db = await this.database;
    var result = await db.update(transactionTable, transaction.toMap(),
        where: '$col2Id = ?', whereArgs: [transaction.id]);
    return result;
  }

  // Delete Operation: delete a transaction from the database
  Future<int> deleteItemTransaction(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $transactionTable WHERE $col2Id = $id');
    return result;
  }

  // Get number of transaction objects in database
  Future<int> getItemTransactionCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $transactionTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the list of map from db and convert to 'ItemTransaction List ' [List <ItemTransaction>]
  Future<List<ItemTransaction>> getItemTransactionList() async {
    var transactionMapList = await getItemTransactionMapList();
    int count = transactionMapList.length;

    List<ItemTransaction> transactionList = List<ItemTransaction>();
    // For loop to creae a 'ItemTransaction List '  from a 'Map List'
    for (int i = 0; i < count; i++) {
      transactionList.add(ItemTransaction.fromMapObject(transactionMapList[i]));
    }

    return transactionList;
  }
}
