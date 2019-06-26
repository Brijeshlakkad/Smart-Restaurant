import 'package:flutter/material.dart';
import 'package:smart_waiter/colors.dart';
import 'package:smart_waiter/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Waiter',
      theme: _lTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }
}

final ThemeData _lTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: lAppBarText,
    primaryColor: lAppBar,
    highlightColor: lYellow50,
    splashColor: lYellow300,
    buttonColor: lYellow300,
    scaffoldBackgroundColor: lBackgroundWhite,
    cardColor: lBackgroundWhite,
    textSelectionColor: lYellow300,
    errorColor: lErrorRed,
    buttonTheme: base.buttonTheme.copyWith(
      buttonColor: Colors.white,
      textTheme: ButtonTextTheme.normal,
    ),
    primaryIconTheme: base.iconTheme.copyWith(color: lBlue900),
    textTheme: _buildAppTextTheme(base.textTheme),
    primaryTextTheme: _buildAppTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildAppTextTheme(base.accentTextTheme),
  );
}

TextTheme _buildAppTextTheme(TextTheme base) {
  return base
      .copyWith(
    headline: base.headline.copyWith(
      fontWeight: FontWeight.w500,
    ),
    title: base.title.copyWith(fontSize: 18.0),
    caption: base.caption.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14.0,
    ),
    body2: base.body2.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
    ),
  )
      .apply(
    displayColor: lBlue900,
    bodyColor: lAppBarText,
  );
}
