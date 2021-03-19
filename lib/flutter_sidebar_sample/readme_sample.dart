import 'package:flutter_sidebar/flutter_sidebar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter Sidebar')),
      drawer: Sidebar.fromJson(
        tabs: [
          {
            'title': 'Chapter A',
            'children': [
              {'title': 'Chapter A1'},
              {'title': 'Chapter A2'},
            ],
          },
          {
            'title': 'Chapter B',
            'children': [
              {'title': 'Chapter B1'},
              {
                'title': 'Chapter B2',
                'children': [
                  {'title': 'Chapter B2a'},
                  {'title': 'Chapter B2b'},
                ],
              },
            ],
          },
          {'title': 'Chapter C'},
        ],
      ),
      onDrawerChanged: (isOpened) {
        print('isOpened = ${isOpened}');
      },
      onEndDrawerChanged: (isOpened) {},
    );
  }
}
