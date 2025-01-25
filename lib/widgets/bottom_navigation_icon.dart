

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomNavigationIcon extends StatelessWidget{

  final Color? iconColor;
  final IconData icon;
  final double opacity;

  BottomNavigationIcon({
    this.iconColor,
    required this.icon,
    required this.opacity,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: opacity,
            child: Container(
              height: 33.0,
              width: 48.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),

          Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
          )
        ]
    );
  }

}