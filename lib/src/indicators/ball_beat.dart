import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

class BallBeat extends StatefulWidget {
  @override
  _BallBeatState createState() => _BallBeatState();
}

class _BallBeatState extends State<BallBeat> with TickerProviderStateMixin {
  static const _BEGIN_TIMES = [350, 0, 350];

  List<AnimationController> _animationControllers = List(3);
  List<Animation<double>> _scaleAnimations = List(3);
  List<Animation<double>> _opacityAnimations = List(3);
  List<CancelableOperation<int>> _delayFeatures = List(3);

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      _animationControllers[i] = AnimationController(
          vsync: this, duration: Duration(milliseconds: 700))
        ..addListener(() => setState(() {}));
      _scaleAnimations[i] = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.75), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear));
      _opacityAnimations[i] = TweenSequence([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.2), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.0), weight: 1),
      ]).animate(CurvedAnimation(
          parent: _animationControllers[i], curve: Curves.linear));

      _delayFeatures[i] = CancelableOperation.fromFuture(
          Future.delayed(Duration(milliseconds: _BEGIN_TIMES[i])).then((t) {
        _animationControllers[i].repeat();
      }));
    }
  }

  @override
  void dispose() {
    _delayFeatures.forEach((f) => f.cancel());
    _animationControllers.forEach((f) => f.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraint) {
      List<Widget> widgets = List(5);
      for (int i = 0; i < 5; i++) {
        if (i.isEven) {
          widgets[i] = Expanded(
            child: Opacity(
              opacity: _opacityAnimations[i ~/ 2].value,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(_scaleAnimations[i ~/ 2].value),
                child: IndicatorShapeWidget(
                  shape: Shape.circle,
                ),
              ),
            ),
          );
        } else {
          widgets[i] = SizedBox(
            width: 2,
          );
        }
      }

      return Row(children: widgets);
    });
  }
}
