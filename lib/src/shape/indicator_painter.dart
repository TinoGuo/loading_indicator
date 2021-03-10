import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loading_indicator/src/decorate/decorate.dart';

const double _kMinIndicatorSize = 36.0;

/// Basic shape.
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

/// Wrapper class for basic shape.
class IndicatorShapeWidget extends StatelessWidget {
  final Shape shape;
  final double? data;
  final int? colorIndex;

  IndicatorShapeWidget({
    Key? key,
    required this.shape,
    this.data,
    this.colorIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DecorateData decorateData = DecorateContext.of(context)!.decorateData;
    final bool shouldUseColors = decorateData.colors != null &&
        colorIndex != null &&
        colorIndex! < decorateData.colors!.length;
    final color = shouldUseColors
        ? decorateData.colors![colorIndex!]
        : DecorateContext.of(context)!.decorateData.color;

//    if (shape == Shape.circle) {
//      return Container(
//        decoration: BoxDecoration(
//          color: color,
//          shape: BoxShape.circle,
//        ),
//      );
//    } else if (shape == Shape.line) {
//      return LayoutBuilder(
//        builder: (ctx, constraint) => Container(
//              decoration: ShapeDecoration(
//                color: color,
//                shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(constraint.maxWidth / 2),
//                ),
//              ),
//            ),
//      );
//    } else if (shape == Shape.rectangle) {
//      return Container(
//        decoration: BoxDecoration(
//          color: color,
//          shape: BoxShape.rectangle,
//        ),
//      );
//    }

    return Container(
      constraints: const BoxConstraints(
        minWidth: _kMinIndicatorSize,
        minHeight: _kMinIndicatorSize,
      ),
      child: CustomPaint(
        painter: _ShapePainter(color, shape, data: data),
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final Color color;
  final Shape shape;
  final Paint _paint;
  final double? data;

  static const double _strokeWidth = 2.0;

  _ShapePainter(this.color, this.shape, {this.data})
      : _paint = Paint()..isAntiAlias = true,
        super();

  @override
  void paint(Canvas canvas, Size size) {
    switch (shape) {
      case Shape.circle:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          size.shortestSide / 2,
          _paint,
        );
        break;
      case Shape.ringThirdFour:
        _paint
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth;
        canvas.drawArc(
            Rect.fromCircle(
                center: Offset(size.width / 2, size.height / 2),
                radius: size.shortestSide / 2),
            -3 * pi / 4,
            3 * pi / 2,
            false,
            _paint);
        break;
      case Shape.rectangle:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRect(Offset.zero & size, _paint);
        break;
      case Shape.ringTwoHalfVertical:
        _paint
          ..color = color
          ..strokeWidth = _strokeWidth
          ..style = PaintingStyle.stroke;
        final rect = Rect.fromLTWH(
            size.width / 4, size.height / 4, size.width / 2, size.height / 2);
        canvas.drawArc(rect, -3 * pi / 4, pi / 2, false, _paint);
        canvas.drawArc(rect, 3 * pi / 4, -pi / 2, false, _paint);
        break;
      case Shape.ring:
        _paint
          ..color = color
          ..strokeWidth = _strokeWidth
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(size.width / 2, size.height / 2),
            size.shortestSide / 2, _paint);
        break;
      case Shape.line:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromLTWH(0, 0, size.width, size.height),
                Radius.circular(size.shortestSide / 2)),
            _paint);
        break;
      case Shape.triangle:
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
      case Shape.arc:
        assert(data != null);
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(
            Offset.zero & size, data!, pi * 2 - 2 * data!, true, _paint);
        break;
      case Shape.circleSemi:
        _paint
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawArc(Offset.zero & size, -pi * 6, -2 * pi / 3, false, _paint);
        break;
    }
  }

  @override
  bool shouldRepaint(_ShapePainter oldDelegate) =>
      this.shape != oldDelegate.shape ||
      this.color != oldDelegate.color ||
      this.data != oldDelegate.data;
}
