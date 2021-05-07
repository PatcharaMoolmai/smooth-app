// import 'dart:math';

// import 'package:flutter/cupertino.dart';
// import 'package:smooth_app/database/database_helper.dart';
// import 'package:sqflite/sqflite.dart';

// class UserCalculate with ChangeNotifier {
//   final dbHelper = DatabaseHelper.instance;
//   Database database;
//   Map<String, dynamic> _useData;
//   Map<String, dynamic> _useNutritionData;
//   double _bmr;
//   double _userProteinPerDay,
//       _userCarbohydratePerDay,
//       _userFatPerDay,
//       _userUnsatFatPerDay,
//       _userSatFatPerDay,
//       _userSodiumPerDay;
//   double _userProteinLeft,
//       _userCarbohydrateLeft,
//       _userFatLeft,
//       _userUnsatFatLeft,
//       _userSatFatLeft,
//       _userSodiumLeft;

//   Future<Map<String, dynamic>> _query() async {
//     final List<Map<String, dynamic>> allRows = await dbHelper.queryAllRows();
//     return _useData = allRows[0];
//   }

//   // Future<Map<String, dynamic>> _query() async {
//   //   final Database db = await database;

//   //   final List<Map<String, dynamic>> maps = await db.query('user_table');

//   //   return _useData = maps[0];
//   // }

//   Future<Map<String, dynamic>> _queryNutrition() async {
//     final int _nid = await dbHelper.queryNutritonRowCount();
//     final allNutrition = await dbHelper.queryNutritionRows(_nid);
//     return _useNutritionData = allNutrition[0];
//   }

//   // BMR calculate (kCal) need to convert into g for display
//   Future<double> _bmrCalculate() async {
//     _query();
//     final String userGender = _useData['gender'].toString();
//     final int userHeight = int.parse(_useData['height'].toString());
//     final int userWeight = int.parse(_useData['weight'].toString());
//     final int userAge = int.parse(_useData['age'].toString());
//     // double _bmr;
//     if (userGender == 'Man') {
//       _bmr = 66 + (13.7 * userWeight) + (5 * userHeight) - (6.8 * userAge);
//     } else {
//       _bmr = 665 + (9.6 * userWeight) + (1.8 * userHeight) - (4.7 * userAge);
//     }
//     return _bmr;
//   }

//   Future<double> nutritionCalculate() async {
//     List<double> proteinList;
//     List<double> carbohydrateList;
//     List<double> fatList;
//     List<double> satFatList;
//     List<double> unsatFatList;
//     List<double> sodiumList;
//     if (_useData['diabates'] == 1) {
//       proteinList.add(_bmr * 0.2);
//       carbohydrateList.add(_bmr * 0.63);
//       satFatList.add(_bmr * 0.07);
//       unsatFatList.add(_bmr * 0.1);
//       fatList.add(_bmr * 0.17);
//       sodiumList.add(2000);
//     }
//     if (_useData['hypertension'] == 1) {
//       proteinList.add(_bmr * 0.15);
//       carbohydrateList.add(_bmr * 0.65);
//       fatList.add(_bmr * 0.2);
//       satFatList.add(_bmr * 0.1);
//       unsatFatList.add(_bmr * 0.1);
//       sodiumList.add(2000);
//     }
//     if (_useData['hyperlipidemia'] == 1) {
//       proteinList.add(_bmr * 0.15);
//       carbohydrateList.add(_bmr * 0.6);
//       satFatList.add(_bmr * 0.07);
//       unsatFatList.add(_bmr * 0.1);
//       fatList.add(_bmr * 0.17);
//       sodiumList.add(2300);
//     }
//     if (_useData['kidney'] == 1) {
//       proteinList.add(_bmr * 0.15);
//       carbohydrateList.add(_bmr * 0.6);
//       satFatList.add(_bmr * 0.07);
//       fatList.add(_bmr * 0.2);
//       unsatFatList.add(_bmr * 0.13);
//       sodiumList.add(2000);
//     }
//     if (_useData['diabates'] == 0 &&
//         _useData['hypertension'] == 0 &&
//         _useData['hyperlipidemia'] == 0 &&
//         _useData['kidney'] == 0) {
//       proteinList.add(_bmr * 0.15);
//       carbohydrateList.add(_bmr * 0.65);
//       satFatList.add(_bmr * 0.1);
//       fatList.add(_bmr * 0.2);
//       unsatFatList.add(_bmr * 0.1);
//       sodiumList.add(2000);
//     }
//     // _userProtein = proteinList.reduce(min);
//     // _userCarbohydrate = carbohydrateList.reduce(min);
//     // _userFat = fatList.reduce(min);
//     // _userSatFat = satFatList.reduce(min);
//     // _userUnsatFat = unsatFatList.reduce(min);
//     // _userSodium = sodiumList.reduce(min);
//   }

