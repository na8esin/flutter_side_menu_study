import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// https://www.youtube.com/watch?v=N-RiyZlv8v8&t=40s
/// AnimatedBuilderのchildってなに？
void main() {
  runApp(ProviderScope(
      child: MaterialApp(
          home: Scaffold(
    body: MyHomePage(),
  ))));
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller =
        useAnimationController(duration: Duration(milliseconds: 500));
    final animation = Tween(begin: 0.0, end: 2 * pi).animate(controller);

    return AnimatedBuilder(
      animation: animation,
      child: FlutterLogo(),
      // 引数のchildは上で指定したchildです。
      builder: (context, child) {
        return Column(
          children: [
            Transform.rotate(
              angle: animation.value,
              child: child,
            ),
            ElevatedButton(
                onPressed: () {
                  if (controller.isDismissed) {
                    controller.forward();
                  } else if (controller.isCompleted) {
                    controller.reverse();
                  }
                },
                child: Icon(Icons.arrow_right))
          ],
        );
      },
    );
  }
}
