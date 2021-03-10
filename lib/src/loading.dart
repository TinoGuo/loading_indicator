library loading;

import 'package:flutter/material.dart';

import 'decorate/decorate.dart';
import 'indicators/audio_equalizer.dart';
import 'indicators/ball_beat.dart';
import 'indicators/ball_clip_rotate.dart';
import 'indicators/ball_clip_rotate_multiple.dart';
import 'indicators/ball_clip_rotate_pulse.dart';
import 'indicators/ball_grid_beat.dart';
import 'indicators/ball_grid_pulse.dart';
import 'indicators/ball_pulse.dart';
import 'indicators/ball_pulse_rise.dart';
import 'indicators/ball_pulse_sync.dart';
import 'indicators/ball_rotate.dart';
import 'indicators/ball_rotate_chase.dart';
import 'indicators/ball_scale.dart';
import 'indicators/ball_scale_multiple.dart';
import 'indicators/ball_scale_ripple.dart';
import 'indicators/ball_scale_ripple_multiple.dart';
import 'indicators/ball_spin_fade_loader.dart';
import 'indicators/ball_triangle_path.dart';
import 'indicators/ball_triangle_path_colored.dart';
import 'indicators/ball_zig_zag.dart';
import 'indicators/ball_zig_zag_deflect.dart';
import 'indicators/circle_stroke_spin.dart';
import 'indicators/cube_transition.dart';
import 'indicators/line_scale.dart';
import 'indicators/line_scale_party.dart';
import 'indicators/line_scale_pulse_out.dart';
import 'indicators/line_scale_pulse_out_rapid.dart';
import 'indicators/line_spin_fade_loader.dart';
import 'indicators/orbit.dart';
import 'indicators/pacman.dart';
import 'indicators/semi_circle_spin.dart';
import 'indicators/square_spin.dart';
import 'indicators/triangle_skew_spin.dart';

///34 different types animation enums.
enum Indicator {
  ballPulse,
  ballGridPulse,
  ballClipRotate,
  squareSpin,
  ballClipRotatePulse,
  ballClipRotateMultiple,
  ballPulseRise,
  ballRotate,
  cubeTransition,
  ballZigZag,
  ballZigZagDeflect,
  ballTrianglePath,
  ballTrianglePathColored,
  ballTrianglePathColoredFilled,
  ballScale,
  lineScale,
  lineScaleParty,
  ballScaleMultiple,
  ballPulseSync,
  ballBeat,
  lineScalePulseOut,
  lineScalePulseOutRapid,
  ballScaleRipple,
  ballScaleRippleMultiple,
  ballSpinFadeLoader,
  lineSpinFadeLoader,
  triangleSkewSpin,
  pacman,
  ballGridBeat,
  semiCircleSpin,
  ballRotateChase,
  orbit,
  audioEqualizer,
  circleStrokeSpin,
}

/// Entrance of the loading.
class LoadingIndicator extends StatelessWidget {
  /// Indicate which type.
  final Indicator indicatorType;

  /// The color you draw on the shape.
  final Color? color;
  final List<Color>? colors;
  LoadingIndicator({
    Key? key,
    required this.indicatorType,
    this.color,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final actualColor = color ?? Theme.of(context).primaryColor;
    return DecorateContext(
      decorateData: DecorateData(
          indicator: indicatorType, color: actualColor, colors: colors),
      child: AspectRatio(
        aspectRatio: 1,
        child: _buildIndicator(),
      ),
    );
  }

  /// return the animation indicator.
  _buildIndicator() {
    switch (indicatorType) {
      case Indicator.ballPulse:
        return BallPulse();
      case Indicator.ballGridPulse:
        return BallGridPulse();
      case Indicator.ballClipRotate:
        return BallClipRotate();
      case Indicator.squareSpin:
        return SquareSpin();
      case Indicator.ballClipRotatePulse:
        return BallClipRotatePulse();
      case Indicator.ballClipRotateMultiple:
        return BallClipRotateMultiple();
      case Indicator.ballPulseRise:
        return BallPulseRise();
      case Indicator.ballRotate:
        return BallRotate();
      case Indicator.cubeTransition:
        return CubeTransition();
      case Indicator.ballZigZag:
        return BallZigZag();
      case Indicator.ballZigZagDeflect:
        return BallZigZagDeflect();
      case Indicator.ballTrianglePath:
        return BallTrianglePath();
      case Indicator.ballTrianglePathColored:
        return BallTrianglePathColored();
      case Indicator.ballTrianglePathColoredFilled:
        return BallTrianglePathColored(isFilled: true);
      case Indicator.ballScale:
        return BallScale();
      case Indicator.lineScale:
        return LineScale();
      case Indicator.lineScaleParty:
        return LineScaleParty();
      case Indicator.ballScaleMultiple:
        return BallScaleMultiple();
      case Indicator.ballPulseSync:
        return BallPulseSync();
      case Indicator.ballBeat:
        return BallBeat();
      case Indicator.lineScalePulseOut:
        return LineScalePulseOut();
      case Indicator.lineScalePulseOutRapid:
        return LineScalePulseOutRapid();
      case Indicator.ballScaleRipple:
        return BallScaleRipple();
      case Indicator.ballScaleRippleMultiple:
        return BallScaleRippleMultiple();
      case Indicator.ballSpinFadeLoader:
        return BallSpinFadeLoader();
      case Indicator.lineSpinFadeLoader:
        return LineSpinFadeLoader();
      case Indicator.triangleSkewSpin:
        return TriangleSkewSpin();
      case Indicator.pacman:
        return Pacman();
      case Indicator.ballGridBeat:
        return BallGridBeat();
      case Indicator.semiCircleSpin:
        return SemiCircleSpin();
      case Indicator.ballRotateChase:
        return BallRotateChase();
      case Indicator.orbit:
        return Orbit();
      case Indicator.audioEqualizer:
        return AudioEqualizer();
      case Indicator.circleStrokeSpin:
        return CircleStrokeSpin();
      default:
        throw Exception("no related indicator type:$indicatorType");
    }
  }
}
