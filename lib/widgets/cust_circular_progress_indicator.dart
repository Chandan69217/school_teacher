import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../initities/colors.dart';

class CustCircularProgress extends StatelessWidget{
  Color? color;
  double? size;
  CustCircularProgress({this.color = CustColors.dark_sky,this.size});
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size.width * 0.05;
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: size! * 0.18,
        ),
      ),
    );
  }

}