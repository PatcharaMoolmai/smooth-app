// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Package imports:
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_ui_library/buttons/smooth_main_button.dart';
import 'package:sqflite/sqflite.dart';

// Project import:
import 'package:smooth_app/database/user_profile_database.dart';
import 'package:smooth_app/pages/user_profile/input_form.dart';
import 'package:smooth_app/database/database_helper.dart';

// import from login lib_loyd

class UserProfile extends StatefulWidget {
  const UserProfile(this._scrollController, {this.callback});
  final ScrollController _scrollController;
  final Function callback;

  static const double _TYPICAL_PADDING_OR_MARGIN = 12;

  static void showUserProfile(
    final BuildContext context, {
    final Function callback,
  }) =>
      showCupertinoModalBottomSheet<Widget>(
        expand: false,
        context: context,
        backgroundColor: Colors.transparent,
        bounce: true,
        barrierColor: Colors.black45,
        builder: (BuildContext context) => UserProfile(
          ModalScrollController.of(context),
          callback: callback,
        ),
      );

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
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
    _query();
    _userDataMap['gender'] = 'Male';
    super.initState();
  }

  Future<void> _update() async {
    // update user profile data
    final Map<String, dynamic> row = <String, dynamic>{
      DatabaseHelper.columnId: 1,
      DatabaseHelper.columnName: _nameTextController.text,
      DatabaseHelper.columnGender: _userDataMap['gender'],
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
    print('update row id: $id');
    print(row);
    super.widget;
  }

  Future<void> _query() async {
    final allRows = await dbHelper.queryAllRows();
    // final allNutritionRows = await dbHelper.queryAllNutritionRows();

    print('query all rows:');
    allRows.forEach((row) {
      print(row);
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double buttonWidth =
        (screenSize.width - UserProfile._TYPICAL_PADDING_OR_MARGIN * 3) / 2;

    return Material(
      child: Container(
        height: screenSize.height * 0.9,
        child: Stack(
          children: <Widget>[
            Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: screenSize.height * 0.9,
                    child: ListView(
                      controller: _scrollController,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          margin:
                              const EdgeInsets.only(top: 20.0, bottom: 24.0),
                          child: Text(
                            // Header
                            'My Profile',
                            style: Theme.of(context).textTheme.headline1,
                          ),
                        ),
                        UserFormInput(
                          _nameTextController,
                          _updateMyTitle,
                          _ageTextController,
                          _heightTextController,
                          _weightTextController,
                        ),
                        SizedBox(
                          height: screenSize.height * 0.15,
                        ),
                      ],
                    ),
                  )
                ]),
            // User Profile Editing

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
                          horizontal: UserProfile._TYPICAL_PADDING_OR_MARGIN,
                          vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SmoothMainButton(
                              text: 'Cancel',
                              minWidth: buttonWidth,
                              important: false,
                              onPressed: () => Navigator.pop(context)),
                          SmoothMainButton(
                            text: 'OK',
                            minWidth: buttonWidth,
                            important: true,
                            onPressed: () {
                              print('insert data process');
                              print('name: ${_nameTextController.text}');
                              _update();
                              Navigator.pop(context);
                              super.widget;
                              if (widget.callback != null) {
                                widget.callback();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void parentAction(List value) {}
}