//   Future<double> proteinCalc() async {
//     _query();
//     _queryNutrition();
//     _bmrCalculate();
//     List<double> proteinList;
//     if (_useData['diabates'] == 1) {
//       proteinList.add(_bmr * 0.2);
//     }
//     if (_useData['hypertension'] == 1) {
//       proteinList.add(_bmr * 0.15);
//     }
//     if (_useData['hyperlipidemia'] == 1) {
//       proteinList.add(_bmr * 0.15);
//     }
//     if (_useData['kidney'] == 1) {
//       proteinList.add(_bmr * 0.15);
//     }
//     if (_useData['diabates'] == 0 &&
//         _useData['hypertension'] == 0 &&
//         _useData['hyperlipidemia'] == 0 &&
//         _useData['kidney'] == 0) {
//       proteinList.add(_bmr * 0.15);
//     }
//     return _userProteinPerDay = proteinList.reduce(min);
//   }

//   Future<double> carbCalc() async {
//     _query();
//     _queryNutrition();
//     _bmrCalculate();
//     List<double> carbohydrateList;
//     if (_useData['diabates'] == 1) {
//       carbohydrateList.add(_bmr * 0.63);
//     }
//     if (_useData['hypertension'] == 1) {
//       carbohydrateList.add(_bmr * 0.65);
//     }
//     if (_useData['hyperlipidemia'] == 1) {
//       carbohydrateList.add(_bmr * 0.6);
//     }
//     if (_useData['kidney'] == 1) {
//       carbohydrateList.add(_bmr * 0.6);
//     }
//     if (_useData['diabates'] == 0 &&
//         _useData['hypertension'] == 0 &&
//         _useData['hyperlipidemia'] == 0 &&
//         _useData['kidney'] == 0) {
//       carbohydrateList.add(_bmr * 0.65);
//     }
//     return _userCarbohydratePerDay = carbohydrateList.reduce(min);
//   }

//   Future<double> fatCalc() async {
//     _query();
//     List<double> fatList;
//     if (_useData['diabates'] == 1) {
//       fatList.add(_bmr * 0.17);
//     }
//     if (_useData['hypertension'] == 1) {
//       fatList.add(_bmr * 0.2);
//     }
//     if (_useData['hyperlipidemia'] == 1) {
//       fatList.add(_bmr * 0.17);
//     }
//     if (_useData['kidney'] == 1) {
//       fatList.add(_bmr * 0.2);
//     }
//     if (_useData['diabates'] == 0 &&
//         _useData['hypertension'] == 0 &&
//         _useData['hyperlipidemia'] == 0 &&
//         _useData['kidney'] == 0) {
//       fatList.add(_bmr * 0.2);
//     }
//     return _userFatPerDay = fatList.reduce(min);
//   }

