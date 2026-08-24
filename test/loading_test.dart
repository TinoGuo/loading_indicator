import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';
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

  testWidgets('line indicators respect strokeWidth', (tester) async {
    const lineIndicators = <Indicator, int>{
      Indicator.lineScale: 5,
      Indicator.lineScaleParty: 4,
      Indicator.lineScalePulseOut: 5,
      Indicator.lineScalePulseOutRapid: 5,
      Indicator.lineSpinFadeLoader: 8,
    };

    Future<void> pumpIndicator(
      Indicator indicator,
      double? strokeWidth,
    ) {
      return tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox.square(
              dimension: 96,
              child: LoadingIndicator(
                indicatorType: indicator,
                colors: const [Colors.blue],
                strokeWidth: strokeWidth,
                pause: true,
              ),
            ),
          ),
        ),
      );
    }

    List<IndicatorShapeWidget> lineShapes() => tester
        .widgetList<IndicatorShapeWidget>(find.byType(IndicatorShapeWidget))
        .where((widget) => widget.shape == Shape.line)
        .toList();

    for (final entry in lineIndicators.entries) {
      await pumpIndicator(entry.key, null);
      expect(lineShapes(), hasLength(entry.value));
      expect(
        lineShapes().map((shape) => shape.lineWidth),
        everyElement(isNull),
      );

      await pumpIndicator(entry.key, 2);
      expect(lineShapes(), hasLength(entry.value));
      expect(lineShapes().map((shape) => shape.lineWidth), everyElement(2));

      await pumpIndicator(entry.key, 12);
      expect(lineShapes(), hasLength(entry.value));
      expect(lineShapes().map((shape) => shape.lineWidth), everyElement(12));
    }

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
