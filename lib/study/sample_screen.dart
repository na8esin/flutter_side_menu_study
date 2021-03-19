import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// https://qiita.com/zwtin/items/5f5557a9dd8746038c87

void main() {
  runApp(ProviderScope(
      child: MaterialApp(
          home: Scaffold(
    body: SampleScreen(),
  ))));
}

class SampleScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    final tweenAnimation =
        Tween(begin: 0.0, end: 1.0).animate(animationController);

    return Scaffold(
      appBar: AppBar(
        title: Text('Sample'),
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget? child) {
              return Positioned(
                left: tweenAnimation.value * 275.0,
                top: tweenAnimation.value * 400.0,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.yellow,
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          if (animationController.isCompleted) {
            animationController.reverse();
          } else {
            animationController.forward();
          }
        },
      ),
    );
  }
}
