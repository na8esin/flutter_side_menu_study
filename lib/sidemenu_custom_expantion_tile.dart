import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'flutter_sidebar_hooks/rotating_translation_arrow.dart';
import 'flutter_sidebar_hooks/custom_expansion_tile.dart';

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
                CustomExpansionTile(
                  trailing: controller.isCompleted ? null : SizedBox.shrink(),
                  expandedAlignment: Alignment.centerRight,
                  title: controller.isCompleted
                      ? Text(
                          'sample title1',
                          // はみ出したテキストは代替記号
                          overflow: TextOverflow.ellipsis,
                        )
                      : Icon(Icons.subtitles),
                  children: [
                    // childrenPaddingを使っても子要素同士の空白がうまくあかない
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: controller.isCompleted
                          ? Text('Text1')
                          : Icon(Icons.edit),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: controller.isCompleted
                          ? Text('Text2')
                          : Icon(Icons.list),
                    ),
                  ],
                ),
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
