// This example shows a [Scaffold] with an [AppBar], a [BottomAppBar] and a
// [FloatingActionButton]. The [body] is a [Text] placed in a [Center] in order
// to center the text within the [Scaffold] and the [FloatingActionButton] is
// centered and docked within the [BottomAppBar] using
// [FloatingActionButtonLocation.centerDocked]. The [FloatingActionButton] is
// connected to a callback that increments a counter.

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
          return Scaffold(
            appBar: AppBar(
              title: Text(indicator.toString().split('.').last),
            ),
            body: Padding(
              padding: const EdgeInsets.all(64),
              child: Center(
                child: LoadingIndicator(
                  indicatorType: indicator,
                  colors: _kDefaultRainbowColors,
                  strokeWidth: 4.0,
                  pathBackgroundColor:
                      showPathBackground ? Colors.black45 : null,
                ),
              ),
            ),
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

class GridWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Grid Demo'),
            floating: true,
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
