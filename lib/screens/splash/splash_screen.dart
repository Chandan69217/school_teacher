import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:school_teacher/initities/colors.dart';
import 'package:school_teacher/screens/authentication/login_screen.dart';
import 'package:school_teacher/screens/dashboard.dart';
import 'package:school_teacher/widgets/cust_circular_progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../initities/consts.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _splashDelay(context);
    return Scaffold(
      backgroundColor: CustColors.dark_sky,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/icons/splash_icon.json'),
          // Text('My School',style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: CustColors.white,fontSize: 42.0),),
          // SizedBox(height: 20,),
          // Center(child: CustCircularProgress(color: CustColors.white,)),
        ],
      )
    );
  }

  Widget _navigateToNextScreen(BuildContext context, bool isLoggedIn) {
    return isLoggedIn
        ? DashboardScreen()
        : LoginScreen();
  }

  Future<void> _splashDelay(BuildContext context) async {
    Pref.instance = await SharedPreferences.getInstance();
    bool isLoggedIn = Pref.instance.getBool(Consts.isLogin) ?? false;
    await Future.delayed(const Duration(seconds: 2),() => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> _navigateToNextScreen(_, isLoggedIn))),);
  }

}

class Pref {
  static late SharedPreferences instance;
}
