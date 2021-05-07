// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Package imports:
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

// import 'local_database.dart';
import 'package:smooth_app/database/local_database.dart';
// Project import:

// class UserProfileDatabase {
//   UserProfileDatabase(this.localDatabase);
//   final LocalDatabase localDatabase;

//   static final UserProfileDatabase instance =
//       LocalDatabase as UserProfileDatabase;

//   static const String userTable = 'user_table';

//   static const String columnId = '_id';
//   static const String columnName = 'name';
//   static const String columnAge = 'age';
//   static const String columnGender = 'gender';
//   static const String columnHeight = 'height';
//   static const String columnWeight = 'weight';
//   static const String colmunDiabates = 'diabates';
//   static const String colmunHypertension = 'hypertension';
//   static const String colmunHyperlipidemia = 'hyperlipidemia';
//   static const String colmunKidneyDisease = 'kidney';

//   static Future<void> onUpgrade(
//     final Database db,
//     final int oldVersion,
//     final int newVersion,
//   ) async {
//     if (oldVersion < 1) {
//       // Create Table user profile table
//       await db.execute('create table $userTable('
//           '$columnId INTEGER PRIMARY KEY AUTOINCREMENT,'
//           '$columnName TEXT NOT NULL,'
//           '$columnGender TEXT NOT NULL,'
//           '$columnAge INTEGER NOT NULL,'
//           '$columnHeight INTEGER NOT NULL,'
//           '$columnWeight INTEGER NOT NULL,'
//           '$colmunDiabates INTEGER,'
//           '$colmunHypertension INTEGER,'
//           '$colmunHyperlipidemia INTEGER,'
//           '$colmunKidneyDisease INTEGER'
//           ')');

//       await db.execute('insert into $userTable('
//           '$columnName,'
//           '$columnGender,'
//           '$columnAge,'
//           '$columnHeight,'
//           '$columnWeight,'
//           '$colmunDiabates,'
//           '$colmunHypertension,'
//           '$colmunHyperlipidemia,'
//           '$colmunKidneyDisease'
//           ') values ("Unknow User", "Man", 18, 170, 70, 0, 0, 0, 0)');
//     }
//   }

//   // Process
//   // user query
//   // Future<List<Map<String, dynamic>>> queryAllRows() async {
//   //   Database db = await localDatabase.database;
//   //   // final List<String> result = <String>[];
//   //   return await db.query(userTable);
//   // }

//   // Future<int> queryRowCount() async {
//   //   Database db = await localDatabase.database;
//   //   return Sqflite.firstIntValue(
//   //       await db.rawQuery('SELECT COUNT(*) FROM $userTable'));
//   // }

//   // // usery insert
//   // Future<int> insert(Map<String, dynamic> row) async {
//   //   Database db = await localDatabase.database;
//   //   return await db.insert(userTable, row);
//   // }

//   // // user update
//   // Future<int> update(Map<String, dynamic> row) async {
//   //   Database db = await localDatabase.database;
//   //   int id = row[columnId] as int;
//   //   return await db
//   //       .update(userTable, row, where: '$columnId = ?', whereArgs: [id]);
//   // }
// }

// class UserNutritionData {
//   UserNutritionData(this.localDatabase);
//   final LocalDatabase localDatabase;

//   static final UserNutritionData instance = LocalDatabase as UserNutritionData;

//   static const String nutritionTable = 'nutrition_table';

//   static const String columnNutritionId = '_nid';
//   static const String columnNutritionCalorie = 'calorie';
//   static const String columnNutritionProtein = 'protein';
//   static const String columnNutritionCarbohydrate = 'carbohydrate';
//   static const String columnNutritionFat = 'fat';
//   static const String columnNutritionSaturedFat = 'saturedFat';
//   static const String columnNutritionSodium = 'sodium';
//   static const String columnNutritionSalt = 'salt';
//   static const String columnNutritionTimeStamp = 'nutrition_timestamp';

