import 'package:flutter/material.dart';

/// Strongly typed matrix transforms that keep compatibility with Flutter
/// versions whose bundled vector_math predates 2.2.0.
extension Matrix4Transform on Matrix4 {
  void translateWithValues(double tx, double ty, double tz, double tw) {
    final values = storage;
    final t1 =
        values[0] * tx + values[4] * ty + values[8] * tz + values[12] * tw;
    final t2 =
        values[1] * tx + values[5] * ty + values[9] * tz + values[13] * tw;
    final t3 =
        values[2] * tx + values[6] * ty + values[10] * tz + values[14] * tw;
    final t4 =
        values[3] * tx + values[7] * ty + values[11] * tz + values[15] * tw;
    values[12] = t1;
    values[13] = t2;
    values[14] = t3;
    values[15] = t4;
  }

  void scaleWithValues(double sx, double sy, double sz, double sw) {
    final values = storage;
    values[0] *= sx;
    values[1] *= sx;
    values[2] *= sx;
    values[3] *= sx;
    values[4] *= sy;
    values[5] *= sy;
    values[6] *= sy;
    values[7] *= sy;
    values[8] *= sz;
    values[9] *= sz;
    values[10] *= sz;
    values[11] *= sz;
    values[12] *= sw;
    values[13] *= sw;
    values[14] *= sw;
    values[15] *= sw;
  }
}
