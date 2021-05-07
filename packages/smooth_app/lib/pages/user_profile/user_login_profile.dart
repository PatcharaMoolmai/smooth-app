// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/database/database_helper.dart';
import 'package:smooth_app/pages/home_page.dart';
import 'package:smooth_app/pages/user_profile/input_form.dart';
import 'package:smooth_ui_library/buttons/smooth_main_button.dart';
import 'package:smooth_ui_library/widgets/smooth_card.dart';

class UserLogin extends StatefulWidget {
  static const double _TYPICAL_PADDING_OR_MARGIN = 12;

  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _ageTextController = TextEditingController();
  final TextEditingController _heightTextController = TextEditingController();
  final TextEditingController _weightTextController = TextEditingController();
  ScrollController _scrollController;

  final Map<String, dynamic> _userDataMap = <String, dynamic>{};

  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<void> _setIsLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', true);
  }

  Future<void> _updateMyTitle(List<dynamic> data) async {
    setState(() {
      _userDataMap[data[0].toString()] = data[1];
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _userDataMap['gender'] = 'Male';
    super.initState();
  }

  Future<void> _insert() async {
    // row to insert
    final Map<String, dynamic> row = <String, dynamic>{
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnName: _nameTextController.text,
      DatabaseHelper.columnGender: _userDataMap['gender'],
      // DatabaseHelper.columnAge: _ageTextController.text,
      DatabaseHelper.columnAge: _userDataMap['age'],
      // DatabaseHelper.columnHeight: _heightTextController.text,
      DatabaseHelper.columnHeight: _userDataMap['height'],
      // DatabaseHelper.columnWeight: _weightTextController.text,
      DatabaseHelper.columnWeight: _userDataMap['weight'],
      DatabaseHelper.colmunDiabates: _userDataMap['diabates'] ??= 0,
      DatabaseHelper.colmunHypertension: _userDataMap['hypertension'] ??= 0,
      DatabaseHelper.colmunHyperlipidemia: _userDataMap['hyperlipidemia'] ??= 0,
      DatabaseHelper.colmunKidneyDisease: _userDataMap['kidney'] ??= 0
    };

    final int id = await dbHelper.update(row);
    print('inserted row id: $id');
    print(row);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double buttonWidth =
        (screenSize.width - UserLogin._TYPICAL_PADDING_OR_MARGIN * 3) / 2;
    return Scaffold(
        backgroundColor: Colors.cyan[700],
        body: Container(
          margin: const EdgeInsets.all(2.0),
          padding: const EdgeInsets.only(top: 10, bottom: 24),
          child: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SmoothCard(
                  child: Column(
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: Text(
                          ' Let us know about you',
                          style: Theme.of(context).textTheme.headline1,
                        ),
                      ),
                      Container(
                          height: screenSize.height * 0.7,
                          child: ListView(
                              controller: _scrollController,
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: <Widget>[
                                SizedBox(
                                  height: 5,
                                ),
                                // Header

                                // Input Form
                                UserFormInput(
                                  _nameTextController,
                                  _updateMyTitle,
                                  _ageTextController,
                                  _heightTextController,
                                  _weightTextController,
                                ),
                              ])),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 4.0,
                            sigmaY: 4.0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal:
                                    UserLogin._TYPICAL_PADDING_OR_MARGIN,
                                vertical: 20.0),
                            child: SmoothMainButton(
                              text: 'Login',
                              minWidth: buttonWidth,
                              important: true,
                              onPressed: () {
                                print('insert data process');
                                print('name: ${_nameTextController.text}');
                                _insert();
                                _setIsLogin();
                                Navigator.push<Widget>(
                                  context,
                                  MaterialPageRoute<Widget>(
                                      builder: (BuildContext context) =>
                                          HomePage()),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ))
            ],
          )),
        ));
  }
}
