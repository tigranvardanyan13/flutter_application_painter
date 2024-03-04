import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OffsetNotifier extends StateNotifier<Offset?> {
  OffsetNotifier() : super(null);

  void updatePosition(Offset newOffset) {
    state = newOffset;
  }
}
