import 'package:flutter/material.dart';
import 'package:school_teacher/initities/colors.dart';

ThemeData themeData(){
  return ThemeData(
      useMaterial3: true,
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: CustColors.black,fontWeight: FontWeight.w600,fontSize: 20.0),
      bodyMedium: TextStyle(color: CustColors.black,fontWeight: FontWeight.w500,fontSize: 18.0),
      bodySmall:  TextStyle(color: CustColors.black,fontSize: 14.0),
    )
  );
}