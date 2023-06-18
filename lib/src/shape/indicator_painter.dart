import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/decorate/decorate.dart';

const double _kMinIndicatorSize = 36.0;

sealed class Shape {}

class Circle implements Shape {
  final double radius;
  const Circle({this.radius = 0});
}

class RingThirdFour implements Shape {
  final double radius;
  const RingThirdFour({this.radius = 0});
}

class Square implements Shape {
  final double size;
  const Square({this.size = 0});
}

class RingTwoHalfVertical implements Shape {
  final double radius;
  const RingTwoHalfVertical({this.radius = 0});
}

class Ring implements Shape {
  final double radius;
  const Ring({this.radius = 0});
}

class Line implements Shape {
  final double strokeWidth;
  const Line({this.strokeWidth = 0});
}

class Triangle implements Shape {
  final double strokeWidth;
  const Triangle({this.strokeWidth = 0});
}

class Arc implements Shape {
  final double radius;
  const Arc({this.radius = 0});
}

class SemiCircle implements Shape {
  final double radius;
  const SemiCircle({this.radius = 0});
}

/// Wrapper class for basic shape.
class IndicatorShapeWidget extends StatelessWidget {
  final Shape shape;
  final double? data;

  /// The index of shape in the widget.
  final int index;

  const IndicatorShapeWidget({
    Key? key,
    required this.shape,
    this.data,
    this.index = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DecorateData decorateData = DecorateContext.of(context)!.decorateData;
    final color = decorateData.colors[index % decorateData.colors.length];

    return Container(
      constraints: const BoxConstraints(
        minWidth: _kMinIndicatorSize,
        minHeight: _kMinIndicatorSize,
      ),
      child: CustomPaint(
        painter: _ShapePainter(
          color,
          shape,
          data,
          decorateData.strokeWidth,
          pathColor: decorateData.pathBackgroundColor,
        ),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final Color color;
  final Shape shape;
  final Paint _paint;
  final double? data;
  final double strokeWidth;
  final Color? pathColor;

  _ShapePainter(
    this.color,
    this.shape,
    this.data,
    this.strokeWidth, {
    this.pathColor,
  })  : _paint = Paint()..isAntiAlias = true,
        super();

  @override
  void paint(Canvas canvas, Size size) {
    switch (shape) {
      case Circle _:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.shortestSide / 2,
          _paint,
        );
        break;
      case RingThirdFour _:
        if (pathColor != null) {
          _paint
            ..color = pathColor!
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke;
          canvas.drawCircle(
            Offset(size.width / 2, size.height / 2),
            size.shortestSide / 2,
            _paint,
          );
        }
        _paint
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;
        canvas.drawArc(
          Rect.fromCircle(
            center: Offset(size.width / 2, size.height / 2),
            radius: size.shortestSide / 2,
          ),
          -3 * pi / 4,
          3 * pi / 2,
          false,
          _paint,
        );
        break;
      case Square _:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRect(Offset.zero & size, _paint);
        break;
      case RingTwoHalfVertical _:
        _paint
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;
        final rect = Rect.fromLTWH(
            size.width / 4, size.height / 4, size.width / 2, size.height / 2);
        canvas.drawArc(rect, -3 * pi / 4, pi / 2, false, _paint);
        canvas.drawArc(rect, 3 * pi / 4, -pi / 2, false, _paint);
        break;
      case Ring _:
        _paint
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(size.width / 2, size.height / 2),
            size.shortestSide / 2, _paint);
        break;
      case Line line:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        if (line.strokeWidth >= size.shortestSide || line.strokeWidth <= 0) {
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromLTWH(0, 0, size.width, size.height),
                  Radius.circular(size.shortestSide / 2)),
              _paint);
        } else {
          canvas.drawRRect(
              RRect.fromRectAndRadius(
                  Rect.fromCenter(
                      center: size.center(Offset.zero),
                      width: line.strokeWidth,
                      height: size.height),
                  Radius.circular(
                      min(line.strokeWidth, size.shortestSide) / 2)),
              _paint);
        }
        break;
      case Triangle _:
        final offsetY = size.height / 4;
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        Path path = Path()
          ..moveTo(0, size.height - offsetY)
          ..lineTo(size.width / 2, size.height / 2 - offsetY)
          ..lineTo(size.width, size.height - offsetY)
          ..close();
        canvas.drawPath(path, _paint);
        break;
      case Arc _:
        assert(data != null);
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(
            Offset.zero & size, data!, pi * 2 - 2 * data!, true, _paint);
        break;
      case SemiCircle _:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(Offset.zero & size, -pi * 6, -2 * pi / 3, false, _paint);
        break;
    }
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) =>
      shape != oldDelegate.shape ||
      color != oldDelegate.color ||
      data != oldDelegate.data ||
      strokeWidth != oldDelegate.strokeWidth ||
      pathColor != oldDelegate.pathColor;
}
