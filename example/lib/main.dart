import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

const List<Color> _kDefaultRainbowColors = const [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoadingIndicator example',
      debugShowCheckedModeBanner: false,
      home: MainWidget(),
    );
  }
}

class MainWidget extends StatelessWidget {
  _showSingleAnimationDialog(
      BuildContext context, Indicator indicator, bool showPathBackground) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: false,
        builder: (ctx) {
          return SingleAnimationWidget(
            indicator: indicator,
            showPathBackground: showPathBackground,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Demo'),
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.grid_on),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GridWidget(),
                ),
              );
            }),
        body: ListView.builder(
          itemBuilder: (ctx, index) {
            return InkWell(
              onTap: () => _showSingleAnimationDialog(
                ctx,
                Indicator.values[index],
                false,
              ),
              onLongPress: () => _showSingleAnimationDialog(
                ctx,
                Indicator.values[index],
                true,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                child: Text(
                  Indicator.values[index].toString().split('.').last,
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            );
          },
          itemCount: Indicator.values.length,
        ),
      );
}

class SingleAnimationWidget extends StatefulWidget {
  const SingleAnimationWidget({
    required this.indicator,
    required this.showPathBackground,
  });

  final Indicator indicator;
  final bool showPathBackground;

  @override
  State<SingleAnimationWidget> createState() => _SingleAnimationWidgetState();
}

class _SingleAnimationWidgetState extends State<SingleAnimationWidget> {
  late final LoadingIndicatorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoadingIndicatorController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pauseAt(LoadingIndicatorPauseBehavior behavior) async {
    try {
      await _controller.pauseAt(0.5, behavior: behavior);
    } on LoadingIndicatorCommandCanceled {
      // A newer toolbar command replaced this request.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.indicator.toString().split('.').last),
        actions: [
          IconButton(
            tooltip: 'Pause now',
            onPressed: _controller.pause,
            icon: const Icon(Icons.pause),
          ),
          IconButton(
            tooltip: 'Wait until 50%',
            onPressed: () =>
                _pauseAt(LoadingIndicatorPauseBehavior.waitUntilTarget),
            icon: const Icon(Icons.hourglass_bottom),
          ),
          IconButton(
            tooltip: 'Jump to 50%',
            onPressed: () =>
                _pauseAt(LoadingIndicatorPauseBehavior.jumpToTarget),
            icon: const Icon(Icons.skip_next),
          ),
          IconButton(
            tooltip: 'Resume',
            onPressed: _controller.resume,
            icon: const Icon(Icons.play_arrow),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(64),
              child: Center(
                child: LoadingIndicator(
                  indicatorType: widget.indicator,
                  colors: _kDefaultRainbowColors,
                  strokeWidth: 4.0,
                  pathBackgroundColor:
                      widget.showPathBackground ? Colors.black45 : null,
                  controller: _controller,
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final status = _controller.status.toString().split('.').last;
              final progress = _controller.progress?.toStringAsFixed(3) ?? '-';
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text('$status  •  $progress'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class GridWidget extends StatefulWidget {
  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  bool _isPaused = true;
  late final List<LoadingIndicatorController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      Indicator.values.length,
      (_) => LoadingIndicatorController()..pause(),
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Grid Demo'),
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isPaused = !_isPaused;
                      for (final controller in _controllers) {
                        if (_isPaused) {
                          controller.pause();
                        } else {
                          controller.resume();
                        }
                      }
                    });
                  },
                  icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause))
            ],
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              (ctx, index) => Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: LoadingIndicator(
                      colors: _kDefaultRainbowColors,
                      indicatorType: Indicator.values[index],
                      strokeWidth: 3,
                      controller: _controllers[index],
                      // pathBackgroundColor: Colors.black45,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
              childCount: Indicator.values.length,
            ),
          ),
        ],
      ),
    );
  }
}
