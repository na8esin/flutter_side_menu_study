import 'dart:math' as math;

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

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    final Animation<double> animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 56,
          child: Transform.rotate(
            angle: animation.value * math.pi,
            child: const Icon(
              Icons.arrow_left,
              size: 32,
            ),
          ),
        ),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
              onPressed: () {
                if (animationController.value < 1.0) {
                  animationController.forward();
                } else if (animationController.value > 0.0) {
                  animationController.reverse();
                }
              },
              icon: const Icon(
                Icons.menu,
                size: 32,
              ),
              label: Text('menu')),
        ),
      ],
    );
  }
}
