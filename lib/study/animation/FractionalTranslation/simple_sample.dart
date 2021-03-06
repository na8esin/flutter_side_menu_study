import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 矢印が右に移動するだけ
/// 参考にしたURL
/// https://stackoverflow.com/questions/65472240/what-is-fractionaltranslation-in-flutter
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
      duration: const Duration(milliseconds: 5000),
    );
    useListenable(controller);
    controller.forward();
    return Container(
      alignment: Alignment.centerLeft,
      child: FractionalTranslation(
          translation: Offset(controller.value, 0),
          child: Icon(
            Icons.arrow_right,
            size: 32,
          )),
    );
  }
}
