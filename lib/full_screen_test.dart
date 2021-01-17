import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:home_indicator/home_indicator.dart';

void main() => runApp(MyAppTest());

class MyAppTest extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyAppTest> {
  bool _isHidden = false;

  Future<void> _fetchIsHidden() async {
    final isHidden = await HomeIndicator.isHidden();
    setState(() {
      _isHidden = isHidden;
    });
  }

  Future<void> _hideHomeIndicator() async {
    await HomeIndicator.hide();
    _fetchIsHidden();
  }

  Future<void> _showHomeIndicator() async {
    await HomeIndicator.show();
    _fetchIsHidden();
  }

  Future<void> _deferAllScreenEdges() async {
    await HomeIndicator.deferScreenEdges(ScreenEdge.values);
    _fetchIsHidden();
  }

  Future<void> _deferNoScreenEdges() async {
    await HomeIndicator.deferScreenEdges([]);
    _fetchIsHidden();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HomeIndicator example app'),
        ),
        body: Container(
          color:Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(onPressed: _hideHomeIndicator, child: Text('Hide')),
                RaisedButton(onPressed: _showHomeIndicator, child: Text('Show')),
                RaisedButton(onPressed: _deferAllScreenEdges, child: Text('Defer all edges')),
                RaisedButton(onPressed: _deferNoScreenEdges, child: Text('Defer no edges')),
                Text("(The indicator might take a second to disappear.)"),
                Text("HomeIndicator.isHidden() == $_isHidden"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}