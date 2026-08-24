import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Defines how an indicator reaches the requested pause position.
enum LoadingIndicatorPauseBehavior {
  /// Keeps playing until the reference timeline naturally reaches the target.
  waitUntilTarget,

  /// Advances every animation track by the same virtual time and pauses now.
  jumpToTarget,
}

/// The current state of a [LoadingIndicatorController].
enum LoadingIndicatorPlaybackStatus {
  /// The controller is not currently connected to a loading indicator.
  detached,

  /// The connected loading indicator is playing.
  playing,

  /// The indicator is playing while waiting for a requested pause position.
  pausing,

  /// The connected loading indicator is paused.
  paused,
}

/// Thrown when a pending [LoadingIndicatorController.pauseAt] command is
/// replaced or the controller is disposed before the target is reached.
class LoadingIndicatorCommandCanceled implements Exception {
  const LoadingIndicatorCommandCanceled([
    this.message = 'The loading indicator command was canceled.',
  ]);

  final String message;

  @override
  String toString() => 'LoadingIndicatorCommandCanceled: $message';
}

enum _PlaybackIntentKind { playing, paused, pauseAt }

class _PlaybackIntent {
  const _PlaybackIntent.playing()
      : kind = _PlaybackIntentKind.playing,
        target = null,
        behavior = null,
        completer = null,
        generation = 0;

  const _PlaybackIntent.paused()
      : kind = _PlaybackIntentKind.paused,
        target = null,
        behavior = null,
        completer = null,
        generation = 0;

  const _PlaybackIntent.pauseAt({
    required this.target,
    required this.behavior,
    required this.completer,
    required this.generation,
  }) : kind = _PlaybackIntentKind.pauseAt;

  final _PlaybackIntentKind kind;
  final double? target;
  final LoadingIndicatorPauseBehavior? behavior;
  final Completer<void>? completer;
  final int generation;
}

/// Controls the playback of one loading indicator.
///
/// A controller can be attached to only one indicator at a time. Commands sent
/// while detached are retained and applied the next time it is attached.
class LoadingIndicatorController extends ChangeNotifier {
  LoadingIndicatorController();

  _IndicatorPlaybackHandle? _handle;
  _PlaybackIntent _intent = const _PlaybackIntent.playing();
  LoadingIndicatorPlaybackStatus _status =
      LoadingIndicatorPlaybackStatus.detached;
  double? _progress;
  int _commandGeneration = 0;
  bool _disposed = false;

  /// The current playback state.
  LoadingIndicatorPlaybackStatus get status => _status;

  /// The normalized value of the indicator's reference timeline.
  ///
  /// Returns null while the controller is detached.
  double? get progress => _progress;

  /// Whether this controller is connected to a loading indicator.
  bool get isAttached => _handle != null;

  /// Immediately pauses every animation track at its current value.
  void pause() {
    _ensureNotDisposed();
    _replaceIntent(const _PlaybackIntent.paused());
    final handle = _handle;
    if (handle != null) {
      handle.pauseNow();
      _setStatus(LoadingIndicatorPlaybackStatus.paused);
      _updateProgress(handle.progress);
    }
  }

  /// Pauses at [progress], which must be between 0.0 and 1.0 inclusive.
  ///
  /// The returned future completes after the indicator has actually paused.
  /// It completes with [LoadingIndicatorCommandCanceled] if another command
  /// replaces it or this controller is disposed first.
  Future<void> pauseAt(
    double progress, {
    LoadingIndicatorPauseBehavior behavior =
        LoadingIndicatorPauseBehavior.waitUntilTarget,
  }) {
    _ensureNotDisposed();
    if (!progress.isFinite || progress < 0.0 || progress > 1.0) {
      throw RangeError.value(
        progress,
        'progress',
        'Must be a finite value between 0.0 and 1.0 inclusive.',
      );
    }

    final completer = Completer<void>();
    final generation = ++_commandGeneration;
    _replaceIntent(
      _PlaybackIntent.pauseAt(
        target: progress,
        behavior: behavior,
        completer: completer,
        generation: generation,
      ),
      incrementGeneration: false,
    );
    _applyIntent();
    return completer.future;
  }

  /// Resumes every animation track from its paused position.
  void resume() {
    _ensureNotDisposed();
    _replaceIntent(const _PlaybackIntent.playing());
    final handle = _handle;
    if (handle != null) {
      handle.resume();
      _setStatus(LoadingIndicatorPlaybackStatus.playing);
      _updateProgress(handle.progress);
    }
  }

  void _replaceIntent(
    _PlaybackIntent intent, {
    bool incrementGeneration = true,
  }) {
    if (incrementGeneration) {
      _commandGeneration++;
    }
    final previousCompleter = _intent.completer;
    if (previousCompleter != null && !previousCompleter.isCompleted) {
      previousCompleter.completeError(
        const LoadingIndicatorCommandCanceled(),
      );
    }
    _intent = intent;
  }

