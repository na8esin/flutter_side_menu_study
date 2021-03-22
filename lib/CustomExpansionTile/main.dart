import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'my_custom_expansion_tile.dart';

void main() {
  runApp(ProviderScope(
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: MyHomePage(),
          ))));
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return MyCustomExpansionTile(
      title: Text('title'),
      children: [
        Text('child1'),
        Text('child2'),
      ],
    );
  }
}
