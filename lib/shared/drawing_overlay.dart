import 'package:flutter/material.dart';
import 'package:flutter_application_painter/models/drawing_state_class.dart';
import 'package:flutter_application_painter/constants/app_colors.dart';
import 'package:flutter_application_painter/constants/app_styles.dart';
import 'package:flutter_application_painter/main.dart';
import 'package:flutter_application_painter/shared/controller_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class DrawingOverlay extends ConsumerWidget {
  const DrawingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawingStates = ref.watch(drawingProvider);
    final controllerPosition = ref.watch(controllerPositionProvider);
    final isDrawingClosed = ref.watch(drawingProvider.notifier).isDrawingClosed;

    return SafeArea(
        child: GestureDetector(
      onTapDown: (details) {
        ref.read(drawingProvider.notifier).startDrawing(details.globalPosition);
      },
      onPanUpdate: (details) {
        ref
            .read(drawingProvider.notifier)
            .continueDrawing(details.globalPosition);

        ref
            .read(controllerPositionProvider.notifier)
            .updatePosition(details.globalPosition);
      },
      onPanEnd: (details) {
        if (drawingStates.isNotEmpty) {
          ref.read(drawingProvider.notifier).stopDrawing();
        }
      },
      child: Stack(children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height - 200),
          painter: DrawingPainter(
              drawingStates: drawingStates,
              isDrawingClosed: isDrawingClosed,
              lineStrokeWidth: 5 * rw(context),
              circleStrokeWidth: 5 * rw(context)),
        ),
        if (controllerPosition != null)
          Positioned(
              top: controllerPosition.dy - 25,
              left: controllerPosition.dx - 25,
              child: const ControllerWidget()),
      ]),
    ));
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingState> drawingStates;
  final bool isDrawingClosed;
  final double? lineStrokeWidth;
  final double? circleStrokeWidth;

  DrawingPainter({
    required this.drawingStates,
    required this.lineStrokeWidth,
    required this.circleStrokeWidth,
    required this.isDrawingClosed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = lineStrokeWidth ?? 5.0;

    final circlePaint = Paint()
      ..color = AppColors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = circleStrokeWidth ?? 5.0;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (final state in drawingStates) {
      linePaint.color = state.lineColor;
      canvas.drawLine(state.startPoint, state.endPoint, linePaint);

      canvas.drawCircle(
          state.startPoint, circleStrokeWidth ?? 5.0, circlePaint);

      canvas.drawCircle(state.endPoint, lineStrokeWidth ?? 5.0, circlePaint);

      final double length = calculateDistance(state.startPoint, state.endPoint);
      final Offset textOffset =
          calculateTextOffset(state.startPoint, state.endPoint);
      textPainter.text = TextSpan(
        text: length.toStringAsFixed(2),
        style: getStyle(
            color: AppColors.bostonBlue,
            fontSize: 17,
            fontWeight: FontWeight.w500),
      );

      final double angle = math.atan2(
        state.endPoint.dy - state.startPoint.dy,
        state.endPoint.dx - state.startPoint.dx,
      );

      canvas.save();
      canvas.translate(textOffset.dx, textOffset.dy);
      canvas.rotate(angle);

      textPainter.layout();
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

      canvas.restore();
    }

    if (isDrawingClosed) {
      final Path closedPath = getClosedPath();

      final Paint fillPaint = Paint()..color = AppColors.white;

      canvas.drawPath(closedPath, fillPaint);
    }
  }

  Path getClosedPath() {
    final Path closedPath = Path();
    if (drawingStates.isNotEmpty) {
      closedPath.moveTo(
        drawingStates[0].startPoint.dx,
        drawingStates[0].startPoint.dy,
      );

      for (int i = 0; i < drawingStates.length; i++) {
        closedPath.lineTo(
          drawingStates[i].endPoint.dx,
          drawingStates[i].endPoint.dy,
        );
      }

      closedPath.close();
    }
    return closedPath;
  }

  double calculateDistance(Offset point1, Offset point2) {
    double dx = point1.dx - point2.dx;
    double dy = point1.dy - point2.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  Offset calculateTextOffset(Offset startPoint, Offset endPoint) {
    final double textX = (startPoint.dx + endPoint.dx) / 2;
    final double textY = (startPoint.dy + endPoint.dy) / 2;

    // Calculate the vector perpendicular to the line
    final double perpendicularVectorX = startPoint.dy - endPoint.dy;
    final double perpendicularVectorY = endPoint.dx - startPoint.dx;

    // Normalize the perpendicular vector
    final double length = math.sqrt(
      perpendicularVectorX * perpendicularVectorX +
          perpendicularVectorY * perpendicularVectorY,
    );
    final double normalizedPerpendicularVectorX = perpendicularVectorX / length;
    final double normalizedPerpendicularVectorY = perpendicularVectorY / length;

    final double offsetTextX = textX - 20 * normalizedPerpendicularVectorX;
    final double offsetTextY = textY - 20 * normalizedPerpendicularVectorY;

    return Offset(offsetTextX, offsetTextY);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
