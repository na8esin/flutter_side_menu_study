import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 矢印が移動しながら、左側の領域のサイズが変わる
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
    const _iconSize = 32.0;
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    useListenable(controller);
    return Row(
      children: [
        ConstrainedBox(
          // 160.0に合わせる
          constraints:
              BoxConstraints(minWidth: (controller.value * 4 + 1) * _iconSize),
          child: Align(
            alignment: Alignment.topLeft,
            child: FractionalTranslation(
              translation: Offset(controller.value * 4, 0),
              child: InkWell(
                onTap: () {
                  if (controller.isDismissed) {
                    controller.forward();
                  } else if (controller.isCompleted) {
                    controller.reverse();
                  }
                },
                child: Transform.rotate(
                  angle: controller.value * math.pi,
                  child: const Icon(
                    Icons.arrow_right,
                    size: _iconSize,
                  ),
                ),
              ),
            ),
          ),
        ),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Center(
            child: MyRightWidget(),
          ),
        )
      ],
    );
  }
}

class MyRightWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
