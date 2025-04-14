import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/signup_screen.dart';

void main() {
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      initialRoute: Constants.routeLogin,
      routes: {
        Constants.routeLogin: (context) => LoginScreen(),
        Constants.routeSignup: (context) => SignupScreen(),
        Constants.routeHome: (context) => HomeScreen(),
      },
    );
  }  
}