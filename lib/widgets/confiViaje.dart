import 'package:flutter/material.dart';

class ConfViajeWidget extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  ConfViajeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _scrollController,
        children: [
          Container(
            height: 200,
            color: Colors.red,
          ),
          Container(
            height: 200,
            color: Colors.blue,
          ),
          Container(
            height: 200,
            color: Colors.green,
          ),
          Container(
            height: 200,
            color: Colors.yellow,
          ),
          Container(
            height: 200,
            color: Colors.orange,
          ),
          Container(
            height: 200,
            color: Colors.purple,
          ),
          Container(
            height: 200,
            color: Colors.brown,
          ),
          Container(
            height: 200,
            color: Colors.pink,
          ),
          Container(
            height: 200,
            color: Colors.teal,
          ),
          Container(
            height: 200,
            color: Colors.indigo,
          ),
          Container(
            height: 200,
            color: Colors.lime,
          ),
          Container(
            height: 200,
            color: Colors.cyan,
          ),
          Container(
            height: 200,
            color: Colors.amber,
          ),
          Container(
            height: 200,
            color: Colors.deepOrange,
          ),
          Container(
            height: 200,
            color: Colors.lightBlue,
          ),
          Container(
            height: 200,
            color: Colors.lightGreen,
          ),
          Container(
            height: 200,
            color: Colors.deepPurple,
          ),
          Container(
            height: 200,
            color: Colors.grey,
          ),
          Container(
            height: 200,
            color: Colors.blueGrey,
          ),
        ],
      ),
    );
  }
}
