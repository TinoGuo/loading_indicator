// This example shows a [Scaffold] with an [AppBar], a [BottomAppBar] and a
// [FloatingActionButton]. The [body] is a [Text] placed in a [Center] in order
// to center the text within the [Scaffold] and the [FloatingActionButton] is
// centered and docked within the [BottomAppBar] using
// [FloatingActionButtonLocation.centerDocked]. The [FloatingActionButton] is
// connected to a callback that increments a counter.

import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoadingIndicator example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
        primaryColor: Colors.white,
      ),
      home: MainWidget(),
    );
  }
}

class MainWidget extends StatelessWidget {
  _showSingleAnimationDialog(BuildContext context, Indicator indicator) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: false,
        builder: (ctx) {
          return Scaffold(
            appBar: AppBar(
              title: Text(indicator.toString().split('.').last),
              backgroundColor: Colors.pink,
            ),
            backgroundColor: Colors.teal,
            body: Padding(
              padding: const EdgeInsets.all(64),
              child: LoadingIndicator(
                indicatorType: indicator,
                color: Colors.white,
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
          backgroundColor: Colors.pink,
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
              onTap: () {
                _showSingleAnimationDialog(ctx, Indicator.values[index]);
              },
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
      backgroundColor: Colors.pink,
      body: GridView.builder(
        itemCount: Indicator.values.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
        ),
        itemBuilder: (ctx, index) => Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16),
              child: LoadingIndicator(
                color: Colors.white,
                indicatorType: Indicator.values[index],
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
