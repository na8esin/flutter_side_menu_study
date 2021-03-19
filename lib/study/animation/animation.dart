import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// https://github.com/flutter/gallery/blob/master/lib/studies/reply/adaptive_nav.dart
// からの抜粋
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
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    useListenable(controller);
    final Animation<double> animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    return InkWell(
      onTap: () {
        if (controller.isDismissed) {
          controller.forward();
        } else if (controller.isCompleted) {
          controller.reverse();
        }
      },
      child: SizedBox(
        height: 56,
        child: Transform.rotate(
          angle: animation.value * math.pi,
          child: const Icon(
            Icons.arrow_left,
            size: 32,
          ),
        ),
      ),
    );
  }
}
