import 'package:app_movil/screens/home.dart';
import 'package:app_movil/screens/login.dart';
import 'package:app_movil/screens/onboarding.dart';
import 'package:app_movil/screens/request_permission.dart';
import 'package:app_movil/screens/splash.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Universidad Taxi',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Montserrat'),
        initialRoute: '/home',
        routes: <String, WidgetBuilder>{
          '/onboarding': (BuildContext context) => const Onboarding(),
          '/login': (BuildContext context) => const Login(),
          '/home': (BuildContext context) => const Home(),
          /* '/splash': (BuildContext context) => const Splash(),
          '/request_permission': (BuildContext context) =>
              const RequestPermission(), */
          /* '/home': (BuildContext context) => new Home(),
          '/settings': (BuildContext context) => new Settings(),
          "/onboarding": (BuildContext context) => new Onboarding(),
          "/pro": (BuildContext context) => new Pro(),
          "/profile": (BuildContext context) => new Profile(),
          "/articles": (BuildContext context) => new Articles(),
          "/components": (BuildContext context) => new Components(),
          "/account": (BuildContext context) => new Register(), */
        });
  }
}
