// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() => runApp(MaterialApp(
      home: AnimationControllerDemo(),
    ));

class AnimationControllerDemo extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: Duration(seconds: 1));

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
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
      },
    );
  }
}