//   Future<double> satFatCalc() async {
//     _query();
//     List<double> satFatList;
//     if (_useData['diabates'] == 1) {
//       satFatList.add(_bmr * 0.07);
//     }
//     if (_useData['hypertension'] == 1) {
//       satFatList.add(_bmr * 0.1);
//     }
//     if (_useData['hyperlipidemia'] == 1) {
//       satFatList.add(_bmr * 0.07);
//     }
//     if (_useData['kidney'] == 1) {
//       satFatList.add(_bmr * 0.07);
//     }
//     if (_useData['diabates'] == 0 &&
//         _useData['hypertension'] == 0 &&
//         _useData['hyperlipidemia'] == 0 &&
//         _useData['kidney'] == 0) {
//       satFatList.add(_bmr * 0.1);
//     }
//     return _userSatFatPerDay = satFatList.reduce(min);
//   }

//   Future<double> unsatFatCalc() async {
//     _query();
//     List<double> unsatFatList;
//     if (_useData['diabates'] == 1) {
//       unsatFatList.add(_bmr * 0.1);
//     }
//     if (_useData['hypertension'] == 1) {
//       unsatFatList.add(_bmr * 0.1);
//     }
//     if (_useData['hyperlipidemia'] == 1) {
//       unsatFatList.add(_bmr * 0.1);
//     }
//     if (_useData['kidney'] == 1) {
//       unsatFatList.add(_bmr * 0.13);
//     }
//     if (_useData['diabates'] == 0 &&
//         _useData['hypertension'] == 0 &&
//         _useData['hyperlipidemia'] == 0 &&
//         _useData['kidney'] == 0) {
//       unsatFatList.add(_bmr * 0.1);
//     }
//     return _userUnsatFatPerDay = unsatFatList.reduce(min);
//   }

//   Future<double> sodiumCalc() async {
//     _query();
//     List<double> sodiumList;
//     if (_useData['diabates'] == 1) {
//       sodiumList.add(2000);
//     }
//     if (_useData['hypertension'] == 1) {
//       sodiumList.add(2000);
//     }
//     if (_useData['hyperlipidemia'] == 1) {
//       sodiumList.add(2300);
//     }
//     if (_useData['kidney'] == 1) {
//       sodiumList.add(2000);
//     }
//     if (_useData['diabates'] == 0 &&
//         _useData['hypertension'] == 0 &&
//         _useData['hyperlipidemia'] == 0 &&
//         _useData['kidney'] == 0) {
//       sodiumList.add(2000);
//     }
//     return _userSodiumPerDay = sodiumList.reduce(min);
//   }

//   Future<double> proteinLeft() async {
//     int proteinConsume = int.parse(_useNutritionData['protein'].toString());
//     return _userProteinLeft = _userProteinPerDay - proteinConsume;
//   }

//   Future<double> carbLeft() async {
//     int carbConsume = int.parse(_useNutritionData['carbohydrate'].toString());
//     return _userCarbohydrateLeft = _userCarbohydratePerDay - carbConsume;
//   }

//   Future<double> fatLeft() async {
//     int fatConsume = int.parse(_useNutritionData['fat'].toString());
//     return _userFatLeft = _userFatPerDay - fatConsume;
//   }

//   Future<double> satFatLeft() async {
//     int satFatConsume = int.parse(_useNutritionData['saturedFat'].toString());
//     return _userSatFatLeft = _userSatFatPerDay - satFatConsume;
//   }

//   Future<double> unsatLeft() async {
//     final int fatConsume = int.parse(_useNutritionData['fat'].toString());
//     final int satFatConsume =
//         int.parse(_useNutritionData['saturedFat'].toString());
//     final int unsatFatConsume = fatConsume - satFatConsume;
//     return _userUnsatFatLeft = _userUnsatFatPerDay - unsatFatConsume;
//   }

//   Future<double> sodiumLeft() async {
//     int sodiumConsume = int.parse(_useNutritionData['sodium'].toString());
//     return _userSodiumLeft = _userSodiumPerDay - sodiumConsume;
//   }
// }
