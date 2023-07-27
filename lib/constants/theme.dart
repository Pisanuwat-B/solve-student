import 'package:flutter/material.dart';

const Color primaryColor = Color(0xff20b153);
Color secoundaryColor = getMaterialColor(primaryColor).shade200;
const Color tertiaryColor = Color(0xFFF2E7E1);
Color backgroundColor = Colors.white;
const Color greyColor = Color(0xffaeaeae);
const Color greyColor2 = Color(0xffE8E8E8);
const Color warningColor = Color(0xffCC6700);
const Color warningColor2 = Color(0xffFFE0B2);

const appTextPrimaryColor = Color(0xff1C1F34);
const appTextSecondaryColor = Color(0xff6C757D);
const cardColor = Color(0xFFF6F7F9);
const borderColor = Color(0xFFEBEBEB);

var gradientStyle = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  stops: [0.3, 0.8],
  colors: [
    primaryColor,
    secoundaryColor,
  ],
);

var gradientColors = [
  primaryColor,
  secoundaryColor,
];

MaterialColor getMaterialColor(Color color) {
  final int red = color.red;
  final int green = color.green;
  final int blue = color.blue;
  final Map<int, Color> shades = {
    50: Color.fromRGBO(red, green, blue, .1),
    100: Color.fromRGBO(red, green, blue, .2),
    200: Color.fromRGBO(red, green, blue, .3),
    300: Color.fromRGBO(red, green, blue, .4),
    400: Color.fromRGBO(red, green, blue, .5),
    500: Color.fromRGBO(red, green, blue, .6),
    600: Color.fromRGBO(red, green, blue, .7),
    700: Color.fromRGBO(red, green, blue, .8),
    800: Color.fromRGBO(red, green, blue, .9),
    900: Color.fromRGBO(red, green, blue, 1),
  };
  return MaterialColor(color.value, shades);
}
