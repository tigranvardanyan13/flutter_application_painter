import 'package:flutter/material.dart';
import 'package:flutter_application_painter/constants/app_colors.dart';
import 'package:flutter_application_painter/constants/app_styles.dart';

class PositionedWidget extends StatelessWidget {
  const PositionedWidget(
      {required this.child,
      this.top,
      this.left,
      this.right,
      this.bottom,
      this.width,
      this.height,
      this.padding,
      super.key});

  final Widget child;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final double? width;
  final double? height;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: Container(
            width: (width ?? 80) * rw(context),
            height: (height ?? 30) * rh(context),
            padding: padding,
            decoration: BoxDecoration(
                color: AppColors.wildsand,
                borderRadius: BorderRadius.circular(10)),
            child: child));
  }
}
