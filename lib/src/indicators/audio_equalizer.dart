import 'package:flutter/material.dart';
import 'package:loading_indicator/src/shape/indicator_painter.dart';

/// AudioEqualizer
class AudioEqualizer extends StatefulWidget {
  @override
  _AudioEqualizerState createState() => _AudioEqualizerState();
}

class _AudioEqualizerState extends State<AudioEqualizer>
    with TickerProviderStateMixin {
  static const _LINE_NUM = 4;
  static const _DURATIONS = [
    4300,
    2500,
    1700,
    3100,
  ];
  static const _VALUES = [
    0.0,
    0.7,
    0.4,
    0.05,
    0.95,
    0.3,
    0.9,
    0.4,
    0.15,
    0.18,
    0.75,
    0.01,
  ];
  List<AnimationController> _animationControllers = [];
  List<Animation<double>> _animations = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _LINE_NUM; i++) {
      _animationControllers.add(AnimationController(
          vsync: this, duration: Duration(milliseconds: _DURATIONS[i])));
      final sequences = <TweenSequenceItem<double>>[];
      for (int j = 0; j < _VALUES.length - 1; j++) {
        sequences.add(TweenSequenceItem(
            tween: Tween(begin: _VALUES[j], end: _VALUES[j + 1]), weight: 1));
      }
      _animations
          .add(TweenSequence(sequences).animate(_animationControllers[i]));
      _animationControllers[i].repeat();
    }
  }

  @override
  void dispose() {
    _animationControllers.forEach((f) => f.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widgets = List<Widget>.filled(7, Container());
    for (int i = 0; i < widgets.length; i++) {
      if (i.isEven) {
        widgets[i] = Expanded(
          child: AnimatedBuilder(
            animation: _animations[i ~/ 2],
            builder: (_, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..scale(1.0, _animations[i ~/ 2].value),
                child: child,
                alignment: Alignment.bottomCenter,
              );
            },
            child: IndicatorShapeWidget(shape: Shape.rectangle),
          ),
        );
      } else {
        widgets[i] = Expanded(child: SizedBox());
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}
