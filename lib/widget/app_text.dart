
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final Color? color;
  final String text;
  final double size;
  final bool bold;

  const AppText({ Key? key,
    this.color = Colors.white,
    required this.text,
    this.size = 20,
    this.bold = false
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontFamily: 'Roboto',
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        fontSize: size,
      ),
    );
  }
}