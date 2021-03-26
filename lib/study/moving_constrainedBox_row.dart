import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../rotating_translation_arrow.dart';
import '../flutter_sidebar_hooks/study_custom_expansion_tile.dart';

void main() {
  runApp(ProviderScope(
      child:
          MaterialApp(debugShowCheckedModeBanner: false, home: MyScaffold())));
}

class MyScaffold extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    const _iconSizeWithPadding = 48.0;
    final controller = useAnimationController(
        duration: const Duration(milliseconds: 250), initialValue: 1.0);
    final x = controller.value;
    useListenable(controller);
    return Row(
      children: [
        // NavigationRailでもConstrainedBoxが使われてる
        ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: _iconSizeWithPadding,
              // 初期が_iconSizeWithPaddingで最後は160になる
              // ここの計算式もちゃんと出さないとなぁ
              maxWidth: (x + 1) * _iconSizeWithPadding + x * 64),
          child: Align(
            alignment: Alignment.topCenter,
            child: ListView(
              children: [
                RotatingTranslationArrow(
                  controller: controller,
                ),
                SizedBox(
                  height: 20,
                ),
                // Rowが原因でoverflowしているわけではない
                controller.isCompleted
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.android), Text('アンドロイド')],
                      )
                    : Icon(Icons.android),
                // 初期表示でoverflowする
                CustomExpansionTile(
                  title: controller.isCompleted
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.hail), Text('hailなicon')],
                        )
                      : Icon(Icons.hail),
                  trailing: SizedBox.shrink(), // を加えるとoverflowしない
                ),
                // 対照実験。こいつもoverflowする
                ExpansionTile(
                  title: controller.isCompleted
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.hail), Text('hailなicon')],
                        )
                      : Icon(Icons.hail),
                  trailing: SizedBox.shrink(),
                ),
                // じゃあtrailingじゃなくて、titleにくっつける
                ExpansionTile(
                  title: controller.isCompleted
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hail),
                            Text('hailなicon'),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 4.0,
                            )
                          ],
                        )
                      : Icon(Icons.hail),
                  trailing: SizedBox.shrink(),
                ),
                // 対照実験。こいつは大丈夫
                ListTile(
                  title: controller.isCompleted
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.hail), Text('hailなicon')],
                        )
                      : Icon(Icons.hail),
                )
              ],
            ),
          ),
        ),
        VerticalDivider(thickness: 1, width: 1),
        Expanded(
          child: Center(
            child: MyTabBarWidget(),
          ),
        )
      ],
    );
  }
}

class MyTabBarWidget extends StatelessWidget {
  const MyTabBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
