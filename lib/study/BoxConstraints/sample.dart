import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(ProviderScope(
      child: MaterialApp(
          home: Scaffold(
    body: MyHomePage(),
  ))));
}

// BoxConstraints forces an infinite width.
class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(),
          child: ListTile(),
        ),
      ],
    );
  }
}
