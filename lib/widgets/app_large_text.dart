import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AppLargeTxt extends StatelessWidget {
  double size;
  final String text;
  final Color color;
  AppLargeTxt({Key ? key, 
    required this.size,
    required this.text, 
    required this.color}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.bold

      ),
    );
  }
}