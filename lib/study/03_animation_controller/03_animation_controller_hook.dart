import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() => runApp(MaterialApp(
      home: AnimationControllerDemo(),
    ));

class AnimationControllerDemo extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: Duration(seconds: 1));
    // https://github.com/rrousselGit/flutter_hooks/issues/204
    useListenable(controller);

    return Scaffold(
      appBar: AppBar(
        title: Text('Animation Controller'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 200),
              child: Text(
                '${controller.value.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headline3,
                textScaleFactor: 1 + controller.value,
              ),
            ),
            ElevatedButton(
              child: Text('animate'),
              onPressed: () {
                if (controller.status == AnimationStatus.completed) {
                  controller.reverse();
                } else {
                  controller.forward();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
