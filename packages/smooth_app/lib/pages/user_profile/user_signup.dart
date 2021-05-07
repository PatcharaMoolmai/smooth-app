import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_ui_library/buttons/smooth_main_button.dart';

import 'input_form.dart';

class UserLoginScreen extends StatefulWidget {
  final ScrollController _scrollController;
  final Function callback;

  static const double _TYPICAL_PADDING_OR_MARGIN = 12;

  const UserLoginScreen(this._scrollController, this.callback);
  @override
  _UserLoginScreenState createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _nameTextController = TextEditingController();
  final TextEditingController _ageTextController = TextEditingController();
  final TextEditingController _heightTextController = TextEditingController();
  final TextEditingController _weightTextController = TextEditingController();

  Future<void> _updateMyTitle(List<dynamic> data) async {
    setState(() {
      _userDataMap[data[0].toString()] = data[1];
    });
  }

  Map<String, dynamic> _userDataMap = Map<String, dynamic>();
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double buttonWidth =
        (screenSize.width - UserLoginScreen._TYPICAL_PADDING_OR_MARGIN * 3) / 2;

    return Material(
      child: Container(
        height: screenSize.height * 0.9,
        child: Stack(
          children: <Widget>[
            // User Profile Editing
            // UserFormInput( _nameTextController, _ageTextController, _heightTextController, _weightTextController, _underlyingDiseaseTextController ),
            UserFormInput(
              _nameTextController,
              _updateMyTitle,
              _ageTextController,
              _heightTextController,
              _weightTextController,
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
                          horizontal: UserLoginScreen._TYPICAL_PADDING_OR_MARGIN,
                          vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // SmoothMainButton(
                          //     text: 'Cancel',
                          //     minWidth: buttonWidth,
                          //     important: false,
                          //     onPressed: () => Navigator.pop(context)),
                          SmoothMainButton(
                            text: 'Login',
                            minWidth: buttonWidth,
                            important: true,
                            onPressed: () {
                              print('login Successful');
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
}
