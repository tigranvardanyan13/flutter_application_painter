import 'package:flutter/material.dart';
import 'package:flutter_application_painter/constants/app_colors.dart';
import 'package:flutter_application_painter/models/drawing_state_class.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

class DrawingNotifier extends StateNotifier<List<DrawingState>> {
  DrawingNotifier() : super([]);
  Offset? lastEndPoint;
  Offset? firstCirclePosition;
  Offset? lastCirclePosition;

  bool _isDrawingEnded = false;

  bool _isDrawingClosed = false;
  bool get isDrawingClosed => _isDrawingClosed;

  List<List<DrawingState>> history = [];

  void startDrawing(Offset startPoint) {
    _isDrawingEnded = false;
    if (_isDrawingClosed) {
      selectCorner(startPoint);
      return;
    }
    if (state.isEmpty) {
      lastEndPoint = startPoint;
      state = [
        ...state,
        DrawingState(startPoint: startPoint, endPoint: startPoint)
      ];
    } else {
      if (state.last.hasIntersection) {
        return;
      }
      if (!isCloseToLastCircle(startPoint)) {
        state.add(DrawingState(
          startPoint: state.last.endPoint,
          endPoint: state.last.endPoint,
        ));
      }
    }
    lastCirclePosition = startPoint;
  }

  void continueDrawing(Offset endPoint) {
    if (lastEndPoint != null &&
        state.isNotEmpty &&
        !_isDrawingEnded &&
        !_isDrawingClosed) {
      final List<DrawingState> updatedState = List.from(state);
      updatedState.last = DrawingState(
        startPoint: lastEndPoint!,
        endPoint: endPoint,
      );

      state = updatedState;
      if (state.length > 1) {
        checkForIntersections();
      }
    } else {
      selectCorner(endPoint);
      moveSelectedCorner(endPoint);
    }
  }

  void stopDrawing() {
    if (_isDrawingClosed) {
      return;
    }
    if (state.last.hasIntersection) {
      return;
    }
    _isDrawingEnded = true;

    if (isCloseToStartingPoint(state.last.endPoint)) {
      final List<DrawingState> updatedState = List.from(state);
      _isDrawingClosed = true;

      updatedState.last = DrawingState(
        startPoint: state.last.startPoint,
        endPoint: state.first.startPoint,
      );
      state = updatedState;
    }
    lastEndPoint = state.isNotEmpty ? state.last.endPoint : null;
  }

  void clearLastLine() {
    if (state.isNotEmpty) {
      lastEndPoint = state.last.startPoint;
      history.add(List.from(state));

      final List<DrawingState> updatedState = List.from(state);
      updatedState.removeLast();
      state = updatedState;
      _isDrawingClosed = false;
    }
  }

  void undoClearLastLine() {
    if (history.isNotEmpty) {
      state = List.from(history.removeLast());
      if (isCloseToStartingPoint(state.last.endPoint)) {
        _isDrawingClosed = true;
      }
    }
  }

  void resetAll() {
    state.clear();
    _isDrawingClosed = false;
  }

  void selectCorner(Offset tapPosition) {
    for (int i = 0; i < state.length; i++) {
      if (isCloseToCorner(tapPosition, state[i].startPoint)) {
        state[i].isSelected = true;
        break;
      } else {
        state[i].isSelected = false;
      }
    }
  }

  void moveSelectedCorner(Offset newPosition) {
    for (int i = 0; i < state.length; i++) {
      if (state[i].isSelected) {
        final List<DrawingState> updatedState = List.from(state);

        updatedState[i] = state[i].copyWith(
          startPoint: newPosition,
        );

        state = updatedState;

        adjustPreviousLine(i, newPosition);

        break;
      }
    }
  }

  void adjustPreviousLine(int index, Offset newPosition) {
    final List<DrawingState> updatedState = List.from(state);

    if (index < 1) {
      updatedState.last = state.last.copyWith(
        endPoint: newPosition,
      );
    } else {
      updatedState[index - 1] = state[index - 1].copyWith(
        endPoint: newPosition,
      );
    }

    state = updatedState;
  }

  void adjustNextLine(int index, Offset newPosition, bool isLast) {
    final List<DrawingState> updatedState = List.from(state);

    if (isLast) {
      updatedState.first = state.first.copyWith(
        startPoint: newPosition,
      );
    } else {
      updatedState[index + 1] = state[index + 1].copyWith(
        startPoint: newPosition,
      );
    }
    state = updatedState;
  }

  bool isCloseToCorner(Offset tapPosition, Offset cornerPosition) {
    double thresholdDistance = 40.0;
    double distance = calculateDistance(tapPosition, cornerPosition);
    return distance <= thresholdDistance;
  }

  bool isCloseToLastCircle(Offset currentPoint) {
    if (lastCirclePosition != null) {
      double thresholdDistance = 40.0;
      double distance = calculateDistance(currentPoint, lastCirclePosition!);
      return distance <= thresholdDistance;
    }
    return false;
  }

