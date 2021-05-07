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
  Map<String, dynamic> _useData;
  bool _fetchingData = true;
  @override
  void initState() {
    _query();
    super.initState();
  }

  Future<void> _query() async {
    final allRows = await dbHelper.queryAllRows();
    final allRowHistory = await dbHelper.queryAllProductHistoryRows();
    print('query all rows:');

    allRows.forEach((row) => print(row));
    allRowHistory.forEach((row) => print(row));
    setState(() {
      _useData = allRows[0];
      _fetchingData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmoothRevealAnimation(
        animationCurve: Curves.easeInOutBack,
        startOffset: const Offset(0.0, 0.1),
        child: Center(
          child: Column(
            children: <Widget>[

              const SizedBox(
                height: 20.0,
              ),
              SmoothCard(
                  child: Column(
                children: <Widget>[
                  // UserProfileCard(),
                  Text(
                    '${_useData['name']}',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
