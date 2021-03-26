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

/// flutter_sidebar_hooksにrotating_translation_arrowを
/// 組み込んでる最中に何かがoverflowするので実験
/// Row, CustomExpansionTile, ExpansionTile
/// の対照実験。
/// ConstrainedBoxの横幅をちゃんと計算して、
/// ちょっと広くなると解消されたからひとまず解決
///
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
              // ちゃんと計算するとoverflowしなくなったのでとりあえずいいや
              maxWidth: (2.5 * x + 1) * _iconSizeWithPadding),
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
                  expandedAlignment: Alignment.centerRight,
                  title: controller.isCompleted
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Icon(Icons.hail), Text('hailなicon')],
                        )
                      : Icon(Icons.hail),
                  children: [
                    ListTile(
                      title: Align(
                          alignment: Alignment.centerRight,
                          child: Text('hello')),
                    )
                  ],
                  //trailing: SizedBox.shrink(),
                ),
                // 対照実験。こいつもoverflowする
                ExpansionTile(
                  expandedAlignment: Alignment.centerRight,
                  title: controller.isCompleted
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.hail), Text('hailなicon')],
                        )
                      : Icon(Icons.hail),
                  trailing: SizedBox.shrink(),
                  children: [
                    ListTile(
                      title: Text('hello'),
                    )
                  ],
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
