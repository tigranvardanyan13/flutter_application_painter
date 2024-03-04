import 'package:flutter/material.dart';
import 'package:flutter_application_painter/constants/app_colors.dart';
import 'package:flutter_application_painter/constants/app_styles.dart';

class ControllerWidget extends StatelessWidget {
  const ControllerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30 * rw(context),
      height: 30 * rh(context),
      child: Stack(children: [
        Center(
          child: Container(
            width: 10 * rw(context),
            height: 10 * rw(context),
            decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    width: 2 * rw(context), color: AppColors.bostonBlue)),
          ),
        ),
        Positioned(
          top: 0,
          left: 12 * rw(context),
          height: 11 * rh(context),
          child: Image.asset('assets/images/arrow.png', fit: BoxFit.cover),
        ),
        Positioned(
            bottom: 0,
            left: 12 * rw(context),
            height: 11 * rh(context),
            child: RotatedBox(
              quarterTurns: 2,
              child: Image.asset('assets/images/arrow.png', fit: BoxFit.cover),
            )),
        Positioned(
            top: 12 * rh(context),
            left: 0,
            width: 11 * rw(context),
            height: 5 * rh(context),
            child: RotatedBox(
              quarterTurns: 3,
              child: Image.asset('assets/images/arrow.png', fit: BoxFit.cover),
            )),
        Positioned(
            top: 12 * rh(context),
            right: 0,
            width: 11 * rw(context),
            height: 5 * rh(context),
            child: RotatedBox(
              quarterTurns: 1,
              child: Image.asset('assets/images/arrow.png', fit: BoxFit.cover),
            )),
      ]),
    );
  }
}
