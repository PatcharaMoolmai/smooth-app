// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'dart:math';
import 'dart:io';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_app/database/database_helper.dart';
import 'package:smooth_app/pages/user_profile/user_card_extra.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class _UserProteinRadial extends StatefulWidget {
  final double height, width, progress;
  final UserCardExtra userCardExtra;

  const _UserProteinRadial(
      {Key key, this.height, this.width, this.progress, this.userCardExtra})
      : super(key: key);
  @override
  __UserProteinRadialState createState() => __UserProteinRadialState();
}

class __UserProteinRadialState extends State<_UserProteinRadial> {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    int bmr;
    List<double> proteinList = [];
    if (_userGender == 'Man') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr =
          (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
              .round();
    }
    if (_useData['diabates'] == 1) {
      proteinList.add(bmr * 0.2);
    }
    if (_useData['hypertension'] == 1) {
      proteinList.add(bmr * 0.15);
    }
    if (_useData['hyperlipidemia'] == 1) {
      proteinList.add(bmr * 0.15);
    }
    if (_useData['kidney'] == 1) {
      proteinList.add(bmr * 0.15);
    }
    if (_useData['diabates'] == 0 &&
        _useData['hypertension'] == 0 &&
        _useData['hyperlipidemia'] == 0 &&
        _useData['kidney'] == 0) {
      proteinList.add(bmr * 0.15);
    }
    var proteinPerDay = proteinList.reduce(min).round(),
        _proteinConsume = double.parse(_useNutritionData['protein'].toString());
    return CustomPaint(
      painter: _RadialPainter(
        progress: _proteinConsume / proteinPerDay,
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
                  text: '${proteinPerDay - _proteinConsume}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF200087),
                  ),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: '/$proteinPerDay \nkcal left',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF200087),
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

class _UserCarbRadial extends StatefulWidget {
  final double height, width, progress;
  final UserCardExtra userCardExtra;

  const _UserCarbRadial(
      {Key key, this.height, this.width, this.progress, this.userCardExtra})
      : super(key: key);

  @override
  __UserCarbRadialState createState() => __UserCarbRadialState();
}

class __UserCarbRadialState extends State<_UserCarbRadial> {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    // int __userCalorie;
    int bmr;
    List<double> carbohydrateList = [];
    if (_userGender == 'Man') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr =
          (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
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
            double.parse(_useNutritionData['carbohydrate'].toString());
    return CustomPaint(
      painter: _RadialPainter(
        progress: _carbohydrateConsume / carbohydratePerDay,
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
                  text: '${carbohydratePerDay - _carbohydrateConsume}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF200087),
                  ),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: '/$carbohydratePerDay \nkcal left',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF200087),
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

class _UserFatRadial extends StatefulWidget {
  final double height, width, progress;
  final UserCardExtra userCardExtra;

  const _UserFatRadial(
      {Key key, this.height, this.width, this.progress, this.userCardExtra})
      : super(key: key);

  @override
  __UserFatRadialState createState() => __UserFatRadialState();
}

class __UserFatRadialState extends State<_UserFatRadial> {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    int bmr;
    List<double> fatList = [];
    List<double> satFatList = [];
    List<double> unsatFatList = [];
    if (_userGender == 'Man') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr =
          (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
              .round();
    }
    if (_useData['diabates'] == 1) {
      fatList.add(bmr * 0.17);
    }
    if (_useData['hypertension'] == 1) {
      fatList.add(bmr * 0.2);
    }
    if (_useData['hyperlipidemia'] == 1) {
      fatList.add(bmr * 0.17);
    }
    if (_useData['kidney'] == 1) {
      fatList.add(bmr * 0.2);
    }
    if (_useData['diabates'] == 0 &&
        _useData['hypertension'] == 0 &&
        _useData['hyperlipidemia'] == 0 &&
        _useData['kidney'] == 0) {
      fatList.add(bmr * 0.2);
    }
    final fatPerDay = fatList.reduce(min).round(),
        _fatConsume = double.parse(_useNutritionData['fat'].toString());
    return CustomPaint(
      painter: _RadialPainter(
        progress: _fatConsume / fatPerDay,
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
                  text: '${fatPerDay - _fatConsume}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF200087),
                  ),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: '/$fatPerDay \nkcal left',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF200087),
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
    Paint paint = Paint()
      ..strokeWidth = 8
      ..color = Color(0xFF200087)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double relativeProgress = 360 * progress;

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

