import 'package:flutter/material.dart';
import 'package:smart_kitchen/colors.dart';
import 'package:smart_kitchen/login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Kitchen',
      theme: _lTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(
              primaryColor: Color(0xFF4aa0d5),
              backgroundColor: Colors.white,
              backgroundImage:
                  new AssetImage("assets/images/login_page_img.jpg"),
            ),
        '/login': (context) => LoginScreen(
              primaryColor: Color(0xFF4aa0d5),
              backgroundColor: Colors.white,
              backgroundImage:
                  new AssetImage("assets/images/login_page_img.jpg"),
            ),
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
    highlightColor: lCyan50,
    splashColor: lCyan300,
    buttonColor: lCyan300,
    scaffoldBackgroundColor: lBackgroundCyan50,
    textSelectionColor: lCyan300,
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
