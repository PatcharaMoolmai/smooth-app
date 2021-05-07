import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sentry/sentry.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_app/database/database_helper.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/pages/home_page.dart';
import 'package:smooth_app/pages/user_profile/user_login_profile.dart';
import 'package:smooth_app/temp/product_preferences_selection.dart';
import 'package:smooth_app/data_models/user_preferences.dart';
import 'package:smooth_app/themes/smooth_theme.dart';
import 'package:smooth_app/themes/theme_provider.dart';
import 'package:smooth_app/data_models/product_preferences.dart';

Future<void> main() async {
  await Sentry.init(
    (dynamic options) {
      options.dsn =
          'https://22ec5d0489534b91ba455462d3736680@o241488.ingest.sentry.io/5376745';
    },
  );
  try {
    runApp(MyApp());
  } catch (exception, stackTrace) {
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserPreferences _userPreferences;
  ProductPreferences _productPreferences;
  LocalDatabase _localDatabase;
  ThemeProvider _themeProvider;
  bool systemDarkmodeOn = false;
  DatabaseHelper _databaseHelper;

  Future<void> _init(BuildContext context) async {
    _userPreferences = await UserPreferences.getUserPreferences();
    _productPreferences = ProductPreferences(
      ProductPreferencesSelection(
        (
          String attributeId,
          String importanceId,
        ) async =>
            await _userPreferences.setImportance(attributeId, importanceId),
        (String attributeId) => _userPreferences.getImportance(attributeId),
        () => _productPreferences.notifyListeners(),
      ),
    );
    try {
      await _productPreferences.loadReferenceFromAssets(
        DefaultAssetBundle.of(context),
      );
    } catch (e) {
      // this is problematic - we should always be able to load the default
      print('Could not load reference files: $e');
      rethrow;
    }
    await _userPreferences.init(_productPreferences);
    _localDatabase = await LocalDatabase.getLocalDatabase();
    _themeProvider = ThemeProvider(_userPreferences);
    // _databaseHelper = await Database
  }

  @override
  void initState() {
    final Brightness brightness =
        SchedulerBinding.instance.window.platformBrightness;
    systemDarkmodeOn = brightness == Brightness.dark;
    // _checkLogin();
    super.initState();
  }

  bool _isLogin = false;
  Future<void> _checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Object isLoginState = prefs.get('isLogin');
    final bool isLogin = (prefs.getBool('isLogin') ?? false);

    setState(() {
      _isLogin = isLogin;
    });

    print('prefs $isLogin');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _init(context),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: <ChangeNotifierProvider<dynamic>>[
              ChangeNotifierProvider<UserPreferences>.value(
                  value: _userPreferences),
              ChangeNotifierProvider<ProductPreferences>.value(
                  value: _productPreferences),
              ChangeNotifierProvider<LocalDatabase>.value(
                  value: _localDatabase),
              ChangeNotifierProvider<ThemeProvider>.value(
                  value: _themeProvider),
              ChangeNotifierProvider<DatabaseHelper>.value(
                  value: _databaseHelper
                  ),
            ],
            child: Consumer<ThemeProvider>(
              builder: (
                BuildContext context,
                ThemeProvider value,
                Widget child,
              ) {
                return MaterialApp(
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  theme: SmoothTheme.getThemeData(
                    Brightness.light,
                    _themeProvider.colorTag,
                  ),
                  darkTheme: SmoothTheme.getThemeData(
                    Brightness.dark,
                    _themeProvider.colorTag,
                  ),
                  themeMode: _themeProvider.darkTheme
                      ? ThemeMode.dark
                      : ThemeMode.light,
                  home: SmoothAppGetLanguage(),
                );
              },
            ),
          );
        }
        return Container(
          color: systemDarkmodeOn ? const Color(0xFF181818) : Colors.white,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

/// Layer needed because we need to know the language
class SmoothAppGetLanguage extends StatefulWidget {
  @override
  _SmoothAppGetLanguageState createState() => _SmoothAppGetLanguageState();
}

class _SmoothAppGetLanguageState extends State<SmoothAppGetLanguage> {
  bool _isLogin = false;

  @override
  void initState(){
    _checkLogin();
    super.initState();
  }
  Future<void> _checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Object isLoginState = prefs.get('isLogin');
    final bool isLogin = (prefs.getBool('isLogin') ?? false);

    setState(() {
      _isLogin = isLogin;
    });

    print('prefs $isLogin');
  }

  @override
  Widget build(BuildContext context) {
    final ProductPreferences productPreferences =
        context.watch<ProductPreferences>();
    final Locale myLocale = Localizations.localeOf(context);
    final String languageCode = myLocale.languageCode;
    final DatabaseHelper databaseHelper =context.watch<DatabaseHelper>();
    _refresh(
      productPreferences,
      DefaultAssetBundle.of(context),
      databaseHelper,
      languageCode,
    );
    return 
    // HomePage();
    !_isLogin ? UserLogin() : HomePage();
  }

  Future<void> _refresh(
    final ProductPreferences productPreferences,
    final AssetBundle assetBundle,
    final DatabaseHelper databaseHelper,
    final String languageCode,
  ) async {
    await databaseHelper.queryAllNutritionRows();
    
    if (productPreferences.languageCode != languageCode) {
      try {
        await productPreferences.loadReferenceFromAssets(
          assetBundle,
          languageCode: languageCode,
        );
      } catch (e) {
        // no problem, we were just trying
      }
    }
    if (!productPreferences.isNetwork) {
      try {
        await productPreferences.loadReferenceFromNetwork(languageCode);
      } catch (e) {
        // no problem, we were just trying
      }
    }
  }
}