  void _applyIntent() {
    final handle = _handle;
    if (handle == null) {
      _setStatus(LoadingIndicatorPlaybackStatus.detached);
      return;
    }

    switch (_intent.kind) {
      case _PlaybackIntentKind.playing:
        handle.resume();
        _setStatus(LoadingIndicatorPlaybackStatus.playing);
        break;
      case _PlaybackIntentKind.paused:
        handle.pauseNow();
        _setStatus(LoadingIndicatorPlaybackStatus.paused);
        break;
      case _PlaybackIntentKind.pauseAt:
        final target = _intent.target!;
        final completer = _intent.completer;
        if (completer == null) {
          handle.pauseAt(
            target,
            LoadingIndicatorPauseBehavior.jumpToTarget,
            () {},
          );
          _setStatus(LoadingIndicatorPlaybackStatus.paused);
          break;
        }

        final generation = _intent.generation;
        _setStatus(LoadingIndicatorPlaybackStatus.pausing);
        handle.pauseAt(target, _intent.behavior!, () {
          _completePauseAt(generation, target);
        });
        break;
    }
    _updateProgress(handle.progress);
  }

  void _completePauseAt(int generation, double target) {
    if (_disposed || generation != _intent.generation) {
      return;
    }
    final completer = _intent.completer;
    _intent = _PlaybackIntent.pauseAt(
      target: target,
      behavior: LoadingIndicatorPauseBehavior.jumpToTarget,
      completer: null,
      generation: generation,
    );
    _setStatus(LoadingIndicatorPlaybackStatus.paused);
    final handle = _handle;
    if (handle != null) {
      _updateProgress(handle.progress);
    }
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  void _attach(_IndicatorPlaybackHandle handle) {
    _ensureNotDisposed();
    if (_handle != null && !identical(_handle, handle)) {
      throw FlutterError(
        'A LoadingIndicatorController cannot control more than one '
        'LoadingIndicator at the same time.',
      );
    }
    _handle = handle;
    _progress = handle.progress;
    _applyIntent();
  }

  void _detach(_IndicatorPlaybackHandle handle) {
    if (!identical(_handle, handle)) {
      return;
    }
    _handle = null;
    _progress = null;
    _setStatus(LoadingIndicatorPlaybackStatus.detached);
  }

  void _updateProgress(double value) {
    if (_disposed || _progress == value) {
      return;
    }
    _progress = value;
    notifyListeners();
  }

  void _setStatus(LoadingIndicatorPlaybackStatus value) {
    if (_disposed || _status == value) {
      return;
    }
    _status = value;
    notifyListeners();
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('LoadingIndicatorController has been disposed.');
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _commandGeneration++;
    final completer = _intent.completer;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(
        const LoadingIndicatorCommandCanceled(
          'The loading indicator controller was disposed.',
        ),
      );
    }
    final handle = _handle;
    _handle = null;
    handle?.controllerWasDisposed(this);
    _progress = null;
    _disposed = true;
    super.dispose();
  }
}

/// Provides the public controller to the private indicator implementation.
class IndicatorControlScope extends InheritedWidget {
  const IndicatorControlScope({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final LoadingIndicatorController? controller;

  static IndicatorControlScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<IndicatorControlScope>();
  }

  @override
  bool updateShouldNotify(IndicatorControlScope oldWidget) {
    return !identical(controller, oldWidget.controller);
  }
}

abstract class _IndicatorPlaybackHandle {
  double get progress;

  void pauseNow();

  void pauseAt(
    double target,
    LoadingIndicatorPauseBehavior behavior,
    VoidCallback onCompleted,
  );

  void resume();

  void controllerWasDisposed(LoadingIndicatorController controller);
}

class _TrackSnapshot {
  const _TrackSnapshot(this.value, this.direction);

  final double value;
  final AnimationStatus direction;
}

class _TrackPosition {
  const _TrackPosition(this.value, this.direction);

  final double value;
  final AnimationStatus direction;
}

/// Shared lifecycle and group-playback behavior for every indicator.
mixin IndicatorController<T extends StatefulWidget> on State<T>
    implements _IndicatorPlaybackHandle {
  static const double _precision = 0.000001;

  List<AnimationController> get animationControllers;

  int get referenceAnimationControllerIndex => 0;

  bool repeatsInReverse(AnimationController controller) => false;

  LoadingIndicatorController? _externalController;
  final Map<AnimationController, AnimationStatus> _savedDirections = {};
  List<_TrackSnapshot>? _waitSnapshot;
  double? _waitTarget;
  VoidCallback? _waitCompleted;
  Duration? _waitTimestamp;
  int _playbackGeneration = 0;
  bool _shouldPlay = true;
  bool _applyingSnapshot = false;

  AnimationController get _referenceController =>
      animationControllers[referenceAnimationControllerIndex];

  @override
  double get progress => _referenceController.value;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncExternalController(IndicatorControlScope.of(context)?.controller);
  }

