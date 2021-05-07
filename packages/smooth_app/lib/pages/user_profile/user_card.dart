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
import 'package:numberpicker/numberpicker.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/database/database_helper.dart';
import 'package:smooth_app/functions/user_calculate.dart';
import 'package:smooth_app/functions/user_product_process.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class UserProfileCard extends StatefulWidget {
  @override
  _UserProfileCardState createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
  final dbHelper = DatabaseHelper.instance;
  Product _product;

  Map<String, dynamic> _useData;
  Map<String, dynamic> _useNutritionData;
  bool _fetchingData = true;
  int _userProtein,
      _userCarbohydrate,
      _userFat,
      _userWeight,
      _userHeight,
      _userAge;
  String _userGender, _userName;
  @override
  void initState() {
    _query();
    getUserInfo();
    super.widget;
    super.initState();
  }

  Future<void> _query() async {
    final List<Map<String, dynamic>> allRows = await dbHelper.queryAllRows();
    final List<Map<String, dynamic>> allNutritionRow =
        await dbHelper.queryAllNutritionRows();
    final int _nid = await dbHelper.queryNutritonRowCount();
    final List<Map<String, dynamic>> queryNutrition =
        await dbHelper.queryNutritionRows(_nid);

    print('query all rows:');
    allRows.forEach((row) => print(row));
    print('query all nutrition rows :');
    allNutritionRow.forEach((row) => print(row));
    setState(() {
      _useData = allRows[0];
      _useNutritionData = queryNutrition[0];
      _fetchingData = false;
      super.widget;
    });
  }

  Future<void> getUserInfo() async {
    setState(() {
      _userName = _useData['name'].toString();
      _userAge = int.parse(_useData['age'].toString());
      _userHeight = int.parse(_useData['height'].toString());
      _userWeight = int.parse(_useData['weight'].toString());
      _userGender = _useData['gender'].toString();
      super.widget;
    });
  }

  List<double> proteinList = [];
  List<double> carbohydrateList = [];
  List<double> fatList = [];
  int _currentHorizontalIntValue = 10;

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    return Positioned(
      top: 0,
      height: height * 0.35,
      left: 0,
      right: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: const Radius.circular(40),
        ),
        child: Container(
          color: Colors.white,
          padding:
              const EdgeInsets.only(top: 0, left: 17, right: 0, bottom: 15),
          child: _fetchingData
              ? const CircularProgressIndicator()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    userInfo(),
                    SizedBox(
                      height: 10,
                    ),
                    nutritionCalc(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget userInfo() {
    final DateTime today = DateTime.now();
    return FutureBuilder(
        future: getUserInfo(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListTile(
              title: Text(
                "${DateFormat("EEEE").format(today)}, ${DateFormat("d MMMM").format(today)}",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Hello, $_userName',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              // trailing: ClipOval(child: Image.asset("assets/user.jpg")),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Widget nutritionCalc() {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    // List<double> proteinList = [];
    // List<double> carbohydrateList = [];
    // List<double> fatList = [];
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
      carbohydrateList.add((bmr * 0.63) / 4);
      fatList.add((bmr * 0.17) / 9);
    }
    if (_useData['hypertension'] == 1) {
      proteinList.add((bmr * 0.15) / 4);
      carbohydrateList.add((bmr * 0.65) / 4);
      fatList.add((bmr * 0.2) / 9);
    }
    if (_useData['hyperlipidemia'] == 1) {
      proteinList.add((bmr * 0.15) / 4);
      carbohydrateList.add((bmr * 0.6) / 9);
      fatList.add((bmr * 0.17) / 9);
    }
    if (_useData['kidney'] == 1) {
      proteinList.add((bmr * 0.15) / 4);
      carbohydrateList.add((bmr * 0.6) / 4);
      fatList.add((bmr * 0.2) / 9);
    }
    if (_useData['diabates'] == 0 &&
        _useData['hypertension'] == 0 &&
        _useData['hyperlipidemia'] == 0 &&
        _useData['kidney'] == 0) {
      proteinList.add((bmr * 0.15) / 4);
      carbohydrateList.add((bmr * 0.65) / 4);
      fatList.add((bmr * 0.2) / 9);
      print(proteinList);
    }
    var proteinPerDay = proteinList.reduce(min).round(),
        carbohydratePerDay = carbohydrateList.reduce(min).round(),
        fatPerDay = fatList.reduce(min).round(),
        _proteinConsume = double.parse(_useNutritionData['protein'].toString()),
        _carbohydrateConsume =
            double.parse(_useNutritionData['carbohydrate'].toString()),
        _fatConsume = double.parse(_useNutritionData['fat'].toString()),
        _calorieConsume = double.parse(_useNutritionData['calorie'].toString());
    var proteinProgress = _proteinConsume / proteinPerDay,
        carbohydrateProgress = _carbohydrateConsume / carbohydratePerDay,
        fatProgress = _fatConsume / fatPerDay,
        proteinLeft = (proteinPerDay - _proteinConsume).round(),
        carbohydrateLeft = (carbohydratePerDay - _carbohydrateConsume).round(),
        fatLeft = (fatPerDay - _fatConsume).round();
    if (proteinProgress >= 1.0) {
      proteinProgress = 1.0;
    }
    if (carbohydrateProgress >= 1.0) {
      carbohydrateProgress = 1.0;
    }
    if (fatProgress >= 1.0) {
      fatProgress = 1.0;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FutureBuilder(
          future: UserProductProcess().productToEat(_product),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                child: Row(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: _RadialProgress(
                        width: width * 0.4,
                        height: width * 0.4,
                        progress: 0.7,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Column(children: <Widget>[
                      _IngredientProgress(
                        ingredient: 'Protein',
                        progress: proteinProgress,
                        progressColor: Colors.pink[900],
                        progressColorEnd: Colors.pink[800],
                        leftAmount: proteinLeft,
                        amountPerDay: proteinPerDay.round(),
                        width: width * 0.28,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      _IngredientProgress(
                        ingredient: 'Carbohydrate',
                        progress: carbohydrateProgress,
                        progressColor: Colors.lightGreen[900],
                        progressColorEnd: Colors.lightGreen[800],
                        leftAmount: carbohydrateLeft,
                        amountPerDay: carbohydratePerDay.round(),
                        width: width * 0.28,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      _IngredientProgress(
                        ingredient: 'Fat',
                        progress: fatProgress,
                        progressColor: Colors.amberAccent[400],
                        progressColorEnd: Colors.amberAccent[100],
                        leftAmount: fatLeft,
                        amountPerDay: fatPerDay.round(),
                        width: width * 0.28,
                      ),
                    ])
                  ],
                ),
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }
}

// User Nutrition List
class _IngredientProgress extends StatelessWidget {
  final String ingredient;
  final int leftAmount;
  final int amountPerDay;
  final double progress, width;
  final Color progressColor;
  final Color progressColorEnd;

  const _IngredientProgress(
      {Key key,
      this.ingredient,
      this.leftAmount,
      this.amountPerDay,
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
      textShow = '$leftAmount / $amountPerDay\n g left';
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

//User Calorie Left
class _RadialProgress extends StatefulWidget {
  final double height, width, progress;
  final UserProfileCard userProfileCard;

  const _RadialProgress(
      {Key key, this.height, this.width, this.progress, this.userProfileCard})
      : super(key: key);

  @override
  __RadialProgressState createState() => __RadialProgressState();
}

class __RadialProgressState extends State<_RadialProgress> {
  final dbHelper = DatabaseHelper.instance;

  Map<String, dynamic> _useData;

  Map<String, dynamic> _useNutritionData;

  bool _fetchingData = true;

  int _userCalorie, _userAge, _userHeight, _userWeight;
  String _userGender;

  @override
  void initState() {
    _query();
    super.initState();
    super.widget;
  }

  Future<void> _query() async {
    final int _nid = await dbHelper.queryNutritonRowCount();
    final allNutritionRow = await dbHelper.queryNutritionRows(_nid);
    final allRow = await dbHelper.queryAllRows();

    print('query all rows:');
    print('${DateFormat("dMy").format(DateTime.now())}');
    allNutritionRow.forEach((row) => print(row));
    setState(() {
      _useData = allRow[0];
      _useNutritionData = allNutritionRow[0];
      _userCalorie = int.parse(_useNutritionData['calorie'].toString());
      _userAge = int.parse(_useData['age'].toString());
      _userHeight = int.parse(_useData['height'].toString());
      _userWeight = int.parse(_useData['weight'].toString());
      _userGender = _useData['gender'].toString();
      _fetchingData = false;
      super.widget;
    });
  }

  @override
  Widget build(BuildContext context) {
    // int __userCalorie;
    int _bmr;
    if (_userGender == 'Male') {
      _bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      _bmr =
          (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
              .round();
    }
    return CustomPaint(
      painter: _RadialPainter(
        progress: _userCalorie / _bmr,
      ),
      child: Container(
        height: widget.height,
        width: widget.width,
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${_bmr - _userCalorie}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.teal[800],
                  ),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: '/$_bmr \nkcal left',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.teal[800],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadialPainter extends CustomPainter {
  final double progress;

  _RadialPainter({this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 8
      ..color = Colors.teal[400]
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double relativeProgress = 360 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: size.width / 2),
      math.radians(-90),
      math.radians(-relativeProgress),
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
