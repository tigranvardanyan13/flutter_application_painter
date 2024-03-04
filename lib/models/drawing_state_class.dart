import 'package:flutter/material.dart';
import 'package:flutter_application_painter/constants/app_colors.dart';

class DrawingState {
  final Offset startPoint;
  final Offset endPoint;
  final bool isLineStart;
  final bool isLineEnd;
  final Color lineColor;
  final bool hasIntersection;
  bool isSelected = false;

  DrawingState(
      {required this.startPoint,
      required this.endPoint,
      this.isLineStart = false,
      this.isLineEnd = false,
      this.lineColor = AppColors.black,
      this.hasIntersection = false,
      this.isSelected = false});
}
