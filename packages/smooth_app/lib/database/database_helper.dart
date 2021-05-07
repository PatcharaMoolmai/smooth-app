import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'local_database.dart';

class DatabaseHelper extends ChangeNotifier {

  @override
  void notifyListeners() => super.notifyListeners();
  
  static const int _databaseVersion = 1;

  static const String userTable = 'user_table';

  static const String columnId = '_id';
  static const String columnName = 'name';
  static const String columnAge = 'age';
  static const String columnGender = 'gender';
  static const String columnHeight = 'height';
  static const String columnWeight = 'weight';
  static const String colmunDiabates = 'diabates';
  static const String colmunHypertension = 'hypertension';
  static const String colmunHyperlipidemia = 'hyperlipidemia';
  static const String colmunKidneyDisease = 'kidney';

  static const String underlyingDiseaseTable = 'underlying_table';

  static const String colmunUnderlyingDiseaseId = '_udid';


  static const String nutritionTable = 'nutrition_table';

  static const String columnNutritionId = '_nid';
  static const String columnNutritionCalorie = 'calorie';
  static const String columnNutritionProtein = 'protein';
  static const String columnNutritionCarbohydrate = 'carbohydrate';
  static const String columnNutritionFat = 'fat';
  static const String columnNutritionSaturedFat = 'saturedFat';
  static const String columnNutritionSodium = 'sodium';
  static const String columnNutritionSalt = 'salt';
  static const String columnNutritionTimeStamp = 'nutrition_timestamp';

  static const String productConsumeTable = 'product_consume';

  static const String productConsumeId = '_pid';
  static const String productConsumeBarcode = 'product_barcode';
  static const String productConsumeTimeStamp = 'product_Timestamp';

  

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _initDatabase() async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'smoothie.db');
    return await openDatabase(path,
        version: _databaseVersion, onCreate: __onCreateDatabase);
  }

  Future<void> __onCreateDatabase(Database db, int version) async {
    await _onCreate(db, version);
    // await _onCreateUnderlying(db, version);
    await _onCreateNutritonTable(db, version);
    await _onCreateProductConsumeTable(db, version);
  }

  // Create User table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('create table $userTable('
        '$columnId INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$columnName TEXT NOT NULL,'
        '$columnGender TEXT NOT NULL,'
        '$columnAge INTEGER NOT NULL,'
        '$columnHeight INTEGER NOT NULL,'
        '$columnWeight INTEGER NOT NULL,'
        '$colmunDiabates INTEGER,'
        '$colmunHypertension INTEGER,'
        '$colmunHyperlipidemia INTEGER,'
        '$colmunKidneyDisease INTEGER'
        ')');

    await db.execute('insert into $userTable('
        '$columnName,'
        '$columnGender,'
        '$columnAge,'
        '$columnHeight,'
        '$columnWeight,'
        '$colmunDiabates,'
        '$colmunHypertension,'
        '$colmunHyperlipidemia,'
        '$colmunKidneyDisease'
        ') values ("Unknow User", "Man", 18, 170, 70, 0, 0, 0, 0)');
  }

  //Create User disease table
  // Future<void> _onCreateUnderlying(Database db, int version) async {
  //   await db.execute('create table $underlyingDiseaseTable('
  //       '$colmunUnderlyingDiseaseId INTEGER PRIMARY KEY AUTOINCREMENT,'
  //       '$columnName TEXT NOT NULL,'
  //       
  //       ')');

  //   await db.execute('insert into $userTable('
  //       '$colmunDiabates,'
  //       '$colmunHypertension,'
  //       '$colmunHyperlipidemia,'
  //       '$colmunKidneyDisease'
  //       ') values (0, 0, 0, 0)');
  // }

  // Create Nutrition table
  Future<void> _onCreateNutritonTable(Database db, int version) async {
    await db.execute('create table $nutritionTable('
        '$columnNutritionId INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$columnNutritionCalorie INTEGER  NOT NULL,'
        '$columnNutritionProtein INTEGER NOT NULL,'
        '$columnNutritionCarbohydrate INTEGER NOT NULL,'
        '$columnNutritionFat INTEGER NOT NULL,'
        '$columnNutritionSaturedFat INTEGER NOT NULL,'
        '$columnNutritionSalt INTEGER NOT NULL,'
        '$columnNutritionSodium INTEGER NOT NULL,'
        '$columnNutritionTimeStamp INTEGER NOT NULL'
        ')');

    await db.execute('insert into $nutritionTable('
        '$columnNutritionCalorie,'
        '$columnNutritionProtein,'
        '$columnNutritionCarbohydrate,'
        '$columnNutritionFat,'
        '$columnNutritionSaturedFat,'
        '$columnNutritionSalt,'
        '$columnNutritionSodium,'
        '$columnNutritionTimeStamp'
        ') values ( 0, 0, 0, 0, 0, 0, 0 ,${DateFormat("dMy").format(DateTime.now())})');
  }

  Future<void> _onCreateProductConsumeTable(Database db, int version) async {
    await db.execute('create table $productConsumeTable('
        '$productConsumeId INTEGER PRIMARY KEY AUTOINCREMENT,'
        '$productConsumeBarcode INTEGER,'
        '$productConsumeTimeStamp INTEGER'
        ')');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(userTable, row);
  }

  Future<int> insertNutriton(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(nutritionTable, row);
  }

  Future<int> insertProductConsume(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(productConsumeTable, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  // user
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(userTable);
  }
  // nutrition
  Future<List<Map<String, dynamic>>> queryAllNutritionRows() async {
    Database db = await instance.database;
    return await db.query(nutritionTable);
  }
  // history
  Future<List<Map<String, dynamic>>> queryAllProductHistoryRows() async {
    Database db = await instance.database;
    return await db.query(productConsumeTable);
  }
  // nutriton selected
  Future<List<Map<String, dynamic>>> queryNutritionRows(int _nid) async {
    Database db = await instance.database;
    return await db.query(nutritionTable,
        where: "$columnNutritionId LIKE '%$_nid%'");
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  // user
  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $userTable'));
  }
  // nutrition
  Future<int> queryRowNutritionCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $nutritionTable'));
  }
  // history
  Future<int> queryRowHistoryCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $productConsumeTable'));
  }

  Future<int> queryNutritonRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $nutritionTable'));
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId] as int;
    return await db
        .update(userTable, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateNutrition(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int nid = row[columnNutritionId] as int;
    return await db.update(nutritionTable, row,
        where: '$columnNutritionId = ?', whereArgs: [nid]);
  }

  Future<int> updateProductConsume(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int pid = row[columnNutritionId] as int;
    return await db.update(productConsumeTable, row,
        where: '$productConsumeTable = ?', whereArgs: [pid]);
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(userTable, where: '$columnId = ?', whereArgs: [id]);
  }

}