//   static Future<void> onUpgrade(
//     final Database db,
//     final int oldVersion,
//     final int newVersion,
//   ) async {
//     if (oldVersion < 1) {
//       // Create Table user profile table
//       await db.execute('create table $nutritionTable('
//           '$columnNutritionId INTEGER PRIMARY KEY AUTOINCREMENT,'
//           '$columnNutritionCalorie INTEGER  NOT NULL,'
//           '$columnNutritionProtein INTEGER NOT NULL,'
//           '$columnNutritionCarbohydrate INTEGER NOT NULL,'
//           '$columnNutritionFat INTEGER NOT NULL,'
//           '$columnNutritionSaturedFat INTEGER NOT NULL,'
//           '$columnNutritionSalt INTEGER NOT NULL,'
//           '$columnNutritionSodium INTEGER NOT NULL,'
//           '$columnNutritionTimeStamp INTEGER NOT NULL'
//           ')');

//       await db.execute('insert into $nutritionTable('
//           '$columnNutritionCalorie,'
//           '$columnNutritionProtein,'
//           '$columnNutritionCarbohydrate,'
//           '$columnNutritionFat,'
//           '$columnNutritionSaturedFat,'
//           '$columnNutritionSalt,'
//           '$columnNutritionSodium,'
//           '$columnNutritionTimeStamp'
//           ') values ( 0, 0, 0, 0, 0, 0, 0 ,${DateFormat("dMy").format(DateTime.now())})');
//     }
//   }

//   // // Process data
//   //   // user query
//   // Future<List<Map<String, dynamic>>> queryAllNutritionRows() async {
//   //   Database db = await localDatabase.database;
//   //   // final List<String> result = <String>[];
//   //   return await db.query(nutritionTable);
//   // }

//   // Future<int> queryNutritionRowCount() async {
//   //   Database db = await localDatabase.database;
//   //   return Sqflite.firstIntValue(
//   //       await db.rawQuery('SELECT COUNT(*) FROM $nutritionTable'));
//   // }

//   // // nutriton selected
//   // Future<List<Map<String, dynamic>>> queryNutritionRowsSelected(int _nid) async {
//   //   Database db = await localDatabase.database;
//   //   return await db.query(nutritionTable,
//   //       where: "$columnNutritionId LIKE '%$_nid%'");
//   // }

//   // // usery insert
//   // Future<int> insertNutrition(Map<String, dynamic> row) async {
//   //   Database db = await localDatabase.database;
//   //   return await db.insert(nutritionTable, row);
//   // }

//   // // user update
//   // Future<int> updateNutrition(Map<String, dynamic> row) async {
//   //   Database db = await localDatabase.database;
//   //   int id = row[columnNutritionId] as int;
//   //   return await db
//   //       .update(nutritionTable, row, where: '$columnNutritionId = ?', whereArgs: [id]);
//   // }
// }

// class UserHistory {
//   UserHistory(this.localDatabase);
//   final LocalDatabase localDatabase;

//   static final UserHistory instance = LocalDatabase as UserHistory;

//   static const String productConsumeTable = 'product_consume';

//   static const String productConsumeId = '_pid';
//   static const String productConsumeBarcode = 'product_barcode';
//   static const String productConsumeTimeStamp = 'product_Timestamp';

//   static Future<void> onUpgrade(
//     final Database db,
//     final int oldVersion,
//     final int newVersion,
//   ) async {
//     if (oldVersion < 1) {
//       // Create Table user profile table
//       await db.execute('create table $productConsumeTable('
//           '$productConsumeId INTEGER PRIMARY KEY AUTOINCREMENT,'
//           '$productConsumeBarcode INTEGER,'
//           '$productConsumeTimeStamp INTEGER'
//           ')');
//     }
//   }
//     // Process
//   // user query
//   // Future<List<Map<String, dynamic>>> queryAllProductConesumeRows() async {
//   //   Database db = await localDatabase.database;
//   //   // final List<String> result = <String>[];
//   //   return await db.query(productConsumeTable);
//   // }

//   // Future<int> queryProductConesumeRowCount() async {
//   //   Database db = await localDatabase.database;
//   //   return Sqflite.firstIntValue(
//   //       await db.rawQuery('SELECT COUNT(*) FROM $productConsumeTable'));
//   // }

//   // // usery insert
//   // Future<int> insertProductConesume(Map<String, dynamic> row) async {
//   //   Database db = await localDatabase.database;
//   //   return await db.insert(productConsumeTable, row);
//   // }

//   // // user update
//   // Future<int> updateProductConesume(Map<String, dynamic> row) async {
//   //   Database db = await localDatabase.database;
//   //   int id = row[productConsumeId] as int;
//   //   return await db
//   //       .update(productConsumeTable, row, where: '$productConsumeId = ?', whereArgs: [id]);
//   // }
// }
