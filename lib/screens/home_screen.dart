import 'package:flutter/material.dart';
import 'package:flutter_application_painter/constants/app_colors.dart';
import 'package:flutter_application_painter/constants/app_styles.dart';
import 'package:flutter_application_painter/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/positioned_widget.dart';
import '../shared/drawing_overlay.dart';
import 'dart:math' as math;

class MyScrollableScreen extends StatefulWidget {
  const MyScrollableScreen({super.key});

  @override
  State<MyScrollableScreen> createState() => _MyScrollableScreenState();
}

class _MyScrollableScreenState extends State<MyScrollableScreen> {
  List<Offset> points = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            bottom: false,
            child: Container(
              color: AppColors.silver,
              child: Stack(children: [
                InteractiveViewer(
                  boundaryMargin: EdgeInsets.all(200 * rw(context)),
                  minScale: 0.1,
                  maxScale: 3.0,
                  child: LayoutBuilder(
                      builder: (context, constraints) => CustomPaint(
                          size: Size(MediaQuery.of(context).size.width + 200,
                              MediaQuery.of(context).size.height + 200),
                          painter:
                              MathPaperPainter(gridSpacing: 20 * rw(context)))),
                ),
                PositionedWidget(
                    bottom: 100 * rh(context),
                    left: 10 * rw(context),
                    right: 10 * rw(context),
                    width: 340 * rw(context),
                    height: 30 * rh(context),
                    padding: EdgeInsets.symmetric(horizontal: 10 * rw(context)),
                    child: Center(
                      child: Text(
                          'Нажмите на любую точку экрана, чтобы построить угол',
                          style: getStyle(
                              fontSize: 12 * rw(context),
                              fontWeight: FontWeight.w500,
                              color: Colors.black)),
                    )),
                Consumer(
                  builder: (context, ref, child) => PositionedWidget(
                      bottom: 25 * rh(context),
                      left: 10 * rw(context),
                      right: 10 * rw(context),
                      width: 340 * rw(context),
                      height: 35 * rh(context),
                      child: Center(
                          child: InkWell(
                              onTap: () {
                                ref.read(drawingProvider.notifier).resetAll();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.all(10 * rw(context)),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.mercury),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.cancel,
                                          color: AppColors.boulder,
                                          size: 13 * rw(context)),
                                      Text(
                                        'Отменить действие',
                                        style: getStyle(
                                            fontSize: 12 * rw(context),
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.boulder),
                                      )
                                    ]),
                              )))),
                ),
                const DrawingOverlay(),
                Consumer(
                    builder: (context, ref, child) => PositionedWidget(
                          top: 10 * rh(context),
                          left: 5 * rw(context),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                    onTap: () {
                                      ref
                                          .read(drawingProvider.notifier)
                                          .clearLastLine();
                                    },
                                    child: const Icon(Icons.reply,
                                        color: AppColors.boulder)),
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 9 * rh(context)),
                                    child: const VerticalDivider(
                                        color: AppColors.boulder)),
                                InkWell(
                                    onTap: () {
                                      ref
                                          .read(drawingProvider.notifier)
                                          .undoClearLastLine();
                                    },
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: const Icon(Icons.reply,
                                          color: AppColors.boulder),
                                    )),
                              ]),
                        )),
              ]),
            )));
  }
}

class MathPaperPainter extends CustomPainter {
  MathPaperPainter({required this.gridSpacing});
  final double gridSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bostonBlue.withOpacity(0.5)
      ..strokeWidth = 0.5;

    // Draw horizontal lines
    for (double i = -500; i < size.height + 500; i += gridSpacing) {
      canvas.drawLine(Offset(-500, i), Offset(size.width + 500, i), paint);
    }

    // Draw vertical lines
    for (double i = -500; i < size.width + 500; i += gridSpacing) {
      canvas.drawLine(Offset(i, -500), Offset(i, size.height + 500), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
