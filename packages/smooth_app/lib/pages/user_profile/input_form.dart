// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:numberpicker/numberpicker.dart';

// Package imports:
import 'package:path/path.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_ui_library/widgets/smooth_expandable_card.dart';
import 'package:smooth_ui_library/widgets/smooth_listTile.dart';
import 'package:sqflite/sqflite.dart';

// Project import:
import 'package:smooth_app/database/user_profile_database.dart';

// import from login lib_loyd

class UserFormInput extends StatefulWidget {
  const UserFormInput(
    this.nameTextController,
    this.parentAction,
    this.ageTextController,
    this.heightTextController,
    this.weightTextController,
  );

  @override
  _UserFormInputState createState() => _UserFormInputState();

  final TextEditingController nameTextController;
  final TextEditingController ageTextController;
  final TextEditingController heightTextController;
  final TextEditingController weightTextController;
  final ValueChanged<List<dynamic>> parentAction;
}

enum GenderEnum { male, female }

class _UserFormInputState extends State<UserFormInput>
    with AutomaticKeepAliveClientMixin<UserFormInput> {
  List _myActivities;
  String _myActivitiesResult;
  GenderEnum _userGender = GenderEnum.male;
  String _selectDateString = 'Select your birthday';
  DateTime _selectedDate = DateTime.now();
  bool _diabatesCheck = false,
      _hypertensionCheck = false,
      _hyperlipidemiaCheck = false,
      _kidneyCheck = false;

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1930, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _selectDateString = '${_selectedDate.toLocal()}'.split(' ')[0];
        _passDataToParent('age', calculateAge(picked));
      });
    print('your age is ${calculateAge(picked)}');
  }

  dynamic calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  int _currentHorizontalIntValue = 50;
  int _currentIntValue = 150;
  // @override
  // void initState() {
  //   super.initState();
  //   _myActivities = [];
  //   _myActivitiesResult = '';
  // }

  final underlyingDisease = [
    {
      'display': 'Diabates (โรคเบาหวาน)',
      'value': 'Diabates',
    },
    {
      'display': 'Hypertension (โรคความดันโลหิตสูง)',
      'value': 'Hypertension',
    },
    {
      "display": "Hyperlipidemia (โรคไขมันในเลือดสูง)",
      "value": "Hyperlipidemia",
    },
    {
      "display": "Kidney disease (โรคไต)",
      "value": "Kidney disease",
    },
  ];
  List<String> _underlyingDisease = [
    'diabates',
    'Hypertension',
    'Hyperlipidemia',
    'Kidney'
  ];

  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.grey[400]),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: Column(
        children: <Widget>[
          // Text('My Profile'),
          SizedBox(
            width: 360,
            child: TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.account_circle),
                  labelText: 'Name',
                  hintText: 'Type Name'),
              textCapitalization: TextCapitalization.sentences,
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Name is required';
                } else {
                  return null;
                }
              },
              controller: widget.nameTextController,
            ),
          ),
          Divider(),
          Row(
            children: <Widget>[
              Icon(
                Icons.wc,
                color: Colors.grey,
              ),
              Radio(
                value: GenderEnum.male,
                groupValue: _userGender,
                onChanged: (GenderEnum value) {
                  setState(() {
                    _passDataToParent('gender', 'Male');
                    _userGender = value;
                  });
                },
              ),
              new GestureDetector(
                onTap: () {
                  setState(() {
                    _passDataToParent('gender', 'Male');
                    _userGender = GenderEnum.male;
                  });
                },
                child: Text('Male'),
              ),
              SizedBox(
                width: 20,
              ),
              Radio(
                value: GenderEnum.female,
                groupValue: _userGender,
                onChanged: (GenderEnum value) {
                  setState(() {
                    _passDataToParent('gender', 'Female');
                    _userGender = value;
                  });
                },
              ),
              new GestureDetector(
                onTap: () {
                  setState(() {
                    _passDataToParent('gender', 'Female');
                    _userGender = GenderEnum.female;
                  });
                },
                child: Text('Female'),
              ),
            ],
          ),
          Divider(),
          // Age Form
          // SizedBox(
          //   width: 360,
          //   child: TextFormField(
          //     decoration: InputDecoration(
          //         border: InputBorder.none,
          //         icon: Icon(Icons.cake),
          //         labelText: 'Age',
          //         hintText: 'Type Age'),
          //     keyboardType: TextInputType.number,
          //     validator: (String value) {
          //       if (value.trim().isEmpty) {
          //         return 'Age is required';
          //       } else {
          //         return null;
          //       }
          //     },
          //     controller: widget.ageTextController,
          //   ),
          // ),
          // Age Datepicker
          SizedBox(
            width: 360,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.cake,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 14.0),
                  child: Container(
                    width: 260,
                    child: RaisedButton(
                      onPressed: () {
                        _selectDate(context);
                      },
                      child: Text(_selectDateString),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          // Height Form
          // SizedBox(
          //   width: 360,
          //   child: TextFormField(
          //     decoration: InputDecoration(
          //         border: InputBorder.none,
          //         icon: Icon(Icons.height),
          //         labelText: 'Height (cm)',
          //         hintText: 'Type Height'),
          //     keyboardType: TextInputType.number,
          //     validator: (String value) {
          //       if (value.trim().isEmpty) {
          //         return 'Height is required';
          //       } else {
          //         return null;
          //       }
          //     },
          //     controller: widget.heightTextController,
          //   ),
          // ),
          // Height Picker
          SizedBox(
              width: 360,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Height',
                      style: TextStyle(color: Colors.grey),
                    ),
                    NumberPicker(
                        value: _currentIntValue,
                        minValue: 100,
                        maxValue: 250,
                        step: 1,
                        haptics: true,
                        itemHeight: 35,
                        onChanged: (int value) => setState(() {
                              _currentIntValue = value;
                              _passDataToParent('height', _currentIntValue);
                            })),
                    const Text(
                      'cm',
                      style: TextStyle(color: Colors.grey),
                    )
                  ])),

          const Divider(),
          // Weight Form
          // SizedBox(
          //   width: 360,
          //   child: TextFormField(
          //     decoration: InputDecoration(
          //         border: InputBorder.none,
          //         icon: Icon(Icons.person),
          //         labelText: 'Weight (kg)',
          //         hintText: 'Type Weight'),
          //     keyboardType: TextInputType.number,
          //     validator: (String value) {
          //       if (value.trim().isEmpty) {
          //         return 'Weight is required';
          //       } else {
          //         return null;
          //       }
          //     },
          //     controller: widget.weightTextController,
          //   ),
          // ),
          // Weight Picker
          SizedBox(
              width: 360,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Text(
                    'Weight',
                    style: TextStyle(color: Colors.grey),
                  ),
                  NumberPicker(
                    value: _currentHorizontalIntValue,
                    minValue: 0,
                    maxValue: 120,
                    step: 1,
                    itemHeight: 35,
                    itemWidth: 50,
                    axis: Axis.horizontal,
                    onChanged: (int value) => setState(() {
                      _currentHorizontalIntValue = value;
                      _passDataToParent('weight', _currentHorizontalIntValue);
                    }),
                    // _passDataToParent('weight', value)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      // border: Border.all(color: Colors.black26),
                    ),
                  ),
                  const Text(
                    'kg',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )),

          const Divider(),
          // Underlying Disease
          underlyingDiseaseChecklist(),
        ],
      ),
    );
  }

  Widget underlyingDiseaseChecklist() {
    return SmoothExpandableCard(
        collapsedHeader: const Text('Underlying Disease (โรคประจำตัว)'),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Checkbox(
                  value: _diabatesCheck,
                  onChanged: _setDiabates,
                ),
                GestureDetector(
                  onTap: () => _setDiabates(!_diabatesCheck),
                  child: const Text(
                    'Diabates Mellitus \n(โรคเบาหวาน)',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _hypertensionCheck,
                  onChanged: _setHypertension,
                ),
                GestureDetector(
                  onTap: () => _setHypertension(!_hypertensionCheck),
                  child: const Text(
                    'Hypertension (โรคความดันโลหิตสูง)',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _hyperlipidemiaCheck,
                  onChanged: _setHyperlipidemia,
                ),
                GestureDetector(
                  onTap: () => _setHyperlipidemia(!_hyperlipidemiaCheck),
                  child: const Text(
                    'Hyperlipidemia (โรคไขมันในเลือดสูง)',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Checkbox(
                  value: _kidneyCheck,
                  onChanged: _setKidneyD,
                ),
                GestureDetector(
                  onTap: () => _setKidneyD(!_kidneyCheck),
                  child: const Text(
                    'Chronic Kidney disease\n(โรคไตเรื้อรัง)',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            )
          ],
        ));
  }

  Future<void> _passDataToParent(String key, dynamic value) async {
    List<dynamic> addData = List<dynamic>();
    addData.add(key);
    addData.add(value);
    widget.parentAction(addData);
  }

  @override
  bool get wantKeepAlive => true;

  void _setDiabates(bool newValue) {
    _passDataToParent('diabates', 1);
    setState(() {
      _diabatesCheck = newValue;
    });
  }

  void _setHypertension(bool newValue) {
    setState(() {
      _passDataToParent('hypertension', 1);
      _hypertensionCheck = newValue;
    });
  }

  void _setHyperlipidemia(bool newValue) {
    setState(() {
      _passDataToParent('hyperlipidemia', 1);
      _hyperlipidemiaCheck = newValue;
    });
  }

  void _setKidneyD(bool newValue) {
    setState(() {
      _passDataToParent('kidney', 1);
      _kidneyCheck = newValue;
    });
  }
}
