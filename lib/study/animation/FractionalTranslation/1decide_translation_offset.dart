import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 横移動したい幅を決めたときにOffsetをいくつに設定すればいいかを調べる
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
    final _controller = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    final _animation = _controller.drive(
      // Offsetの指定が楽になる
      Tween<Offset>(
        begin: const Offset(0.0, 0.0),
        end: const Offset(2, 0.0),
      ),
    );
    useListenable(_controller);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      FractionalTranslation(
          translation: _animation.value,
          child: InkWell(
            // InkWellがあるとマウスを載せたときにサイズがわかる
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_right,
                size: 32,
              ),
            ),
          )),
      Container(
//        width: (32 + 16) * 2, // = 96
        width: (32 + 16) * 3, // = 144
        height: 32,
        color: Colors.blueGrey,
      ),
      ElevatedButton(
          onPressed: () {
            if (_controller.isDismissed) {
              _controller.forward();
            } else if (_controller.isCompleted) {
              _controller.reverse();
            }
          },
          child: Text('move'))
    ]);
  }
}
