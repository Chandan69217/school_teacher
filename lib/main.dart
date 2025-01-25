import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_teacher/initities/theme.dart';
import 'package:school_teacher/screens/dashboard.dart';
import 'package:school_teacher/screens/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: themeData(),
        home: SplashScreen(),
      ),
    );
  }
}

