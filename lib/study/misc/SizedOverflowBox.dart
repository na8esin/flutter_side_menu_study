import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// SizedOverflowBoxの効果を研究する
void main() {
  runApp(ProviderScope(
      child: MaterialApp(
    home: MyHomePage(),
  )));
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
        duration: Duration(milliseconds: 500), initialValue: 0.0);
    useListenable(controller);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (controller.isDismissed) {
            controller.forward();
          } else if (controller.isCompleted) {
            controller.reverse();
          }
        },
      ),
      // ConstrainedBoxと違って、領域外に移動しても例外が発生しないだけ？
      body: SizedOverflowBox(
        size: Size(300 * controller.value, double.infinity),
        child: Text('hello'),
      ),
    );
  }
}
