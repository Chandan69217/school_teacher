import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../initities/colors.dart';

class CustCircularProgress extends StatelessWidget{
  Color? color;
  CustCircularProgress({this.color = CustColors.dark_sky});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25.0,
      height: 25.0,
      child: Center(
        child: CircularProgressIndicator(
          color: color,
        ),
      ),
    );
  }

}