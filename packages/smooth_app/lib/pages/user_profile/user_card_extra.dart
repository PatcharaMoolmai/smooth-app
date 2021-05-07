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
import 'package:openfoodfacts/model/Product.dart';
import 'package:smooth_app/database/database_helper.dart';
import 'package:smooth_app/functions/user_product_process.dart';
import 'package:smooth_app/pages/user_profile/user_edit_profile.dart';
import 'package:smooth_app/pages/user_profile/user_login_profile.dart';
import 'package:smooth_app/pages/user_profile/user_profile_screen.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class UserCardExtra extends StatefulWidget {
  @override
  _UserCardExtraState createState() => _UserCardExtraState();
}

class _UserCardExtraState extends State<UserCardExtra> {
  final dbHelper = DatabaseHelper.instance;
  ScrollController _scrollController;
  Map<String, dynamic> _useData;
  Map<String, dynamic> _useNutritionData;
  bool _fetchingData = true;
  int _userCalorie,
      _userProteinConsume,
      _userCarbohydrateConsume,
      _userFatConsume,
      _userSaturedFatConsume,
      _userUnSaturedFatConsume,
      _userSodiumConsume,
      _userWeight,
      _userHeight,
      _userAge;
  String _userGender;
  int userH, userW;
  @override
  void initState() {
    _scrollController = ScrollController();
    _query();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    _userUnSaturedFatConsume = _userFatConsume - _userSaturedFatConsume;
    var proteinPerDay = _userWeight * (0.2),
        carbohydratePerDay = _userWeight * (0.5),
        fatPerDay = _userWeight * (0.2);
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    Product _product;
    return Scaffold(
      body: SmoothRevealAnimation(
        animationCurve: Curves.easeInOutBack,
        startOffset: const Offset(0.0, 0.1),
        child: Center(
          child: Container(
            // mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.center,
            child: ListView(
              controller: _scrollController,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: <Widget>[
                SizedBox(
                  height: 10,
                ),
                SmoothCard(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Nutrition Today',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    sodiumCard(),
                    proteinCard(),
                    carbohydrateCard(),
                    fatCard(),
                  ],
                )),
                GestureDetector(
                  child: SmoothCard(
                      child: Column(children: <Widget>[
                    ListTile(
                      title: Text(
                        'Name',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      subtitle: Text(
                        ' ${_useData['name']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _useData['gender'] == 'Male'
                              ? Colors.blue[200]
                              : Colors.pink[200],
                        ),
                      ),
                    ),
                    _underlyingDisease(),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      'See more',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    )
                  ])),
                  onTap: () async {
                    await Navigator.push<Widget>(
                      context,
                      MaterialPageRoute<Widget>(
                          builder: (BuildContext context) =>
                              // UserLogin(),
                              UserProfilePage()),
                    );
                  },
                ),
                // SmoothSimpleButton(
                //     text: 'Clear List',
                //     width: 150.0,
                //     onPressed: () => UserProductProcess().resetToZero()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _underlyingDisease() {
    final int userDiabete = int.parse(_useData['diabates'].toString()),
        userHypertension = int.parse(_useData['hypertension'].toString()),
        userHyperlipidemia = int.parse(_useData['hyperlipidemia'].toString()),
        userKidneyDisease = int.parse(_useData['kidney'].toString());
    final Map<String, int> underlyingDiseaseMap = {
      'Diabates Mellitus (โรคเบาหวาน)': userDiabete,
      'Hypertension (โรคความดันโลหิตสูง)': userHypertension,
      'Hyperlipidemia (โรคไขมันในเลือดสูง)': userHyperlipidemia,
      'Chronic Kidney Disease (โรคไตเรื้อรัง)': userKidneyDisease,
    };
    underlyingDiseaseMap.removeWhere((String key, int value) {
      return value == 0;
    });
    if (userDiabete == 1 ||
        userHypertension == 1 ||
        userHyperlipidemia == 1 ||
        userKidneyDisease == 1) {
      return ListTile(
        title: Text(
          'Underlying Disease (โรคประจำตัว)',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        subtitle: Text(
          '${underlyingDiseaseMap.keys.join(',\n')}',
          style: const TextStyle(color: Colors.deepOrange, fontSize: 16),
        ),
      );
    } else {
      return ListTile(
        title: Text(
          'Underlying Disease (โรคประจำตัว)',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        subtitle: const Text('ไม่พบโรคประจำตัว'),
      );
    }
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
        _proteinConsume = double.parse(_useNutritionData['protein'].toString());
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
            const SizedBox(
              height: 10,
            ),
            Row(children: <Widget>[
              const SizedBox(
                width: 5,
              ),
              _UserProteinRadial(
                width: width * 0.35,
                height: width * 0.35,
                progress: 0.7,
              ),
              const SizedBox(
                width: 10,
              ),
              _IngredientProgress(
                ingredient: 'Protein',
                progress: proteinProgress,
                progressColor: Colors.pink[900],
                progressColorEnd: Colors.pink[800],
                leftAmount: proteinLeft,
                amountPerday: proteinPerDay.round(),
                width: width * 0.28,
              ),
            ]),
            const SizedBox(
              height: 10,
            ),
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
            double.parse(_useNutritionData['carbohydrate'].toString());
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
            const SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                _UserCarbRadial(
                  width: width * 0.35,
                  height: width * 0.35,
                  progress: 0.7,
                ),
                const SizedBox(
                  width: 10,
                ),
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
            ),
            SizedBox(
              height: 10,
            ),
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
        _fatConsume = double.parse(_useNutritionData['fat'].toString()),
        _satFatConsume = double.parse(_useNutritionData['fat'].toString()),
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
            SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                _UserFatRadial(
                  width: width * 0.35,
                  height: width * 0.35,
                  progress: 0.7,
                ),
                const SizedBox(
                  width: 10,
                ),
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
            SizedBox(
              height: 10,
            ),
          ],
        ));
  }

  Widget sodiumCard() {
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;
    List<double> sodiumList = [];
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
        _sodiumConsume = double.parse(_useNutritionData['fat'].toString());
    return SmoothCard(
        color: Colors.lime[50],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 10,
            ),
            Row(
              children: <Widget>[
                const SizedBox(
                  width: 5,
                ),
                _UserSodiumRadial(
                  width: width * 0.35,
                  height: width * 0.35,
                  progress: 0.7,
                ),
                const SizedBox(
                  width: 10,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'SODIUM',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: 1.0,
                        width: 130.0,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 5,),
                    _SaltProgress(
                      ingredient: 'Salt',
                      progress: (_sodiumConsume * 2.54 / 1000) /
                          (sodiumPerDay * 2.54 / 1000),
                      progressColor: Colors.lime[800],
                      progressColorEnd: Colors.lime[700],
                      leftAmount: (sodiumPerDay - _sodiumConsume) * 2.54 / 1000,
                      amountPerday: sodiumPerDay * 2.54 / 1000,
                      width: width * 0.25,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
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
      textShow = '$leftAmount / $amountPerday \n g left';
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
  final double leftAmount;
  final double amountPerday;
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
      textShow = '${leftAmount.toStringAsFixed(2)} / $amountPerday \n g left';
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

class _UserSodiumRadial extends StatefulWidget {
  const _UserSodiumRadial(
      {Key key, this.height, this.width, this.progress, this.userCardExtra})
      : super(key: key);
  final double height, width, progress;
  final UserCardExtra userCardExtra;

  @override
  __UserSodiumRadialState createState() => __UserSodiumRadialState();
}

class __UserSodiumRadialState extends State<_UserSodiumRadial> {
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
    List<double> sodiumList = [];
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
        _sodiumConsume = double.parse(_useNutritionData['fat'].toString());
    return CustomPaint(
      painter: _RadialSodiumPainter(
        progress: _sodiumConsume / sodiumPerDay,
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
                  text: '${sodiumPerDay - _sodiumConsume}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.lime[700],
                  ),
                ),
                const TextSpan(text: '\n'),
                TextSpan(
                  text: '/$sodiumPerDay \nmg left',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.lime[800],
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

class _UserProteinRadial extends StatefulWidget {
  const _UserProteinRadial(
      {Key key, this.height, this.width, this.progress, this.userCardExtra})
      : super(key: key);
  final double height, width, progress;
  final UserCardExtra userCardExtra;

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
    if (_userGender == 'Male') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr = (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
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
        _proteinConsume =
            4 * (double.parse(_useNutritionData['protein'].toString()));
    return CustomPaint(
      painter: _RadialProteinPainter(
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
                    color: Colors.pink[800],
                  ),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: '/$proteinPerDay \nkcal left',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.pink[900],
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
  const _UserCarbRadial(
      {Key key, this.height, this.width, this.progress, this.userCardExtra})
      : super(key: key);
  final double height, width, progress;
  final UserCardExtra userCardExtra;

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
    if (_userGender == 'Male') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr = (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
          .round();
    }
    if (_useData['diabates'] == 1) {
      carbohydrateList.add(bmr * 0.63);
    }
    if (_useData['hypertension'] == 1) {
      carbohydrateList.add(bmr * 0.65);
    }
    if (_useData['hyperlipidemia'] == 1) {
      carbohydrateList.add(bmr * 0.6);
    }
    if (_useData['kidney'] == 1) {
      carbohydrateList.add(bmr * 0.6);
    }
    if (_useData['diabates'] == 0 &&
        _useData['hypertension'] == 0 &&
        _useData['hyperlipidemia'] == 0 &&
        _useData['kidney'] == 0) {
      carbohydrateList.add(bmr * 0.65);
    }
    var carbohydratePerDay = carbohydrateList.reduce(min).round(),
        _carbohydrateConsume =
            4 * double.parse(_useNutritionData['carbohydrate'].toString());
    return CustomPaint(
      painter: _RadialCarbPainter(
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
                    color: Colors.lightGreen[800],
                  ),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: '/$carbohydratePerDay \nkcal left',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.lightGreen[900],
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
    int bmr;
    List<double> fatList = [];

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
    if (_userGender == 'Male') {
      bmr = (66 + (13.7 * _userWeight) + (5 * _userHeight) - (6.8 * _userAge))
          .round();
    } else {
      bmr = (665 + (9.6 * _userWeight) + (1.8 * _userHeight) - (4.7 * _userAge))
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
      painter: _RadialFatPainter(
        progress: _fatConsume * 9 / fatPerDay,
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
                  text: '${fatPerDay - (_fatConsume * 9)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.amberAccent[400],
                  ),
                ),
                TextSpan(text: '\n'),
                TextSpan(
                  text: '/$fatPerDay \nkcal left',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.amberAccent[700],
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

class _RadialProteinPainter extends CustomPainter {
  final double progress;

  _RadialProteinPainter({this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 8
      ..color = Colors.pink[900]
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

class _RadialCarbPainter extends CustomPainter {
  final double progress;

  _RadialCarbPainter({this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 8
      ..color = Colors.lightGreen[900]
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

class _RadialFatPainter extends CustomPainter {
  final double progress;

  _RadialFatPainter({this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 8
      ..color = Colors.amberAccent[400]
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

class _RadialSodiumPainter extends CustomPainter {
  _RadialSodiumPainter({this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = 8
      ..color = Colors.lime[600]
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
