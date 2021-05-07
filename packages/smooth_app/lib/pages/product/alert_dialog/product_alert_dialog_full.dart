import 'dart:math';

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:smooth_app/database/database_helper.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';

class AlertDialogFull extends StatefulWidget {
  const AlertDialogFull(this.product);
  final Product product;
  @override
  _AlertDialogFullState createState() => _AlertDialogFullState();
}

class _AlertDialogFullState extends State<AlertDialogFull> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  Map<String, dynamic> _useData;
  Map<String, dynamic> _useNutritionData;
  bool _fetchingData = true;
  Product _product;
  int _userCalorie,
      _userProteinConsume,
      _userCarbohydrateConsume,
      _userFatConsume,
      _userSaturedFatConsume,
      _userUnSaturedFatConsume,
      _userSodiumConsume,
      _userWeight,
      _userHeight,
      _userAge,
      _bmr;
  String _userGender;
  int userH, userW;
  List<double> proteinList,
      carbohydrateList,
      fatList,
      satFatList,
      unsatFatList,
      sodiumList;
  double proteinPerDay,
      carbPerDay,
      fatPerDay,
      satFatPerDay,
      unsatFatPerDay,
      sodiumPerDay;
  double productProtein,
      productCarb,
      productFat,
      productSatFat,
      productSodium,
      productEnergy;

  static const User SMOOTH_USER = User(
    userId: 'project-smoothie',
    password: 'smoothie',
    comment: 'Test user for project smoothie',
  );

  @override
  void initState() {
    // _scrollController = ScrollController();
    _query();
    super.initState();
    // bmrCalculate();
    super.initState();
    retrieveProductBarcodeData(_product);
  }

  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    final int _nid = await dbHelper.queryNutritonRowCount();
    final allNutrition = await dbHelper.queryNutritionRows(_nid);

    print('query all rows:');
    allRows.forEach((row) => print(row));
    allNutrition.forEach((row) => print(row));

    setState(() {
      _useData = allRows[0];
      _useNutritionData = allNutrition[0];
      _userProteinConsume = int.parse(_useNutritionData['protein'].toString());
      _userCarbohydrateConsume =
          int.parse(_useNutritionData['carbohydrate'].toString());
      _userFatConsume = int.parse(_useNutritionData['fat'].toString());
      _userSaturedFatConsume =
          int.parse(_useNutritionData['saturedFat'].toString());
      _userSodiumConsume = int.parse(_useNutritionData['sodium'].toString());
      _userAge = int.parse(_useData['age'].toString());
      _userHeight = int.parse(_useData['height'].toString());
      _userWeight = int.parse(_useData['weight'].toString());
      _userGender = _useData['gender'].toString();
      _fetchingData = false;
    });
  }

  void retrieveProductBarcodeData(Product product) async {
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
      print('Error retreiving the product');

      return;
    }
    setState(() {
      productEnergy = result.product.nutriments.proteinsServing;
    });
  }

  @override
  Widget build(BuildContext context) {
    _product ??= widget.product;
    return Container(
      child: Column(children: <Widget>[
        const Text('If you consume at this portion'),
        const SizedBox(
          height: 10,
        ),
        const Text('Your amount of nutrient left will be'),
        energyCard(),
        sodiumCard(),
        proteinCard(),
        carbohydrateCard(),
        fatCard()
      ]),
    );
  }
  Widget energyCard() {
    final double width = MediaQuery.of(context).size.width;
    int bmr; //kcal
    if (_userGender == 'Male') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr = (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
          .round();
    }
    var energyPerday = bmr,
        energyConsume = double.parse(_useNutritionData['calorie'].toString()) +
            (widget.product.nutriments.energyKcal);
    var energyProgress = energyConsume / energyPerday,
        energyLeft = (energyPerday - energyConsume).round();
    return SmoothCard(
        color: Colors.teal[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              _IngredientProgress(
                ingredient: 'Energy',
                progress: energyProgress,
                progressColor: Colors.teal[900],
                progressColorEnd: Colors.teal[800],
                leftAmount: energyLeft,
                amountPerday: energyPerday.round(),
                width: width * 0.28,
              ),
            ])
          ],
        ));
  }

  Widget proteinCard() {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    List<double> proteinList = [];
    int bmr; //kcal
    if (_userGender == 'Male') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr = (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
          .round();
    }
    if (_useData['diabates'] == 1) {
      proteinList.add((bmr * 0.2) / 4);
    }
    if (_useData['hypertension'] == 1) {
      proteinList.add((bmr * 0.15) / 4);
    }
    if (_useData['hyperlipidemia'] == 1) {
      proteinList.add((bmr * 0.15) / 4);
    }
    if (_useData['kidney'] == 1) {
      proteinList.add((bmr * 0.15) / 4);
    }
    if (_useData['diabates'] == 0 &&
        _useData['hypertension'] == 0 &&
        _useData['hyperlipidemia'] == 0 &&
        _useData['kidney'] == 0) {
      proteinList.add((bmr * 0.15) / 4);
    }
    var proteinPerDay = proteinList.reduce(min).round(),
        _proteinConsume =
            double.parse(_useNutritionData['protein'].toString()) +
                (widget.product.nutriments.proteinsServing);
    var proteinProgress = _proteinConsume / proteinPerDay,
        proteinLeft = (proteinPerDay - _proteinConsume).round();
    if (proteinProgress >= 1.0) {
      proteinProgress = 1.0;
    }
    return SmoothCard(
        color: Colors.pink[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(children: <Widget>[
              _IngredientProgress(
                ingredient: 'Protein',
                progress: proteinProgress,
                progressColor: Colors.pink[900],
                progressColorEnd: Colors.pink[800],
                leftAmount: proteinLeft,
                amountPerday: proteinPerDay.round(),
                width: width * 0.28,
              ),
            ])
          ],
        ));
  }

  Widget carbohydrateCard() {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    List<double> carbohydrateList = [];
    int bmr; //kcal
    if (_userGender == 'Male') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr = (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
          .round();
    }
    if (_useData['diabates'] == 1) {
      carbohydrateList.add((bmr * 0.63) / 4);
    }
    if (_useData['hypertension'] == 1) {
      carbohydrateList.add((bmr * 0.65) / 4);
    }
    if (_useData['hyperlipidemia'] == 1) {
      carbohydrateList.add((bmr * 0.6) / 9);
    }
    if (_useData['kidney'] == 1) {
      carbohydrateList.add((bmr * 0.6) / 4);
    }
    if (_useData['diabates'] == 0 &&
        _useData['hypertension'] == 0 &&
        _useData['hyperlipidemia'] == 0 &&
        _useData['kidney'] == 0) {
      carbohydrateList.add((bmr * 0.65) / 4);
    }
    var carbohydratePerDay = carbohydrateList.reduce(min).round(),
        _carbohydrateConsume =
            double.parse(_useNutritionData['carbohydrate'].toString()) +
                (widget.product.nutriments.carbohydratesServing);
    var carbohydrateProgress = _carbohydrateConsume / carbohydratePerDay,
        carbohydrateLeft = (carbohydratePerDay - _carbohydrateConsume).round();
    if (carbohydrateProgress >= 1.0) {
      carbohydrateProgress = 1.0;
    }
    return SmoothCard(
        color: Colors.lightGreen[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                _IngredientProgress(
                  ingredient: 'Carbohydrate',
                  progress: carbohydrateProgress,
                  progressColor: Colors.lightGreen[900],
                  progressColorEnd: Colors.lightGreen[800],
                  leftAmount: carbohydrateLeft,
                  amountPerday: carbohydratePerDay.round(),
                  width: width * 0.28,
                ),
              ],
            )
          ],
        ));
  }

  Widget fatCard() {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    List<double> fatList = [];
    List<double> satFatList = [];
    List<double> unsatFatList = [];
    int bmr; //kcal
    if (_userGender == 'Male') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr = (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
          .round();
    }
    if (_useData['diabates'] == 1) {
      fatList.add((bmr * 0.17) / 9);
      satFatList.add((bmr * 0.07) / 9);
      unsatFatList.add((bmr * 0.1) / 9);
    }
    if (_useData['hypertension'] == 1) {
      fatList.add((bmr * 0.2) / 9);
      satFatList.add(bmr * 0.1);
      unsatFatList.add(bmr * 0.1);
    }
    if (_useData['hyperlipidemia'] == 1) {
      fatList.add((bmr * 0.17) / 9);
      satFatList.add((bmr * 0.07) / 9);
      unsatFatList.add((bmr * 0.1) / 9);
    }
    if (_useData['kidney'] == 1) {
      fatList.add((bmr * 0.2) / 9);
      satFatList.add((bmr * 0.07) / 9);
      unsatFatList.add((bmr * 0.13) / 9);
    }
    if (_useData['diabates'] == 0 &&
        _useData['hypertension'] == 0 &&
        _useData['hyperlipidemia'] == 0 &&
        _useData['kidney'] == 0) {
      fatList.add((bmr * 0.2) / 9);
      satFatList.add((bmr * 0.1) / 9);
      unsatFatList.add((bmr * 0.1) / 9);
    }
    final fatPerDay = fatList.reduce(min).round(),
        satFatPerDay = satFatList.reduce(min).round(),
        unsatFatPerday = unsatFatList.reduce(min).round(),
        _fatConsume = double.parse(_useNutritionData['fat'].toString()) +
            (widget.product.nutriments.fatServing),
        _satFatConsume = double.parse(_useNutritionData['fat'].toString()) +
            (widget.product.nutriments.saturatedFatServing),
        _unsatFatConsume = _fatConsume - _satFatConsume;
    var fatProgress = _fatConsume / fatPerDay,
        satfatProgress = _satFatConsume / satFatPerDay,
        unsatProgress = _unsatFatConsume / unsatFatPerday,
        fatLeft = (fatPerDay - _fatConsume).round(),
        satFatLeft = (satFatPerDay - _satFatConsume).round(),
        unsatFatLeft = (unsatFatPerday - _unsatFatConsume).round();

    if (fatProgress >= 1.0) {
      fatProgress = 1.0;
    }
    if (satfatProgress >= 1.0) {
      satfatProgress = 1.0;
    }
    if (unsatProgress >= 1.0) {
      unsatProgress = 1.0;
    }
    return SmoothCard(
        color: Colors.amber[100],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  _IngredientProgress(
                    ingredient: 'Fat',
                    progress: fatProgress,
                    progressColor: Colors.amberAccent[400],
                    progressColorEnd: Colors.amberAccent[100],
                    leftAmount: fatLeft,
                    amountPerday: fatPerDay.round(),
                    width: width * 0.28,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  _IngredientProgress(
                    ingredient: 'Satured Fat',
                    progress: satfatProgress,
                    progressColor: Colors.amber,
                    progressColorEnd: Colors.amber[300],
                    leftAmount: satFatLeft,
                    amountPerday: satFatPerDay.round(),
                    width: width * 0.28,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  _IngredientProgress(
                    ingredient: 'Unsatured Fat',
                    progress: unsatProgress,
                    progressColor: Colors.amber,
                    progressColorEnd: Colors.amber[300],
                    leftAmount: unsatFatLeft,
                    amountPerday: unsatFatPerday.round(),
                    width: width * 0.28,
                  ),
                ])
              ],
            ),
          ],
        ));
  }

  Widget sodiumCard() {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    List<int> sodiumList = [];
    int bmr; //kcal
    if (_userGender == 'Male') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr = (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
          .round();
    }
    if (_useData['diabates'] == 1) {
      sodiumList.add(2000);
    }
    if (_useData['hypertension'] == 1) {
      sodiumList.add(2000);
    }
    if (_useData['hyperlipidemia'] == 1) {
      sodiumList.add(2300);
    }
    if (_useData['kidney'] == 1) {
      sodiumList.add(2000);
    }
    if (_useData['diabates'] == 0 &&
        _useData['hypertension'] == 0 &&
        _useData['hyperlipidemia'] == 0 &&
        _useData['kidney'] == 0) {
      sodiumList.add(2000);
    }
    var sodiumPerDay = sodiumList.reduce(min).round(),
        _sodiumConsume = int.parse(_useNutritionData['fat'].toString()) +
            (widget.product.nutriments.sodiumServing * 1000).round();
    return SmoothCard(
        color: Colors.lime[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SaltProgress(
                      ingredient: 'Sodium',
                      progress: _sodiumConsume / sodiumPerDay,
                      progressColor: Colors.lime[800],
                      progressColorEnd: Colors.lime[700],
                      leftAmount: sodiumPerDay - _sodiumConsume,
                      amountPerday: sodiumPerDay,
                      width: width * 0.25,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ));
  }
}