  bool isCloseToStartingPoint(Offset currentEndpoint) {
    double thresholdDistance = 40.0;
    Offset startingPoint = state.first.startPoint;

    double distance = calculateDistance(currentEndpoint, startingPoint);
    return distance <= thresholdDistance;
  }

  double calculateDistance(Offset point1, Offset point2) {
    double dx = point1.dx - point2.dx;
    double dy = point1.dy - point2.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  void checkForIntersections() {
    final int lastIndex = state.length - 1;
    List<DrawingState> updatedState = [...state];

    final Line newLine = Line(
      start: state[lastIndex - 1].endPoint,
      end: state[lastIndex].endPoint,
    );

    for (int i = 0; i < lastIndex; i++) {
      DrawingState updatedDrawingState = state[i];

      final Line existingLine = Line(
        start: state[i].startPoint,
        end: state[i].endPoint,
      );

      var xmax = math.max(state[state.length - 2].endPoint.dx,
          state[state.length - 2].startPoint.dx);
      var xmin = math.min(state[state.length - 2].endPoint.dx,
          state[state.length - 2].startPoint.dx);

      var ymax = math.max(state[state.length - 2].endPoint.dy,
          state[state.length - 2].startPoint.dy);
      var ymin = math.min(state[state.length - 2].endPoint.dy,
          state[state.length - 2].startPoint.dy);

      if (i == (lastIndex - 1)) {
        if (xmax > newLine.end.dx && newLine.end.dx > xmin) {
          if (ymax > newLine.end.dy && newLine.end.dy > ymin) {
            updatedDrawingState.copyWith(lineColor: AppColors.red);

            updatedDrawingState = state[lastIndex]
                .copyWith(lineColor: AppColors.red, hasIntersection: true);

            updatedState[lastIndex] = updatedDrawingState;
          }
        }
      } else {
        if (doIntersect(
            newLine.start, newLine.end, existingLine.start, existingLine.end)) {
          updatedDrawingState.copyWith(lineColor: AppColors.red);

          updatedDrawingState = state[lastIndex]
              .copyWith(lineColor: AppColors.red, hasIntersection: true);

          updatedState[lastIndex] = updatedDrawingState;
        } else {
          updatedDrawingState.copyWith(hasIntersection: false);
        }
      }
    }

    state = updatedState;
  }

  bool doIntersect(Offset p1, Offset q1, Offset p2, Offset q2) {
    // Check if the point q lies on line segment 'pr'
    bool onSegment(Offset p, Offset q, Offset r) {
      return (q.dx <= math.max(p.dx, r.dx) &&
          q.dx >= math.min(p.dx, r.dx) &&
          q.dy <= math.max(p.dy, r.dy) &&
          q.dy >= math.min(p.dy, r.dy));
    }

    // Skip checking if the shared endpoint is the same as the start of the new line
    if ((q1.dx == p2.dx && q1.dy == p2.dy) ||
        (q1.dx == q2.dx && q1.dy == q2.dy)) {
      return false;
    }

    int o1 = orientation(p1, q1, p2);
    int o2 = orientation(p1, q1, q2);
    int o3 = orientation(p2, q2, p1);
    int o4 = orientation(p2, q2, q1);

    // General case
    if (o1 != o2 && o3 != o4) {
      return true;
    }

    // p1 , q1 and p2 are collinear and p2 lies on segment p1q1
    if (o1 == 0 && onSegment(p1, p2, q1)) return true;

    // p1 , q1 and q2 are collinear and q2 lies on segment p1q1
    if (o2 == 0 && onSegment(p1, q2, q1)) return true;

    // p2 , q2 and p1 are collinear and p1 lies on segment p2q2
    if (o3 == 0 && onSegment(p2, p1, q2)) return true;

    // p2 , q2 and q1 are collinear and q1 lies on segment p2q2
    if (o4 == 0 && onSegment(p2, q1, q2)) return true;

    return false;
  }

  int orientation(Offset p, Offset q, Offset r) {
    double val = (q.dy - p.dy) * (r.dx - q.dx) - (q.dx - p.dx) * (r.dy - q.dy);
    if (val == 0) return 0;
    return (val > 0) ? 1 : 2;
  }
}

class Line {
  final Offset start;
  final Offset end;

  Line({required this.start, required this.end});
}

extension DrawingStateExtension on DrawingState {
  DrawingState copyWith(
      {Offset? startPoint,
      Offset? endPoint,
      bool? isLineStart,
      bool? isLineEnd,
      Color? lineColor,
      bool? hasIntersection}) {
    return DrawingState(
        startPoint: startPoint ?? this.startPoint,
        endPoint: endPoint ?? this.endPoint,
        isLineStart: isLineStart ?? this.isLineStart,
        isLineEnd: isLineEnd ?? this.isLineEnd,
        lineColor: lineColor ?? this.lineColor,
        hasIntersection: hasIntersection ?? this.hasIntersection);
  }
}
