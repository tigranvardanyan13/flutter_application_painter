import 'package:flutter/material.dart';

const int relativeWidth = 360;
const int relativeHeight = 640;
const String fontNameDefault = 'SF UI Display';

double rw(BuildContext context) {
  return rwWidth(MediaQuery.of(context).size.width);
}

double rwWidth(double width) {
  return width / relativeWidth;
}

double rh(BuildContext context) {
  return rhHeight(MediaQuery.of(context).size.height);
}

double rhHeight(double height) {
  return height / relativeHeight;
}

TextStyle getStyle(
    {Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextDecoration? textDecoration,
    double? height}) {
  return TextStyle(
      fontFamily: fontNameDefault,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      decoration: textDecoration,
      height: height);
}
