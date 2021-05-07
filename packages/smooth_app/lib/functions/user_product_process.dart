// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/database_helper.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/database/user_profile_database.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class UserProductProcess with ChangeNotifier {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  // final UserProfileDatabase userProfileDatabase = UserProfileDatabase.instance;
  // final UserNutritionData userNutritionData = UserNutritionData.instance;
  // final UserHistory userHistory = UserHistory.instance;
  Map<String, dynamic> _useData;
  Product _product;
  double _nid,
      calorie,
      protein,
      carbohydrate,
      fat,
      saturedFat,
      unsaturedFat,
      sodium,
      salt;
  String nutritionTimeStamp;

  void initState() {
    _query();
    // super.intState();
  }

  static const User SMOOTH_USER = User(
    userId: 'project-smoothie',
    password: 'smoothie',
    comment: 'Test user for project smoothie',
  );

  Future<void> _query() async {
    final allNutrition = await dbHelper.queryAllNutritionRows();
    _useData = allNutrition[0];
    // calorie = int.parse(_useData['calorie'].toString())+200;
    // protein = int.parse(_useData['protein'].toString())+3;
    // carbohydrate = int.parse(_useData['carbohydrate'].toString())+5;
    // fat = int.parse(_useData['fat'].toString())+3;
    // saturedFat = int.parse(_useData['saturedFat'].toString())+1;
    // // unsaturedFat = fat - unsaturedFat;
    // sodium = int.parse(_useData['sodium'].toString())+600;
    // salt = int.parse(_useData['salt'].toString())+0;
  }

  Future<void> productToEat(Product product) async {
    final String toEatBarcode = product.barcode;
    final ProductQueryConfiguration configurations = ProductQueryConfiguration(
        toEatBarcode,
        language: OpenFoodFactsLanguage.GERMAN,
        fields: [
          ProductField.NUTRIMENTS,
          ProductField.INGREDIENTS_TEXT,
          ProductField.INGREDIENTS,
          ProductField.ADDITIVES,
          ProductField.NUTRIENT_LEVELS
        ]);

    final ProductResult result =
        await OpenFoodAPIClient.getProduct(configurations, user: SMOOTH_USER);

    if (result.status != 1) {
      // print('Error retreiving the product : ${result.status.errorVerbose}');
      print('Error retreiving the product ');

      return;
    }
    final String ingredientsT = result.product.ingredientsText;
    final List<Ingredient> ingredients = result.product.ingredients;

    final double energyServing =
        result.product.nutriments.energyServing / 4.184;
    final double fatServing = result.product.nutriments.fatServing;
    final double saltServing = result.product.nutriments.saltServing;
    final double saturedfatServing =
        result.product.nutriments.saturatedFatServing;
    final double carbohydrateServing =
        result.product.nutriments.carbohydratesServing;
    final double proteinServing = result.product.nutriments.proteinsServing;
    final double sodiumServing = result.product.nutriments.sodiumServing;
    // final int _nid = await dbHelper.queryNutritonRowCount();
    final int _nid = await dbHelper.queryNutritonRowCount();
    final _hid = await dbHelper.queryRowHistoryCount();
    final allNutrition = await dbHelper.queryNutritionRows(_nid);
    _useData = allNutrition[0];
    int rowCount = int.parse(_useData['_nid'].toString());
    int rowHistoryCount = _hid;
    // time stamp not successful yet
    nutritionTimeStamp = _useData['nutrition_timestamp'].toString();
    final String dataToday = DateFormat('dMy').format(DateTime.now());
    calorie = double.parse(_useData['calorie'].toString()) + energyServing;
    protein = double.parse(_useData['protein'].toString()) + proteinServing;
    carbohydrate =
        double.parse(_useData['carbohydrate'].toString()) + carbohydrateServing;
    fat = double.parse(_useData['fat'].toString()) + fatServing;
    saturedFat =
        double.parse(_useData['saturedFat'].toString()) + saturedfatServing;
    // unsaturedFat = fat - unsaturedFat;
    sodium = double.parse(_useData['sodium'].toString()) + sodiumServing;
    salt = double.parse(_useData['salt'].toString()) + saltServing;
    final Map<String, dynamic> row = <String, dynamic>{
      DatabaseHelper.columnNutritionId: rowCount,
      DatabaseHelper.columnNutritionCalorie: calorie.round(),
      DatabaseHelper.columnNutritionProtein: protein.round(),
      DatabaseHelper.columnNutritionCarbohydrate: carbohydrate.round(),
      DatabaseHelper.columnNutritionFat: fat.round(),
      DatabaseHelper.columnNutritionSaturedFat: saturedFat.round(),
      DatabaseHelper.columnNutritionSodium: sodium.round(),
      DatabaseHelper.columnNutritionSalt: salt.round(),
      DatabaseHelper.columnNutritionTimeStamp: nutritionTimeStamp
    };
    final Map<String, dynamic> rowInsert = <String, dynamic>{
      DatabaseHelper.columnNutritionId: rowCount + 1,
      DatabaseHelper.columnNutritionCalorie: calorie.round(),
      DatabaseHelper.columnNutritionProtein: protein.round(),
      DatabaseHelper.columnNutritionCarbohydrate: carbohydrate.round(),
      DatabaseHelper.columnNutritionFat: fat.round(),
      DatabaseHelper.columnNutritionSaturedFat: saturedFat.round(),
      DatabaseHelper.columnNutritionSodium: sodium.round(),
      DatabaseHelper.columnNutritionSalt: salt.round(),
      DatabaseHelper.columnNutritionTimeStamp:
          int.parse(DateFormat('dMy').format(DateTime.now()))
    };
    //History
    final Map<String, dynamic> rowInsertHistory = <String, dynamic>{
      DatabaseHelper.productConsumeId: rowHistoryCount + 1,
      DatabaseHelper.productConsumeBarcode: calorie.round(),
      DatabaseHelper.productConsumeTimeStamp:
          int.parse(DateFormat('dMy').format(DateTime.now()))
    };

    if (DateFormat('dMy').format(DateTime.now()) == nutritionTimeStamp) {
      final int nid = await dbHelper.updateNutrition(row);
      print('update row id: $nid');
      // use when history rdy
      // final int pid = await dbHelper.insertProductConsume(rowInsertHistory);
      // print('update row id: $pid');
    } else {
      final int nid = await dbHelper.insertNutriton(rowInsert);
      print('insert row id: $nid a new day!');
      // final int pid = await dbHelper.insertProductConsume(rowInsertHistory);
      // print('insert row id: $pid a new day!');
    }
    // final int nid = await dbHelper.updateNutrition(row);
    // print('update row id: $nid');
    print(row);
    print(toEatBarcode);
    print(rowCount);
    print(nutritionTimeStamp);

    notifyListeners();
  }

  Future<void> productToEat1of2(Product product) async {
    final String toEatBarcode = product.barcode;
    final ProductQueryConfiguration configurations = ProductQueryConfiguration(
        toEatBarcode,
        language: OpenFoodFactsLanguage.GERMAN,
        fields: [
          ProductField.NUTRIMENTS,
          ProductField.INGREDIENTS_TEXT,
          ProductField.INGREDIENTS,
          ProductField.ADDITIVES,
          ProductField.NUTRIENT_LEVELS
        ]);

    final ProductResult result =
        await OpenFoodAPIClient.getProduct(configurations, user: SMOOTH_USER);

    if (result.status != 1) {
      // print('Error retreiving the product : ${result.status.errorVerbose}');
      print('Error retreiving the product ');

      return;
    }
    final String ingredientsT = result.product.ingredientsText;
    final List<Ingredient> ingredients = result.product.ingredients;

    final double energyServing =
        result.product.nutriments.energyServing / 4.184;
    final double fatServing = result.product.nutriments.fatServing;
    final double saltServing = result.product.nutriments.saltServing;
    final double saturedfatServing =
        result.product.nutriments.saturatedFatServing;
    final double carbohydrateServing =
        result.product.nutriments.carbohydratesServing;
    final double proteinServing = result.product.nutriments.proteinsServing;
    final double sodiumServing = result.product.nutriments.sodiumServing;
    // final int _nid = await dbHelper.queryNutritonRowCount();
    final int _nid = await dbHelper.queryNutritonRowCount();
    final _hid = await dbHelper.queryRowHistoryCount();
    final allNutrition = await dbHelper.queryNutritionRows(_nid);
    _useData = allNutrition[0];
    int rowCount = int.parse(_useData['_nid'].toString());
    int rowHistoryCount = _hid;
    // time stamp not successful yet
    nutritionTimeStamp = _useData['nutrition_timestamp'].toString();
    final String dataToday = DateFormat('dMy').format(DateTime.now());
    calorie =
        double.parse(_useData['calorie'].toString()) + (energyServing * 1 / 2);
    protein =
        double.parse(_useData['protein'].toString()) + (proteinServing * 1 / 2);
    carbohydrate = double.parse(_useData['carbohydrate'].toString()) +
        (carbohydrateServing * 1 / 2);
    fat = double.parse(_useData['fat'].toString()) + (fatServing * 1 / 2);
    saturedFat = double.parse(_useData['saturedFat'].toString()) +
        (saturedfatServing * 1 / 2);
    // unsaturedFat = fat - unsaturedFat;
    sodium =
        double.parse(_useData['sodium'].toString()) + (sodiumServing * 1 / 2);
    salt = double.parse(_useData['salt'].toString()) + (saltServing * 1 / 2);
    final Map<String, dynamic> row = <String, dynamic>{
      DatabaseHelper.columnNutritionId: rowCount,
      DatabaseHelper.columnNutritionCalorie: calorie.round(),
      DatabaseHelper.columnNutritionProtein: protein.round(),
      DatabaseHelper.columnNutritionCarbohydrate: carbohydrate.round(),
      DatabaseHelper.columnNutritionFat: fat.round(),
      DatabaseHelper.columnNutritionSaturedFat: saturedFat.round(),
      DatabaseHelper.columnNutritionSodium: sodium.round(),
      DatabaseHelper.columnNutritionSalt: salt.round(),
      DatabaseHelper.columnNutritionTimeStamp: nutritionTimeStamp
    };
    final Map<String, dynamic> rowInsert = <String, dynamic>{
      DatabaseHelper.columnNutritionId: rowCount + 1,
      DatabaseHelper.columnNutritionCalorie: calorie.round(),
      DatabaseHelper.columnNutritionProtein: protein.round(),
      DatabaseHelper.columnNutritionCarbohydrate: carbohydrate.round(),
      DatabaseHelper.columnNutritionFat: fat.round(),
      DatabaseHelper.columnNutritionSaturedFat: saturedFat.round(),
      DatabaseHelper.columnNutritionSodium: sodium.round(),
      DatabaseHelper.columnNutritionSalt: salt.round(),
      DatabaseHelper.columnNutritionTimeStamp:
          int.parse(DateFormat('dMy').format(DateTime.now()))
    };
    //History
    final Map<String, dynamic> rowInsertHistory = <String, dynamic>{
      DatabaseHelper.productConsumeId: rowHistoryCount + 1,
      DatabaseHelper.productConsumeBarcode: calorie.round(),
      DatabaseHelper.productConsumeTimeStamp:
          int.parse(DateFormat('dMy').format(DateTime.now()))
    };

    if (DateFormat('dMy').format(DateTime.now()) == nutritionTimeStamp) {
      final int nid = await dbHelper.updateNutrition(row);
      print('update row id: $nid');
      // use when history rdy
      // final int pid = await dbHelper.insertProductConsume(rowInsertHistory);
      // print('update row id: $pid');
    } else {
      final int nid = await dbHelper.insertNutriton(rowInsert);
      print('insert row id: $nid a new day!');
      // final int pid = await dbHelper.insertProductConsume(rowInsertHistory);
      // print('insert row id: $pid a new day!');
    }
    // final int nid = await dbHelper.updateNutrition(row);
    // print('update row id: $nid');
    print(row);
    print(toEatBarcode);
    print(rowCount);
    print(nutritionTimeStamp);

    notifyListeners();
  }

  Future<void> productToEat3of4(Product product) async {
    final String toEatBarcode = product.barcode;
    final ProductQueryConfiguration configurations = ProductQueryConfiguration(
        toEatBarcode,
        language: OpenFoodFactsLanguage.GERMAN,
        fields: [
          ProductField.NUTRIMENTS,
          ProductField.INGREDIENTS_TEXT,
          ProductField.INGREDIENTS,
          ProductField.ADDITIVES,
          ProductField.NUTRIENT_LEVELS
        ]);

    final ProductResult result =
        await OpenFoodAPIClient.getProduct(configurations, user: SMOOTH_USER);

    if (result.status != 1) {
      // print('Error retreiving the product : ${result.status.errorVerbose}');
      print('Error retreiving the product ');

      return;
    }
    final String ingredientsT = result.product.ingredientsText;
    final List<Ingredient> ingredients = result.product.ingredients;

    final double energyServing =
        result.product.nutriments.energyServing / 4.184;
    final double fatServing = result.product.nutriments.fatServing;
    final double saltServing = result.product.nutriments.saltServing;
    final double saturedfatServing =
        result.product.nutriments.saturatedFatServing;
    final double carbohydrateServing =
        result.product.nutriments.carbohydratesServing;
    final double proteinServing = result.product.nutriments.proteinsServing;
    final double sodiumServing = result.product.nutriments.sodiumServing;
    // final int _nid = await dbHelper.queryNutritonRowCount();
    final int _nid = await dbHelper.queryNutritonRowCount();
    final _hid = await dbHelper.queryRowHistoryCount();
    final allNutrition = await dbHelper.queryNutritionRows(_nid);
    _useData = allNutrition[0];
    int rowCount = int.parse(_useData['_nid'].toString());
    int rowHistoryCount = _hid;
    // time stamp not successful yet
    nutritionTimeStamp = _useData['nutrition_timestamp'].toString();
    final String dataToday = DateFormat('dMy').format(DateTime.now());
    calorie =
        double.parse(_useData['calorie'].toString()) + (energyServing * 3 / 4);
    protein =
        double.parse(_useData['protein'].toString()) + (proteinServing * 3 / 4);
    carbohydrate = double.parse(_useData['carbohydrate'].toString()) +
        (carbohydrateServing * 3 / 4);
    fat = double.parse(_useData['fat'].toString()) + (fatServing * 3 / 4);
    saturedFat = double.parse(_useData['saturedFat'].toString()) +
        (saturedfatServing * 3 / 4);
    // unsaturedFat = fat - unsaturedFat;
    sodium =
        double.parse(_useData['sodium'].toString()) + (sodiumServing * 3 / 4);
    salt = double.parse(_useData['salt'].toString()) + (saltServing * 3 / 4);
    final Map<String, dynamic> row = <String, dynamic>{
      DatabaseHelper.columnNutritionId: rowCount,
      DatabaseHelper.columnNutritionCalorie: calorie.round(),
      DatabaseHelper.columnNutritionProtein: protein.round(),
      DatabaseHelper.columnNutritionCarbohydrate: carbohydrate.round(),
      DatabaseHelper.columnNutritionFat: fat.round(),
      DatabaseHelper.columnNutritionSaturedFat: saturedFat.round(),
      DatabaseHelper.columnNutritionSodium: sodium.round(),
      DatabaseHelper.columnNutritionSalt: salt.round(),
      DatabaseHelper.columnNutritionTimeStamp: nutritionTimeStamp
    };
    final Map<String, dynamic> rowInsert = <String, dynamic>{
      DatabaseHelper.columnNutritionId: rowCount + 1,
      DatabaseHelper.columnNutritionCalorie: calorie.round(),
      DatabaseHelper.columnNutritionProtein: protein.round(),
      DatabaseHelper.columnNutritionCarbohydrate: carbohydrate.round(),
      DatabaseHelper.columnNutritionFat: fat.round(),
      DatabaseHelper.columnNutritionSaturedFat: saturedFat.round(),
      DatabaseHelper.columnNutritionSodium: sodium.round(),
      DatabaseHelper.columnNutritionSalt: salt.round(),
      DatabaseHelper.columnNutritionTimeStamp:
          int.parse(DateFormat('dMy').format(DateTime.now()))
    };
    //History
    final Map<String, dynamic> rowInsertHistory = <String, dynamic>{
      DatabaseHelper.productConsumeId: rowHistoryCount + 1,
      DatabaseHelper.productConsumeBarcode: calorie.round(),
      DatabaseHelper.productConsumeTimeStamp:
          int.parse(DateFormat('dMy').format(DateTime.now()))
    };

    if (DateFormat('dMy').format(DateTime.now()) == nutritionTimeStamp) {
      final int nid = await dbHelper.updateNutrition(row);
      print('update row id: $nid');
      // use when history rdy
      // final int pid = await dbHelper.insertProductConsume(rowInsertHistory);
      // print('update row id: $pid');
    } else {
      final int nid = await dbHelper.insertNutriton(rowInsert);
      print('insert row id: $nid a new day!');
      // final int pid = await dbHelper.insertProductConsume(rowInsertHistory);
      // print('insert row id: $pid a new day!');
    }
    // final int nid = await dbHelper.updateNutrition(row);
    // print('update row id: $nid');
    print(row);
    print(toEatBarcode);
    print(rowCount);
    print(nutritionTimeStamp);

    notifyListeners();
  }

  Future<void> productToEat1of4(Product product) async {
    final String toEatBarcode = product.barcode;
    final ProductQueryConfiguration configurations = ProductQueryConfiguration(
        toEatBarcode,
        language: OpenFoodFactsLanguage.GERMAN,
        fields: [
          ProductField.NUTRIMENTS,
          ProductField.INGREDIENTS_TEXT,
          ProductField.INGREDIENTS,
          ProductField.ADDITIVES,
          ProductField.NUTRIENT_LEVELS
        ]);

    final ProductResult result =
        await OpenFoodAPIClient.getProduct(configurations, user: SMOOTH_USER);

    if (result.status != 1) {
      // print('Error retreiving the product : ${result.status.errorVerbose}');
      print('Error retreiving the product ');

      return;
    }
    final String ingredientsT = result.product.ingredientsText;
    final List<Ingredient> ingredients = result.product.ingredients;

    final double energyServing =
        result.product.nutriments.energyServing / 4.184;
    final double fatServing = result.product.nutriments.fatServing;
    final double saltServing = result.product.nutriments.saltServing;
    final double saturedfatServing =
        result.product.nutriments.saturatedFatServing;
    final double carbohydrateServing =
        result.product.nutriments.carbohydratesServing;
    final double proteinServing = result.product.nutriments.proteinsServing;
    final double sodiumServing = result.product.nutriments.sodiumServing;
    // final int _nid = await dbHelper.queryNutritonRowCount();
    final int _nid = await dbHelper.queryNutritonRowCount();
    final _hid = await dbHelper.queryRowHistoryCount();
    final allNutrition = await dbHelper.queryNutritionRows(_nid);
    _useData = allNutrition[0];
    int rowCount = int.parse(_useData['_nid'].toString());
    int rowHistoryCount = _hid;
    // time stamp not successful yet
    nutritionTimeStamp = _useData['nutrition_timestamp'].toString();
    final String dataToday = DateFormat('dMy').format(DateTime.now());
    calorie =
        double.parse(_useData['calorie'].toString()) + (energyServing * 1 / 4);
    protein =
        double.parse(_useData['protein'].toString()) + (proteinServing * 1 / 4);
    carbohydrate = double.parse(_useData['carbohydrate'].toString()) +
        (carbohydrateServing * 1 / 4);
    fat = double.parse(_useData['fat'].toString()) + (fatServing * 1 / 4);
    saturedFat = double.parse(_useData['saturedFat'].toString()) +
        (saturedfatServing * 1 / 4);
    // unsaturedFat = fat - unsaturedFat;
    sodium =
        double.parse(_useData['sodium'].toString()) + (sodiumServing * 1 / 4);
    salt = double.parse(_useData['salt'].toString()) + (saltServing * 1 / 4);
    final Map<String, dynamic> row = <String, dynamic>{
      DatabaseHelper.columnNutritionId: rowCount,
      DatabaseHelper.columnNutritionCalorie: calorie.round(),
      DatabaseHelper.columnNutritionProtein: protein.round(),
      DatabaseHelper.columnNutritionCarbohydrate: carbohydrate.round(),
      DatabaseHelper.columnNutritionFat: fat.round(),
      DatabaseHelper.columnNutritionSaturedFat: saturedFat.round(),
      DatabaseHelper.columnNutritionSodium: sodium.round(),
      DatabaseHelper.columnNutritionSalt: salt.round(),
      DatabaseHelper.columnNutritionTimeStamp: nutritionTimeStamp
    };
    final Map<String, dynamic> rowInsert = <String, dynamic>{
      DatabaseHelper.columnNutritionId: rowCount + 1,
      DatabaseHelper.columnNutritionCalorie: calorie.round(),
      DatabaseHelper.columnNutritionProtein: protein.round(),
      DatabaseHelper.columnNutritionCarbohydrate: carbohydrate.round(),
      DatabaseHelper.columnNutritionFat: fat.round(),
      DatabaseHelper.columnNutritionSaturedFat: saturedFat.round(),
      DatabaseHelper.columnNutritionSodium: sodium.round(),
      DatabaseHelper.columnNutritionSalt: salt.round(),
      DatabaseHelper.columnNutritionTimeStamp:
          int.parse(DateFormat('dMy').format(DateTime.now()))
    };
    //History
    final Map<String, dynamic> rowInsertHistory = <String, dynamic>{
      DatabaseHelper.productConsumeId: rowHistoryCount + 1,
      DatabaseHelper.productConsumeBarcode: calorie.round(),
      DatabaseHelper.productConsumeTimeStamp:
          int.parse(DateFormat('dMy').format(DateTime.now()))
    };

    if (DateFormat('dMy').format(DateTime.now()) == nutritionTimeStamp) {
      final int nid = await dbHelper.updateNutrition(row);
      print('update row id: $nid');
      // use when history rdy
      // final int pid = await dbHelper.insertProductConsume(rowInsertHistory);
      // print('update row id: $pid');
    } else {
      final int nid = await dbHelper.insertNutriton(rowInsert);
      print('insert row id: $nid a new day!');
      // final int pid = await dbHelper.insertProductConsume(rowInsertHistory);
      // print('insert row id: $pid a new day!');
    }
    // final int nid = await dbHelper.updateNutrition(row);
    // print('update row id: $nid');
    print(row);
    print(toEatBarcode);
    print(rowCount);
    print(nutritionTimeStamp);

    notifyListeners();
  }

  Future<void> showEnergy(Product product) async {
    String toEatBarcode = product.barcode;
    ProductQueryConfiguration configurations = ProductQueryConfiguration(
        toEatBarcode,
        language: OpenFoodFactsLanguage.GERMAN,
        fields: [
          ProductField.NUTRIMENTS,
          ProductField.INGREDIENTS_TEXT,
          ProductField.INGREDIENTS,
          ProductField.ADDITIVES,
          ProductField.NUTRIENT_LEVELS
        ]);

    ProductResult result =
        await OpenFoodAPIClient.getProduct(configurations, user: SMOOTH_USER);

    if (result.status != 1) {
      // print('Error retreiving the product : ${result.status.errorVerbose}');
      print('Error retreiving the product ');

      return;
    }
  }

  void resetToZero() async {
    initState();
    final Map<String, dynamic> row = <String, dynamic>{
      DatabaseHelper.columnNutritionId: 1,
      DatabaseHelper.columnNutritionCalorie: 0,
      DatabaseHelper.columnNutritionProtein: 0,
      DatabaseHelper.columnNutritionCarbohydrate: 0,
      DatabaseHelper.columnNutritionFat: 0,
      DatabaseHelper.columnNutritionSaturedFat: 0,
      DatabaseHelper.columnNutritionSodium: 0,
      DatabaseHelper.columnNutritionSalt: 0
    };
    final int nid = await dbHelper.updateNutrition(row);
    print('update row id: $nid');
    print(row);
  }

  notifyListeners();
}
