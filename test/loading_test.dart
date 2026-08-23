import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:loading_indicator/src/transition/matrix4_transform.dart';

void main() {
  group('Matrix4Transform', () {
    test('translates using homogeneous coordinates', () {
      final matrix = Matrix4.identity()
        ..translateWithValues(2.0, 3.0, 4.0, 1.0);

      expect(
        matrix.storage,
        orderedEquals([
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          2.0,
          3.0,
          4.0,
          1.0,
        ]),
      );
    });

    test('scales each matrix column', () {
      final matrix = Matrix4.identity()..scaleWithValues(2.0, 3.0, 4.0, 1.0);

      expect(
        matrix.storage,
        orderedEquals([
          2.0,
          0.0,
          0.0,
          0.0,
          0.0,
          3.0,
          0.0,
          0.0,
          0.0,
          0.0,
          4.0,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
        ]),
      );
    });
  });

  testWidgets('builds every indicator without errors', (tester) async {
    for (final indicator in Indicator.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox.square(
              dimension: 100,
              child: LoadingIndicator(indicatorType: indicator),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        tester.takeException(),
        isNull,
        reason: '$indicator should build without errors',
      );
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