  @override
  void activate() {
    super.activate();
    final scope =
        context.getInheritedWidgetOfExactType<IndicatorControlScope>();
    _syncExternalController(scope?.controller);
  }

  @override
  void deactivate() {
    _cancelWait();
    _removeReferenceListener();
    final controller = _externalController;
    _externalController = null;
    controller?._detach(this);
    super.deactivate();
  }

  void _syncExternalController(LoadingIndicatorController? controller) {
    if (identical(_externalController, controller)) {
      return;
    }
    _cancelWait();
    _removeReferenceListener();
    _externalController?._detach(this);
    _externalController = controller;
    if (controller == null) {
      _resumeAll();
      return;
    }

    _referenceController.addListener(_onReferenceTick);
    try {
      controller._attach(this);
    } catch (_) {
      _referenceController.removeListener(_onReferenceTick);
      _externalController = null;
      _shouldPlay = false;
      _playbackGeneration++;
      _stopAll(_snapshotTracks());
      rethrow;
    }
  }

  void _removeReferenceListener() {
    if (animationControllers.isNotEmpty) {
      _referenceController.removeListener(_onReferenceTick);
    }
  }

  void _onReferenceTick() {
    if (_applyingSnapshot) {
      return;
    }
    _externalController?._updateProgress(_referenceController.value);
    final target = _waitTarget;
    final previous = _waitSnapshot;
    if (target == null || previous == null) {
      return;
    }

    final previousReference = previous[referenceAnimationControllerIndex];
    // Flutter 2 exposes `instance` as nullable; it is non-null once a State is
    // receiving animation ticks.
    // ignore: unnecessary_non_null_assertion
    final now = SchedulerBinding.instance!.currentSystemFrameTimeStamp;
    final previousTimestamp = _waitTimestamp ?? now;
    final elapsed =
        now >= previousTimestamp ? now - previousTimestamp : Duration.zero;
    final timeToTarget = _timeToTarget(
      previousReference,
      target,
      repeatsInReverse(_referenceController),
      _referenceController.duration!,
    );
    if (elapsed >= timeToTarget) {
      final completed = _waitCompleted;
      _clearWaitState();
      _applyAdvancedSnapshot(previous, timeToTarget, target);
      completed?.call();
    } else {
      _waitSnapshot = _advancedSnapshot(previous, elapsed);
      _waitTimestamp = now;
    }
  }

  @override
  void pauseNow() {
    _cancelWait();
    _shouldPlay = false;
    _playbackGeneration++;
    final snapshot = _snapshotTracks();
    _stopAll(snapshot);
    _externalController?._updateProgress(_referenceController.value);
  }

  @override
  void pauseAt(
    double target,
    LoadingIndicatorPauseBehavior behavior,
    VoidCallback onCompleted,
  ) {
    _cancelWait();
    final snapshot = _snapshotTracks();
    final reference = snapshot[referenceAnimationControllerIndex];
    if ((reference.value - target).abs() <= _precision) {
      _shouldPlay = false;
      _stopAll(snapshot);
      _setReferenceValue(target);
      onCompleted();
      return;
    }

    if (behavior == LoadingIndicatorPauseBehavior.jumpToTarget) {
      final delta = _timeToTarget(
          reference,
          target,
          repeatsInReverse(_referenceController),
          _referenceController.duration!);
      _applyAdvancedSnapshot(snapshot, delta, target);
      onCompleted();
      return;
    }

    _waitTarget = target;
    _waitCompleted = onCompleted;
    _waitSnapshot = snapshot;
    if (!_shouldPlay ||
        animationControllers.any((element) => !element.isAnimating)) {
      _resumeAll();
    }
    // ignore: unnecessary_non_null_assertion
    _waitTimestamp = SchedulerBinding.instance!.currentSystemFrameTimeStamp;
  }

  @override
  void resume() {
    _cancelWait();
    _resumeAll();
  }

  void _resumeAll() {
    _shouldPlay = true;
    final generation = ++_playbackGeneration;
    for (final controller in animationControllers) {
      final reverse = repeatsInReverse(controller);
      final direction = _savedDirections[controller] ??
          (controller.status == AnimationStatus.reverse
              ? AnimationStatus.reverse
              : AnimationStatus.forward);
      if (reverse &&
          direction == AnimationStatus.reverse &&
          controller.value > controller.lowerBound + _precision &&
          controller.value < controller.upperBound - _precision) {
        controller.reverse().orCancel.then((_) {
          if (mounted && _shouldPlay && generation == _playbackGeneration) {
            controller.repeat(reverse: true);
          }
        }).catchError((Object error) {
          if (error is! TickerCanceled) {
            FlutterError.reportError(FlutterErrorDetails(exception: error));
          }
        });
      } else {
        controller.repeat(reverse: reverse);
      }
    }
  }

