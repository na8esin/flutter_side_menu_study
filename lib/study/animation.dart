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
        duration: kThemeAnimationDuration, initialValue: 1.0);
    final Animation<double> animation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Align(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: animation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 56,
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    InkWell(
                      key: const ValueKey('ReplyLogo'),
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: Row(
                        children: [
                          Transform.rotate(
                            angle: animation.value * math.pi,
                            child: const Icon(
                              Icons.arrow_left,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        animationController.value =
                            animationController.value == 1.0 ? 0.0 : 1.0;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
