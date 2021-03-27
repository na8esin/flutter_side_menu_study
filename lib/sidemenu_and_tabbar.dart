import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'flutter_sidebar_hooks/rotating_translation_arrow.dart';

/// 目標 : firebaseのコンソールみたいな
/// ExpansionTileの足りない要素
/// 　開いただけで（子要素を選択しなくても）選択状態になる
/// 足りない要素
///   選択されてるメニューのアイコンを反転させる
/// 　　icon, selectedIcon
/// 　左メニュの選択状態って同期する？
///
/// 足りない要素を補うためには？
///   パッケージを探す
///     https://pub.dev/packages/flutter_sidebar
///     https://github.com/tusharsadhwani/scaffold_responsive
///       完全に消えるのはいまいち。アイコンだけの状態が欲しい
///     https://pub.dev/packages/responsive_scaffold

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
    final selectIndex = useState(0);
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
                // ExpansionTileはontapもselectedもない
                // プルダウンを開くと問答無用で選択状態になるから
                // 他のtileとの整合性を保つにはカスタマイズしかない
                ExpansionTile(
                  collapsedBackgroundColor: Colors.red,
                  backgroundColor: Colors.blue,
                  onExpansionChanged: (value) {
                    // 開くとtrue閉まるとfalse
                  },
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
                ListTile(
                  onTap: () {
                    selectIndex.value = 1;
                  },
                  // そもそもListTileの時点で、titleとtrailingの間の余白が大きい
                  title: controller.isCompleted
                      ? Text('sample title2')
                      : Icon(Icons.person),
                  // 閉じたときの右側にある微妙な空白を調整するため
                  trailing: controller.isCompleted
                      ? Icon(Icons.arrow_back)
                      : SizedBox.shrink(),
                  selected: selectIndex.value == 1,
                ),
                ListTile(
                  onTap: () {
                    selectIndex.value = 2;
                  },
                  selected: selectIndex.value == 2,
                  title: controller.isCompleted
                      ? Row(
                          // これだと余白が少なくできるけど、少しは開けたいから、
                          // ExpansionTileを使って1単語で済ませる方がいい
                          children: [
                            Text('sample title3'),
                            Icon(Icons.arrow_back)
                          ],
                        )
                      : Icon(Icons.android),
                ),
                // 子要素が無い場合もExpansionTileで統一できる？
                //   -> できない。選択するときに線が入っちゃうから
                ExpansionTile(
                  trailing: SizedBox.shrink(),
                  expandedAlignment: Alignment.centerRight,
                  // 折り返しを防ぐためにも単語１つで済ます
                  title: controller.isCompleted
                      ? Text(
                          'sample title4',
                          overflow: TextOverflow.ellipsis,
                        )
                      : Icon(Icons.subtitles),
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

const List<Tab> tabs = <Tab>[
  Tab(text: 'Zeroth'),
  Tab(text: 'First'),
  Tab(text: 'Second'),
];

class MyTabBarWidget extends StatelessWidget {
  const MyTabBarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      // The Builder widget is used to have a different BuildContext to access
      // closest DefaultTabController.
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            // Your code goes here.
            // To get index of current tab use tabController.index
          }
        });
        return Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: tabs,
            ),
          ),
          body: TabBarView(
            children: tabs.map((Tab tab) {
              return Center(
                child: Text(
                  tab.text! + ' Tab',
                  style: Theme.of(context).textTheme.headline5,
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}
