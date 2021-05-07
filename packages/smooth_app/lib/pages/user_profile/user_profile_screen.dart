// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:math';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/database/database_helper.dart';
import 'package:smooth_app/pages/home_page.dart';
import 'package:smooth_app/pages/scan/scan_page.dart';
import 'package:smooth_app/pages/user_profile/user_card.dart';
import 'package:smooth_app/pages/user_profile/user_edit_profile.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_ui_library/animations/smooth_reveal_animation.dart';
import 'package:smooth_ui_library/buttons/smooth_simple_button.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final dbHelper = DatabaseHelper.instance;
  int userH, userW;
  Map<String, dynamic> _useData;
  bool _fetchingData = true;
  @override
  void initState() {
    _query();
    super.initState();
  }

  Future<void> _query() async {
    final allRows = await dbHelper.queryAllRows();
    final allNutrition = await dbHelper.queryAllNutritionRows();
    print('query all rows:');

    allRows.forEach((row) => print(row));
    allNutrition.forEach((row) => print(row));
    setState(() {
      _useData = allRows[0];
      userH = int.parse(_useData['height'].toString());
      userW = int.parse(_useData['weight'].toString());
      _fetchingData = false;
    });
  }

  double _bmi;
  int userW_m;

  Widget showBMI() {
    _bmi = userW / pow(userH / 100, 2);
    if (_bmi > 30) {
      return ListTile(
        title: Text(
          'BMI',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        subtitle: Text(
          '${_bmi.toStringAsFixed(2)} = Obesity (เข้าข่ายโรคอ้วน)',
          style: TextStyle(
            fontSize: 15,
            color: Colors.red,
          ),
        ),
      );
    } else if (_bmi > 25) {
      return ListTile(
        title: Text(
          'BMI',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        subtitle: Text(
          '${_bmi.toStringAsFixed(2)} = Overweight (น้ำหนักเกินเกณฑ์)',
          style: TextStyle(
            fontSize: 15,
            color: Colors.brown,
          ),
        ),
      );
    } else if (_bmi > 18.5) {
      return ListTile(
        title: Text(
          'BMI',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        subtitle: Text(
          '${_bmi.toStringAsFixed(2)} = Normal (ปกติ)',
          style: TextStyle(
            fontSize: 15,
            color: Colors.green,
          ),
        ),
      );
    } else {
      return ListTile(
        title: Text(
          'BMI',
          style: Theme.of(context).textTheme.subtitle2,
        ),
        subtitle: Text(
          '${_bmi.toStringAsFixed(2)} =  Underweight (น้อยกว่าเกณฑ์)',
          style: TextStyle(
            fontSize: 15,
            color: Colors.yellow,
          ),
        ),
      );
    }
  }

  Widget _underlyingDisease() {
    final int userDiabete = int.parse(_useData['diabates'].toString()),
        userHypertension = int.parse(_useData['hypertension'].toString()),
        userHyperlipidemia = int.parse(_useData['hyperlipidemia'].toString()),
        userKidneyDisease = int.parse(_useData['kidney'].toString());
    // String diabateUI, hypertensionUI, hyperlipidemiaUI, kidneyUI;
    final Map<String, int> underlyingDiseaseMap = {
      'Diabates Mellitus (โรคเบาหวาน)': userDiabete,
      'Hypertension (โรคความดันโลหิตสูง)': userHypertension,
      'Hyperlipidemia (โรคไขมันในเลือดสูง)': userHyperlipidemia,
      'Chronic Kidney Disease (โรคไตเรื้อรัง)': userKidneyDisease,
    };
    List<Widget> underDList = new List<Widget>();
    underlyingDiseaseMap.removeWhere((String key, int value) {
      return value == 0;
    });
    if (userDiabete == 1 ||
        userHypertension == 1 ||
        userHyperlipidemia == 1 ||
        userKidneyDisease == 1) {
      // for (var underlyingList in underlyingDiseaseMap.keys) {
      //   underDList.add(ListTile(subtitle: Text(underlyingList)));
      // }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmoothRevealAnimation(
        animationCurve: Curves.easeInOutBack,
        startOffset: const Offset(0.0, 0.1),
        child: Center(
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 20.0,
              ),
              SmoothCard(
                  child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    '${_useData['name']}',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    title: Text(
                      'Age',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    subtitle: Text(
                      '${_useData['age']} years (ปี)',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Gender',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    subtitle: Text(
                      '${_useData['gender']}',
                      style: TextStyle(
                        fontSize: 15,
                        color: _useData['gender'] == 'Male'
                            ? Colors.blue[200]
                            : Colors.pink[200],
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Height',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    subtitle: Text('${_useData['height']} cm (เซนติเมตร)',
                        style: const TextStyle(fontSize: 15)),
                  ),
                  ListTile(
                    title: Text(
                      'Weight',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    subtitle: Text('${_useData['weight']} kg (กิโลกรัม)',
                        style: const TextStyle(fontSize: 15)),
                  ),
                  showBMI(),
                  _underlyingDisease(),
                  const SizedBox(
                    height: 20.0,
                  ),
                ],
              )),
              // SmoothSimpleButton(
              //     text: 'Edit your user profile',
              //     width: 150.0,
              //     onPressed: () => UserProfile.showUserProfile(context)),
            ],
          ),
        ),
      ),
    );
  }
}
