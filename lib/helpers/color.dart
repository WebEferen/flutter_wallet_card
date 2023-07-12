import 'package:flutter/services.dart';

const white = Color.fromRGBO(255, 255, 255, 1);
const black = Color.fromRGBO(0, 0, 0, 1);

Color color({String? color, Color defaultColor = black}) {
  if (color == null) return defaultColor;

  final expression = RegExp(r'rgb\((\d{1,3}),(\d{1,3}),(\d{1,3})\)');
  final match = expression.firstMatch(color.replaceAll(' ', ''));

  if (match == null) return black;

  final red = int.parse(match.group(1)!);
  final green = int.parse(match.group(2)!);
  final blue = int.parse(match.group(3)!);

  return Color.fromRGBO(red, green, blue, 1);
}

String fromColor(Color? color) {
  if (color == null) return 'rgb(0,0,0)';
  return 'rgb(${color.red},${color.green},${color.blue})';
}
