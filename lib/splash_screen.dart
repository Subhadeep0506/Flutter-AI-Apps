// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_const_constructors

import './home_screen.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      title: Text(
        'Captions Generator',
        style: TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontFamily: 'Satisfy',
        ),
      ),
      loadingText: Text(
        'Loading...',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      loaderColor: Colors.white,
      navigateAfterSeconds: HomePage(),
      imageBackground: Image.asset('assets/splashscreen.png').image,
    );
  }
}
