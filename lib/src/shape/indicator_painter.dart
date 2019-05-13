import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/decorate/decorate.dart';

const double _kMinIndicatorSize = 36.0;
const double _kStrokeWidth = 2.0;

enum Shape {
  circle,
  ringThirdFour,
  rectangle,
  ringTwoHalfVertical,
  ring,
  line,
  triangle,
  arc,
  circleSemi,
}

class IndicatorShapeWidget extends StatelessWidget {
  final Shape shape;
  final double data;

  IndicatorShapeWidget(this.shape, {this.data});

  @override
  Widget build(BuildContext context) {
    final color = DecorateContext.of(context).decorateData.color;

    if (shape == Shape.circle) {
      return Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    } else if (shape == Shape.line) {
      return LayoutBuilder(
        builder: (ctx, constraint) => Container(
              decoration: ShapeDecoration(
                color: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(constraint.maxWidth / 2),
                ),
              ),
            ),
      );
    } else if (shape == Shape.rectangle) {
      return Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.rectangle,
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
          minWidth: _kMinIndicatorSize, minHeight: _kMinIndicatorSize),
      child: CustomPaint(
        foregroundPainter: _ShapePainter(color, shape, data: data),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final Color color;
  final Shape shape;
  final Path _path;
  final Paint _paint;
  final double data;

  _ShapePainter(this.color, this.shape, {this.data})
      : _path = Path(),
        _paint = Paint()..isAntiAlias = true,
        super();

  @override
  void paint(Canvas canvas, Size size) {
    final minEdge = min(size.width, size.height);
    var handleCanvas = false;
    switch (shape) {
      case Shape.circle:
        _path.addArc(
            Rect.fromCircle(
                center: Offset(size.width / 2, size.height / 2),
                radius: minEdge / 2),
            0,
            360);
        _path.close();
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        break;
      case Shape.ringThirdFour:
        _path.addArc(
            Rect.fromLTRB(0, 0, minEdge, minEdge), -3 * pi / 4, 3 * pi / 2);
        _paint
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _kStrokeWidth;
        break;
      case Shape.rectangle:
        _path.moveTo(0, 0);
        _path.lineTo(size.width, 0);
        _path.lineTo(size.width, size.height);
        _path.lineTo(0, size.height);
        _path.close();
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        break;
      case Shape.ringTwoHalfVertical:
        _path.addArc(
            Rect.fromLTWH(size.width / 4, size.height / 4, size.width / 2,
                size.height / 2),
            -3 * pi / 4,
            pi / 2);
        _path.addArc(
            Rect.fromLTWH(size.width / 4, size.height / 4, size.width / 2,
                size.height / 2),
            pi * 3 / 4,
            -pi / 2);
        _paint
          ..color = color
          ..strokeWidth = _kStrokeWidth
          ..style = PaintingStyle.stroke;
        break;
      case Shape.ring:
        _path.addArc(
            Rect.fromCircle(
                center: Offset(size.width / 2, size.height / 2),
                radius: size.width / 2),
            0,
            2 * pi);
        _paint
          ..color = color
          ..strokeWidth = _kStrokeWidth
          ..style = PaintingStyle.stroke;
        break;
      case Shape.line:
        _path.addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Radius.circular(size.width / 2)));
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        break;
      case Shape.triangle:
        final offsetY = size.height / 4;
        _path
          ..moveTo(0, size.height - offsetY)
          ..lineTo(size.width / 2, size.height / 2 - offsetY)
          ..lineTo(size.width, size.height - offsetY)
          ..close();
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        break;
      case Shape.arc:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), data,
            pi * 2 - 2 * data, true, _paint);
        handleCanvas = true;
        break;
      case Shape.circleSemi:
        _path.addArc(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: size.shortestSide / 2,
            ),
            -pi * 6,
            -2 * pi / 3);
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        break;
    }
    if (!handleCanvas) {
      canvas.drawPath(_path, _paint);
    }
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) => false;
}
