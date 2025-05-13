import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_teacher/initities/theme.dart';
import 'package:school_teacher/screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'E-Attendance',
        theme: themeData(),
        home: SplashScreen(),
      ),
    );
  }
}