class _IngredientProgress extends StatelessWidget {
  final String ingredient;
  final int leftAmount;
  final int amountPerday;
  final double progress, width;
  final Color progressColor;
  final Color progressColorEnd;

  const _IngredientProgress(
      {Key key,
      this.ingredient,
      this.leftAmount,
      this.amountPerday,
      this.progress,
      this.progressColor,
      this.width,
      this.progressColorEnd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String textShow;
    if (leftAmount < 0) {
      textShow = 'over limit';
    } else {
      textShow = '$leftAmount / $amountPerday g';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          ingredient.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 10,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.black12,
                  ),
                ),
                Container(
                  height: 10,
                  width: width * progress,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: progressColor,
                      gradient: LinearGradient(
                          colors: [progressColor, progressColorEnd])),
                )
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              textShow,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SaltProgress extends StatelessWidget {
  final String ingredient;
  final int leftAmount;
  final int amountPerday;
  final double progress, width;
  final Color progressColor;
  final Color progressColorEnd;

  const _SaltProgress(
      {Key key,
      this.ingredient,
      this.leftAmount,
      this.amountPerday,
      this.progress,
      this.progressColor,
      this.width,
      this.progressColorEnd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String textShow;
    if (leftAmount < 0) {
      textShow = 'over limit';
    } else {
      textShow = '$leftAmount / $amountPerday mg';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          ingredient.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 10,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.black12,
                  ),
                ),
                Container(
                  height: 10,
                  width: width * progress,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: progressColor,
                      gradient: LinearGradient(
                          colors: [progressColor, progressColorEnd])),
                )
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              textShow,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EnergyProgress extends StatelessWidget {
  final String ingredient;
  final int leftAmount;
  final int amountPerday;
  final double progress, width;
  final Color progressColor;
  final Color progressColorEnd;

  const _EnergyProgress(
      {Key key,
      this.ingredient,
      this.leftAmount,
      this.amountPerday,
      this.progress,
      this.progressColor,
      this.width,
      this.progressColorEnd})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String textShow;
    if (leftAmount < 0) {
      textShow = 'over limit';
    } else {
      textShow = '$leftAmount / $amountPerday kcal';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          ingredient.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: 10,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    color: Colors.black12,
                  ),
                ),
                Container(
                  height: 10,
                  width: width * progress,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: progressColor,
                      gradient: LinearGradient(
                          colors: [progressColor, progressColorEnd])),
                )
              ],
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              textShow,
              style: TextStyle(
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
