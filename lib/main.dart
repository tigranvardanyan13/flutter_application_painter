import 'package:flutter/material.dart';
import 'package:flutter_application_painter/models/drawing_state_class.dart';
import 'package:flutter_application_painter/providers/controller_notifier.dart';
import 'package:flutter_application_painter/providers/drawing_notifier.dart';
import 'package:flutter_application_painter/screens/home_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final drawingProvider =
    StateNotifierProvider.autoDispose<DrawingNotifier, List<DrawingState>>(
        (ref) => DrawingNotifier());

final controllerPositionProvider =
    StateNotifierProvider.autoDispose<OffsetNotifier, Offset?>(
        (ref) => OffsetNotifier());

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyScrollableScreen(),
    );
  }
}
