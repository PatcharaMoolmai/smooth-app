// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

class UserProfileInput extends StatefulWidget {
  const UserProfileInput(
      {Key key,
      this.nameTextController,
      this.ageTextController,
      this.heightTextController,
      this.weightTextController,
      this.underlying_diseaseTextController,
      this.parentAction})
      : super(key: key);

  final TextEditingController nameTextController;
  final TextEditingController ageTextController;
  final TextEditingController heightTextController;
  final TextEditingController weightTextController;
  final TextEditingController underlying_diseaseTextController;

  final ValueChanged<List<dynamic>> parentAction;

  @override
  _UserProfileInputState createState() => _UserProfileInputState();
}

enum GenderEnum { man, woman }

class _UserProfileInputState extends State<UserProfileInput>
    with AutomaticKeepAliveClientMixin<UserProfileInput> {
  GenderEnum _userGender = GenderEnum.man;
  List _myActivities;
  String _selectDateString = 'Select your birthday';
  DateTime _selectedDate = DateTime.now();
  final underlying_disease = [
    {
      "display": "Diabates (โรคเบาหวาน)",
      "value": "Diabates",
    },
    {
      "display": "Hypertension (โรคความดันโลหิตสูง)",
      "value": "Hypertension",
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

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime(1930, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _selectDateString = "${_selectedDate.toLocal()}".split(' ')[0];
        _passDataToParent('age', calculateAge(picked));
      });
    print('your age is ${calculateAge(picked)}');
  }

  int calculateAge(DateTime birthDate) {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.all(13.0),
      decoration: BoxDecoration(
        // border: Border.all(color: Colors.grey[400]),
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child: Column(
        children: <Widget>[
          const Text('My Profile'),
          SizedBox(
            width: 360,
            child: TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.account_circle),
                  labelText: 'Name',
                  hintText: 'Type Name'),
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
                value: GenderEnum.man,
                groupValue: _userGender,
                onChanged: (GenderEnum value) {
                  setState(() {
                    _passDataToParent('gender', 'Man');
                    _userGender = value;
                  });
                },
              ),
              new GestureDetector(
                onTap: () {
                  setState(() {
                    _passDataToParent('gender', 'Man');
                    _userGender = GenderEnum.man;
                  });
                },
                child: Text('Man'),
              ),
              SizedBox(
                width: 20,
              ),
              Radio(
                value: GenderEnum.woman,
                groupValue: _userGender,
                onChanged: (GenderEnum value) {
                  setState(() {
                    _passDataToParent('gender', 'Woman');
                    _userGender = value;
                  });
                },
              ),
              new GestureDetector(
                onTap: () {
                  setState(() {
                    _passDataToParent('gender', 'Woman');
                    _userGender = GenderEnum.woman;
                  });
                },
                child: Text('Woman'),
              ),
            ],
          ),
          Divider(),
          // Age Form
          SizedBox(
            width: 360,
            child: TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.cake),
                  labelText: 'Age',
                  hintText: 'Type Age'),
              keyboardType: TextInputType.number,
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Age is required';
                } else {
                  return null;
                }
              },
              controller: widget.ageTextController,
            ),
          ),
          Divider(),
          SizedBox(
            width: 360,
            child: TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.height),
                  labelText: 'Height',
                  hintText: 'Type Age'),
              keyboardType: TextInputType.number,
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Height is required';
                } else {
                  return null;
                }
              },
              controller: widget.heightTextController,
            ),
          ),
          Divider(),
          SizedBox(
            width: 360,
            child: TextFormField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.person),
                  labelText: 'Weight',
                  hintText: 'Type Age'),
              keyboardType: TextInputType.number,
              validator: (String value) {
                if (value.trim().isEmpty) {
                  return 'Weight is required';
                } else {
                  return null;
                }
              },
              controller: widget.weightTextController,
            ),
          ),
          Divider(),
          // Congenital Disease
          MultiSelectFormField(
            autovalidate: false,
            chipBackGroundColor: Colors.red,
            chipLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            dialogTextStyle: TextStyle(fontWeight: FontWeight.bold),
            checkBoxActiveColor: Colors.blue,
            checkBoxCheckColor: Colors.green,
            dialogShapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),

            title: Text(
              'Underlying Disease(โรคประจำตัว)',
              style: TextStyle(fontSize: 16),
            ),
            dataSource: underlying_disease,
            textField: 'display',
            valueField: 'value',
            okButtonLabel: 'OK',
            cancelButtonLabel: 'CANCEL',
            hintWidget: Text(
                'หากท่านมีอาการของโรคดังต่อไปนี้ กรุณาเลือกโรคที่ท่านเป็นด้วยครับ'),
            initialValue: _myActivities,
            // onSaved: (value) {
            //   if (value == null) return;
            //   setState(() {
            //     _myActivities = value;
            //   });
            // },
          ),
        ],
      ),
    );
  }

  void _passDataToParent(String key, dynamic value) {
    List<dynamic> addData = List<dynamic>();
    addData.add(key);
    addData.add(value);
    widget.parentAction(addData);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => throw UnimplementedError();
}