  List<_TrackSnapshot> _snapshotTracks() {
    return animationControllers.map((controller) {
      final direction = controller.status == AnimationStatus.reverse
          ? AnimationStatus.reverse
          : controller.status == AnimationStatus.forward
              ? AnimationStatus.forward
              : _savedDirections[controller] ?? AnimationStatus.forward;
      return _TrackSnapshot(controller.value, direction);
    }).toList(growable: false);
  }

  void _stopAll(List<_TrackSnapshot> snapshot) {
    for (var i = 0; i < animationControllers.length; i++) {
      final controller = animationControllers[i];
      _savedDirections[controller] = snapshot[i].direction;
      controller.stop(canceled: false);
    }
  }

  Duration _timeToTarget(
    _TrackSnapshot reference,
    double target,
    bool reverse,
    Duration duration,
  ) {
    double distance;
    if (!reverse) {
      distance = target >= reference.value
          ? target - reference.value
          : 1.0 - reference.value + target;
    } else if (reference.direction == AnimationStatus.reverse) {
      distance = target <= reference.value
          ? reference.value - target
          : reference.value + target;
    } else {
      distance = target >= reference.value
          ? target - reference.value
          : 1.0 - reference.value + 1.0 - target;
    }
    return Duration(
      microseconds: (duration.inMicroseconds * distance).round(),
    );
  }

  void _applyAdvancedSnapshot(
    List<_TrackSnapshot> snapshot,
    Duration delta,
    double target,
  ) {
    _shouldPlay = false;
    _playbackGeneration++;
    _applyingSnapshot = true;
    _stopAll(snapshot);
    final advanced = _advancedSnapshot(
      snapshot,
      delta,
      useUpperBoundForExactWraps: (target - 1.0).abs() <= _precision,
    );
    for (var i = 0; i < animationControllers.length; i++) {
      final controller = animationControllers[i];
      final position = advanced[i];
      _savedDirections[controller] = position.direction;
      controller.value = position.value;
    }
    _setReferenceValue(target);
    _applyingSnapshot = false;
    _externalController?._updateProgress(target);
  }

  List<_TrackSnapshot> _advancedSnapshot(
    List<_TrackSnapshot> snapshot,
    Duration delta, {
    bool useUpperBoundForExactWraps = false,
  }) {
    return List<_TrackSnapshot>.generate(animationControllers.length, (index) {
      final controller = animationControllers[index];
      final position = _advanceTrack(
        snapshot[index],
        delta,
        controller.duration!,
        repeatsInReverse(controller),
        useUpperBoundForExactWraps,
      );
      return _TrackSnapshot(position.value, position.direction);
    }, growable: false);
  }

  _TrackPosition _advanceTrack(
    _TrackSnapshot snapshot,
    Duration delta,
    Duration duration,
    bool reverse,
    bool useUpperBoundForExactWraps,
  ) {
    final elapsed = delta.inMicroseconds / duration.inMicroseconds;
    if (!reverse) {
      final total = snapshot.value + elapsed;
      var value = total % 1.0;
      if (useUpperBoundForExactWraps &&
          total > 0.0 &&
          value.abs() <= _precision) {
        value = 1.0;
      }
      return _TrackPosition(value, AnimationStatus.forward);
    }

    var phase = snapshot.direction == AnimationStatus.reverse
        ? 2.0 - snapshot.value
        : snapshot.value;
    phase = (phase + elapsed) % 2.0;
    if (phase < 1.0) {
      return _TrackPosition(phase, AnimationStatus.forward);
    }
    return _TrackPosition(2.0 - phase, AnimationStatus.reverse);
  }

  void _setReferenceValue(double target) {
    _applyingSnapshot = true;
    _referenceController.value = target;
    _applyingSnapshot = false;
  }

  void _cancelWait() {
    _clearWaitState();
  }

  void _clearWaitState() {
    _waitTarget = null;
    _waitCompleted = null;
    _waitSnapshot = null;
    _waitTimestamp = null;
  }

  @override
  void controllerWasDisposed(LoadingIndicatorController controller) {
    if (!identical(_externalController, controller)) {
      return;
    }
    _cancelWait();
    _removeReferenceListener();
    _externalController = null;
    _resumeAll();
  }

  @override
  void dispose() {
    _cancelWait();
    _removeReferenceListener();
    final controller = _externalController;
    _externalController = null;
    controller?._detach(this);
    _shouldPlay = false;
    _playbackGeneration++;
    for (final element in animationControllers) {
      element.dispose();
    }
    super.dispose();
  }
}
